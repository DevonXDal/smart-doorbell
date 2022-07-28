import 'dart:async';

import 'package:doorbell_pi_app/data/database/app_persistence_db.dart';
import 'package:doorbell_pi_app/repositories/app_persistence_repository.dart';
import 'package:doorbell_pi_app/widgets/pages/no_doorbells_registered_page.dart';
import 'package:get/get.dart';

class ServerNotConfiguredController extends GetxController {
  late AppPersistenceRepository _persistenceRepository;
  late Timer _asyncCheckTimer; // Used to make async call right after constructor

  ServerNotConfiguredController() {
    _persistenceRepository = Get.find();

    _asyncCheckTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _attemptInitialLogin();
    });
  }

  Future<void> _attemptInitialLogin() async {
    _asyncCheckTimer.cancel();
    WebServer? activeWebServer = await _persistenceRepository.getActiveWebServer();

    if (activeWebServer == null) return;

    Get.off(() => const NoDoorbellsRegisteredPage());
  }
}