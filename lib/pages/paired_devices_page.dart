import 'package:flutter/material.dart';

class PairedDevicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Paired Devices')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('List of paired devices'),
            // Aqui você pode listar os dispositivos Bluetooth pareados.
          ],
        ),
      ),
    );
  }
}
