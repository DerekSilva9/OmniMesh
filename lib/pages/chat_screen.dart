import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para o MethodChannel (Modo Servidor)
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; 
import '../constants/bluetooth_constants.dart'; // Seus UUIDs

class ChatScreen extends StatefulWidget {
  // Parâmetros base
  final BluetoothDevice device; 
  
  // Parâmetros do Modo Servidor (passados pela ListenerPage)
  final bool isGattServer;
  final MethodChannel? serverChannel;
  final Stream<String>? incomingMessageStream;

  const ChatScreen({
    super.key,
    required this.device,
    this.isGattServer = false,
    this.serverChannel,
    this.incomingMessageStream,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];
  String _status = 'Conectando...';

  // Componentes BLE (apenas para o Modo Cliente)
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _notifyCharacteristic;
  StreamSubscription? _bleSubscription;
  StreamSubscription? _serverStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initializeChatMode();
  }

  @override
  void dispose() {
    _bleSubscription?.cancel();
    _serverStreamSubscription?.cancel();
    _messageController.dispose();
    // Opcional: desconectar do BLE se estiver no modo cliente
    // if (!widget.isGattServer) widget.device.disconnect(); 
    super.dispose();
  }

  // --- LÓGICA DE INICIALIZAÇÃO DE MODO ---

  void _initializeChatMode() {
    if (widget.isGattServer) {
      _initializeServerMode();
    } else {
      _initializeClientMode();
    }
  }

  // MODO CLIENTE (Conecta e configura características FBP)
  Future<void> _initializeClientMode() async {
    _updateStatus('Procurando Serviço BLE...');
    try {
      // 1. Descobrir Serviços
      final services = await widget.device.discoverServices();
      final service = services.firstWhere((s) => s.uuid == chatServiceGuid);

      // 2. Encontrar Características (WRITE para enviar, NOTIFY para receber)
      _writeCharacteristic = service.characteristics.firstWhere(
        (c) => c.uuid == writeCharacteristicGuid,
      );
      _notifyCharacteristic = service.characteristics.firstWhere(
        (c) => c.uuid == notifyCharacteristicGuid,
      );

      // 3. Habilitar Notificações para receber mensagens do Servidor
      await _notifyCharacteristic!.setNotifyValue(true);
      
      // 4. Escutar mensagens do Servidor
      _bleSubscription = _notifyCharacteristic!.lastValueStream.listen((value) {
        if (value.isNotEmpty) {
          final messageText = utf8.decode(value);
          _handleIncomingMessage(messageText, false); // Recebido do par
        }
      });
      
      _updateStatus('Cliente pronto: ${widget.device.platformName}');

    } catch (e) {
      _updateStatus('Erro no Cliente BLE. Tente reconectar: ${e.toString()}');
    }
  }

  // MODO SERVIDOR (Escuta o Stream vindo da ListenerPage)
  void _initializeServerMode() {
    if (widget.incomingMessageStream != null) {
      // Escutar o stream vindo da ListenerPage (que recebe do Kotlin)
      _serverStreamSubscription = widget.incomingMessageStream!.listen((messageText) {
        _handleIncomingMessage(messageText, false); // Recebido do par
      });
      _updateStatus('Servidor pronto: Aguardando mensagens...');
    } else {
      _updateStatus('Erro: Stream de entrada não fornecido.');
    }
  }
  
  // --- LÓGICA DE MENSAGENS ---

  void _handleIncomingMessage(String text, bool isSelf) {
    String prefix = isSelf ? '📱 Você' : '👤 ${widget.device.platformName}';
    
    // Usamos WidgetsBinding para garantir que o setState ocorra após o listen
    WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
            _messages.add('$prefix: $text');
        });
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final messageBytes = utf8.encode(text);
    _messageController.clear();
    
    try {
      if (widget.isGattServer) {
        // MODO SERVIDOR: Envia via MethodChannel para o Kotlin (que usa NOTIFY)
        if (widget.serverChannel == null) throw Exception("Server channel não está disponível.");
        
        await widget.serverChannel!.invokeMethod('sendData', {
          'data': messageBytes,
          'characteristicUuid': NOTIFY_CHARACTERISTIC_UUID, // Notifica o Cliente
        });
        
      } else {
        // MODO CLIENTE: Envia via flutter_blue_plus (escreve no WRITE Characteristic do Servidor)
        if (_writeCharacteristic == null) throw Exception("Write Characteristic não encontrado.");
        
        // Escreve os bytes. using withoutResponse: true para ser mais rápido.
        await _writeCharacteristic!.write(messageBytes, withoutResponse: true);
      }
      
      // Adiciona a mensagem à lista local após o envio BLE
      _handleIncomingMessage(text, true);
      _updateStatus("Mensagem enviada.");

    } catch (e) {
      _updateStatus("Erro ao enviar via BLE: ${e.toString()}");
    }
  }
  
  void _updateStatus(String newStatus) {
    if (mounted) {
      setState(() => _status = newStatus);
    }
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.platformName.isEmpty ? 'Chat com ${widget.device.remoteId.str}' : 'Chat com ${widget.device.platformName}'),
        backgroundColor: widget.isGattServer ? Colors.deepPurple.shade700 : Colors.blue.shade700,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                widget.isGattServer ? 'SERVIDOR' : 'CLIENTE', 
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Status Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(_status, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          
          // Lista de Mensagens
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.startsWith('📱');
                
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(message),
                  ),
                );
              },
            ),
          ),
          
          // Input de Mensagem
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  child: const Icon(Icons.send),
                  backgroundColor: Colors.deepPurple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}