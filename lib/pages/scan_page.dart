import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  List<BluetoothDiscoveryResult> _devicesList = [];
  bool _isDiscovering = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions(); // Solicita permissões ao iniciar a tela
  }

  // Solicita permissões necessárias para Bluetooth e localização
  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
      Permission.locationWhenInUse,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);
    if (!allGranted) {
      print("Permissões necessárias não concedidas!");
    }
  }

  // Inicia o escaneamento de dispositivos Bluetooth
  void startDiscovery() async {
    setState(() {
      _isDiscovering = true;
      _devicesList.clear();
    });

    FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
      if (!_devicesList.any((element) => element.device.address == result.device.address)) {
        setState(() {
          _devicesList.add(result);
        });
      }
    }).onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Escaneando Dispositivos"),
      ),
      body: Column(
        children: [
          if (_isDiscovering)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isDiscovering ? null : startDiscovery,
            child: Text(_isDiscovering ? "Escaneando..." : "Iniciar Escaneamento"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _devicesList.length,
              itemBuilder: (context, index) {
                final device = _devicesList[index].device;
                return ListTile(
                  title: Text(device.name ?? "Desconhecido"),
                  subtitle: Text(device.address),
                  onTap: () {
                    BluetoothConnection.toAddress(device.address).then((connection) {
                      print("Conexão estabelecida com ${device.name}");
                      // Aqui você pode navegar para a tela de chat, se quiser
                    }).catchError((e) {
                      print("Erro ao conectar: $e");
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
