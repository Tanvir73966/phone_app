import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../services/call_service.dart';

class ContactCard extends StatelessWidget {
  final ContactModel contact;
  const ContactCard({required this.contact, Key? key}) : super(key: key);

  Future<void> _callNumber(BuildContext context) async {
    bool success = await CallService.makeSystemCall(contact.phone);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Call failed or permission denied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(contact.name),
      subtitle: Text(contact.phone),
      trailing: IconButton(
        icon: const Icon(Icons.call, color: Colors.green),
        onPressed: () => _callNumber(context),
      ),
    );
  }
}
