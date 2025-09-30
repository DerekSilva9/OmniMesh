import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/bluetooth_manager.dart';

class ChatScreen extends StatefulWidget {
  final dynamic device; // Use BluetoothDevice se possível
  ChatScreen({required this.device, Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<String> _messages = [];
  late BluetoothManager _btManager;

  @override
  void initState() {
    super.initState();
    _btManager = BluetoothManager();
    _messages = List.from(_btManager.receivedMessages);

    _btManager.connection?.input?.listen((data) {
      String received = utf8.decode(data);
      setState(() {
        _messages.add('👤 ${received.trim()}');
      });
    });
  }

  void _sendMessage() {
    String text = _messageController.text.trim();
    if (text.isEmpty) return;
    _btManager.sendMessage(text);
    setState(() {
      _messages.add('📱 Você: $text');
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.device.name ?? 'Dispositivo')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder:
                  (context, index) => ListTile(title: Text(_messages[index])),
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Colors.deepPurple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
