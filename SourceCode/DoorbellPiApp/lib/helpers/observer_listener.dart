/// This ObserverListener abstract class serves to be used as an implicit interface for any listener objects for an observer.
/// This provides the observer a known method to call in the listener class to perform an update action.
///
/// Author: Devon X. Dalrymple
/// Version: 2022-07-17
abstract class ObserverListener {

  /// Update may be called by the listener or an observer it is listening to.
  /// When update is called, the listener should update its data in reaction to the event.
  void doListenerUpdate();
}