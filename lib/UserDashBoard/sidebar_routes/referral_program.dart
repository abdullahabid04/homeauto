import 'package:flutter/material.dart';
import '../../models/user_data.dart';
import '../../utils/internet_access.dart';
import '../../utils/show_dialog.dart';
import '../../utils/show_progress.dart';
import '/models/my_referrals_data.dart';
import 'add_referral.dart';

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
  var referralFormKey = GlobalKey<FormState>();
  bool _autoValidateComplain = false;
  bool internetAccess = false;
  ScrollController _scrollController = ScrollController();

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

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    bool internetAccess = await checkInternetAccess.check();
    setState(() {
      this.internetAccess = internetAccess;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Referral Program"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.person_add),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: ((context) => AddReferral(
                          user: widget.user,
                          callbackUser: widget.callbackUser,
                        ))),
              ),
            ),
          ],
        ),
        body:
            _isLoading ? ShowProgress() : createListView(context, _referrals));
  }

  Widget _contactWidget(BuildContext context, Referrals referral) {
    return Card(
        child: ListTile(
      title: Text(referral.referralName!),
      subtitle: Text(referral.referralMobile!),
      leading: Icon(Icons.person),
      trailing: IconButton(
        icon: Icon(Icons.send),
        onPressed: () => {},
      ),
    ));
  }

  Widget createListView(BuildContext context, List<Referrals> referralsList) {
    return new ListView.separated(
      itemCount: referralsList.length,
      itemBuilder: (context, index) =>
          _contactWidget(context, referralsList[index]),
      separatorBuilder: (context, index) => new Divider(),
    );
  }

  @override
  void onAddReferralError(String? error) {}

  @override
  void onAddReferralSucccss(String? message) {}

  @override
  void onGetReferralError(String? error) {
    setState(() {
      _isLoading = false;
    });
    _showDialog.showDialogCustom(context, "Error", error!);
  }

  @override
  void onGetReferralSucccss(List<Referrals>? referrals) {
    setState(() {
      _referrals = referrals!;
      _isLoading = false;
    });
    _showDialog.showDialogCustom(context, "Success", "Referrals found");
  }
}
