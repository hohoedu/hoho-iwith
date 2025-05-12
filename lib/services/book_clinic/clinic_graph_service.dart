import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/book_clinic/clinic_book_data.dart';
import 'package:flutter_application/models/book_clinic/clinic_bubble_data.dart';
import 'package:flutter_application/models/book_clinic/clinic_graph_data.dart';
import 'package:flutter_application/models/book_info/book_info_data.dart';
import 'package:flutter_application/models/notice/notice_list_data.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// 독서클리닉 그래프 가져오기
Future<void> clinicGraphService(id, ym) async {
  final graphData = Get.put(ClinicGraphDataController());
  String url = dotenv.get('CLINIC_GRAPH_URL');
  String startYM = formatYM(getCurrentYear(), 01);
  final Map<String, dynamic> requestData = {
    "id": id,
    "sym": startYM,
    "eym": ym,
  };

  // HTTP POST 요청
  final response = await dio.post(url, data: jsonEncode(requestData));
  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      final resultValue = resultList['result'];

      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        final List<ClinicGraphData> clinicGraphDataList =
            (resultList['data'] as List).map((json) => ClinicGraphData.fromJson(json)).toList();
        graphData.setClinicGraphDataList(clinicGraphDataList);
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        graphData.clearGraphDataList();
      }
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
