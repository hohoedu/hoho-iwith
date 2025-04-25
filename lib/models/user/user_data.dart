import 'package:flutter_application/models/user/sibling_data.dart';
import 'package:get/get.dart';

class UserData {
  final String stuId;
  final String name;
  final String centerId;
  final String centerName;
  final bool isSibling;
  final String sibling;
  final bool isFirstLogin;

  UserData({
    required this.stuId,
    required this.name,
    required this.centerId,
    required this.centerName,
    required this.isSibling,
    required this.sibling,
    required this.isFirstLogin,
  });

  UserData.fromJson(Map<String, dynamic> json)
      : stuId = json['stuid'] ?? '',
        name = json['name'] ?? '',
        centerId = json['cid'] ?? '',
        centerName = json['cname'] ?? '',
        isSibling = json['brotherGb'] == 'Y' ? true : false,
        sibling = json['sibling'],
        isFirstLogin = json['firstLogin'] == 'Y' ? true : false;

  factory UserData.fromSibling(SiblingData s) {
    return UserData(
      stuId: s.stuId,
      name: s.name,
      centerId: s.centerId,
      centerName: s.centerName,
      isSibling: s.isSibling,
      sibling: s.sibling,
      isFirstLogin: s.isFirstLogin,
    );
  }
}

class UserDataController extends GetxController {
  final Rx<UserData?> _userData = Rx<UserData?>(null);

  void setUserData(UserData userData) {
    _userData.value = userData;
    update();
  }

  UserData get userData => _userData.value!;
}
