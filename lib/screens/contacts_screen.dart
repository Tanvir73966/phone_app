import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contacts_provider.dart';
import '../models/contact_model.dart';
import '../widgets/contact_card.dart';

class ContactsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final contactsProvider = Provider.of<ContactsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Contacts')),
      body: ListView.builder(
        itemCount: contactsProvider.contacts.length,
        itemBuilder: (context, index) {
          return ContactCard(contact: contactsProvider.contacts[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          contactsProvider.addContact(
              ContactModel(name: 'New Contact', phone: '+880000000000'));
        },
      ),
    );
  }
}
