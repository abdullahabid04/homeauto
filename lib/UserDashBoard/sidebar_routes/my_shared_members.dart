import 'package:flutter/material.dart';
import 'package:last_home_auto/models/shared_members_data.dart';
import 'package:last_home_auto/utils/show_status.dart';
import '../../models/user_data.dart';
import '../../userpreferances/user_preferances.dart';
import '../../utils/internet_access.dart';
import '../../utils/show_dialog.dart';
import '../../utils/show_progress.dart';
import '/models/my_referrals_data.dart';
import 'add_referral.dart';

class SharedMembers extends StatefulWidget {
  const SharedMembers({Key? key}) : super(key: key);

  @override
  State<SharedMembers> createState() => _SharedMembersState();
}

class _SharedMembersState extends State<SharedMembers>
    implements MembersContract {
  bool _isLoading = true;
  late String mobile_no;
  String user_id = UserSharedPreferences.getUserUniqueId() ?? "";
  late MembersPresenter _presenter;
  List<Members> _members = <Members>[];
  late ShowDialog _showDialog;
  var referralFormKey = GlobalKey<FormState>();
  bool _autoValidateComplain = false;
  bool internetAccess = false;
  ScrollController _scrollController = ScrollController();
  ShowStatus _showStatus = new ShowStatus();

  @override
  void initState() {
    _showDialog = new ShowDialog();
    _presenter = new MembersPresenter(this);
    _getMembers();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getMembers() async {
    await _presenter.doGetMembers(user_id);
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
        actions: [],
      ),
      body: _isLoading
          ? ShowProgress()
          : _members.length != 0
              ? createListView(context, _members)
              : _showStatus.showStatus("no shared members"),
    );
  }

  Widget _contactWidget(BuildContext context, Members member) {
    return Card(
        child: ListTile(
      title: Text(member.userName!),
      subtitle: Text(member.userContact!),
      leading: Icon(Icons.person),
      trailing: IconButton(
        icon: Icon(Icons.send),
        onPressed: () => {},
      ),
    ));
  }

  Widget createListView(BuildContext context, List<Members> membersList) {
    return new ListView.separated(
      itemCount: membersList.length,
      itemBuilder: (context, index) =>
          _contactWidget(context, membersList[index]),
      separatorBuilder: (context, index) => new Divider(),
    );
  }

  @override
  void onGetMembersErrors() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onGetMembersSuccess(SharedMembersData userDetails) {
    setState(() {
      _members = userDetails.members!;
      _isLoading = false;
    });
  }
}
