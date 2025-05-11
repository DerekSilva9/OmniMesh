import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  List<BluetoothDevice> _devicesList = [];
  bool _isDiscovering = false;

  @override
  void initState() {
    super.initState();
    _checkBluetoothState();
  }

  // Função para verificar o estado do Bluetooth
  Future<void> _checkBluetoothState() async {
    BluetoothState state = await FlutterBluetoothSerial.instance.state;
    if (state == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
    }
  }

  // Função para escanear dispositivos Bluetooth
  Future<void> _discoverDevices() async {
    // Verificar se já está em processo de descoberta
    if (_isDiscovering) return;

    setState(() {
      _isDiscovering = true;
    });

    // Limpar a lista de dispositivos antes de iniciar a busca
    _devicesList.clear();

    FlutterBluetoothSerial.instance.startDiscovery().listen(
      (BluetoothDiscoveryResult result) {
        setState(() {
          _devicesList.add(result.device);
        });
      },
      onDone: () {
        setState(() {
          _isDiscovering = false;
        });
      },
      onError: (e) {
        print("Erro durante a descoberta: $e");
        setState(() {
          _isDiscovering = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan Page')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _discoverDevices,
            child: Text('Iniciar Escaneamento'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _devicesList.length,
              itemBuilder: (context, index) {
                final device = _devicesList[index];
                return ListTile(
                  title: Text(device.name ?? "Unknown"),
                  subtitle: Text(device.address),
                  onTap: () {
                    BluetoothConnection.toAddress(device.address).then((connection) {
                      print("Conexão estabelecida com ${device.name}");
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
