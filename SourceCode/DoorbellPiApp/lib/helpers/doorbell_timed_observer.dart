import 'dart:async';

import 'package:doorbell_pi_app/helpers/observer.dart';
import 'package:get/get.dart';

import '../repositories/main_server_repository.dart';

class DoorbellTimedObserver extends Observer {
  late Timer _updateTimer;
  late final String _doorbellDisplayName;
  late MainServerRepository _serverRepository;

  /// This creates the doorbell timed observer and starts its update counter.
  /// Every 20 seconds, this will try to update information about the doorbell.
  DoorbellTimedObserver(this._doorbellDisplayName) : super() {
    _serverRepository = Get.find();

    _updateTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      _fetchNewStatus();
    });
  }

  /// Stops the timer that calls for the information on the doorbell that this observer is for to be stopped.
  void stopObserverProcesses() {
    _updateTimer.cancel();
  }

  // Tells the server repository the doorbell name and asks it to update status information.
  // If this is successfull, then the listeners will be notified.
  Future<void> _fetchNewStatus() async {
    if (await _serverRepository.tryUpdatingSpecificDoorbell(_doorbellDisplayName)) {
      notifyListeners();
    }
  }

}