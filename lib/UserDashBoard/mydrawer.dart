import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blue,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                margin: EdgeInsets.zero,
                accountName: Text("Abdullah"),
                accountEmail: Text("Abdullah@aquapure.com"),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.blue,
                  backgroundImage: AssetImage('assets/images/logo.png'),
                ),
              ),
            ),
            ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Scan for quality'),
                onTap: () {}),
            ListTile(
                leading: const Icon(Icons.devices),
                title: const Text('My Devices'),
                onTap: () {}),
            ListTile(
                leading: const Icon(Icons.miscellaneous_services),
                title: const Text('Service History'),
                onTap: () {}),
            ListTile(
                leading: const Icon(Icons.money),
                title: const Text('Billing'),
                onTap: () {}),
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
