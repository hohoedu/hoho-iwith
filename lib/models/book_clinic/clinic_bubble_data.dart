import 'package:get/get.dart';

class ClinicBubbleData {
  final String label;
  final String score;
  final String result;

  ClinicBubbleData({
    required this.label,
    required this.score,
    required this.result,
  });

  ClinicBubbleData.fromJson(Map<String, dynamic> json)
      : label = json['qtypestr'] ?? '',
        score = json['per'],
        result = json['result'];
}

class ClinicBubbleDataController extends GetxController {
  List<ClinicBubbleData> _clinicBubbleDataList = <ClinicBubbleData>[];

  void setClinicBubbleDataList(List<ClinicBubbleData> clinicBubbleDataList) {
    _clinicBubbleDataList = List.from(clinicBubbleDataList);
    update();
  }

  List<ClinicBubbleData> get clinicBubbleDataList => _clinicBubbleDataList;
}
