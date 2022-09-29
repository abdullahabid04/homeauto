import 'package:flutter/material.dart';
import 'package:last_home_auto/models/remote_control.dart';
import 'package:last_home_auto/utils/show_progress.dart';

class DeviceRemote extends StatefulWidget {
  final String device_id;
  const DeviceRemote({Key? key, required this.device_id}) : super(key: key);

  @override
  State<DeviceRemote> createState() => _DeviceRemoteState();
}

class _DeviceRemoteState extends State<DeviceRemote>
    implements DeviceRemoteControlContract {
  bool _isLoading = true;
  late DeviceRemoteControlPresenter _presenter;
  List<Control> _control = <Control>[];
  List<Remote> _remote = <Remote>[];

  @override
  void initState() {
    _presenter = new DeviceRemoteControlPresenter(this);
    _getDeviceRemote();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getDeviceRemote() async {
    await _presenter.doGetRemote(widget.device_id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _isLoading
          ? ShowProgress()
          : createRemote(context, _control, _remote),
    );
  }

  Widget createRemote(BuildContext context, List<Control> listControl,
      List<Remote> listRemote) {
    return new GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisExtent: 175,
        childAspectRatio: 1.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      padding: EdgeInsetsGeometry.lerp(
        EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        5.0,
      ),
      itemCount: listRemote.length,
      itemBuilder: ((context, index) =>
          createPort(context, listControl, listRemote, index)),
    );
  }

  Widget createPort(BuildContext context, List<Control> _controlList,
      List<Remote> _remoteList, int index) {
    return portWidget(context, _controlList[index], _remoteList[index]);
  }

  Widget portWidget(BuildContext context, Control control, Remote remote) {
    return Container(
      child: ClipOval(
        child: Material(
          color: Colors.black12,
          child: Center(
            child: Container(
              child: Center(
                child: Ink.image(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.modulate,
                  ),
                  image: NetworkImage(
                      "https://webstockreview.net/images/button-clipart-power-19.png"),
                  fit: BoxFit.fill,
                  width: 32,
                  height: 32,
                  child: InkWell(onTap: () => {}),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onDeviceRemoteError() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onDeviceRemoteSuccess(DeviceRemoteControl remoteControl) {
    setState(() {
      _control = remoteControl.control!;
      _remote = remoteControl.remote!;
      _isLoading = false;
    });
  }
}
