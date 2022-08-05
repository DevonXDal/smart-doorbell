import 'dart:async';

import 'package:doorbell_pi_app/controllers/doorbell_page_controllers/participant_widget.dart';
import 'package:doorbell_pi_app/controllers/listening_controller.dart';
import 'package:doorbell_pi_app/data/database/app_persistence_db.dart';
import 'package:doorbell_pi_app/enumerations/loading_state.dart';
import 'package:doorbell_pi_app/json/twilio_room_connection_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:twilio_programmable_video/twilio_programmable_video.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/observer.dart';
import '../../repositories/app_persistence_repository.dart';
import '../../repositories/main_server_repository.dart';

/// A substantial amount of this code is from: https://www.twilio.com/blog/create-chat-room-app-twilio-video-flutter-bloc
///
/// This DoorbellVideoChatController is the controller that handles the DoorbellVideoChatView widget.
/// This controller aids in functions around joining, leaving, and attending video chats/calls started through Twilio.
/// Whenever someone leaves or joins, including this device, this controller is responsible for notifying the app user of these changes.
///
/// Author: Devon X. Dalrymple
/// Version: 2022-08-24
class DoorbellVideoChatController extends ListeningController {
  static const noOneInCall = "No one is connected";

  late final String _doorbellDisplayName;
  late AppPersistenceRepository _persistenceRepository;
  late MainServerRepository _serverRepository;

  late RxString peopleInCall; // Used for displaying who is in a call, when this app is not.
  late RxBool isInCall; // Whether this device is connected to the call/chat
  late RxBool shouldShowWidget; // Whether this widget should show at all.
  late Rx<LoadingState> currentLoadingState;
  late Rx<List<ParticipantWidget>> participants;
  late RxBool audioInEnabled; // Whether the user's mic is on
  late RxBool audioOutEnabled; // Whether the user's speakers are outputting the doorbell user's voice

  late int _secondsSinceDoorbellPressed;
  late Timer? _countUpTimer;
  late String? _roomToken;
  late String? _roomName;
  late List<String> _displayNamesOfAppUsersInCall;
  late Room? _videoChatRoom;
  late List<StreamSubscription> _streamSubscriptions;


  DoorbellVideoChatController(this._doorbellDisplayName, Observer observerForDoorbell) : super(observerForDoorbell) {
    _persistenceRepository = Get.find();
    _serverRepository = Get.find();
    _secondsSinceDoorbellPressed = 61;
    _countUpTimer = null;
    _displayNamesOfAppUsersInCall = List.empty(growable: true);
    _streamSubscriptions = List.empty(growable: true);
    participants = Rx(List.empty(growable: true));

    peopleInCall = RxString("");
    isInCall = RxBool(false);
    currentLoadingState = Rx(LoadingState.Initial);
    shouldShowWidget = RxBool(false);

    _fetchAppDisplayName();
    _fetchNewInformationFromDatabase();

  }

  /// Updates the controller using new information recently added to the app's database
  @override
  void doListenerUpdate() {
    _fetchNewInformationFromDatabase();
  }

  /// Configures the connection related options for this device and puts the app in a video chat with the doorbell if a successful connection to the server and Twilio are made.
  /// The user will be notified, via the snackbar, if the connection fails.
  Future<void> joinVideoChat() async {
    currentLoadingState.value = LoadingState.Loading;

    TwilioRoomConnectionData? connectionData = await _serverRepository.tryFetchTwilioVideoCallDataForDoorbell(_doorbellDisplayName);
    if (connectionData == null) {
      Get.snackbar("Failed to Connect", "The server was unable to establish a call with the doorbell. Please wait a few seconds and try again.");
      currentLoadingState.value = LoadingState.Loaded;
      return;
    }

    _roomName = connectionData.roomName;
    _roomToken = connectionData.token;

    try {
      await TwilioProgrammableVideo.setAudioSettings(speakerphoneEnabled: true, bluetoothPreferred: true); // Uses phone's speakers, or a bluetooth audio output device
      String trackId = const Uuid().v4();

      ConnectOptions connectionOptions = ConnectOptions(
        _roomToken!,
        roomName: _roomName!,
        preferredAudioCodecs: [OpusCodec()],
        audioTracks: [LocalAudioTrack(true, 'audio_track-$trackId')],
        dataTracks: [LocalDataTrack(
            DataTrackOptions(name: 'data_track-$trackId')
        )],
        enableNetworkQuality: true,
        networkQualityConfiguration: NetworkQualityConfiguration(
          remote: NetworkQualityVerbosity.NETWORK_QUALITY_VERBOSITY_MINIMAL
        ),
        enableDominantSpeaker: true
      );

      _videoChatRoom = await TwilioProgrammableVideo.connect(connectionOptions);

      _streamSubscriptions.add(_videoChatRoom!.onConnected.listen(_onConnected));
      _streamSubscriptions.add(_videoChatRoom!.onDisconnected.listen(_onDisconnected));
      _streamSubscriptions.add(_videoChatRoom!.onReconnecting.listen(_onReconnecting));
      _streamSubscriptions.add(_videoChatRoom!.onConnectFailure.listen(_onConnectFailure));

      isInCall.value = true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// Disconnects this device from the video call.
  /// This will indirectly lead to the doorbell disconnecting if no more people are connected.
  Future<void> disconnectFromVideoCall() async {
    currentLoadingState.value = LoadingState.Loading;

    await _videoChatRoom!.disconnect();

    currentLoadingState.value = LoadingState.Loaded;
    isInCall.value = false;
  }

  /// By reloading, the loading state is changed twice in order to help refresh the video chat widget so that all people connected are handled properly.
  void reload() {
    currentLoadingState.value = LoadingState.Loading;
    currentLoadingState.value = LoadingState.Loaded;
  }

  ParticipantWidget _buildParticipant({
    required Widget child,
    required String? id,
  }) {
    return ParticipantWidget(
      id: id,
      child: child,
    );
  }

  void _onDisconnected(RoomDisconnectedEvent event) {
    Get.snackbar("No Longer in Chat", "Either you have left the call, the five minute time limit has occurred, or the connection was lost.");
    isInCall.value = false;
  }

  void _onReconnecting(RoomReconnectingEvent room) {
    Get.snackbar("Chat Connection Lost", "The connection to the chat has been lost. Trying to reconnect...");
  }

  void _onConnected(Room room) {
    // When connected for the first time, add remote participant listeners
    _streamSubscriptions
        .add(_videoChatRoom!.onParticipantConnected.listen(_onParticipantConnected));
    _streamSubscriptions.add(
        _videoChatRoom!.onParticipantDisconnected.listen(_onParticipantDisconnected));
    final localParticipant = room.localParticipant;
    if (localParticipant == null) {
      return;
    }

    // Only add ourselves when connected for the first time too.
    participants.value.add(_buildParticipant(
        child: localParticipant.localVideoTracks[0].localVideoTrack.widget(),
        id: const Uuid().v4()));

    for (final remoteParticipant in room.remoteParticipants) {
      var participant = participants.value.firstWhereOrNull(
              (participant) => participant.id == remoteParticipant.sid);
      if (participant == null) {
        _addRemoteParticipantListeners(remoteParticipant);
      }
    }
    reload();
  }

  void _onConnectFailure(RoomConnectFailureEvent event) {
    Get.snackbar("Failed to Connect", "Failed to connect to the video chat room.");
  }

  void _onParticipantConnected(RoomParticipantConnectedEvent event) {
    Get.snackbar("Person joined the call", "${event.remoteParticipant.sid} joined");
    _addRemoteParticipantListeners(event.remoteParticipant);
    reload();
  }

  void _onParticipantDisconnected(RoomParticipantDisconnectedEvent event) {
    Get.snackbar("Person left the call", "${event.remoteParticipant.sid} left");
    participants.value.removeWhere(
            (ParticipantWidget p) => p.id == event.remoteParticipant.sid);
    reload();
  }

  void _addRemoteParticipantListeners(RemoteParticipant remoteParticipant) {
    _streamSubscriptions.add(remoteParticipant.onVideoTrackSubscribed
        .listen(_addOrUpdateParticipant));
    _streamSubscriptions.add(remoteParticipant.onAudioTrackSubscribed
        .listen(_addOrUpdateParticipant));
  }

  void _addOrUpdateParticipant(RemoteParticipantEvent event) {
    final participant = participants.value.firstWhereOrNull(
          (ParticipantWidget participant) =>
      participant.id == event.remoteParticipant.sid,
    );

    if (participant == null) {
      if (event is RemoteVideoTrackSubscriptionEvent) {
        participants.value.insert(
          0,
          _buildParticipant(
            child: event.remoteVideoTrack.widget(),
            id: event.remoteParticipant.sid,
          ),
        );
        reload();
      }
    }
  }

    void _handleTimer(bool shouldCountUp) {
    if (shouldCountUp && _countUpTimer == null) {
      _countUpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _changeSecondCountOnWidget();
      });
    } else if (_countUpTimer != null) {
      _countUpTimer!.cancel();
      _countUpTimer = null;
    }
  }


  Future<void> _changeSecondCountOnWidget() async {
    if (++_secondsSinceDoorbellPressed > 60) {
      _handleTimer(false);

      if (peopleInCall.value == "") {
        shouldShowWidget.value = false;
      }
    }
  }

  Future<void> _fetchAppDisplayName() async {
    WebServer? currentWebServer = await _persistenceRepository.getActiveWebServer();

  }

  // Fetches the most recent information from the app's database. Updates any of the relevant fields
  Future<void> _fetchNewInformationFromDatabase() async {
    Doorbell selectedDoorbell = (await _persistenceRepository.getDoorbellByDisplayName(_doorbellDisplayName))!;
    _secondsSinceDoorbellPressed = ((DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) - selectedDoorbell.lastActivationTime.toInt());

    if (_secondsSinceDoorbellPressed <= 60) {
      _handleTimer(true);

      if (!isInCall.value) {
        _fetchConnectedAppUsers(selectedDoorbell);
      }
    }

    if (_secondsSinceDoorbellPressed > 60 && selectedDoorbell.doorbellStatus != 'In Call') {
      shouldShowWidget.value = false;
    }

  }

  Future<void> _fetchConnectedAppUsers(Doorbell selectedDoorbell) async {
    List<String>? possibleListOfAppUsersInCall = await _serverRepository.tryFetchAppUsersInVideoCall(_doorbellDisplayName);
    if (possibleListOfAppUsersInCall == null || possibleListOfAppUsersInCall.isEmpty) {
      peopleInCall.value = noOneInCall;
      return;
    }

    _displayNamesOfAppUsersInCall = possibleListOfAppUsersInCall;
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < _displayNamesOfAppUsersInCall.length && i < 2; i++) {
      if (i > 0) {
        buffer.write(', ');
      }
      
      buffer.write(_displayNamesOfAppUsersInCall[i]);
    }
    
    if (_displayNamesOfAppUsersInCall.length > 2) {
      buffer.write('and ${_displayNamesOfAppUsersInCall.length - 2} others');
    }
    
    peopleInCall.value = buffer.toString();
  }

  @override
  void dispose() {
    _countUpTimer?.cancel();
    _videoChatRoom?.disconnect();
    _videoChatRoom?.dispose();
    super.dispose();
  }
}