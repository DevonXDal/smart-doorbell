import 'dart:async';

import 'package:get/get.dart';

class NoDoorbellsRegisteredController extends GetxController {
  late Timer _listUpdatingTimer;

  NoDoorbellsRegisteredController() {
    _listUpdatingTimer = Timer.periodic(Duration(minutes: 1), (_) => _tryFetchingNewDoorbells());
  }

  _tryFetchingNewDoorbells() {

  }
}