import 'dart:convert';
import 'package:flutter_application/models/center_info_data.dart';
import 'package:flutter_application/utils/network_check.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

///////////////
// 센터 정보 //
///////////////

// 센터 정보 가져오는 함수
Future<void> getCenterInfoData() async {

  final ConnectivityController connectivityController = Get.put(ConnectivityController());        // 네트워크 연결체크

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('CENTERID_INFO_URL');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final centerId = prefs.getString('centerId');

    // HTTP POST 요청
    var response = await http.post(
      Uri.parse(url), 
      body: {
        "cid": centerId
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
          CenterInfoData centerInfoData = CenterInfoData.fromJson(resultList[0]);
          final CenterInfoDataController centerInfoDataController = Get.put(CenterInfoDataController());
          centerInfoDataController.setCenterInfoData(centerInfoData);
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {
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