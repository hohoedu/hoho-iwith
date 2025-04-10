import 'package:get/get.dart';

////////////////////////
//  월말 레포트 보이기   //
////////////////////////

// 데이터 클래스
class ReportViewData {
  final String hVisible; // 독서 권수
  final String iVisible;

  ReportViewData({
    required this.hVisible,
    required this.iVisible,
  });

  factory ReportViewData.fromJson(Map<String, dynamic> json) {
    return ReportViewData(
      hVisible: json['Hview_yn'] ?? "",
      iVisible: json['Iview_yn'] ?? "",
    );
  }
}

// 데이터 컨트롤러
class ReportViewDataController extends GetxController {
  ReportViewData? _reportViewData;

  void setReportViewData(ReportViewData reportViewData) {
    _reportViewData = reportViewData;
    update();
  }

  ReportViewData? get reportViewData => _reportViewData;
}
