import 'dart:convert';

import 'package:flutter_application/models/payment_data.dart';
import 'package:flutter_application/utils/get_current_date.dart';
import 'package:flutter_application/utils/get_dropdown_stuId.dart';
import 'package:flutter_application/utils/network_check.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/////////////////////
// 교육비 결제 내역 //
/////////////////////

Future<void> getPaymentData() async {
  // 컨트롤러
  final ConnectivityController connectivityController =
      Get.put(ConnectivityController());
  final StudentIdController studentIdController =
      Get.put(StudentIdController());

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('PAYMENT_RESULT_URL');

    // 학생 아이디
    final stuId = studentIdController.getStuId();

    // 현재년도
    final currrentYear = getCurrentYear().toString();

    // HTTP POST 요청
    var response = await http
        .post(Uri.parse(url), body: {'stuid': stuId, 'yy': currrentYear});
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
          List<PaymentData> paymentDataList = resultList0
              .map<PaymentData>((json) => PaymentData.fromJson(json))
              .toList();
          final PaymentDataController paymentDataController =
              Get.put(PaymentDataController());
          paymentDataController.setPaymentDataList(paymentDataList);
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {
          failDialog1("응답 오류", "");
        }
      }
    }
    // 응답을 받지 못했을 때
    catch (e) {
      null;
    }
  } else {
    failDialog1("연결 실패", "인터넷 연결을 확인해주세요");
  }
}
