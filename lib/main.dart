import 'package:flutter/material.dart';
import 'pages/scan_page.dart';
import 'pages/listener_page.dart';
import 'pages/chat_page.dart';
import 'pages/paired_devices_page.dart';

void main() {
  runApp(const OmniMeshApp());
}

class OmniMeshApp extends StatelessWidget {
  const OmniMeshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniMesh',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ScanPage(),
    ListenerPage(),
    ChatPage(),
    PairedDevicesPage(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OmniMesh'),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Escanear',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wifi_tethering),
            label: 'Aguardar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Pareados',
          ),
        ],
      ),
    );
  }
}
