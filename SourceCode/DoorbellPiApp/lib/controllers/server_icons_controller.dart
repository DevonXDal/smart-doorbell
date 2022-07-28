import 'dart:async';

import 'package:doorbell_pi_app/data/database/app_persistence_db.dart';
import 'package:doorbell_pi_app/enumerations/server_connection_state.dart';
import 'package:doorbell_pi_app/repositories/app_persistence_repository.dart';
import 'package:get/get.dart';

class ServerIconsController extends GetxController {
  late Rx<ServerConnectionState> connectionState;
  late Rx<WebServer?> activeServer;

  late AppPersistenceRepository _persistenceRepository;
  late Timer _checkConnectionTimer;

  ServerIconsController() {
    connectionState = Rx(ServerConnectionState.NotConnected);
    activeServer = Rx(null);
    _persistenceRepository = Get.find();

    _checkServerConnectionState();

    _checkConnectionTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkServerConnectionState();
    });
  }

  Future<void> _checkServerConnectionState() async {
    activeServer.value = await _persistenceRepository.getActiveWebServer();

    if (activeServer.value == null) {
      connectionState.value = ServerConnectionState.NotConnected;
    } else if (!activeServer.value!.lastConnectionSuccessful) {
      connectionState.value = ServerConnectionState.NotReachable;
    } else {
      connectionState.value = ServerConnectionState.Reachable;
    }
  }

  @override
  void dispose() {
    _checkConnectionTimer.cancel();
    super.dispose();
  }
}