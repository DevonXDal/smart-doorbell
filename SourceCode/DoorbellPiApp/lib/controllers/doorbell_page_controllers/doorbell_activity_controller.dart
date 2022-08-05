import 'dart:async';
import 'dart:typed_data';

import 'package:doorbell_pi_app/helpers/observer.dart';
import 'package:doorbell_pi_app/repositories/main_server_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';


import '../../data/database/app_persistence_db.dart';
import '../../repositories/app_persistence_repository.dart';
import '../listening_controller.dart';

class DoorbellActivityController extends ListeningController {
  static const noActivityString = 'No activity in the past minute from the doorbell...';

  late final String _doorbellDisplayName;
  late AppPersistenceRepository _persistenceRepository;
  late MainServerRepository _serverRepository;

  late RxString viewMessage;
  late Rx<Uint8List?> imageContent;

  late int _secondsSinceDoorbellPressed;
  late Timer? _countUpTimer;

  DoorbellActivityController(this._doorbellDisplayName, Observer observerForDoorbell) : super(observerForDoorbell) {
    _persistenceRepository = Get.find();
    _serverRepository = Get.find();
    _secondsSinceDoorbellPressed = 61;
    _countUpTimer = null; // Deals with LateInitializationError from not being registered as null

    viewMessage = RxString(noActivityString);
    imageContent = Rx(null);
    _fetchNewInformationFromDatabaseAndServer();
  }

  @override
  void doListenerUpdate() {
    _fetchNewInformationFromDatabaseAndServer();
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
      viewMessage.value = noActivityString;
      _handleTimer(false);
    } else {
      viewMessage.value = _secondsSinceMessage();
    }
  }

  String _secondsSinceMessage() {
    return 'Activated Doorbell: $_secondsSinceDoorbellPressed seconds ago';
  }

  Future<void> _fetchNewInformationFromDatabaseAndServer() async {
    Doorbell selectedDoorbell = (await _persistenceRepository.getDoorbellByDisplayName(_doorbellDisplayName))!;

    if (kDebugMode) {
      print(DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000);
      print(DateTime.now().toUtc().millisecondsSinceEpoch / 1000);
      print(selectedDoorbell.lastActivationTime);
      print(selectedDoorbell.lastActivationTime.toInt());
      print((DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) - selectedDoorbell.lastActivationTime.toInt());

    }
    _secondsSinceDoorbellPressed = ((DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) - selectedDoorbell.lastActivationTime.toInt());

    if (_secondsSinceDoorbellPressed <= 60) {
      imageContent.value ??= await _serverRepository.tryFetchDoorbellActivityImage(_doorbellDisplayName);
      _handleTimer(true);
    }
  }

  @override
  void dispose() {
      _countUpTimer?.cancel();
      super.dispose();
  }

}