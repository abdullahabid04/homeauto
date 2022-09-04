import 'package:flutter/material.dart';
import 'package:last_home_auto/models/home_data.dart';
import 'package:last_home_auto/models/room_data.dart';
import '/models/user_data.dart';
import '../../models/device_data.dart';
import 'home_widget.dart';

class UserHomes extends StatefulWidget {
  final homeList;
  const UserHomes({Key key, this.homeList}) : super(key: key);

  @override
  State<UserHomes> createState() => _UserHomesState();
}

class _UserHomesState extends State<UserHomes> {
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
    return createListView(context, widget.homeList);
  }

  Widget createListView(BuildContext context, List<Home> hmlist) {
    return new GridView.count(
      crossAxisCount: 2,
      // Generate 100 Widgets that display their index in the List
      children: hmlist
          .map((value) => HomeWidget(
                home: value,
              ))
          .toList(),
    );
  }
}
