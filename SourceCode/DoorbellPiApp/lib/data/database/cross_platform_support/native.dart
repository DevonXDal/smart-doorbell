import 'dart:io';

import 'package:doorbell_pi_app/data/database/app_persistence_db.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

AppPersistenceDb constructDb() {
  final db = LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
  return AppPersistenceDb(db);
}