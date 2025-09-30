import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/bluetooth_manager.dart'; // Adicionado
import 'chat_screen.dart'; // Importando a tela de chat

class ListenerPage extends StatefulWidget {
  @override
  _ListenerPageState createState() => _ListenerPageState();
}

class _ListenerPageState extends State<ListenerPage> {
  static const platform = MethodChannel(
    'bluetooth_server',
  ); // Definindo o channel
  bool _isListening = false;

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
    });

    try {
      // Chama o método Kotlin para iniciar o servidor Bluetooth
      final Map result = await platform.invokeMethod('startServer');
      print(result);

      // Supondo que o método nativo retorna um mapa com 'connection' e 'device'
      final connection = result['connection'];
      final device = result['device'];
      BluetoothManager().acceptConnection(connection, device);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen(device: device)),
      ); // Navegando para a tela de chat
    } on PlatformException catch (e) {
      print("Erro: ${e.message}");
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Listener Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isListening ? 'Aguardando conexões...' : 'Pronto para escutar.',
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  _isListening
                      ? null
                      : _startListening, // Chama o método para começar a ouvir
              child: Text('Começar a ouvir'),
            ),
          ],
        ),
      ),
    );
  }
}
