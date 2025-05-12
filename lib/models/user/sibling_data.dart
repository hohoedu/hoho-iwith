import 'package:get/get.dart';

class SiblingData {
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

  SiblingData({
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
  });

  SiblingData.fromJson(Map<String, dynamic> json)
      : stuId = json['stuid'] ?? '',
        centerId = json['cid'] ?? '',
        appId = json['appid'] ?? '',
        name = json['name'] ?? '',
        age = json['hak'] ?? '',
        bookCode = json['ihak'] ?? '',
        centerName = json['cname'] ?? '',
        isSibling = json['brotherGb'] == 'Y' ? true : false,
        sibling = json['sibling'],
        isFirstLogin = json['firstLogin'] == 'Y' ? true : false,
        profileImage = json['profileimg'] ?? '';
}

class SiblingDataController extends GetxController {
  List<SiblingData> _siblingDataList = <SiblingData>[];

  void setSiblingDataList(List<SiblingData> siblingDataList) {
    _siblingDataList = List.from(siblingDataList);
    update();
  }

  void updateSiblingProfile(String stuId, String newProfileImage) {
    final index = _siblingDataList.indexWhere((s) => s.stuId == stuId);
    if (index != -1) {
      final old = _siblingDataList[index];
      _siblingDataList[index] = SiblingData(
        stuId: old.stuId,
        centerId: old.centerId,
        appId: old.appId,
        name: old.name,
        age: old.age,
        bookCode: old.bookCode,
        centerName: old.centerName,
        isSibling: old.isSibling,
        sibling: old.sibling,
        isFirstLogin: old.isFirstLogin,
        profileImage: newProfileImage,
      );
      update();
    }
  }

  List<SiblingData> get siblingDataList => _siblingDataList;
}
