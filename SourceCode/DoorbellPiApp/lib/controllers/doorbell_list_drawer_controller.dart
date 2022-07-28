import 'dart:async';

import 'package:doorbell_pi_app/widgets/pages/server_not_configured_page.dart';
import 'package:get/get.dart';

import '../data/database/app_persistence_db.dart';
import '../repositories/app_persistence_repository.dart';

class DoorbellListDrawerController extends GetxController {
  late Rx<List<Doorbell>> sortedConnectedDoorbells;
  late Rx<bool> isConnectedToWebServer;

  late AppPersistenceRepository _persistenceRepository;
  late Timer _updateTimer;

  DoorbellListDrawerController() {
    sortedConnectedDoorbells = Rx(List.empty());
    isConnectedToWebServer = Rx(false);

    _persistenceRepository = Get.find();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _ensureCorrectList();
    });

    _ensureCorrectList();
  }

  Future<void> disconnectFromWebServer() async {
    await _persistenceRepository.makeActiveWebServerInactive();
    isConnectedToWebServer.value = false;
    sortedConnectedDoorbells.value = List.empty();

    Get.offAll(() => const ServerNotConfiguredPage());
  }

  Future<void> _ensureCorrectList() async {
    List<Doorbell>? doorbellsForActiveServer = await _persistenceRepository.getDoorbellsForActiveServer();

    if (doorbellsForActiveServer == null) { // No active server, thus, no doorbells
      isConnectedToWebServer.value = false;
      sortedConnectedDoorbells.value = List.empty();

      return;
    }

    doorbellsForActiveServer.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    isConnectedToWebServer.value = true;
    sortedConnectedDoorbells.value = doorbellsForActiveServer;
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }
}