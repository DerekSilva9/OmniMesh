// lib/services/bluetooth_manager.dart
import 'dart:convert';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'; // REMOVIDO
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // ADICIONADO

class BluetoothManager {
  static final BluetoothManager _instance = BluetoothManager._internal();
  factory BluetoothManager() => _instance;

  BluetoothManager._internal();

  final List<String> receivedMessages = [];

  // Adicione este método temporariamente:
  void sendMessage(String message) {
    // TODO: Implementar envio usando flutter_blue_plus
    print('Mensagem enviada (stub): $message');
  }
}
