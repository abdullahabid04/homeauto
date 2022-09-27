import 'package:flutter/material.dart';
import 'package:last_home_auto/utils/api_response.dart';
import '../../UserDashBoard/sidebar_routes/goto_mydevices.dart';
import '../../constants/colors.dart';
import '../../models/home_data.dart';
import '../../models/manufactured_products.dart';
import '../../models/room_data.dart';
import '../../userpreferances/user_preferances.dart';
import '/models/device_data.dart';

class AddDevice extends StatefulWidget {
  final Products product;
  final String device_id;
  final Home home;
  final Room room;
  const AddDevice(
      {Key? key,
      required this.product,
      required this.device_id,
      required this.home,
      required this.room})
      : super(key: key);

  @override
  State<AddDevice> createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> implements CreateDeviceContract {
  bool _isLoading = false;
  String user_id = UserSharedPreferences.getUserUniqueId() ?? "";
  late CreateDevicePresenter _presenter;
  TextEditingController _controller = new TextEditingController();
  String deviceName = "";

  @override
  void initState() {
    _presenter = new CreateDevicePresenter(this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _createNewDevice(String device_name) async {
    _presenter.doCreateDevice(user_id, widget.home.homeId!, widget.room.roomId!,
        widget.device_id, device_name, widget.product.deviceType!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Device")),
      body: Container(
        alignment: Alignment.center,
        child: Center(
          child: Container(
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.devices,
                    ),
                    hintText: "Device name",
                    contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(
                  height: 25,
                ),
                RaisedButton(
                  color: kHAutoBlue300,
                  onPressed: () {
                    setState(() {
                      deviceName = _controller.value.text.toString();
                      _isLoading = true;
                    });
                    _createNewDevice(deviceName);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onCreateDeviceError() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onCreateDeviceSuccess(ResponseDataAPI userDetails) {
    setState(() {
      _isLoading = false;
    });
    Future.delayed(
      Duration(milliseconds: 500),
    );
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute(builder: (BuildContext context) => MyDevices()),
      ((route) => false),
    );
  }
}
