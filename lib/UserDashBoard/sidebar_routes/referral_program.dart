import 'package:flutter/material.dart';
import '../../models/user_data.dart';
import '../../utils/show_dialog.dart';
import '../../utils/show_progress.dart';
import '/models/my_referrals_data.dart';

class ReferProgram extends StatefulWidget {
  final User? user;
  final Function? callbackUser;
  const ReferProgram({Key? key, this.user, this.callbackUser})
      : super(key: key);

  @override
  State<ReferProgram> createState() => _ReferProgramState();
}

class _ReferProgramState extends State<ReferProgram>
    implements ReferralProgramContractor {
  bool _isLoading = true;
  late String mobile_no;
  late String _referralName, _referralMobile;
  late ReferralProgramPresetner _presenter;
  List<Referrals> _referrals = <Referrals>[];
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  late ShowDialog _showDialog;

  @override
  void initState() {
    _presenter = new ReferralProgramPresetner(this);
    _showDialog = new ShowDialog();
    _getReferrals(widget.user!.userId);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getReferrals(String? user_id) async {
    await _presenter.doGetReferrals(user_id!);
  }

  _addReferral(String referralName, String referralMobile) async {
    await _presenter.doGetDevices(
        widget.user!.userId!, referralName, referralMobile);
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
                        controller: _nameController,
                        onSaved: (val) => _referralName = val!,
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
                          hintText: 'Referral Name',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(25),
                    child: Expanded(
                      child: TextFormField(
                        controller: _mobileController,
                        onSaved: (val) => _referralMobile = val!,
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
                          hintText: 'Referral Mobile',
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
                                _addReferral(_referralName, _referralMobile);
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
            _isLoading ? ShowProgress() : createListView(context, _referrals));
  }

  Widget _contactWidget(BuildContext context, Referrals referral) {
    return Card(
        child: ListTile(
      title: Text(referral.referralName!),
      subtitle: Text(referral.referralMobile!),
      trailing: Icon(Icons.contact_phone),
      leading: IconButton(
        icon: Icon(Icons.call),
        onPressed: () => {},
      ),
    ));
  }

  Widget createListView(BuildContext context, List<Referrals> contactList) {
    return new GridView.count(
      crossAxisCount: 2,
      children:
          contactList.map((value) => _contactWidget(context, value)).toList(),
    );
  }

  @override
  void onAddReferralError(String? error) {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onAddReferralSucccss(String? message) {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onGetReferralError(String? error) {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onGetReferralSucccss(List<Referrals>? referrals) {
    setState(() {
      _referrals = referrals!;
      _isLoading = false;
    });
  }
}
