import 'package:get/get.dart';

class ClinicBookData {
  final String title;
  final String date;

  ClinicBookData({
    required this.title,
    required this.date,
  });

  ClinicBookData.fromJson(Map<String, dynamic> json)
      : title = json['title'] ?? '',
        date = json['sdate'] ?? '';
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
