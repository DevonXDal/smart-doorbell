import 'package:doorbell_pi_app/helpers/observer.dart';
import 'package:doorbell_pi_app/helpers/observer_listener.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';

/// This ListeneingController abstract class serves to provide common functionality to listening controllers.
/// By extending this class, subclasses pass along the observer to listen to and this class will manage and dispose of the observer as necessary.
///
/// Author: Devon X. Dalrymple
/// Version: 2022-07-17
abstract class ListeningController extends GetxController implements ObserverListener {
  late Observer _observer;

  @protected Observer get observer => _observer;

  /// Using this constructor sets up the observer for listening controller subclasses.
  /// Once the controller gets disposed, the listener will be removed from the observer.
  ListeningController(this._observer) {
    _observer.addListener(this);
  }

  @override
  void dispose() {
    _observer.tryRemoveListener(this);
    super.dispose();
  }
}