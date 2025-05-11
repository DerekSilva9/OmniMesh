import 'package:flutter/material.dart';
import 'central_page.dart';
import 'peripheral_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ModeSelectorPage(),
    );
  }
}

class ModeSelectorPage extends StatelessWidget {
  const ModeSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selecione o Modo")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("Modo Scanner (Central)"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CentralPage()), // Remover const aqui
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Modo Anunciante (Periférico)"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PeripheralPage()), // Remover const aqui
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
