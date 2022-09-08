import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../show_user.dart';
import 'sidebar_routes/goto_myhomes.dart';
import 'sidebar_routes/goto_myrooms.dart';
import 'sidebar_routes/goto_mydevices.dart';

class MyDrawer extends StatefulWidget {
  final User? user;
  final Function? callbackUser;
  const MyDrawer({Key? key, required this.user, this.callbackUser})
      : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState(user!, callbackUser!);
}

class _MyDrawerState extends State<MyDrawer> {
  late User user;
  late Function callbackUser;

  callbackThis(User user) {
    this.callbackUser(user);
    setState(() {
      this.user = user;
    });
  }

  _MyDrawerState(User user, Function callbackUser) {
    this.user = user;
    this.callbackUser = callbackUser;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blue,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                margin: EdgeInsets.zero,
                accountName: Text(widget.user!.name),
                accountEmail: Text(widget.user!.email),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.blue,
                  backgroundImage: AssetImage('assets/images/logo.png'),
                ),
              ),
            ),
            ListTile(
                leading: const Icon(Icons.home),
                title: const Text('My Homes'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) => MyHomes())));
                }),
            ListTile(
                leading: const Icon(Icons.room),
                title: const Text('My Rooms'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) => MyRooms())));
                }),
            ListTile(
                leading: const Icon(Icons.devices),
                title: const Text('My Devices'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) => MyDevices())));
                }),
            ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowUser(
                        user: this.user,
                        callbackUser: this.callbackThis,
                      ),
                    ),
                  );
                }),
            ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share my devices'),
                onTap: () {}),
            ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {}),
            ListTile(
                leading: const Icon(Icons.call),
                title: const Text('Contact us'),
                onTap: () {}),
            ListTile(
                leading: const Icon(Icons.groups),
                title: const Text('Referral Program'),
                onTap: () {}),
            ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Log Out'),
                onTap: () => {}),
          ],
        ),
      ),
    );
  }
}
