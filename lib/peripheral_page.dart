import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BlePeripheralPage(),
    );
  }
}

class PeripheralPage extends StatelessWidget {
  const PeripheralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Periférico BLE")),
      body: Center(child: const Text('Modo Periférico')),
    );
  }
}

class BlePeripheralPage extends StatefulWidget {
  const BlePeripheralPage({super.key});

  @override
  State<BlePeripheralPage> createState() => _BlePeripheralPageState();
}

class _BlePeripheralPageState extends State<BlePeripheralPage> {
  final flutterBlePeripheral = FlutterBlePeripheral();
  bool _isAdvertising = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _startAdvertising(); // Inicia o anúncio do periférico
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetoothAdvertise,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

  Future<void> _startAdvertising() async {
    if (!_isAdvertising) {
      final advertisementData = AdvertiseData(
        localName: 'MeuDispositivo', // Nome do dispositivo periférico
        serviceUuid: '1234', // UUID do serviço (você pode escolher um único UUID)
      );

      // Para o método start(), apenas 'advertiseData' é necessário
      await flutterBlePeripheral.start(advertiseData: advertisementData);
      
      setState(() {
        _isAdvertising = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Periférico BLE"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _isAdvertising ? null : _startAdvertising,
          child: const Text("Iniciar Anúncio"),
        ),
      ),
    );
  }
}
