import 'package:doorbell_pi_app/data/database/web_servers.dart';
import 'package:drift/drift.dart';

@DataClassName("Doorbell")
class Doorbells extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  Int64Column get activeSinceUnix => int64()();
  TextColumn get doorbellStatus => text()();
  Int64Column get lastActivationTime => int64()();
  IntColumn get serverId => integer().references(WebServers, #id)();
}