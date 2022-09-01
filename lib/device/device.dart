import 'package:flutter/material.dart';
import '/colors.dart';

class Device extends StatefulWidget {
  const Device({Key key}) : super(key: key);

  @override
  State<Device> createState() => _DeviceState();
}

class _DeviceState extends State<Device> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () async {
          // await getInternetAccessObject();
          // if (internetAccess) {
          //   setState(() {
          //     _timerStatus = 0;
          //   });
          //   await Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => DeviceStatusScreen(
          //           user: this.user,
          //           room: widget.room,
          //           device: dvList[index],
          //           updateDeviceList: this.updateDeviceList),
          //     ),
          //   );
          //   setState(() {
          //     _isLoading = true;
          //     _timerStatus = 1;
          //   });
          //   getDeviceList();
          // } else {
          //   this._showDialog.showDialogCustom(
          //       context,
          //       "Internet Connection Problem",
          //       "Please check your internet connection",
          //       fontSize: 17.0,
          //       boxHeight: 58.0);
          // }
        },
        splashColor: kHAutoBlue300,
        child: Container(
          padding:
              EdgeInsets.only(left: 10.0, top: 20.0, bottom: 20.0, right: 10.0),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: ListTile(
                    title: Hero(
                      tag: "abc",
                      child: Text(
                        "txt",
                        textAlign: TextAlign.left,
                        style: Theme.of(context)
                            .textTheme
                            .headline1
                            .copyWith(fontSize: 17.0),
                      ),
                    ),
                    subtitle: Text(
                      "txt",
                      style: TextStyle(
                        fontSize: 13.0,
                      ),
                    ),
                    trailing: new Container(
                      width: 10.0,
                      height: 10.0,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40.0,
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 40.0,
                      child: FlatButton(
                        onPressed: () async {
                          // await getInternetAccessObject();
                          // if (internetAccess) {
                          //   Map dvDetails = new Map();
                          //   dvDetails = dvList[index].toMap();
                          //   dvDetails['isModifying'] = true;
                          //   setState(() {
                          //     _timerStatus = 0;
                          //   });
                          //   final result = await Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => GetDeviceDetails(
                          //         hardware: widget.hardware,
                          //         deviceList: dvList,
                          //         dvDetails: dvDetails,
                          //         imgList: dvImgList,
                          //       ),
                          //     ),
                          //   );
                          //   setState(() {
                          //     _timerStatus = 1;
                          //   });
                          //   print(result.toString());
                          //   if (result != null && !result['error']) {
                          //     setState(() {
                          //       _isLoading = true;
                          //     });
                          //     _renameDevice(dvList[index], result['dvName'],
                          //         result['dvImg'], result['dvPort']);
                          //   }
                          // } else {
                          //   this._showDialog.showDialogCustom(
                          //       context,
                          //       "Internet Connection Problem",
                          //       "Please check your internet connection",
                          //       fontSize: 17.0,
                          //       boxHeight: 58.0);
                          // }
                        },
                        child: Icon(Icons.edit),
                      ),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    SizedBox(
                      width: 40.0,
                      child: FlatButton(
                        onPressed: () async {
                          // await _deleteDevice(dvList[index]);
                        },
                        child: Icon(Icons.delete),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
