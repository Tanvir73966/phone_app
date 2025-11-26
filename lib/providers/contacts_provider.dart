import 'package:flutter/material.dart';
import '../models/contact_model.dart';

class ContactsProvider extends ChangeNotifier {
  List<ContactModel> _contacts = [
    ContactModel(name: 'Alice', phone: '+880123456789'),
    ContactModel(name: 'Bob', phone: '+880987654321'),
  ];

  List<ContactModel> get contacts => _contacts;

  void addContact(ContactModel contact) {
    _contacts.add(contact);
    notifyListeners();
  }

  void removeContact(ContactModel contact) {
    _contacts.remove(contact);
    notifyListeners();
  }
}
