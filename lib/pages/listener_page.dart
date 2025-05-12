import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Para usar MethodChannel

class ListenerPage extends StatefulWidget {
  @override
  _ListenerPageState createState() => _ListenerPageState();
}

class _ListenerPageState extends State<ListenerPage> {
  static const platform = MethodChannel('bluetooth_server');  // Definindo o channel
  bool _isListening = false;

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
    });

    try {
      // Chama o método Kotlin para iniciar o servidor Bluetooth
      final String result = await platform.invokeMethod('startServer');
      print(result);

      // Aqui você pode lidar com a resposta, que será a confirmação de conexão.
      // Depois disso, você pode usar essa resposta para lidar com a comunicação adicional.

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
            Text(_isListening ? 'Escutando conexões...' : 'Pronto para escutar.'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isListening ? null : _startListening,  // Chama o método para começar a ouvir
              child: Text('Começar a ouvir'),
            ),
          ],
        ),
      ),
    );
  }
}
