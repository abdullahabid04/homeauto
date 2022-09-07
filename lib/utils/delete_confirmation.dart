import 'package:flutter/material.dart';

class DeleteConfirmation {
  Future<bool> showConfirmDialog(BuildContext context,
      {title = "Are you sure?"}) async {
    bool status = false;
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Container(
          child: Text('$title'),
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
                status = false;
              }),
          new FlatButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context);
              status = true;
            },
          )
        ],
      ),
    );
    return status;
  }
}
