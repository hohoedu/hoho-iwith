import 'package:get/get.dart';

class ClinicBookData {
  final String title;

  ClinicBookData({
    required this.title,
  });

  ClinicBookData.fromJson(Map<String, dynamic> json) : title = json['title'] ?? '';
}

class ClinicBookDataController extends GetxController {
  List<ClinicBookData> _clinicBookDataList = <ClinicBookData>[];

  void setClinicBookDataList(List<ClinicBookData> clinicBookDataList) {
    _clinicBookDataList = List.from(clinicBookDataList);
    update();
  }

  List<ClinicBookData> get clinicBookDataList => _clinicBookDataList;
}
