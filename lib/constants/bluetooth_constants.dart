// lib/constants/bluetooth_constants.dart

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Este é o identificador exclusivo do nosso Serviço de Chat (como se fosse a "porta" principal do OmniMesh)
const String CHAT_SERVICE_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"; 

// 1. Característica de Escrita (Write)
// Usada pelo CLIENTE (ScanPage) para ENVIAR mensagens ao Servidor (ListenerPage).
const String WRITE_CHARACTERISTIC_UUID = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"; 

// 2. Característica de Notificação (Notify)
// Usada pelo SERVIDOR (ListenerPage) para ENVIAR mensagens de volta ao Cliente (ScanPage).
const String NOTIFY_CHARACTERISTIC_UUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"; 

// Converte as strings para o tipo Guid (necessário para a API do flutter_blue_plus)
final Guid chatServiceGuid = Guid(CHAT_SERVICE_UUID);
final Guid writeCharacteristicGuid = Guid(WRITE_CHARACTERISTIC_UUID);
final Guid notifyCharacteristicGuid = Guid(NOTIFY_CHARACTERISTIC_UUID);