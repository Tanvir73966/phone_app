import 'package:flutter/material.dart';
import '../models/call_model.dart';
import '../services/call_service.dart';

class CallLogCard extends StatelessWidget {
  final CallModel call;
  const CallLogCard({required this.call, Key? key}) : super(key: key);

  Future<void> _callNumber(BuildContext context) async {
    bool success = await CallService.makeSystemCall(call.phone);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Call failed or permission denied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${call.time.hour}:${call.time.minute.toString().padLeft(2, '0')}';
    return ListTile(
      title: Text(call.name),
      subtitle: Text('${call.phone} • ${call.type} • $timeStr'),
      trailing: IconButton(
        icon: const Icon(Icons.call, color: Colors.green),
        onPressed: () => _callNumber(context),
      ),
    );
  }
}
