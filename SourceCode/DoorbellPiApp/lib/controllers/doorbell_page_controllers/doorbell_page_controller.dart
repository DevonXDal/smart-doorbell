import 'package:doorbell_pi_app/helpers/doorbell_timed_observer.dart';
import 'package:get/get.dart';

/// This DoorbellPageController doesn't actually control the display data on the page itself through the page.
/// Instead it holds onto the observer that the widgets on the page require for doorbell updates to be performed.
/// When the page is navigated away from, this controller stops the timer so that no extra calls are made to refresh this doorbell's information.
///
/// Author: Devon X. Dalrymple
/// Version: 2022-07-17
class DoorbellPageController extends GetxController {
  late final DoorbellTimedObserver _observer;

  DoorbellPageController(this._observer);

  @override
  void dispose() {
    _observer.stopObserverProcesses();
  }
}