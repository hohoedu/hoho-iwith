import 'package:flutter_application/models/user/sibling_data.dart';
import 'package:get/get.dart';

class UserData {
  final String stuId;
  final String centerId;
  final String appId;
  final String name;
  final String centerName;
  final bool isSibling;
  final String sibling;
  final bool isFirstLogin;
  final String profileImage;

  UserData({
    required this.stuId,
    required this.centerId,
    required this.appId,
    required this.name,
    required this.centerName,
    required this.isSibling,
    required this.sibling,
    required this.isFirstLogin,
    required this.profileImage,
  });

  UserData.fromJson(Map<String, dynamic> json)
      : stuId = json['stuid'] ?? '',
        centerId = json['cid'] ?? '',
        appId = json['appid'] ?? '',
        name = json['name'] ?? '',
        centerName = json['cname'] ?? '',
        isSibling = json['brotherGb'] == 'Y' ? true : false,
        sibling = json['sibling'],
        isFirstLogin = json['firstLogin'] == 'Y' ? true : false,
        profileImage = json['profileimg'] ?? 0;

  factory UserData.fromSibling(SiblingData s) {
    return UserData(
      stuId: s.stuId,
      centerId: s.centerId,
      appId: s.appId,
      name: s.name,
      centerName: s.centerName,
      isSibling: s.isSibling,
      sibling: s.sibling,
      isFirstLogin: s.isFirstLogin,
      profileImage: s.profileImage,
    );
  }
}

class UserDataController extends GetxController {
  final Rx<UserData?> _userData = Rx<UserData?>(null);

  void setUserData(UserData userData) {
    _userData.value = userData;
    update();
  }

  void updateUserProfile(String newProfileImage) {
    if (_userData.value != null) {
      final currentData = _userData.value!;
      final updatedUserData = UserData(
        stuId: currentData.stuId,
        centerId: currentData.centerId,
        appId: currentData.appId,
        name: currentData.name,
        centerName: currentData.centerName,
        isSibling: currentData.isSibling,
        sibling: currentData.sibling,
        isFirstLogin: currentData.isFirstLogin,
        profileImage: newProfileImage,
      );
      _userData.value = updatedUserData;
      update();
    }
  }

  UserData get userData => _userData.value!;
}
