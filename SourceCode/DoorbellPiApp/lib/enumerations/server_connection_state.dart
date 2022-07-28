/// This ServerConnectionState enum represents the three possible server connection states for this app.
/// This is used for widgets that display information based on the server connection.
///
/// They are:
/// 1. NotConnected: There is no active server to attempt to reach. N/A option
/// 2. NotReachable: There is an active server selected, but for one reason or another it cannot be reached currently.
/// 3. Reachable: There is an active server selected, and the active server is reachable.
enum ServerConnectionState {
  NotConnected, NotReachable, Reachable
}