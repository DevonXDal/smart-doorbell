import 'dart:async';

import 'package:doorbell_pi_app/data/database/app_persistence_db.dart';
import 'package:doorbell_pi_app/data/database/app_persistence_repository.dart';
import 'package:doorbell_pi_app/enumerations/server_connection_state.dart';
import 'package:get/get.dart';

class ServerInfoController extends GetxController {
  late Rx<ServerConnectionState> _connectionState;
  late Rx<WebServer?> _activeServer;

  late AppPersistenceRepository _persistenceRepository;
  late Timer _checkConnectionTimer;

  ServerInfoController() {
    _checkConnectionTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkServerConnectionState();
    });
  }

  Future<void> _checkServerConnectionState() async {

  }

  @override
  void dispose() {
    _checkConnectionTimer.cancel();
    super.dispose();
  }
}