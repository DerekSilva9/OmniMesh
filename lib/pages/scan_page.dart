// scan_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  List<BluetoothDevice> _devicesList = [];

  @override
  void initState() {
    super.initState();
    _discoverDevices();
  }

  // Função para escanear dispositivos Bluetooth
  Future<void> _discoverDevices() async {
    // Limpa a lista de dispositivos antes de iniciar a busca
    _devicesList.clear();
    
    // Inicia a descoberta de dispositivos
    FlutterBluetoothSerial.instance.startDiscovery().listen((BluetoothDiscoveryResult result) {
      setState(() {
        // Adiciona dispositivos encontrados na lista
        _devicesList.add(result.device);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan Page')),
      body: ListView.builder(
        itemCount: _devicesList.length,
        itemBuilder: (context, index) {
          final device = _devicesList[index];
          return ListTile(
            title: Text(device.name ?? "Unknown"),
            subtitle: Text(device.address),
            onTap: () {
              // Ao clicar no dispositivo, tentar a conexão
              BluetoothConnection.toAddress(device.address).then((connection) {
                print("Conexão estabelecida com ${device.name}");
                // Aqui você pode navegar para a página de chat, se necessário
              }).catchError((e) {
                print("Erro ao conectar: $e");
              });
            },
          );
        },
      ),
    );
  }
}
