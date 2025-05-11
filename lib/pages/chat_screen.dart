import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ChatScreen extends StatefulWidget {
  final BluetoothDevice device;

  ChatScreen({required this.device});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  BluetoothConnection? _connection;
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];
  bool _isConnecting = true;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  void _connectToDevice() async {
    try {
      _connection = await BluetoothConnection.toAddress(widget.device.address);
      setState(() {
        _isConnecting = false;
        _isConnected = true;
      });
      print('Conectado a ${widget.device.name}');

      _connection!.input!.listen((data) {
        String received = utf8.decode(data);
        setState(() {
          _messages.add('👤 ${received.trim()}');
        });
      }).onDone(() {
        print('Desconectado pelo outro dispositivo');
        setState(() {
          _isConnected = false;
        });
      });
    } catch (e) {
      print('Erro na conexão: $e');
      setState(() {
        _isConnecting = false;
      });
    }
  }

  void _sendMessage() {
    String text = _messageController.text.trim();
    if (text.isEmpty || _connection == null || !_connection!.isConnected) return;

    _connection!.output.add(utf8.encode(text + "\n"));
    setState(() {
      _messages.add('📱 Você: $text');
      _messageController.clear();
    });
  }

  @override
  void dispose() {
    _connection?.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name ?? 'Dispositivo'),
      ),
      body: _isConnecting
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(_messages[index]),
                    ),
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
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
