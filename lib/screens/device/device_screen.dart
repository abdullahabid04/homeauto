import 'package:flutter/material.dart';
import '/models/user_data.dart';
import '../../models/device_data.dart';
import 'device_widget.dart';

class UserDevices extends StatefulWidget {
  final deviceList;
  const UserDevices({Key key, this.deviceList}) : super(key: key);

  @override
  State<UserDevices> createState() => _UserDevicesState();
}

class _UserDevicesState extends State<UserDevices> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return createListView(context, widget.deviceList);
  }

  Widget createListView(BuildContext context, List<Devices> dvList) {
    return new GridView.count(
      crossAxisCount: 2,
      // Generate 100 Widgets that display their index in the List
      children: dvList
          .map((value) => DeviceWidget(
                device: value,
              ))
          .toList(),
    );
  }
}
