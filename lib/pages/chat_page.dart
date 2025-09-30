import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // ADICIONADO
import 'chat_screen.dart'; // Tela real de chat

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // List<BluetoothDevice> _devices = []; // COMENTE OU REMOVA
  // OBTENÇÃO DE DISPOSITIVOS PAREADOS PRECISA SER ADAPTADA PARA flutter_blue_plus

  @override
  void initState() {
    super.initState();
    // _loadPairedDevices(); // COMENTE OU REMOVA
  }

  // Future<void> _loadPairedDevices() async {
  //   List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
  //   setState(() {
  //     _devices = devices;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contatos Pareados')),
      body: Center(
        child: Text(
          'Função de dispositivos pareados precisa ser adaptada para flutter_blue_plus',
          textAlign: TextAlign.center,
        ),
      ),
      // O código abaixo foi comentado pois depende da API antiga
      // body: _devices.isEmpty
      //     ? Center(child: Text('Nenhum dispositivo pareado encontrado'))
      //     : ListView.builder(
      //         itemCount: _devices.length,
      //         itemBuilder: (context, index) {
      //           final device = _devices[index];
      //           return ListTile(
      //             leading: Icon(Icons.person),
      //             title: Text(device.name ?? 'Desconhecido'),
      //             subtitle: Text(device.address),
      //             onTap: () {
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (context) => ChatScreen(device: device),
      //                 ),
      //               );
      //             },
      //           );
      //         },
      //       ),
    );
  }
}
