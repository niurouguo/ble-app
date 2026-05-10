import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE 智能药盒',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  BluetoothDevice? connectedDevice;
  
  String temperature = '--';
  String humidity = '--';
  String medicineRemaining = '--';
  String connectionStatus = '未连接';
  bool isConnecting = false;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.nearbyWifiDevices,
    ].request();
  }

  Future<void> connectToDevice() async {
    setState(() {
      isConnecting = true;
      connectionStatus = '正在连接...';
    });

    try {
      // Start scanning
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
      
      // Listen for scan results
      FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult result in results) {
          // Target device MAC: C2:38:B1:17:AA:FC
          if (result.device.remoteId.toString().toUpperCase() == 'C2:38:B1:17:AA:FC') {
            await FlutterBluePlus.stopScan();
            await connectDevice(result.device);
            break;
          }
        }
      });

      // Timeout handling
      await Future.delayed(const Duration(seconds: 6));
      if (!isConnected) {
        setState(() {
          connectionStatus = '连接超时，请重试';
          isConnecting = false;
        });
      }
    } catch (e) {
      setState(() {
        connectionStatus = '连接失败: $e';
        isConnecting = false;
      });
    }
  }

  Future<void> connectDevice(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 10));
      
      setState(() {
        connectedDevice = device;
        isConnected = true;
        isConnecting = false;
        connectionStatus = '已连接: ${device.remoteId}';
      });

      // Discover services
      List<BluetoothService> services = await device.discoverServices();
      
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.properties.notify || characteristic.properties.read) {
            await characteristic.setNotifyValue(true);
            characteristic.value.listen((value) {
              String data = String.fromCharCodes(value);
              parseData(data);
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        connectionStatus = '连接错误: $e';
        isConnecting = false;
      });
    }
  }

  void parseData(String rawData) {
    try {
      Map<String, dynamic> data = jsonDecode(rawData);
      setState(() {
        temperature = data['temp']?.toString() ?? '--';
        humidity = data['humidity']?.toString() ?? '--';
        medicineRemaining = data['weight']?.toString() ?? '--';
      });
    } catch (e) {
      print('JSON解析错误: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE 智能药盒监控'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                      size: 48,
                      color: isConnected ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      connectionStatus,
                      style: TextStyle(
                        fontSize: 16,
                        color: isConnected ? Colors.green : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Data Display Cards
            _buildDataCard('温度', '$temperature °C', Icons.thermostat, Colors.orange),
            const SizedBox(height: 15),
            _buildDataCard('湿度', '$humidity %', Icons.water_drop, Colors.blue),
            const SizedBox(height: 15),
            _buildDataCard('药品余量', '$medicineRemaining g', Icons.medication, Colors.green),
            
            const Spacer(),
            
            // Connect Button
            ElevatedButton.icon(
              onPressed: isConnecting ? null : connectToDevice,
              icon: isConnecting 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.bluetooth_searching),
              label: Text(
                isConnecting ? '连接中...' : (isConnected ? '重新连接' : '连接设备'),
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: isConnected ? Colors.green : Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    connectedDevice?.disconnect();
    super.dispose();
  }
}
