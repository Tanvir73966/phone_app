class CallModel {
  final String name;
  final String phone;
  final DateTime time;
  final String type; // "incoming", "outgoing", "missed"

  CallModel({required this.name, required this.phone, required this.time, required this.type});
}
