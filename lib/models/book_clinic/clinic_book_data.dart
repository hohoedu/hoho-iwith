import 'package:get/get.dart';

class ClinicBookData {
  final String title;

  ClinicBookData({
    required this.title,
  });

  ClinicBookData.fromJson(Map<String, dynamic> json) : title = json['title'] ?? '';
}

class ClinicBookDataController extends GetxController {
  RxList<ClinicBookData> clinicBookDataList = <ClinicBookData>[].obs;

  void setClinicBookDataList(List<ClinicBookData> newList) {
    clinicBookDataList.assignAll(newList);
  }

  void clearBookDataList() {
    clinicBookDataList.clear();
  }

  List<ClinicBookData> get newList => clinicBookDataList;
}
