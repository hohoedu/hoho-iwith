import 'dart:convert';
import 'package:flutter_application/models/attendance_data.dart';
import 'package:flutter_application/utils/network_check.dart';
import 'package:flutter_application/utils/get_dropdown_stuId.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/utils/get_current_date.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

/////////////////
// 출석 데이터 //
/////////////////

Future<void> getAttendanceData(month) async {

  // 컨트롤러
  final AttendanceDataController attendanceDataController = Get.put(AttendanceDataController());
  final ConnectivityController connectivityController = Get.put(ConnectivityController());        
  final StudentIdController studentIdController = Get.put(StudentIdController());

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('TIME_CHECK_URL');
    
    // 학생 아이디
    final stuId = studentIdController.getStuId();

    // 현재 연도
    final currentPageMonth = month;
    String ym = formatYM(currentYear, currentPageMonth);

    // HTTP POST 요청
    var response = await http.post(
      Uri.parse(url), 
      body: {
        'ym': ym, 
        'stuid': stuId
      }
    );

    // 응답의 content-type utf-8로 인코딩으로 설정
    if (response.headers['content-type']?.toLowerCase().contains('charset=utf-8') != true) {
      response.headers['content-type'] = 'application/json; charset=utf-8';
    }
    try {
      // 응답을 성공적으로 받았을 때
      if (response.statusCode == 200) {
        final resultList = json.decode(response.body);

        // 응답 데이터가 성공일 때
        if (resultList[0]["result"] == null) {
          final resultList0 = resultList.cast<Map<String, dynamic>>();
          List<AttendanceData> attenceDataList = resultList0.map<AttendanceData>((json) => AttendanceData.fromJson(json)).toList();
          final AttendanceDataController attendanceDataController = Get.put(AttendanceDataController());     
          attendanceDataController.setAttendanceDataList(attenceDataList);
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {
          failDialog1("응답 오류", "출석 정보가 없어요");
        }
      }
    }
    // 응답을 받지 못했을 때
    catch (e) {
      attendanceDataController.setAttendanceDataList([]);     // 빈 리스트로 설정하여 화면에서 데이터를 제거
    }
  } else {
    failDialog1("연결 실패", "인터넷 연결을 확인해주세요");
  }
}