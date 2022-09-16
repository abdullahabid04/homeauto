import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:last_home_auto/utils/show_progress.dart';
import '../../models/user_data.dart';
import '../../utils/internet_access.dart';
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
  String _complain = "";
  late CompanyDataPresenter _presenter;
  List<Contactor> _contactors = <Contactor>[];
  final message = TextEditingController();
  late ShowDialog _showDialog;
  var complainFormKey = GlobalKey<FormState>();
  bool _autoValidateComplain = false;
  bool internetAccess = false;
  ScrollController _scrollController = ScrollController();

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

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    bool internetAccess = await checkInternetAccess.check();
    setState(() {
      this.internetAccess = internetAccess;
    });
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

  _showComplainDialog(BuildContext context) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: complainFormKey,
                child: new TextFormField(
                  scrollController: _scrollController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  onSaved: (val) => _complain = val!,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (val) async {
                    await getInternetAccessObject();
                    if (internetAccess) {
                      var form = complainFormKey.currentState;
                      if (form!.validate()) {
                        form.save();
                        Navigator.pop(context);
                        setState(() {
                          _isLoading = true;
                          _autoValidateComplain = false;
                        });
                      } else {
                        setState(() {
                          _autoValidateComplain = true;
                        });
                      }
                    } else {
                      Navigator.pop(context);
                      this._showDialog.showDialogCustom(
                          context,
                          "Internet Connection Problem",
                          "Please check your internet connection",
                          fontSize: 17.0,
                          boxHeight: 58.0);
                    }
                  },
                  autofocus: true,
                  decoration: new InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.greenAccent, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1.0),
                    ),
                    labelText: 'Complaint',
                  ),
                ),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
            child: const Text('CANCEL'),
            onPressed: () {
              var form = complainFormKey.currentState;
              form!.reset();
              Navigator.pop(context);
            },
          ),
          new FlatButton(
            child: const Text('SEND'),
            onPressed: () async {
              await getInternetAccessObject();
              if (internetAccess) {
                var form = complainFormKey.currentState;
                if (form!.validate()) {
                  form.save();
                  Navigator.pop(context);
                  setState(() {
                    _isLoading = true;
                    _autoValidateComplain = false;
                  });
                  _sendMessage(widget.user!.userId!, _complain);
                } else {
                  setState(() {
                    _autoValidateComplain = true;
                  });
                }
              } else {
                Navigator.pop(context);
                this._showDialog.showDialogCustom(
                    context,
                    "Internet Connection Problem",
                    "Please check your internet connection",
                    fontSize: 17.0,
                    boxHeight: 58.0);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Contact us"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.message),
              onPressed: () => _showComplainDialog(context),
            ),
          ],
        ),
        body:
            _isLoading ? ShowProgress() : createListView(context, _contactors));
  }

  Widget _contactWidget(BuildContext context, Contactor contactor) {
    return Card(
        child: ListTile(
      title: Text(contactor.contactorName!),
      subtitle: Text(contactor.contactorRole!),
      leading: Icon(Icons.person),
      trailing: IconButton(
        icon: Icon(Icons.call),
        onPressed: () => _makeCall(contactor.contactorMobile),
      ),
    ));
  }

  Widget createListView(BuildContext context, List<Contactor> contactList) {
    return new ListView.separated(
      itemCount: contactList.length,
      itemBuilder: (context, index) =>
          _contactWidget(context, contactList[index]),
      separatorBuilder: (context, index) => new Divider(),
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
