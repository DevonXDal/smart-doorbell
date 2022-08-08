import 'package:doorbell_pi_app/data/database/app_persistence_db.dart';
import 'package:get/get.dart';

/// This AppPersistenceRepository class exists to remove the common operations on the database from other classes.
/// This is done to reduce code duplication. Some classes may no longer need direct database access.
/// Custom queries specific to a single method are not handled.
/// This allows methods in other classes to appear to be more clean and reduce the length of complex methods.
///
/// Author: Devon X. Dalrymple
/// Version: 2022-07-14
class AppPersistenceRepository {
  late AppPersistenceDb _db;

  /// This sets up the repository using dependency injection to find the database.
  /// This should only be ran when the database can be depenedency injected.
  AppPersistenceRepository() {
    _db = Get.find();
  }


  /// This method returns a list of doorbells from the database that are assigned to the currently active Web server.
  /// A null is returned when there is no active server. An empty list is due to a lack of assigned doorbells.
  /// Otherwise, each connected doorbell will be returned in the list.
  Future<List<Doorbell>?> getDoorbellsForActiveServer() async {
    WebServer? activeServer = await getActiveWebServer();
    if (activeServer == null) return null;

    return await (_db.select(_db.doorbells)
      ..where((doorbell) => doorbell.serverId.equals(activeServer.id))).get();
  }

  /// This method returns the Web server marked as active if it exists. Otherwise,
  /// if no Web server is active, then null is returned.
  Future<WebServer?> getActiveWebServer() async {
    return await (_db.select(_db.webServers)
      ..where((webServer) => webServer.activeWebServerConnection.equals(true))).getSingleOrNull();
  }

  /// This method uses the expected id to try and locate a specific doorbell.
  /// Null is returned when that doorbell does not exist.
  Future<Doorbell?> getDoorbellById(int id) async {
    return await (_db.select(_db.doorbells)
      ..where((doorbell) => doorbell.id.equals(id))).getSingleOrNull();
  }

  /// This method uses the expected display name (which should be unique) to try and locate a specific doorbell.
  /// Null is returned when that doorbell does not exist.
  Future<Doorbell?> getDoorbellByDisplayName(String displayName) async {
    return await (_db.select(_db.doorbells)
      ..where((doorbell) => doorbell.name.equals(displayName))).getSingleOrNull();
  }

  /// This method uses the expected id to try and locate a specific Web server.
  /// Null is returned when that Web server does not exist.
  Future<WebServer?> getWebServerById(int id) async {
    return await (_db.select(_db.webServers)
      ..where((webServer) => webServer.id.equals(id))).getSingleOrNull();
  }

  /// This method uses the expected ip address to try and locate a specific Web server.
  /// Null is returned when that Web server does not exist.
  Future<WebServer?> getWebServerByIP(String ipAddress) async {
    return await (_db.select(_db.webServers)
      ..where((webServer) => webServer.ipAddress.equals(ipAddress))).getSingleOrNull();
  }

  /// Returns every doorbell in the database.
  Future<List<Doorbell>> getDoorbells() async {
    return await (_db.select(_db.doorbells)).get();
  }

  /// Returns every Web server listed in the database.
  Future<List<WebServer>> getWebServers() async {
    return await (_db.select(_db.webServers)).get();
  }

  /// Attempts to either insert or update the doorbell depending on its id.
  /// If the id is negative, then the doorbell will be inserted.
  /// Else, the doorbell will be updated using its provided id.
  /// Then, if something goes wrong, a return value of false will be returned.
  Future<bool> insertOrUpdateDoorbell(Doorbell doorbell) async {
    if (doorbell.id < 0) {
      await _db.into(_db.doorbells).insert(doorbell.copyWith(id: await getNextAvailableDoorbellId()));

      return true;
    }

    try {
      await _db.update(_db.doorbells).replace(doorbell);

      return true;
    } catch (_) {
      return false; // There is no doorbell that could be replaced
    }
  }

  /// Attempts to either insert or update the Web server depending on its id.
  /// If the id is negative, then the Web server will be inserted.
  /// Else, the Web server will be updated using its provided id.
  /// Then, if something goes wrong, a return value of false will be returned.
  Future<bool> insertOrUpdateWebServer(WebServer server) async {
    if (server.id < 0) {

      await _db.into(_db.webServers).insert(server.copyWith(id: await getNextAvailableWebServerId()));

      return true;
    }

    try {
      await _db.update(_db.webServers).replace(server);

      return true;
    } catch (_) {
      return false; // There is no web server that could be replaced
    }
  }

  /// Using the id provided, the doorbell will be removed from the database.
  /// If this is done successfully (the doorbell must be in the database to work),
  /// then true will be returned.
  Future<bool> deleteDoorbell(int id) async {
    try {
      await (_db.delete(_db.doorbells)
        ..where((d) => d.id.equals(id))).go();

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Returns true if an active Web server is made inactive,
  /// otherwise, this returns false.
  Future<bool> makeActiveWebServerInactive() async {
    WebServer? possibleActiveWebServer = await getActiveWebServer();
    if (possibleActiveWebServer == null) return false;

    insertOrUpdateWebServer(WebServer(
        id: possibleActiveWebServer.id,
        ipAddress: possibleActiveWebServer.ipAddress,
        portNumber: possibleActiveWebServer.portNumber,
        displayName: possibleActiveWebServer.displayName,
        lastConnectionSuccessful: possibleActiveWebServer.lastConnectionSuccessful,
        activeWebServerConnection: false)
    );

    while (await makeActiveWebServerInactive()) {} // This recursively ensures nothing else is active


    return true;
  }

  /// Returns the next guaranteed available doorbell id to insert a doorbell into the database.
  Future<int> getNextAvailableDoorbellId() async {
    List<Doorbell> sortedDoorbells = (await getDoorbells())..sort((a, b) => a.id.compareTo(b.id));
    if (sortedDoorbells.isEmpty) return 0;

    return sortedDoorbells.last.id + 1;
  }

  /// Returns the next guaranteed available Web server id to insert a Web server into the database.
  Future<int> getNextAvailableWebServerId() async {
    List<WebServer> sortedWebServers = (await getWebServers())..sort((a, b) => a.id.compareTo(b.id));
    if (sortedWebServers.isEmpty) return 0;

    return sortedWebServers.last.id + 1;
  }

  Future<void> setWhetherLastConnectionToServerWasSuccessful(WebServer serverContacted, bool wasSuccessful) async {
    insertOrUpdateWebServer(WebServer(
        id: serverContacted.id,
        ipAddress: serverContacted.ipAddress,
        portNumber: serverContacted.portNumber,
        displayName: serverContacted.displayName,
        lastConnectionSuccessful: wasSuccessful,
        activeWebServerConnection: serverContacted.activeWebServerConnection)
    );
  }

}