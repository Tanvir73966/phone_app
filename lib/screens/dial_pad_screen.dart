import 'package:flutter/material.dart';
import '../services/call_service.dart';

class DialPadScreen extends StatefulWidget {
  @override
  _DialPadScreenState createState() => _DialPadScreenState();
}

class _DialPadScreenState extends State<DialPadScreen> {
  String number = '';

  // Add a digit
  void _addDigit(String digit) {
    setState(() => number += digit);
  }

  // Delete last digit
  void _deleteDigit() {
    if (number.isNotEmpty) {
      setState(() => number = number.substring(0, number.length - 1));
    }
  }

  // Call or USSD
  Future<void> _call() async {
    if (number.isEmpty) return;

    bool isUSSD = number.startsWith('*') && number.endsWith('#');

    try {
      if (isUSSD) {
        String response = await CallService.runUSSD(number);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response), duration: Duration(seconds: 3)),
        );
      } else {
        bool success = await CallService.makeSystemCall(number);
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Call failed or permission denied')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Build a dial pad button
  Widget _buildButton(String digit) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: TextButton(
          onPressed: () => _addDigit(digit),
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 20),
          ),
          child: Text(
            digit,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 60),
        Text(
          number,
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(children: [_buildButton('1'), _buildButton('2'), _buildButton('3')]),
              Row(children: [_buildButton('4'), _buildButton('5'), _buildButton('6')]),
              Row(children: [_buildButton('7'), _buildButton('8'), _buildButton('9')]),
              Row(children: [_buildButton('*'), _buildButton('0'), _buildButton('#')]),
              Row(
                children: [
                  // Delete button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextButton(
                        onPressed: _deleteDigit,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: Icon(Icons.backspace, size: 28, color: Colors.red[700]),
                      ),
                    ),
                  ),
                  // Call button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextButton(
                        onPressed: _call,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.green[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: Icon(Icons.call, size: 32, color: Colors.green[900]),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
