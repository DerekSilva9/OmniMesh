import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class PairedDevicesPage extends StatefulWidget {
  @override
  _PairedDevicesPageState createState() => _PairedDevicesPageState();
}

class _PairedDevicesPageState extends State<PairedDevicesPage> {
  List<BluetoothDevice> _bondedDevices = [];

  @override
  void initState() {
    super.initState();
    _getBondedDevices();
  }

  void _getBondedDevices() async {
    List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {
      _bondedDevices = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dispositivos Pareados')),
      body: _bondedDevices.isEmpty
          ? Center(child: Text('Nenhum dispositivo pareado encontrado'))
          : ListView.builder(
              itemCount: _bondedDevices.length,
              itemBuilder: (context, index) {
                final device = _bondedDevices[index];
                return ListTile(
                  title: Text(device.name ?? 'Desconhecido'),
                  subtitle: Text(device.address),
                  trailing: Icon(Icons.bluetooth_connected),
                  onTap: () {
                    BluetoothConnection.toAddress(device.address).then((connection) {
                      print("Conectado a ${device.name}");
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
