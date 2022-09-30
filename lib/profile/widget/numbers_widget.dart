import 'package:flutter/material.dart';

class NumbersWidget extends StatelessWidget {
  final int device_count;
  final int room_count;
  final int home_count;

  const NumbersWidget(
      {super.key,
      required this.device_count,
      required this.room_count,
      required this.home_count});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildButton(context, '${device_count.toString()}', 'Total Devices'),
          buildDivider(),
          buildButton(context, '${room_count.toString()}', 'Total Rooms'),
          buildDivider(),
          buildButton(context, '${home_count.toString()}', 'Total Homes'),
        ],
      );
  Widget buildDivider() => Container(
        height: 24,
        child: VerticalDivider(),
      );

  Widget buildButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
}
