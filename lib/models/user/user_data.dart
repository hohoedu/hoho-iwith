import 'package:flutter_application/models/user/sibling_data.dart';
import 'package:get/get.dart';

class UserData {
  final String stuId;
  final String centerId;
  final String appId;
  final String name;
  final String age;
  final String bookCode;
  final String centerName;
  final bool isSibling;
  final String sibling;
  final bool isFirstLogin;
  final String profileImage;

  /// 서비스 구분: BOTH | CENTER | BOOKSTORE | NONE (서버 미제공 시 CENTER 로 간주)
  final String serviceType;
  final bool useCenter;
  final bool useBookstore;

  UserData({
    required this.stuId,
    required this.centerId,
    required this.appId,
    required this.name,
    required this.age,
    required this.bookCode,
    required this.centerName,
    required this.isSibling,
    required this.sibling,
    required this.isFirstLogin,
    required this.profileImage,
    this.serviceType = 'CENTER',
    this.useCenter = true,
    this.useBookstore = false,
  });

  /// 책방만 이용하는 학생 → 책방 전용 화면으로 분기
  bool get isBookstoreOnly => serviceType == 'BOOKSTORE';

  UserData.fromJson(Map<String, dynamic> json)
      : stuId = json['stuid'] ?? '',
        name = json['name'] ?? '',
        centerId = json['cid'] ?? '',
        centerName = json['cname'] ?? '',
        appId = json['appid'] ?? '',
        age = json['hak'] ?? '',
        bookCode = json['ihak'] ?? '',
        isSibling = json['brotherGb'] == 'Y' ? true : false,
        sibling = json['sibling'] ?? '',
        isFirstLogin = json['firstLogin'] == 'Y' ? true : false,
        profileImage = json['profileimg'] ?? '',
        serviceType = json['serviceType'] ?? 'CENTER',
        useCenter = json['useCenter'] == true,
        useBookstore = json['useBookstore'] == true;

  factory UserData.fromSibling(SiblingData s) {
    return UserData(
      stuId: s.stuId,
      centerId: s.centerId,
      appId: s.appId,
      name: s.name,
      age: s.age,
      bookCode: s.bookCode,
      centerName: s.centerName,
      isSibling: s.isSibling,
      sibling: s.sibling,
      isFirstLogin: s.isFirstLogin,
      profileImage: s.profileImage,
      serviceType: s.serviceType,
      useCenter: s.useCenter,
      useBookstore: s.useBookstore,
    );
  }
}

class UserDataController extends GetxController {
  final Rx<UserData?> _userData = Rx<UserData?>(null);
  bool isAdmin = false;

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
        age: currentData.age,
        bookCode: currentData.bookCode,
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
