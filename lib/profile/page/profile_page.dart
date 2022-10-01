import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:last_home_auto/models/get_all_count_names.dart';
import '../../userpreferances/user_preferances.dart';
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
import '/utils/get_image_from_asset.dart';

class ProfilePage extends StatefulWidget {
  final User? user;
  final Function? callbackUser;
  ProfilePage({Key? key, this.user, this.callbackUser}) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    implements UserContract, GetNamesCountContract {
  bool _isLoading = true;
  bool internetAccess = false;
  String user_id = UserSharedPreferences.getUserUniqueId() ?? "";
  String imagePath = UserSharedPreferences.getUserProfileImagePath() ?? "";
  File? profileImage;
  int? _device_count = 0;
  int? _room_count = 0;
  int? _home_count = 0;
  late CheckPlatform _checkPlatform;
  late User? user;

  late ShowDialog showDialog;
  late ShowInternetStatus _showInternetStatus;

  late UserPresenter _userPresenter;
  late GetNamesCountPresenter _presenter;

  @override
  initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    profileImage = File(imagePath);
    showDialog = new ShowDialog();
    _userPresenter = new UserPresenter(this);
    _presenter = new GetNamesCountPresenter(this);
    _checkPlatform = new CheckPlatform(context: context);
    _showInternetStatus = new ShowInternetStatus();
    getInternetAccessObject();
    getUserProfile();
    getAllNamesCount();
    _getProfileImage();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getProfileImage() async {
    if (imagePath != "") {
      profileImage = File(imagePath);
    } else {
      profileImage = await getImageFileFromAssets("assets/images/user.png");
    }
  }

  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    bool internetAccessDummy = await checkInternetAccess.check();
    setState(() {
      internetAccess = internetAccessDummy;
    });
  }

  getUserProfile() async {
    await _userPresenter.doGetUser(user_id);
  }

  getAllNamesCount() async {
    await _presenter.doGetAllNamesCounts(user_id);
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
                  imageFile: profileImage,
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
                NumbersWidget(
                  device_count: _device_count ?? 0,
                  room_count: _room_count ?? 0,
                  home_count: _home_count ?? 0,
                ),
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
    });
    Future.delayed(
      Duration(milliseconds: 250),
    );
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onGetNamesCountError() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onGetNamesCountSuccess(
      int device_count, int room_count, int home_count) {
    setState(() {
      _device_count = device_count;
      _room_count = room_count;
      _home_count = home_count;
    });
    Future.delayed(
      Duration(milliseconds: 250),
    );
    setState(() {
      _isLoading = false;
    });
  }
}
