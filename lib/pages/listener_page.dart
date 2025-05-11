// listener_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ListenerPage extends StatefulWidget {
  @override
  _ListenerPageState createState() => _ListenerPageState();
}

class _ListenerPageState extends State<ListenerPage> {
  BluetoothConnection? _connection;

  @override
  void initState() {
    super.initState();
  }

  // Função para começar a ouvir conexões Bluetooth
  Future<void> _startListening() async {
    // Aqui, você pode tentar escutar uma conexão com Bluetooth
    FlutterBluetoothSerial.instance.onStateChanged().listen((state) async {
      if (state == BluetoothState.STATE_ON) {
        // Iniciar o servidor e esperar por conexões, no caso, utilizar o BluetoothConnection
        BluetoothConnection.toAddress("00:00:00:00:00:00").then((connection) {
          setState(() {
            _connection = connection;
          });
          print("Conexão recebida!");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Listener Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Aguardando conexões...'),
            ElevatedButton(
              onPressed: _startListening,
              child: Text('Começar a ouvir'),
            ),
          ],
        ),
      ),
    );
  }
}
