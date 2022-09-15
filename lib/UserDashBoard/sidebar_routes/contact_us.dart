import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:last_home_auto/utils/show_progress.dart';
import '../../models/user_data.dart';
import '../../utils/show_dialog.dart';
import '/models/company_data.dart';

class Contact extends StatefulWidget {
  final User? user;
  final Function? callbackUser;
  const Contact({Key? key, this.user, this.callbackUser}) : super(key: key);

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> implements CompanyDataContract {
  bool _isLoading = true;
  late String mobile_no;
  late String complain;
  late CompanyDataPresenter _presenter;
  List<Contactor> _contactors = <Contactor>[];
  final message = TextEditingController();
  late ShowDialog _showDialog;

  @override
  void initState() {
    _presenter = new CompanyDataPresenter(this);
    _showDialog = new ShowDialog();
    _getContacts();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getContacts() async {
    await _presenter.doGetContacts();
  }

  _makeCall(contact) async {
    await FlutterPhoneDirectCaller.callNumber(contact);
  }

  _sendMessage(String user_id, String _complain) async {
    await _presenter.doSendComplaint(user_id, _complain);
  }

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
                      child: TextFormField(
                        controller: message,
                        onSaved: (val) => complain = val!,
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
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("cancel")),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                });
                                _sendMessage(widget.user!.userId!, complain);
                              },
                              child: Text("send")),
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Contact us"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.message),
            onPressed: () => showCustomDialog(context),
          ),
        ),
        body:
            _isLoading ? ShowProgress() : createListView(context, _contactors));
  }

  Widget _contactWidget(BuildContext context, Contactor contactor) {
    return Card(
        child: ListTile(
      title: Text(contactor.contactorName!),
      subtitle: Text(contactor.contactorRole!),
      trailing: Icon(Icons.contact_phone),
      leading: IconButton(
        icon: Icon(Icons.call),
        onPressed: () => _makeCall(contactor.contactorMobile),
      ),
    ));
  }

  Widget createListView(BuildContext context, List<Contactor> contactList) {
    return new GridView.count(
      crossAxisCount: 2,
      children:
          contactList.map((value) => _contactWidget(context, value)).toList(),
    );
  }

  @override
  void onCompanyGetContactsError(String error) {
    setState(() {
      _isLoading = false;
    });
    _showDialog.showDialogCustom(context, "Error", error);
  }

  @override
  void onCompanyGetContactsSuccess(List<Contactor>? contactors) {
    setState(() {
      _contactors = contactors!;
      _isLoading = false;
    });
  }

  @override
  void onCompanySendComplaintError(String error) {
    setState(() {
      _isLoading = false;
    });
    _showDialog.showDialogCustom(context, "Error", error);
  }

  @override
  void onCompanySendComplaintSuccess(String message) {
    setState(() {
      _isLoading = false;
    });
    _showDialog.showDialogCustom(context, "success", message);
  }
}
