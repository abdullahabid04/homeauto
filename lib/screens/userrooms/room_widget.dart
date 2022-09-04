import 'package:flutter/material.dart';
import '/colors.dart';

class RoomWidget extends StatefulWidget {
  final room;
  const RoomWidget({Key key, this.room}) : super(key: key);

  @override
  State<RoomWidget> createState() => _RoomWidgetState();
}

class _RoomWidgetState extends State<RoomWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: () async {},
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
                      tag: Object(),
                      child: Text(
                        "def",
                        textAlign: TextAlign.left,
                        style: Theme.of(context)
                            .textTheme
                            .headline1
                            .copyWith(fontSize: 17.0),
                      ),
                    ),
                    subtitle: Text(
                      "ghi",
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
                Expanded(
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 40.0,
                        child: FlatButton(
                          onPressed: () async {},
                          child: Icon(Icons.edit),
                        ),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      SizedBox(
                        width: 40.0,
                        child: FlatButton(
                          onPressed: () async {},
                          child: Icon(Icons.delete),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
