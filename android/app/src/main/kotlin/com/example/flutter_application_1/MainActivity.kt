package com.omnimesh.app

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothServerSocket
import android.bluetooth.BluetoothSocket
import android.os.Bundle
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.util.*
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    private val CHANNEL = "bluetooth_server"
    private val APP_NAME = "OmniMesh"
    private val APP_UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "startServer") {
                startBluetoothServer(result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun startBluetoothServer(result: MethodChannel.Result) {
        val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()

        // Verificar se o Bluetooth está disponível e ativado
        if (bluetoothAdapter == null) {
            result.error("BLUETOOTH_UNAVAILABLE", "Bluetooth não está disponível", null)
            return
        }

        if (!bluetoothAdapter.isEnabled) {
            result.error("BLUETOOTH_DISABLED", "Bluetooth não está ativado", null)
            return
        }

        // Iniciar o servidor Bluetooth em uma thread separada
        thread {
            try {
                // Criar o servidor Bluetooth usando o UUID
                val serverSocket: BluetoothServerSocket = bluetoothAdapter.listenUsingRfcommWithServiceRecord(APP_NAME, APP_UUID)

                // Aguardar até que um dispositivo se conecte
                val socket: BluetoothSocket = serverSocket.accept()

                // Enviar uma resposta ao Flutter informando que a conexão foi bem-sucedida
                runOnUiThread {
                    result.success("Conexão recebida de ${socket.remoteDevice.name}")
                }

                // Aqui, você pode adicionar lógica para ler e escrever mensagens com o dispositivo conectado
                // Por exemplo, iniciar uma thread para ler dados do socket

                // Fechar o socket do servidor após a comunicação
                serverSocket.close()
            } catch (e: IOException) {
                // Em caso de erro ao tentar iniciar o servidor, retornar o erro
                runOnUiThread {
                    result.error("SERVER_ERROR", "Erro ao iniciar servidor Bluetooth: ${e.message}", null)
                }
            }
        }
    }
}
