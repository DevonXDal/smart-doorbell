import 'dart:io';

import 'package:doorbell_pi_app/data/database/app_persistence_db.dart';
import 'package:doorbell_pi_app/repositories/main_server_repository.dart';
import 'package:doorbell_pi_app/widgets/pages/server_not_configured_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const AppLoader());
}

class AppLoader extends StatelessWidget {
  const AppLoader({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.put<AppPersistenceDb>(AppPersistenceDb()); // Provides database access when needed
    Get.put<MainServerRepository>(MainServerRepository());
    Get.put<FlutterSecureStorage>(const FlutterSecureStorage());

    return GetMaterialApp(
      title: "Devon's DoorbellPi",
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: const ServerNotConfiguredPage(),
    );
  }
}

// Temporary development class - https://stackoverflow.com/questions/54285172/how-to-solve-flutter-certificate-verify-failed-error-while-performing-a-post-req - m123
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

