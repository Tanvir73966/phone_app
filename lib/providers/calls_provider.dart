import 'package:flutter/material.dart';
import '../models/call_model.dart';

class CallsProvider extends ChangeNotifier {
  List<CallModel> _calls = [
    CallModel(name: 'Alice', phone: '+880123456789', time: DateTime.now().subtract(Duration(minutes: 10)), type: 'incoming'),
    CallModel(name: 'Bob', phone: '+880987654321', time: DateTime.now().subtract(Duration(hours: 1)), type: 'outgoing'),
  ];

  List<CallModel> get calls => _calls;

  void addCall(CallModel call) {
    _calls.insert(0, call);
    notifyListeners();
  }

  void removeCall(CallModel call) {
    _calls.remove(call);
    notifyListeners();
  }
}
