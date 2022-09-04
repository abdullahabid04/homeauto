import 'package:flutter/material.dart';
import 'package:last_home_auto/models/room_data.dart';
import '/models/user_data.dart';
import '../../models/device_data.dart';
import 'room_widget.dart';

class UserRooms extends StatefulWidget {
  final roomList;
  const UserRooms({Key key, this.roomList}) : super(key: key);

  @override
  State<UserRooms> createState() => _UserRoomsState();
}

class _UserRoomsState extends State<UserRooms> {
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
    return createListView(context, widget.roomList);
  }

  Widget createListView(BuildContext context, List<Room> roomList) {
    return new GridView.count(
      crossAxisCount: 2,
      // Generate 100 Widgets that display their index in the List
      children: roomList
          .map((value) => RoomWidget(
                room: value,
              ))
          .toList(),
    );
  }
}
