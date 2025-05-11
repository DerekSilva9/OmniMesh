import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BluetoothScanPage(),
    );
  }
}

class BluetoothScanPage extends StatefulWidget {
  @override
  _BluetoothScanPageState createState() => _BluetoothScanPageState();
}

class _BluetoothScanPageState extends State<BluetoothScanPage> {
  List<BluetoothDiscoveryResult> _devicesList = [];
  bool _isScanning = false;

  // Função para verificar e pedir permissões
  Future<void> _checkPermissions() async {
    // Solicitar permissão para escanear Bluetooth
    PermissionStatus bluetoothStatus = await Permission.bluetoothScan.request();
    PermissionStatus locationStatus = await Permission.location.request();

    if (bluetoothStatus.isGranted && locationStatus.isGranted) {
      _startScan();
    } else {
      // Caso as permissões não sejam concedidas, exibe uma mensagem
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Permissões necessárias'),
            content: Text(
                'É necessário conceder permissões de Bluetooth e Localização para escanear dispositivos.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  // Iniciar a busca por dispositivos Bluetooth
  void _startScan() {
    setState(() {
      _isScanning = true;
      _devicesList.clear();
    });

    FlutterBluetoothSerial.instance.startDiscovery().listen((device) {
      setState(() {
        _devicesList.add(device);
      });
    }).onDone(() {
      setState(() {
        _isScanning = false;
      });
    });
  }

  // Exibir lista de dispositivos encontrados
  Widget _buildDeviceList() {
    if (_devicesList.isEmpty) {
      return Center(child: Text('Nenhum dispositivo encontrado.'));
    }

    return ListView.builder(
      itemCount: _devicesList.length,
      itemBuilder: (context, index) {
        final device = _devicesList[index];
        return ListTile(
          title: Text(device.device.name ?? 'Desconhecido'),
          subtitle: Text(device.device.address),
          trailing: IconButton(
            icon: Icon(Icons.bluetooth),
            onPressed: () {
              // Aqui você pode adicionar a lógica para conectar ao dispositivo
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner Bluetooth'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isScanning ? null : _checkPermissions,
            child: Text(_isScanning ? 'Escaneando...' : 'Iniciar Busca'),
          ),
          Expanded(child: _buildDeviceList()),
        ],
      ),
    );
  }
}
