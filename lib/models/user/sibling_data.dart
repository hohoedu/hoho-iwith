import 'package:get/get.dart';

class SiblingData {
  final String stuId;
  final String name;
  final String centerId;
  final String centerName;
  final bool isSibling;
  final String sibling;
  final bool isFirstLogin;

  SiblingData({
    required this.stuId,
    required this.name,
    required this.centerId,
    required this.centerName,
    required this.isSibling,
    required this.sibling,
    required this.isFirstLogin,
  });

  SiblingData.fromJson(Map<String, dynamic> json)
      : stuId = json['stuid'] ?? '',
        name = json['name'] ?? '',
        centerId = json['cid'] ?? '',
        centerName = json['cname'] ?? '',
        isSibling = json['brotherGb'] == 'Y' ? true : false,
        sibling = json['sibling'],
        isFirstLogin = json['firstLogin'] == 'Y' ? true : false;
}

class SiblingDataController extends GetxController {
  List<SiblingData> _siblingDataList = <SiblingData>[];

  void setSiblingDataList(List<SiblingData> siblingDataList) {
    _siblingDataList = List.from(siblingDataList);
    update();
  }

  List<SiblingData> get siblingDataList => _siblingDataList;
}
