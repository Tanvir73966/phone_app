import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:overlay_support/overlay_support.dart';

import 'providers/contacts_provider.dart';
import 'providers/calls_provider.dart';

import 'screens/contacts_screen.dart';
import 'screens/calls_screen.dart';
import 'screens/dial_pad_screen.dart';

import 'services/call_service.dart';

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
  bool _permissionsGranted = false;
  bool _isDefaultDialer = false;

  final List<Widget> _screens = [
    ContactsScreen(),
    CallsScreen(),
    DialPadScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initPermissions();
  }

  /// Request phone permissions
  void _initPermissions() async {
    bool granted = await CallService.requestPermissions();
    setState(() {
      _permissionsGranted = granted;
    });

    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Phone permissions are required to make calls and run USSD.'),
        ),
      );
    }
  }

  /// Request user to set this app as default dialer
  void _requestDefaultDialer() async {
    bool granted = await CallService.requestDefaultDialer();
    setState(() {
      _isDefaultDialer = granted;
    });

    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'You need to set this app as the default dialer to make calls.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This app is now set as the default dialer.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone App'),
        actions: [
          if (_permissionsGranted && !_isDefaultDialer)
            TextButton(
              onPressed: _requestDefaultDialer,
              child: const Text(
                'Set Default Dialer',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
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
