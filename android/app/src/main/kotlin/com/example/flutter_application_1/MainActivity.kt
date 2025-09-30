package com.omnimesh.app

import android.bluetooth.*
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.bluetooth.le.BluetoothLeAdvertiser
import android.content.Context
import android.os.ParcelUuid
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "bluetooth_server"
    private val TAG = "OmniMeshGATTServer"
    
    // Serviço Bluetooth
    private var bluetoothGattServer: BluetoothGattServer? = null
    private var bluetoothLeAdvertiser: BluetoothLeAdvertiser? = null
    private var flutterChannel: MethodChannel? = null
    
    // Variáveis para armazenar as características GATT
    private var writeCharacteristic: BluetoothGattCharacteristic? = null
    private var notifyCharacteristic: BluetoothGattCharacteristic? = null

    // Variável para armazenar o dispositivo conectado (para poder enviar notificações)
    private var connectedDevice: BluetoothDevice? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flutterChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        flutterChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startServer" -> {
                    // Espera os UUIDs definidos no Dart
                    val serviceUuidStr = call.argument<String>("serviceUuid") ?: ""
                    val writeCharUuidStr = call.argument<String>("writeCharUuid") ?: ""
                    val notifyCharUuidStr = call.argument<String>("notifyCharUuid") ?: ""
                    
                    startGattServer(serviceUuidStr, writeCharUuidStr, notifyCharUuidStr, result)
                }
                "stopServer" -> {
                    stopGattServer()
                    result.success(true)
                }
                "sendData" -> {
                    val data = call.argument<ByteArray>("data")
                    val characteristicUuidStr = call.argument<String>("characteristicUuid")
                    if (data != null && characteristicUuidStr != null) {
                        sendDataToClient(data, characteristicUuidStr)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGS", "Dados ou UUID de Característica inválidos.", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startGattServer(serviceUuidStr: String, writeCharUuidStr: String, notifyCharUuidStr: String, result: MethodChannel.Result) {
        val bluetoothManager: BluetoothManager? = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager?
        val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()

        if (bluetoothManager == null || bluetoothAdapter == null || !bluetoothAdapter.isEnabled) {
            result.error("BLUETOOTH_UNAVAILABLE", "Bluetooth indisponível ou desativado.", null)
            return
        }
        
        try {
            // 1. Criar o Servidor GATT
            bluetoothGattServer = bluetoothManager.openGattServer(this, gattServerCallback)

            // 2. Criar o Serviço e as Características
            val serviceUUID = UUID.fromString(serviceUuidStr)
            val writeUUID = UUID.fromString(writeCharUuidStr)
            val notifyUUID = UUID.fromString(notifyCharUuidStr)
            
            val chatService = BluetoothGattService(serviceUUID, BluetoothGattService.SERVICE_TYPE_PRIMARY)

            // Característica de ESCREVER (Recebe dados do Cliente)
            writeCharacteristic = BluetoothGattCharacteristic(
                writeUUID, 
                BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE,
                BluetoothGattCharacteristic.PERMISSION_WRITE
            )
            chatService.addCharacteristic(writeCharacteristic)
            
            // Característica de NOTIFICAR (Envia dados para o Cliente)
            notifyCharacteristic = BluetoothGattCharacteristic(
                notifyUUID, 
                BluetoothGattCharacteristic.PROPERTY_NOTIFY,
                BluetoothGattCharacteristic.PERMISSION_READ
            )
            // Descriptor Cliente Configuration (necessário para NOTIFY)
            notifyCharacteristic?.addDescriptor(
                BluetoothGattDescriptor(UUID.fromString("00002902-0000-1000-8000-00805f9b34fb"), 
                    BluetoothGattDescriptor.PERMISSION_WRITE or BluetoothGattDescriptor.PERMISSION_READ)
            )
            chatService.addCharacteristic(notifyCharacteristic)
            
            // 3. Adicionar o Serviço ao Servidor
            bluetoothGattServer?.addService(chatService)

            // 4. Iniciar Anúncio BLE (Advertising)
            bluetoothLeAdvertiser = bluetoothAdapter.bluetoothLeAdvertiser
            startAdvertising(serviceUUID)
            
            result.success(true)
            
        } catch (e: Exception) {
            Log.e(TAG, "Erro ao configurar Servidor GATT: ${e.message}")
            result.error("GATT_ERROR", "Erro ao configurar Servidor GATT: ${e.message}", null)
        }
    }

    private fun startAdvertising(serviceUUID: UUID) {
        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_BALANCED)
            .setConnectable(true)
            .setTimeout(0) // Anúncio infinito
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_MEDIUM)
            .build()

        val data = AdvertiseData.Builder()
            .setIncludeDeviceName(true)
            .addServiceUuid(ParcelUuid(serviceUUID))
            .build()
            
        bluetoothLeAdvertiser?.startAdvertising(settings, data, advertiseCallback)
        Log.i(TAG, "Iniciando Anúncio BLE...")
    }

    private fun stopGattServer() {
        bluetoothLeAdvertiser?.stopAdvertising(advertiseCallback)
        bluetoothGattServer?.close()
        bluetoothGattServer = null
        connectedDevice = null
        Log.i(TAG, "Servidor BLE parado.")
    }
    
    private val advertiseCallback = object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings) {
            Log.i(TAG, "Anúncio BLE iniciado com sucesso")
            flutterChannel?.invokeMethod("updateStatus", "Anúncio BLE iniciado.")
        }

        override fun onStartFailure(errorCode: Int) {
            Log.e(TAG, "Falha ao iniciar anúncio: $errorCode")
            flutterChannel?.invokeMethod("updateStatus", "Falha no Anúncio BLE: $errorCode")
        }
    }

    private val gattServerCallback = object : BluetoothGattServerCallback() {
        override fun onConnectionStateChange(device: BluetoothDevice, status: Int, newState: Int) {
            super.onConnectionStateChange(device, status, newState)
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                Log.i(TAG, "Cliente conectado: ${device.name}")
                connectedDevice = device
                // Notifica o Flutter sobre a conexão
                flutterChannel?.invokeMethod("onClientConnected", mapOf(
                    "remoteId" to device.address,
                    "remoteName" to (device.name ?: "Desconhecido")
                ))
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                Log.i(TAG, "Cliente desconectado: ${device.name}")
                connectedDevice = null
                flutterChannel?.invokeMethod("updateStatus", "Cliente desconectado. Aguardando...")
            }
        }

        override fun onCharacteristicWriteRequest(device: BluetoothDevice, requestId: Int, characteristic: BluetoothGattCharacteristic, preparedWrite: Boolean, responseNeeded: Boolean, offset: Int, value: ByteArray) {
            super.onCharacteristicWriteRequest(device, requestId, characteristic, preparedWrite, responseNeeded, offset, value)
            
            if (characteristic.uuid == writeCharacteristic?.uuid) {
                val message = String(value, Charsets.UTF_8)
                Log.i(TAG, "Dados recebidos do cliente: $message")
                
                // 1. Responde à requisição de escrita (necessário para algumas operações)
                bluetoothGattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, offset, value)
                
                // 2. Notifica o Flutter que a mensagem chegou
                flutterChannel?.invokeMethod("onDataReceived", mapOf(
                    "data" to message, 
                    "deviceAddress" to device.address
                ))
            }
        }

        override fun onDescriptorWriteRequest(device: BluetoothDevice?, requestId: Int, descriptor: BluetoothGattDescriptor?, preparedWrite: Boolean, responseNeeded: Boolean, offset: Int, value: ByteArray?) {
            super.onDescriptorWriteRequest(device, requestId, descriptor, preparedWrite, responseNeeded, offset, value)
            // Se o cliente escreve no descriptor 0x2902 (CCCD), ele está HABILITANDO notificações
            if (descriptor?.uuid == UUID.fromString("00002902-0000-1000-8000-00805f9b34fb")) {
                val enabled = value?.get(0)?.toInt() == 1
                Log.i(TAG, "Notificações para ${device?.name} ${if (enabled) "habilitadas" else "desabilitadas"}")
                // Responde ao cliente
                if (responseNeeded) {
                    bluetoothGattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, null)
                }
            }
        }
    }
    
    // Função para enviar dados do Servidor (Kotlin) para o Cliente (Flutter Blue Plus)
    private fun sendDataToClient(data: ByteArray, characteristicUuidStr: String) {
        if (connectedDevice == null || bluetoothGattServer == null) {
            Log.w(TAG, "Nenhum cliente conectado para enviar dados.")
            return
        }
        
        // Atualmente, apenas suportamos NOTIFY (enviar dados)
        val characteristic = notifyCharacteristic 

        if (characteristic != null) {
            characteristic.value = data
            // Envia a notificação
            bluetoothGattServer?.notifyCharacteristicChanged(connectedDevice, characteristic, false)
            Log.i(TAG, "Dados enviados via NOTIFY para ${connectedDevice?.name}")
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        stopGattServer()
    }
}
