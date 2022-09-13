import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import '../../models/user_data.dart';

class Contact extends StatefulWidget {
  final User? user;
  final Function? callbackUser;
  const Contact({Key? key, this.user, this.callbackUser}) : super(key: key);

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  final message = TextEditingController();
  late String mobile_no;

  void showCustomDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            height: 300,
            child: Material(
              child: SizedBox.expand(
                  child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    child: Text("Send Complain"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25),
                    child: Expanded(
                      child: TextField(
                        controller: message,
                        maxLines: 5,
                        minLines: 5,
                        autocorrect: true,
                        autofocus: false,
                        decoration: new InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: BorderSide(
                                color: Colors.greenAccent, width: 3.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: BorderSide(
                                color: Colors.blueAccent, width: 3.0),
                          ),
                          hintText: 'Write your complain here',
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: TextButton(
                              onPressed: () {}, child: Text("cancel")),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child:
                              TextButton(onPressed: () {}, child: Text("send")),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
            ),
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(40)),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: Offset(-1, 0), end: Offset.zero);
        } else {
          tween = Tween(begin: Offset(1, 0), end: Offset.zero);
        }

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }

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
    Size size = MediaQuery.of(context).size;
    return Container(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 50),
        child: Row(children: [
          Expanded(
              child: ElevatedButton(
                  onPressed: () async {
                    await FlutterPhoneDirectCaller.callNumber(mobile_no);
                  },
                  child: Text("Call"))),
          Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
          Expanded(
              child: ElevatedButton(
                  onPressed: () {
                    showCustomDialog(context);
                  },
                  child: Text("Message"))),
        ]),
      ),
    );
  }
}
