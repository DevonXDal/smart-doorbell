import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// This MainServerRepository class handles the requests made to the Web server. This reduces the amount of work other classes have to do with http.
/// All requests to the main Web server will be handled by this class.
///
/// Author: Devon X. Dalrymple
/// Version: 2022-06-25
class MainServerRepository {

  /// This method attempts to simplify the process of connecting to the Web server to login in the device by requiring only four of the six fields.
  /// The request headers are also configured. No processing of the response happens during this call. That responsibility is left to the caller.
  Future<http.Response> tryLoginAttempt(String ipAddress, int port, String password, String displayName) async {
    // https://stackoverflow.com/questions/50278258/http-post-with-json-on-body-flutter-dart - Raj Yadav

    String loginURL = "https://$ipAddress:$port/api/Authentication/login";

    Map loginData = {
      "deviceUUID": await _generateDeviceUUID(),
      "displayName": displayName,
      "deviceType": "App",
      "password": password
    };

    return await http.post(Uri.parse(loginURL),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(loginData)
    );
  }

  // This is done in order to help the Web server identify the device between logins.
  Future<String> _generateDeviceUUID() async {
    // https://stackoverflow.com/questions/45031499/how-to-get-unique-device-id-in-flutter - Oswin Noetzelmann
    DeviceInfoPlugin infoPlugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await infoPlugin.androidInfo;
      return androidInfo.androidId.toString();
    } else if (kIsWeb) {
      // As mentioned from the source of this code, no device UUID can be expected from a Web browser, this makes a good effort for one, however.
      WebBrowserInfo webInfo = await infoPlugin.webBrowserInfo;
      String webUUID = webInfo.hardwareConcurrency.toString() + webInfo.browserName.toString();

      if (webInfo.userAgent != null) {
        webUUID = webUUID + webInfo.userAgent.toString();
      }

      if (webInfo.vendor != null) {
        webUUID = webUUID + webInfo.vendor.toString();
      }

      return webUUID;
    } else {
      return "UnknownDeviceUUID"; // This should not be thrown but prevents an error from being thrown.
    }
  }
}