class TwilioRoomConnectionData {
  final String token;
  final String roomName;

  TwilioRoomConnectionData(this.token, this.roomName);

  // https://www.bezkoder.com/dart-flutter-parse-json-string-array-to-object-list/
  factory TwilioRoomConnectionData.fromJson(dynamic json) {
    try {
      return TwilioRoomConnectionData(json['Token'] as String, json['RoomName']);
    } catch(_) {
      return TwilioRoomConnectionData(json[0]['Token'] as String, json[0]['RoomName']);
    }

  }
}