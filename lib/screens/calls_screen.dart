import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calls_provider.dart';
import '../widgets/call_log_card.dart';

class CallsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final callsProvider = Provider.of<CallsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Call Logs')),
      body: ListView.builder(
        itemCount: callsProvider.calls.length,
        itemBuilder: (context, index) {
          return CallLogCard(call: callsProvider.calls[index]);
        },
      ),
    );
  }
}
