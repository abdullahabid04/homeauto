import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/profile/page/edit_profile_page.dart';
import '/profile/widget/button_widget.dart';
import '/profile/widget/numbers_widget.dart';
import '/profile/widget/profile_widget.dart';
import '/models/user_data.dart';
import '/utils/show_progress.dart';
import '/utils/internet_access.dart';
import '/utils/show_dialog.dart';
import '/utils/show_internet_status.dart';
import '/utils/check_platform.dart';

class ProfilePage extends StatefulWidget {
  User? user;
  Function? callbackUser;
  ProfilePage({Key? key, this.user, this.callbackUser}) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> implements UserContract {
  bool _isLoading = true;
  bool internetAccess = false;
  late CheckPlatform _checkPlatform;
  late User? user;

  late ShowDialog showDialog;
  late ShowInternetStatus _showInternetStatus;

  late UserPresenter _userPresenter;

  @override
  initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    showDialog = new ShowDialog();
    _userPresenter = new UserPresenter(this);
    _checkPlatform = new CheckPlatform(context: context);
    _showInternetStatus = new ShowInternetStatus();
    getInternetAccessObject();
    getUserProfile();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    bool internetAccessDummy = await checkInternetAccess.check();
    setState(() {
      internetAccess = internetAccessDummy;
    });
  }

  getUserProfile() async {
    await _userPresenter.doGetUser(widget.user!.userId!);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? ShowProgress()
        : Scaffold(
            appBar: AppBar(),
            body: ListView(
              physics: BouncingScrollPhysics(),
              children: [
                ProfileWidget(
                  imagePath:
                      "https://digitalsynopsis.com/wp-content/uploads/2014/06/supercar-wallpapers-bugatti-3.jpg",
                  onClicked: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(
                            user: user, callbackUser: widget.callbackUser),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                buildName(user!),
                const SizedBox(height: 24),
                Center(child: buildUpgradeButton()),
                const SizedBox(height: 24),
                NumbersWidget(),
                const SizedBox(height: 48),
              ],
            ),
          );
  }

  Widget buildName(User user) => Column(
        children: [
          Text(
            user.userName!,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            user.eMail!,
            style: TextStyle(color: Colors.grey),
          )
        ],
      );

  Widget buildUpgradeButton() => ButtonWidget(
        text: 'Upgrade To PRO',
        onClicked: () {},
      );

  @override
  void onUserError(String? error) {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onUserSuccess(User userDetails) {
    setState(() {
      user = userDetails;
      _isLoading = false;
    });
  }
}
