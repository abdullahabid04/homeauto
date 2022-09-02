import 'package:flutter/material.dart';
import '/models/user_data.dart';
import '/screens/device/device_data.dart';
import '/screens/device/device.dart';

class DashBoard extends StatefulWidget {
  final deviceList;
  const DashBoard({Key key, this.deviceList}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
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
