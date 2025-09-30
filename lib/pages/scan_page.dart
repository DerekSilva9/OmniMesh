// lib/pages/scan_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  void initState() {
    super.initState();
    // Inicia a varredura automaticamente (pode pedir permissão de Localização aqui)
    _startScan();
  }

  void _startScan() async {
    // Para garantir que nenhuma varredura anterior esteja ativa
    await FlutterBluePlus.stopScan(); 
    
    // Inicia a varredura por 10 segundos
    // O 'withServices' pode ser adicionado depois para filtrar apenas o seu chat service
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10)); 
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan(); // Garante que a varredura pare ao sair da página
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Indicador de Progresso (StreamBuilder<bool> monitora se está escaneando)
        StreamBuilder<bool>(
          stream: FlutterBluePlus.isScanning,
          initialData: false,
          builder: (context, snapshot) {
            final isScanning = snapshot.data ?? false;
            if (isScanning) {
              return const LinearProgressIndicator(color: Colors.deepPurple);
            } else {
              // Botão de Rescanear
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: _startScan, 
                  icon: const Icon(Icons.refresh),
                  label: const Text("Escanear Novamente"),
                ),
              );
            }
          },
        ),

        // 2. Lista de Resultados (StreamBuilder<List<ScanResult>> lista os dispositivos)
        Expanded(
          child: StreamBuilder<List<ScanResult>>(
            stream: FlutterBluePlus.scanResults,
            initialData: const [],
            builder: (context, snapshot) {
              final results = snapshot.data!;
              if (results.isEmpty) {
                return const Center(child: Text("Nenhum dispositivo encontrado."));
              }
              
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  // Filtra resultados sem nome para uma lista mais limpa
                  final name = result.device.platformName.isNotEmpty 
                                  ? result.device.platformName
                                  : (result.advertisementData.localName.isNotEmpty 
                                     ? result.advertisementData.localName
                                     : 'Dispositivo Desconhecido');
                  
                  // Se o dispositivo não tem nome, ignoramos.
                  if (name == 'Dispositivo Desconhecido') {
                      return const SizedBox.shrink();
                  }

                  return ListTile(
                    title: Text(name),
                    subtitle: Text("ID: ${result.device.remoteId} | Sinal: ${result.rssi} dBm"),
                    onTap: () {
                      // **PRÓXIMO PASSO: INICIAR A CONEXÃO**
                      print("Tentar conectar a: $name");
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}