import 'dart:core';

class DoorbellUpdateData {
  final String displayName;
  final int lastTurnedOnUnix;
  final String doorbellStatus;
  final int LastActivationUnix;

  DoorbellUpdateData(this.displayName, this.lastTurnedOnUnix, this.doorbellStatus, this.LastActivationUnix);

  // https://www.bezkoder.com/dart-flutter-parse-json-string-array-to-object-list/
  factory DoorbellUpdateData.fromJson(dynamic json) {
    return DoorbellUpdateData(json['DisplayName'] as String, json['LastTurnedOn'] as int, json['DoorbellStatus'] as String, json['LastActivationUnix'] as int);
  }
}