import 'package:get/get.dart';

class ClinicGraphData {
  final String year;
  final String month;
  final String count;

  ClinicGraphData({
    required this.year,
    required this.month,
    required this.count,
  });

  ClinicGraphData.fromJson(Map<String, dynamic> json)
      : year = json['ym'].toString().substring(0, 4),
        month = json['ym'].toString().substring(4, 6),
        count = json['cnt'] ?? '';
}

class ClinicGraphDataController extends GetxController {
  List<ClinicGraphData> _clinicGraphDataList = <ClinicGraphData>[];

  void setClinicGraphDataList(List<ClinicGraphData> clinicGraphDataList) {
    _clinicGraphDataList = List.from(clinicGraphDataList);
    update();
  }

  List<ClinicGraphData> get clinicGraphDataList => _clinicGraphDataList;
}
