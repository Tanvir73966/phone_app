import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:overlay_support/overlay_support.dart';

import 'providers/contacts_provider.dart';
import 'providers/calls_provider.dart';

import 'screens/contacts_screen.dart';
import 'screens/calls_screen.dart';
import 'screens/dial_pad_screen.dart';

import 'services/call_service.dart'; // Important

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ContactsProvider()),
          ChangeNotifierProvider(create: (_) => CallsProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Phone App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          home: HomeScreen(),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    ContactsScreen(),
    CallsScreen(),
    DialPadScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _requestDefaultDialer();
  }

  /// 🔥 Requests the user to set this app as the default dialer
  void _requestDefaultDialer() async {
    try {
      bool granted = await CallService.requestDefaultDialer();
      if (!granted) {
        // Optional: show a message if the user declines
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please set this app as the default dialer to make calls.')),
        );
      }
    } catch (e) {
      print('Error requesting default dialer: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.contacts), label: 'Contacts'),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Calls'),
          BottomNavigationBarItem(icon: Icon(Icons.dialpad), label: 'Dial Pad'),
        ],
      ),
    );
  }
}
