import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class PairedDevicesPage extends StatefulWidget {
  @override
  _PairedDevicesPageState createState() => _PairedDevicesPageState();
}

class _PairedDevicesPageState extends State<PairedDevicesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dispositivos Pareados')),
      body: Center(
        child: Text(
          'Função de dispositivos pareados precisa ser adaptada para flutter_blue_plus',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
