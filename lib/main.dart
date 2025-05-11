import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BleScannerPage(),
    );
  }
}

class BleScannerPage extends StatefulWidget {
  const BleScannerPage({super.key});

  @override
  State<BleScannerPage> createState() => _BleScannerPageState();
}

class _BleScannerPageState extends State<BleScannerPage> {
  final flutterReactiveBle = FlutterReactiveBle();
  final List<DiscoveredDevice> _devices = [];

  bool _scanning = false;
  StreamSubscription<DiscoveredDevice>? _scanStream;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }


void _toggleScan() {
  if (_scanning) {
    _scanStream?.cancel();
    _scanStream = null;
  } else {  
    _devices.clear(); // limpa a lista antes de escanear de novo
    _scanStream = flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
      if (!_devices.any((d) => d.id == device.id)) {
        setState(() {
          _devices.add(device);
        });
      }
    });
  }
  setState(() { 
    _scanning = !_scanning;
  });
}

  StreamSubscription<ConnectionStateUpdate>? _connection;

void _connectToDevice(DiscoveredDevice device) {
  _connection?.cancel(); // Cancela qualquer conexão anterior
  _connection = flutterReactiveBle.connectToDevice(
    id: device.id,
    connectionTimeout: const Duration(seconds: 10),
  ).listen((connectionState) {
    print("Estado de conexão com ${device.name}: ${connectionState.connectionState}");
    // Aqui podemos exibir o estado na interface depois
  }, onError: (error) {
    print("Erro ao conectar: $error");
  });
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text("Dispositivos BLE"),
        actions: [
          IconButton(
            icon: Icon(_scanning ? Icons.stop : Icons.play_arrow),
            onPressed: _toggleScan,
          ),
        ],
      ),
      body: ListView(
        children: _devices
            .map((d) => ListTile(
                  title: Text(d.name.isNotEmpty ? d.name : "(sem nome)"),
                  subtitle: Text(d.id),
                  onTap: () {
                  _connectToDevice(d);
                },
                ))
            .toList(),
      ),
    );
  }
}
