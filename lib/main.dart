import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothPage(),
    );
  }
}

class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  List<BluetoothDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    _getDevices();
  }

  _getDevices() async {
    try {
      var pairedDevices = await _bluetooth.getBondedDevices();
      setState(() {
        _devices = pairedDevices;
      });
    } catch (e) {
      print("Erro ao buscar dispositivos Bluetooth: $e");
    }
  }

  _connectToDevice(BluetoothDevice device) async {
    try {
      BluetoothConnection.toAddress(device.address).then((connection) {
        print('Conectado ao ${device.name}');
      }).catchError((error) {
        print('Erro ao conectar: $error');
      });
    } catch (e) {
      print("Erro ao tentar conectar: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dispositivos Bluetooth"),
      ),
      body: _devices.isEmpty
          ? Center(child: CircularProgressIndicator()) // Exibe um carregando
          : ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_devices[index].name ?? "Dispositivo desconhecido"),
                  subtitle: Text(_devices[index].address),
                  onTap: () {
                    _connectToDevice(_devices[index]);
                  },
                );
              },
            ),
    );
  }
}
