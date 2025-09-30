// lib/services/bluetooth_manager.dart
import 'dart:convert';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothManager {
  static final BluetoothManager _instance = BluetoothManager._internal();
  factory BluetoothManager() => _instance;

  BluetoothManager._internal();

  BluetoothConnection? _connection;
  BluetoothDevice? _connectedDevice;

  final List<String> receivedMessages = [];

  BluetoothConnection? get connection => _connection;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // Conecta a um dispositivo (usado no scan_page)
  Future<bool> connect(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _connectedDevice = device;
      _listenIncoming();
      return true;
    } catch (e) {
      print('Erro ao conectar: $e');
      return false;
    }
  }

  // Aceita uma conexão entrante (usado no listener_page)
  void acceptConnection(BluetoothConnection connection, BluetoothDevice device) {
    _connection = connection;
    _connectedDevice = device;
    _listenIncoming();
  }

  // Envia mensagem
  void sendMessage(String message) {
    if (_connection != null && _connection!.isConnected) {
      _connection!.output.add(utf8.encode(message + "\n"));
      _connection!.output.allSent;
    }
  }

  // Escuta mensagens recebidas
  void _listenIncoming() {
    _connection?.input?.listen((data) {
      String received = utf8.decode(data);
      receivedMessages.add(received.trim());
      print("Mensagem recebida: $received");
    }).onDone(() {
      print("Conexão encerrada pelo outro dispositivo");
      _connection = null;
      _connectedDevice = null;
    });
  }

  // Desconecta
  void disconnect() {
    _connection?.dispose();
    _connection = null;
    _connectedDevice = null;
  }
}
