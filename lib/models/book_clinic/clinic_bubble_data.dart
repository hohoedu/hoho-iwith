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
  RxList<ClinicBubbleData> clinicBubbleDataList = <ClinicBubbleData>[].obs;

  void setClinicBubbleDataList(List<ClinicBubbleData> newList) {
    clinicBubbleDataList.assignAll(newList);
  }

  void clearBubbleDataList() {
    clinicBubbleDataList.clear();
  }
}
