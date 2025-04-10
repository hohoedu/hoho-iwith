import 'dart:convert';

import 'package:flutter_application/models/class_info_data.dart';
import 'package:flutter_application/models/login_data.dart';
import 'package:flutter_application/utils/network_check.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

////////////////////////
//  수업 정보, 형제   //
////////////////////////

// 수업정보 가져오는 함수
Future<void> getClassInfoData() async {
  // 컨트롤러
  final LoginDataController loginDataController =
      Get.put(LoginDataController());
  final ConnectivityController connectivityController =
      Get.put(ConnectivityController());
  final ClassInfoDataController classInfoDataController =
      Get.put(ClassInfoDataController());

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('CLASS_INFO_URL');

    // 형제자매 코드
    String sibling = loginDataController.loginData!.sibling;

    // 로그인 아이디
    String stuId = loginDataController.loginData!.id;
    // HTTP POST 요청
    var response = await http.post(Uri.parse(url), body: {
      'sibling': sibling,
      'stuid': stuId,
    });
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
        // 응답 데이터가 리스트일 경우
        if (resultList is List && resultList.isNotEmpty) {
          // 응답 데이터가 성공일 때
          if (resultList[0]["result"] == "0000") {
            final resultList0 = resultList.cast<Map<String, dynamic>>();
            List<ClassInfoData> classInfoDataList = resultList0
                .map<ClassInfoData>((json) => ClassInfoData.fromJson(json))
                .toList();

            classInfoDataController.setClassInfoDataList(classInfoDataList);
            classInfoDataController.setSnamesList(classInfoDataList);
          }
        } else {
          classInfoDataController.setSnamesList([]);
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
