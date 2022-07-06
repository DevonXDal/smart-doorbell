import 'package:drift/drift.dart';

/// This is not for Web page delivery. This is a database model for the Web server that the device is connected to.
///
/// Author: Devon X. Dalrymple
/// Version: 2022-06-25
@DataClassName("WebServer")
class WebServers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ipAddress => text().withLength(min: 7, max: 15)();
  IntColumn get portNumber => integer()();
  TextColumn get displayName => text().withLength(min: 3)();
  BoolColumn get lastConnectionSuccessful => boolean()();
  BoolColumn get activeWebServerConnection => boolean().nullable()();
}