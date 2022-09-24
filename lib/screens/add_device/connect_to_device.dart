import 'dart:async';
import 'dart:convert' show utf8;

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ConnectToDevice extends StatefulWidget {
  @override
  _ConnectToDeviceState createState() => _ConnectToDeviceState();
}

class _ConnectToDeviceState extends State<ConnectToDevice> {
  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String TARGET_DEVICE_NAME = "ESP32-BLE-Server";
  FlutterBlue flutterBlue = FlutterBlue.instance;
  late StreamSubscription<ScanResult> scanSubscription;
  late BluetoothDevice targetDevice;
  BluetoothCharacteristic? targetCharacteristic;
  String connectionText = "";
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    flutterBlue.isScanning.listen((isScanning) {
      _isScanning = isScanning;
    });

    startScan();
  }

  startScan() {
    setState(() {
      connectionText = "Start Scanning";
    });

    scanSubscription =
        flutterBlue.scan(scanMode: ScanMode.lowPower).listen((scanResult) {
      print(scanResult.device.name);
      if (scanResult.device.name.contains(TARGET_DEVICE_NAME)) {
        setState(() {
          connectionText = "Found Target Device";
        });
        targetDevice = scanResult.device;
        stopScan();
        connectToDevice();
      }
    }, onDone: () => stopScan(), cancelOnError: true);
  }

  stopScan() {
    flutterBlue.stopScan();
    scanSubscription.cancel();
  }

  connectToDevice() async {
    if (targetDevice == null) {
      return;
    }
    setState(() {
      connectionText = "Device Connecting";
    });
    await targetDevice.connect();
    setState(() {
      connectionText = "Device Connected";
    });
    discoverServices();
  }

  disconnectFromDeivce() {
    if (targetDevice == null) {
      return;
    }
    targetDevice.disconnect();
    setState(() {
      connectionText = "Device Disconnected";
    });
  }

  discoverServices() async {
    if (targetDevice == null) {
      return;
    }
    List<BluetoothService> services = await targetDevice.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristics) {
          if (characteristics.uuid.toString() == CHARACTERISTIC_UUID) {
            targetCharacteristic = characteristics;
            setState(() {
              connectionText = "All Ready with ${targetDevice.name}";
            });
          }
        });
      }
    });
  }

  writeData(String data) async {
    if (targetCharacteristic == null) {
      return;
    }
    List<int> bytes = utf8.encode(data);
    await targetCharacteristic?.write(bytes);
  }

  readData() async {
    List<int>? bytes;
    bytes = await targetCharacteristic?.read();
    return utf8.decode(bytes!);
  }

  @override
  void dispose() {
    super.dispose();
    stopScan();
  }

  submitAction() {
    String wifiData =
        '${wifiNameController.value.text.toString()},${wifiPasswordController.value.text.toString()}';
    print(wifiData);
    writeData(wifiData);
  }

  TextEditingController wifiNameController = TextEditingController();
  TextEditingController wifiPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(connectionText),
      ),
      body: Container(
          child: targetCharacteristic == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: wifiNameController,
                        decoration:
                            const InputDecoration(labelText: 'Wifi Name'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: wifiPasswordController,
                        decoration:
                            const InputDecoration(labelText: 'Wifi Password'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: FlatButton(
                        onPressed: submitAction,
                        color: Colors.indigoAccent,
                        child: const Text('Submit'),
                      ),
                    )
                  ],
                )),
    );
  }
}
