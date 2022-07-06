
import 'package:doorbell_pi_app/data/database/doorbells.dart';
import 'package:doorbell_pi_app/data/database/web_servers.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'app_persistence_db.g.dart';

/// This InternalDatabaseManager class serves to handle SQLite operations.
/// This file is used for the code generator for Drift.
/// This uses Drift instead of SQFlite in order to support Web deployments.
///
/// This database provides persistent storage of non-secrets.
///
/// Author: Devon X. Dalrymple (Code Generation and Database Code from Simon Binder [simolus3 on GitHub])
/// Version: 2022-06-26
@DriftDatabase(tables: [WebServers, Doorbells])
class AppPersistenceDb extends _$AppPersistenceDb {
  AppPersistenceDb() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}