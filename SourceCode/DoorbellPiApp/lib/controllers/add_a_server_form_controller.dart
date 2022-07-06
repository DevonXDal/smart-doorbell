import 'dart:async';

import 'package:doorbell_pi_app/data/database/app_persistence_db.dart';
import 'package:doorbell_pi_app/repositories/main_server_repository.dart';
import 'package:doorbell_pi_app/widgets/pages/no_doorbells_registered_page.dart';
import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;

/// Manages the Add a Server page in order to ensure that form data is validated successfully.
/// This also handles checking if the server is located with the ip address and port.
/// Validation will fail if the password is incorrect.
///
/// Author: Devon X. Dalrymple
/// Version: 2022-06-24
class AddAServerFormController extends GetxController {
  late RxString ipAddress;
  late RxString port;
  late RxString password;
  late RxString displayName;

  late RxnString errorText;

  late Timer autoValidationTimer;

  Rxn<Function()> submitFunc = Rxn<Function()>(null);

  AddAServerFormController() : super() {
    ipAddress = RxString("");
    port = RxString("");
    password = RxString("");
    displayName = RxString("");

    errorText = RxnString("");
  }

  // https://stackoverflow.com/questions/64544571/flutter-getx-forms-validation - Baker
  @override
  void onInit() {
    super.onInit();
    // debounce<String>(RxString(""), _validations, time: const Duration(milliseconds: 1000)); - Not running as expected

    autoValidationTimer = Timer.periodic(const Duration(seconds: 2), (timer) { _validations(); }); // Every second, do autovalidation on the fields
  }

  void _validations() async {
    StringBuffer errorBuffer = StringBuffer();
    submitFunc.value = null; // disable submit while validating

    _validateIPAddress(errorBuffer);
    _validatePortNumber(errorBuffer);
    _validatePassword(errorBuffer);
    _validateDisplayName(errorBuffer);

    if (errorBuffer.toString().isEmpty) {
      submitFunc.value = _submitFunction();
      errorText.value = "";
    } else {
      errorText.value = errorBuffer.toString();

    }

    update();
  }

  Future<void> Function() _submitFunction() {
    return () async {
      MainServerRepository mainServerRepository = Get.find();

      http.Response? possibleConnection = await mainServerRepository.tryLoginAttempt(ipAddress.string, int.parse(port.value), password.string, displayName.string);

      if (possibleConnection == null) {
        Get.snackbar("Did not Locate Server", "Either the Server IP address and port is incorrect or an Internet connection is missing.");
      } else if (possibleConnection.statusCode == 200) {
        Get.snackbar("Connection Established", "Please wait while information on the Web server is collected.");

        FlutterSecureStorage storage = Get.find();
        AppPersistenceDb database = Get.find();

        var existingWebServer = await (database.select(database.webServers)..where(
                (webServer) => webServer.ipAddress.equals(ipAddress.string) & webServer.portNumber.equals(int.parse(port.value)))).get();

        if (existingWebServer.length > 0) { // One already exists
            WebServer previouslyStored = existingWebServer.first;

            database.update(database.webServers).replace( // Update the entry
                WebServer(
                    id: previouslyStored.id,
                    ipAddress: previouslyStored.ipAddress,
                    portNumber: previouslyStored.portNumber,
                    displayName: displayName.string,
                    lastConnectionSuccessful: true,
                    activeWebServerConnection: true
                )
            );
        } else {
          database.into(database.webServers).insert( // Update the entry
              WebServer(
                  id: -1,
                  ipAddress: ipAddress.string,
                  portNumber: int.parse(port.value),
                  displayName: displayName.string,
                  lastConnectionSuccessful: true,
                  activeWebServerConnection: true
              )
          );
        }

        storage.write(key: "Password", value: password.string);
        storage.write(key: "JWT", value: possibleConnection.body);
        Get.offAll(const NoDoorbellsRegisteredPage());
      } else if (possibleConnection.statusCode == 400) {
        Get.snackbar("Bad Request", "An error in the app occured trying to contact the Web server.");
      } else if (possibleConnection.statusCode == 401) {
        Get.snackbar("Incorrect Password", "The server rejected the login due to an incorrect password");
      } else if (possibleConnection.statusCode == 403) {
        Get.snackbar("Forbidden", "This device has been banned from the Web server. No access is granted.");
      } else {
        Get.snackbar("Unknown Status Code (${possibleConnection.statusCode})", "The connection was reached with the Web server but its return is not understood.");
      }
    };
  }

  void _validateIPAddress(StringBuffer errorBuffer) {
    if (ipAddress.isEmpty) {
      errorBuffer.writeln("IP Address must not be empty");
    }

    try {
        List<int> bytesArray = List<int>.filled(4, -1);
        int currentPos = 0;

        ipAddress.value.split(".").forEach((element) {
          bytesArray[currentPos++] = int.parse(element);
        });
        
        if (bytesArray.any((element) => element < 0 || element > 255)) {
          throw Exception("Not a valid byte integer");
        }
    } catch (_) {
      errorBuffer.writeln("IP Address must be formatted like '23.54.23.122' from 0-255.");
    }
  }

  void _validatePortNumber(StringBuffer errorBuffer) {

    try {
      if (int.parse(port.value) < 10 || int.parse(port.value) > 65535) {
        errorBuffer.writeln(
            "Port number must be a valid port number greater than 10 and less than or equal to 65,535.");
      }
    } catch (_) {
      errorBuffer.writeln(
          "Port number must be a valid port number");
    }
  }

  void _validatePassword(StringBuffer errorBuffer) {
    if (password.string.length < 6) {
      errorBuffer.writeln("The password must be at least six characters long.");
    }
  }

  void _validateDisplayName(StringBuffer errorBuffer) {
    if (displayName.string.length < 3) {
      errorBuffer.writeln("Your display name must be at least three characters long.");
    }
  }

  @override
  void dispose() {
    autoValidationTimer.cancel();
    super.dispose();
  }
}