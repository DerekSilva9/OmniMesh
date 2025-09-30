import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // Adicionado
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
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
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
  BluetoothAdapterState _lastState = BluetoothAdapterState.unknown;

  final List<Widget> _pages = [
    ScanPage(),
    ListenerPage(),
    ChatPage(),
    PairedDevicesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothAdapterState>(
      stream: FlutterBluePlus.adapterState,
      initialData: BluetoothAdapterState.unknown,
      builder: (context, snapshot) {
        final state = snapshot.data ?? BluetoothAdapterState.unknown;
        _handleAdapterState(state);

        if (state == BluetoothAdapterState.on) {
          // Bluetooth ligado: mostra a navegação principal
          return Scaffold(
            appBar: AppBar(title: const Text('OmniMesh')),
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
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'Pareados',
                ),
              ],
            ),
          );
        } else {
          // Bluetooth desligado ou indisponível
          return Scaffold(
            appBar: AppBar(title: const Text("OmniMesh")),
            body: Center(
              child: Text(
                'O Bluetooth está ${state.toString().substring(21)}.',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          );
        }
      },
    );
  }

  void _handleAdapterState(BluetoothAdapterState currentState) {
    if (currentState == _lastState) return;

    if (currentState == BluetoothAdapterState.off ||
        currentState == BluetoothAdapterState.unavailable) {
      // CORREÇÃO: Agende a chamada do SnackBar para após o build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Por favor, ligue o Bluetooth para continuar.',
              ),
              action: SnackBarAction(
                label: 'LIGAR',
                onPressed: () {
                  FlutterBluePlus.turnOn();
                },
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      });
    }

    // Se o estado anterior era OFF e agora está ON, remova qualquer SnackBar antigo.
    if (_lastState != BluetoothAdapterState.on &&
        currentState == BluetoothAdapterState.on) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      });
    }

    _lastState = currentState;
  }
}
