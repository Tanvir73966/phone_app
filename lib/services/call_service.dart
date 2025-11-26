import 'package:flutter/services.dart';

class CallService {
  static const MethodChannel _channel = MethodChannel("custom.dialer/channel");

  /// Makes a direct system call
  static Future<bool> makeSystemCall(String number) async {
    try {
      final bool result =
          await _channel.invokeMethod("makeCall", {"number": number});
      return result;
    } catch (e) {
      print("Error making call: $e");
      return false;
    }
  }

  /// Runs a USSD code (like *123#)
  static Future<String> runUSSD(String code) async {
    try {
      final String result =
          await _channel.invokeMethod("runUSSD", {"code": code});
      return result;
    } catch (e) {
      print("Error running USSD: $e");
      return "Error";
    }
  }

  /// Requests the user to set this app as the default dialer
  static Future<bool> requestDefaultDialer() async {
    try {
      final bool granted =
          await _channel.invokeMethod("requestDefaultDialer");
      return granted;
    } catch (e) {
      print("Error requesting default dialer: $e");
      return false;
    }
  }
}
