import 'dart:async';
import 'dart:convert' show utf8;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:last_home_auto/screens/add_device/select_home_for_device.dart';
import '../../constants/colors.dart';
import '../../utils/show_progress.dart';
import '/models/manufactured_products.dart';
import '/models/get_device_unique_id.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

class ConnectToDevice extends StatefulWidget {
  final Products product;

  const ConnectToDevice({super.key, required this.product});
  @override
  _ConnectToDeviceState createState() => _ConnectToDeviceState();
}

class _ConnectToDeviceState extends State<ConnectToDevice>
    implements DeviceIdContracor {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late DeviceIdPresenter _presenter;
  final NetworkInfo _info = NetworkInfo();
  TextEditingController wifiNameController = TextEditingController();
  TextEditingController wifiPasswordController = TextEditingController();
  late TextEditingValue _value;
  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  late final String TARGET_DEVICE_NAME;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult>? scanSubscription;
  late BluetoothDevice targetDevice;
  BluetoothCharacteristic? targetCharacteristic;
  String connectionText = "";
  late String? wifiName;
  late String _deviceId;
  bool _isLoading = false;
  bool _isProcessing = true;

  @override
  void initState() {
    _presenter = new DeviceIdPresenter(this);
    getDeviceUniqueId();
    checkWiFiConnectivity();
    TARGET_DEVICE_NAME = widget.product.deviceBtName!;
    startScan();
    super.initState();
  }

  @override
  void dispose() {
    stopScan();
    super.dispose();
  }

  getDeviceUniqueId() async {
    await _presenter.doGetDeviceId();
  }

  checkWiFiConnectivity() async {
    _connectionStatus = await _connectivity.checkConnectivity();
    if (_connectionStatus == ConnectivityResult.wifi) {
      initConnectivity();
      checkWiFiInfo();
    }
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;

    try {
      result = await _connectivity.checkConnectivity();
    } on Exception catch (e) {
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  checkWiFiInfo() async {
    wifiName = await _info.getWifiName();
    _setWiFiNameValue();
  }

  _setWiFiNameValue() {
    String filteredWiFiName = wifiName!.replaceAll('"', '');
    _value = TextEditingValue(text: filteredWiFiName);
    wifiNameController.value = _value;
  }

  startScan() {
    setState(() {
      connectionText = "Start scanning";
    });

    scanSubscription = flutterBlue
        .scan(
      scanMode: ScanMode.lowPower,
      timeout: Duration(seconds: 10),
    )
        .listen((scanResult) {
      print(scanResult.device.name);
      if (scanResult.device.name.contains(TARGET_DEVICE_NAME)) {
        setState(() {
          connectionText = "Found Target Device";
        });
        targetDevice = scanResult.device;
        stopScan();
        connectToDevice();
      }
    }, onDone: stopScan(), onError: stopScan(), cancelOnError: true);
  }

  stopScan() {
    flutterBlue.stopScan();
    scanSubscription?.cancel();
    scanSubscription = null;
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

  submitAction() {
    String wifiData =
        '${wifiNameController.value.text.toString()},${wifiPasswordController.value.text.toString()},${_deviceId}';
    print(wifiData);
    writeData(wifiData);
    Future.delayed(Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(connectionText),
      ),
      body: _isLoading
          ? ShowProgress()
          : Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                      "WiFi Credentials",
                      style: TextStyle(
                        fontSize: 20.0,
                        letterSpacing: 3.0,
                        wordSpacing: 5.0,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: wifiNameController,
                        decoration: new InputDecoration(
                          hintText: "WiFi Name",
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                          prefixIcon: Icon(
                            Icons.person_outline,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: wifiPasswordController,
                        decoration: new InputDecoration(
                          hintText: "WiFi Password",
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                          prefixIcon: Icon(
                            Icons.person_outline,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: FlatButton(
                        onPressed: () {
                          submitAction();
                          Future.delayed(
                            Duration(seconds: 1),
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: ((context) => SelectHomeForDevice(
                                    product: widget.product,
                                    device_id: _deviceId,
                                  )),
                            ),
                          );
                        },
                        color: kHAutoBlue50,
                        child: const Text('Submit'),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void onDeviceIdError(String error) {
    setState(() {
      _isProcessing = false;
    });
  }

  @override
  void onDeviceIdSuccess(String device_id) {
    setState(() {
      _deviceId = device_id;
      _isProcessing = false;
    });
  }
}
