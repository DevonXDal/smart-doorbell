import 'dart:core';

class DoorbellUpdateData {
  final String displayName;
  final int lastTurnedOnUnix;
  final String doorbellStatus;
  final int LastActivationUnix;

  DoorbellUpdateData(this.displayName, this.lastTurnedOnUnix, this.doorbellStatus, this.LastActivationUnix);

  // https://www.bezkoder.com/dart-flutter-parse-json-string-array-to-object-list/
  factory DoorbellUpdateData.fromJson(dynamic json) {
    try {
      return DoorbellUpdateData(json['displayName'] as String, json['lastTurnedOn'], json['doorbellStatus'] as String, json['lastActivationUnix']);
    } catch(_) {
      return DoorbellUpdateData(json[0]['displayName'] as String, json[0]['lastTurnedOn'], json[0]['doorbellStatus'] as String, json[0]['lastActivationUnix']);
    }

  }
}