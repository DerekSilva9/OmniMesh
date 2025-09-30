import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; 
import 'package:permission_handler/permission_handler.dart'; // NOVO IMPORT
import '../constants/bluetooth_constants.dart';
import 'chat_screen.dart'; 

class ListenerPage extends StatefulWidget {
  const ListenerPage({super.key});

  @override
  State<ListenerPage> createState() => _ListenerPageState();
}

class _ListenerPageState extends State<ListenerPage> {
  static const MethodChannel _serverChannel = MethodChannel('bluetooth_server');
  
  String _status = "Pronto para Escutar.";
  bool _isListening = false;
  
  final StreamController<String> _messageController = StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    _serverChannel.setMethodCallHandler(_handleNativeCall);
  }
  
  @override
  void dispose() {
    _stopListening(); 
    _messageController.close();
    super.dispose();
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    if (!mounted) return; 

    switch (call.method) {
      case 'onClientConnected':
        final String remoteId = call.arguments['remoteId'];
        final String remoteName = call.arguments['remoteName'] ?? 'Desconhecido';
        
        // Versão minimalista que funciona com pacotes FBP antigos
        final connectedDevice = BluetoothDevice(
          remoteId: DeviceIdentifier(remoteId),
        );

        _updateStatus("Conectado a $remoteName como Servidor!");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              device: connectedDevice,
              isGattServer: true, 
              serverChannel: _serverChannel, 
              incomingMessageStream: _messageController.stream, 
            ),
          ),
        );
        break;

      case 'onDataReceived':
        final String message = call.arguments['data'];
        _updateStatus("Recebido (Kotlin): $message");
        _messageController.add(message);
        break;
        
      case 'onClientDisconnected':
         _updateStatus("Cliente desconectado. Aguardando...");
         break;

      case 'updateStatus':
        _updateStatus(call.arguments);
        break;
    }
    return null;
  }

  // NOVO MÉTODO PARA SOLICITAR PERMISSÕES
  Future<bool> _checkAndRequestPermissions() async {
    // Permissões necessárias para Servidor GATT (Android 12/API 31+)
    final permissions = [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse, 
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();

    // Retorna true se todas as essenciais foram concedidas
    return statuses.values.every((status) => status.isGranted);
  }

  Future<void> _startListening() async {
    // PASSO 1: CHECAR E SOLICITAR PERMISSÕES
    if (await _checkAndRequestPermissions() == false) {
      _updateStatus("Permissões de Bluetooth negadas ou não concedidas.");
      return;
    }

    setState(() {
      _isListening = true;
      _status = "Iniciando modo escuta e anúncio BLE...";
    });

    try {
      // PASSO 2: CHAMA O NATIVO APÓS OBTER AS PERMISSÕES
      final bool success = await _serverChannel.invokeMethod('startServer', {
        'serviceUuid': CHAT_SERVICE_UUID,
        'writeCharUuid': WRITE_CHARACTERISTIC_UUID,
        'notifyCharUuid': NOTIFY_CHARACTERISTIC_UUID,
      });

      if (!success) {
        throw Exception("O código nativo retornou falha ao iniciar o Servidor.");
      }
      
      _updateStatus("Servidor GATT Ativo. Anunciando...");

    } on PlatformException catch (e) {
      _updateStatus("Erro Nativo (Android): ${e.message}");
      setState(() => _isListening = false);
    } catch (e) {
       _updateStatus("Erro: ${e.toString()}");
       setState(() => _isListening = false);
    }
  }

  void _stopListening() async {
    try {
      await _serverChannel.invokeMethod('stopServer');
      setState(() {
        _isListening = false;
        _status = "Pronto para Escutar.";
      });
    } catch (e) {
      _updateStatus("Erro ao parar servidor: ${e.toString()}");
    }
  }

  void _updateStatus(String newStatus) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _status = newStatus);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modo Escuta (Servidor)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_tethering, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: _isListening ? Colors.black : Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Text(_isListening ? 'Parar Escuta' : 'Começar a Ouvir'),
            ),
          ],
        ),
      ),
    );
  }
}