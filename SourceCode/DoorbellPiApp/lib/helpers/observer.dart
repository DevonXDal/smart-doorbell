import 'observer_listener.dart';

/// This Observer class provides the functionality to follow the observer pattern.
/// It has a maximum listener collection size dependent on the size set by its constructor.
class Observer {
  late List<ObserverListener> _listeners;

  /// Creates the observer with no listeners.
  Observer() {
    _listeners = List.of(Iterable.empty(), growable: true);
  }

  /// Notifies the listeners that a change has occured.
  /// The listeners are now expected to collect new information.
  void notifyListeners() {
    for (var element in _listeners) {
      element.doListenerUpdate();
    }
  }

  /// Adds the listener object to the collection of listeners
  void addListener(ObserverListener listener) {
    _listeners.add(listener);
  }

  /// Removes the listener from the collection if it exists
  void tryRemoveListener(ObserverListener listener) {
    try {
      _listeners.remove(listener);
    } catch (_) {}
  }

  /// Removes all listeners from the collection of listeners
  void clearListeners() {
    _listeners.clear();
  }
}