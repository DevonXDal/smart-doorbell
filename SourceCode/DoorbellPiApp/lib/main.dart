import 'dart:io';

import 'package:doorbell_pi_app/data/database/app_persistence_db.dart';
import 'package:doorbell_pi_app/data/database/cross_platform_support/shared.dart' as database_platform_decider;
import 'package:doorbell_pi_app/repositories/app_persistence_repository.dart';
import 'package:doorbell_pi_app/repositories/main_server_repository.dart';
import 'package:doorbell_pi_app/widgets/pages/server_not_configured_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data/app_colors.dart';

void main() {
  if (kDebugMode) {
    HttpOverrides.global = NoForcedSSLCertificateHttpOverrides(); // This needs to be done before any app connections to the server are made.
  }
  runApp(const AppLoader()); // Flutter begins here with the runApp
}

class AppLoader extends StatelessWidget {
  const AppLoader({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.put<AppPersistenceDb>(database_platform_decider.constructDb()); // Provides database access when needed
    Get.put<AppPersistenceRepository>(AppPersistenceRepository()); // Provides common database operations
    Get.put<MainServerRepository>(MainServerRepository()); // Provides a central location to make calls to the main server
    Get.put<FlutterSecureStorage>(const FlutterSecureStorage()); // Provides a storage for secrets like the server password

    return GetMaterialApp(
      title: "Devon's DoorbellPi", // This is the app's name
      theme: ThemeData(
        primarySwatch: Colors.yellow, // Without a format, things like a buttons background will default to this yellow.
        fontFamily: GoogleFonts.lato().fontFamily,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 14, color: AppColors.textForegroundOrange,),
          bodyLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textForegroundOrange,),
          labelSmall: TextStyle(fontSize: 16, color: Colors.white70),
          labelMedium: TextStyle(fontSize: 20, color: Colors.white70),
        )
      ),
      home: const ServerNotConfiguredPage(),
    );
  }
}

// Class for development - https://stackoverflow.com/questions/54285172/how-to-solve-flutter-certificate-verify-failed-error-while-performing-a-post-req - m123
// Its purpose is to allow connections without SSL certificates during debugging as SSL certificates require an open connection to the Web server in testing.
class NoForcedSSLCertificateHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

