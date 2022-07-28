import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:doorbell_pi_app/doorbell_update_data.dart';
import 'package:doorbell_pi_app/repositories/app_persistence_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;

import '../data/database/app_persistence_db.dart';

/// This MainServerRepository class handles the requests made to the Web server. This reduces the amount of work other classes have to do with http.
/// All requests to the main Web server will be handled by this class.
///
/// Author: Devon X. Dalrymple
/// Version: 2022-07-14
class MainServerRepository {
  late AppPersistenceRepository _persistenceRepository;

  MainServerRepository() {
    _persistenceRepository = Get.find();
  }

  /// This method attempts to simplify the process of connecting to the Web server to login in the device by requiring only four of the six fields.
  /// The request headers are also configured. No processing of the response happens during this call. That responsibility is left to the caller.
  Future<http.Response?> tryLoginAttempt(String ipAddress, int port, String password, String displayName) async {
    // https://stackoverflow.com/questions/50278258/http-post-with-json-on-body-flutter-dart - Raj Yadav

    String loginURL = "https://$ipAddress:$port/api/Authentication/login";

    Map loginData = {
      "deviceUUID": await _generateDeviceUUID(),
      "displayName": displayName,
      "deviceType": "App",
      "password": password
    };

    try {
      return await http.post(Uri.parse(loginURL),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(loginData)
      ).timeout(const Duration(seconds: 10));
    } catch (_) {
      try { // Unsecure connection
        return await http.post(Uri.parse(loginURL.replaceAll("https", "http")),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(loginData)
        ).timeout(const Duration(seconds: 3));
      } catch (_) {

      }
      return null;
    }

  }

  /// This is the method needed in order to go and ask the server for the list of doorbells it currently has and to alter the app's list to match the server's.
  /// Returns true if the connection was made successfully and the database was updated correctly.
  Future<bool> tryUpdatingDoorbellList() async {
    WebServer? server = await _persistenceRepository.getActiveWebServer();
    if (server == null) return false;


    String fetchingDoorbellsURL = "https://${server.ipAddress}:${server.portNumber}/App/GetDoorbells";
    var headers = await _buildHeaders(); // Fetches information like the JWT required to successfully connect.
    
    try {
      http.Response response = await http.get(Uri.parse(fetchingDoorbellsURL), headers: headers);
      await _persistenceRepository.setWhetherLastConnectionToServerWasSuccessful(server, true);

      if (response.statusCode == 401) { // JWT expired, need to refresh
        if (await _tryRefreshingTheJWT(server)) {
          return tryUpdatingDoorbellList();
        }
      }

      if (response.statusCode == 200) {
        List<Doorbell>? appDoorbells = await _persistenceRepository.getDoorbellsForActiveServer();
        if (appDoorbells == null) return false;

        var updateDataGroup = jsonDecode(response.body) as List; // Multiple sets of DoorbellUpdateData objects should appear in the json. This is step 1 for a list.
        List<DoorbellUpdateData> serverDoorbells = updateDataGroup.map((e) => DoorbellUpdateData.fromJson(e)).toList(); // This is step 2 in the conversion

        List<bool> wasSpecificServerListedDoorbellFound = List.generate(serverDoorbells.length, (_) => false); // This boolean lists are used to check which doorbells from app or server,
        List<bool> wasSpecificAppListedDoorbellFound = List.generate(appDoorbells.length, (_) => false); // have been located during the loops

        for (int appDoorbellsIndex = 0; appDoorbellsIndex < appDoorbells.length; appDoorbellsIndex++) {

          for (int serverIndex = 0; serverIndex < serverDoorbells.length; serverIndex++) {
            if (appDoorbells[appDoorbellsIndex].name == serverDoorbells[serverIndex].displayName) {
              wasSpecificServerListedDoorbellFound[serverIndex] = true;
              wasSpecificAppListedDoorbellFound[appDoorbellsIndex] = true;

              await _persistenceRepository.insertOrUpdateDoorbell( // Update the entry
                  Doorbell(
                      id: appDoorbells[appDoorbellsIndex].id,
                      lastActivationTime: BigInt.from(serverDoorbells[serverIndex].LastActivationUnix),
                      serverId: appDoorbells[appDoorbellsIndex].serverId,
                      activeSinceUnix: BigInt.from(serverDoorbells[serverIndex].lastTurnedOnUnix),
                      doorbellStatus: serverDoorbells[serverIndex].doorbellStatus,
                      name: appDoorbells[appDoorbellsIndex].name
                  )
              );
            }
          }

          if (!wasSpecificAppListedDoorbellFound[appDoorbellsIndex]) { // Delete current doorbells assigned for the server but that are not listed by the server.
            await _persistenceRepository.deleteDoorbell(appDoorbells[appDoorbellsIndex].id);
          }
        }

        for (int i = 0; i < serverDoorbells.length; i++) { // This is for any entries that are not currently on the phone
          if (!wasSpecificServerListedDoorbellFound[i]) {
            await _persistenceRepository.insertOrUpdateDoorbell( // Insert the entry
                Doorbell(
                    id: -1,
                    lastActivationTime: BigInt.from(serverDoorbells[i].LastActivationUnix),
                    serverId: server.id,
                    activeSinceUnix: BigInt.from(serverDoorbells[i].lastTurnedOnUnix),
                    doorbellStatus: serverDoorbells[i].doorbellStatus,
                    name: serverDoorbells[i].displayName

                )
            );
          }
        }

        return true; // If the status code is reached and no exception is thrown
      }
    } catch (_) {
      await _persistenceRepository.setWhetherLastConnectionToServerWasSuccessful(server, true);
    }

    return false;
  }

  /// This is the method needed in order to go and ask the server for the current status of a selected doorbell.
  /// This will remove the doorbell from the database if the server states it either does not exist or is banned.
  /// Returns true if the connection was made successfully and the database was updated correctly.
  Future<bool> tryUpdatingSpecificDoorbell(String displayName) async {
    // For more detailed information in comments on the process used here, check tryUpdatingDoorbellList(). This has to only do one doorbell and is simpler in nature.

    WebServer? server = await _persistenceRepository.getActiveWebServer();
    if (server == null) return false;

    Doorbell? doorbellWithDisplayName = await _persistenceRepository.getDoorbellByDisplayName(displayName);
    if (doorbellWithDisplayName == null) return false;

    String fetchingDoorbellsURL = "https://${server.ipAddress}:${server.portNumber}/App/GetDoorbellUpdate?doorbellDisplayName=$displayName";
    var headers = await _buildHeaders();


    try {
      http.Response response = await http.get(Uri.parse(fetchingDoorbellsURL), headers: headers);
      await _persistenceRepository.setWhetherLastConnectionToServerWasSuccessful(server, true);

      if (response.statusCode == 401) { // JWT expired, need to refresh
        if (await _tryRefreshingTheJWT(server)) {
          return tryUpdatingDoorbellList();
        }
      }

      if (response.statusCode == 200) {

        DoorbellUpdateData updateDataForDoorbellWithDisplayName = DoorbellUpdateData.fromJson(jsonDecode(response.body));

        _persistenceRepository.insertOrUpdateDoorbell( // Update the entry
            Doorbell(
                id: doorbellWithDisplayName.id,
                lastActivationTime: BigInt.from(updateDataForDoorbellWithDisplayName.LastActivationUnix),
                serverId: doorbellWithDisplayName.serverId,
                activeSinceUnix: BigInt.from(updateDataForDoorbellWithDisplayName.lastTurnedOnUnix),
                doorbellStatus: updateDataForDoorbellWithDisplayName.doorbellStatus,
                name: doorbellWithDisplayName.name

            )
        );

        return true; // If the status code is reached and no exception is thrown
      }

      if (response.statusCode == 400) { // Banned Device or Not Found
        await _persistenceRepository.deleteDoorbell(doorbellWithDisplayName.id);
      }
    } catch (_) {
      await _persistenceRepository.setWhetherLastConnectionToServerWasSuccessful(server, false);
    }

    return false;
  }

  // This is done in order to help the Web server identify the device between logins.
  Future<String> _generateDeviceUUID() async {
    // https://stackoverflow.com/questions/45031499/how-to-get-unique-device-id-in-flutter - Oswin Noetzelmann
    DeviceInfoPlugin infoPlugin = DeviceInfoPlugin();

    if (kIsWeb) {
      // As mentioned from the source of this code, no device UUID can be expected from a Web browser, this makes a good effort for one, however.
      WebBrowserInfo webInfo = await infoPlugin.webBrowserInfo;
      String webUUID = webInfo.hardwareConcurrency.toString() + webInfo.browserName.toString();

      if (webInfo.userAgent != null) {
        webUUID = webUUID + webInfo.userAgent!.toString();
      }

      if (webInfo.vendor != null) {
        webUUID = webUUID + webInfo.vendor!.toString();
      }

      return webUUID;
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await infoPlugin.androidInfo;
      return androidInfo.androidId.toString() + androidInfo.brand.toString() + androidInfo.board.toString() + androidInfo.fingerprint.toString();
    } else {
      return "UnknownDeviceUUID"; // This should not be thrown but prevents an error from being thrown.
    }


  }

  // Provides any necessary security or helper headers for each call to the active Web server.
  Future<Map<String, String>> _buildHeaders() async {
    FlutterSecureStorage storage = Get.find();
    
    return {
      'Authorization': "Bearer ${await storage.read(key: 'JWT')}"
    };
  }

  // Returns true if the JWT is refreshed successfully
  Future<bool> _tryRefreshingTheJWT(WebServer server) async {
    FlutterSecureStorage storage = Get.find();

    String? pass = await storage.read(key: 'Password');
    http.Response? response = await tryLoginAttempt(server.ipAddress, server.portNumber, pass!, server.displayName);

    if (response == null)  {
      await _persistenceRepository.setWhetherLastConnectionToServerWasSuccessful(server, false);
      return false;
    }

    if (response.statusCode == 200) {
      var token = await jsonDecode(response.body);

      String tokenValue = token['token'];
      storage.write(key: "JWT", value: tokenValue);
      return true;
    }

    return false;
  }
}