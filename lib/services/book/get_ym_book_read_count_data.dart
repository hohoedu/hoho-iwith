import 'dart:convert';

import 'package:flutter_application/models/book_data/ym_book_count_data.dart';
import 'package:flutter_application/utils/get_dropdown_stuId.dart';
import 'package:flutter_application/utils/network_check.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/////////////////////////////////////
// 연간 월별 독서량 데이터(선그래프) //
/////////////////////////////////////

// 연간 월별 독서량 데이터 가져오는 함수
Future<void> getYMBookReadCountData(year, month) async {
  // 컨트롤러
  final ConnectivityController connectivityController =
      Get.put(ConnectivityController());
  final StudentIdController studentIdController =
      Get.put(StudentIdController());

  if (connectivityController.isConnected.value) {
    String url = dotenv.get("BOOK_READ_YM_CNT_URL");

    // 학생 아이디
    final stuId = studentIdController.getStuId();

    // 해당 페이지 연월
    final currrentPageYear = year;
    final currentPageMonth = month;
    String yy = formatY(currrentPageYear, currentPageMonth);

    // HTTP POST 요청
    var response =
        await http.post(Uri.parse(url), body: {'stuid': stuId, 'yy': yy});

    // 응답의 content-type utf-8로 인코딩으로 설정
    if (response.headers['content-type']
            ?.toLowerCase()
            .contains('charset=utf-8') !=
        true) {
      response.headers['content-type'] = 'application/json; charset=utf-8';
    }
    try {
      // 응답을 성공적으로 받았을 때
      if (response.statusCode == 200) {
        final resultList = json.decode(response.body);

        // 응답 데이터가 성공일 때
        if (resultList[0]["result"] == null) {
          final resultList0 = resultList.cast<Map<String, dynamic>>();
          List<YMBookCountData> ymBookCountDataList = resultList0
              .map<YMBookCountData>((json) => YMBookCountData.fromJson(json))
              .toList();
          final YMBookCountDataController ymBookCountDataController =
              Get.put(YMBookCountDataController());
          ymBookCountDataController.setYMBookCountDataList(ymBookCountDataList);
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {
          failDialog1("응답 오류", "독클 결과가 없어요");
        }
      }
    }
    // 응답을 받지 못했을 때
    catch (e) {
      throw Exception('$e');
    }
  } else {
    failDialog1("연결 실패", "인터넷 연결을 확인해주세요");
  }
}
