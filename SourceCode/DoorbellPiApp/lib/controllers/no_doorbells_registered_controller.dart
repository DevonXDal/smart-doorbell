import 'dart:async';

import 'package:doorbell_pi_app/repositories/app_persistence_repository.dart';
import 'package:doorbell_pi_app/repositories/main_server_repository.dart';
import 'package:doorbell_pi_app/widgets/pages/doorbell_page.dart';
import 'package:get/get.dart';

import '../data/database/app_persistence_db.dart';


/// This NoDoorbellsRegisteredController runs during the use of the No Doorbells Registered page to check
/// every so often if one or more doorbells have been connected to the server. If they have, then this controller
/// will redirect the user automatically to the first alphabetical doorbell.
///
/// Author: Devon X. Dalrymple
/// Version: 2022-07-14
class NoDoorbellsRegisteredController extends GetxController {
  late Timer _listUpdatingTimer;
  late MainServerRepository _serverRepository;
  late AppPersistenceRepository _persistenceRepository;

  NoDoorbellsRegisteredController() {
    _listUpdatingTimer = Timer.periodic(const Duration(minutes: 2), (_) => tryFetchingNewDoorbells());
    _serverRepository = Get.find();
    _persistenceRepository = Get.find();
    tryFetchingNewDoorbells();
  }

  // This checks to see if the server has new doorbells listed. If it does, then the
  tryFetchingNewDoorbells() async {

    if (await _serverRepository.tryUpdatingDoorbellList()) {
      List<Doorbell>? doorbellsForActiveServer = await _persistenceRepository.getDoorbellsForActiveServer();

      if (doorbellsForActiveServer == null) return;

      if (doorbellsForActiveServer.isEmpty) {
        Get.snackbar('Server Queried', 'The Web server responded that there are no doorbells yet.');
        return;
      }

      doorbellsForActiveServer.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      _listUpdatingTimer.cancel();
      Get.off(() => DoorbellPage(doorbellsForActiveServer.first.name));
    }
  }

  @override
  void dispose() {
    try {
      _listUpdatingTimer.cancel();
    } catch (_) {}

    super.dispose();
  }


}