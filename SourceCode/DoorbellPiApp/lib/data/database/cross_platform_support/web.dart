import 'package:doorbell_pi_app/data/database/app_persistence_db.dart';
import 'package:drift/web.dart';

AppPersistenceDb constructDb() {
  return AppPersistenceDb(WebDatabase('db'));
}