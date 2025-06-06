import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/notice/notice_list_data.dart';
import 'package:flutter_application/models/payment/payment_data.dart';
import 'package:flutter_application/screens/payment/payment_screen.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// 납부 내역 가져오기
Future<void> paymentService(id) async {
  final paymentData = Get.put(PaymentDataController());
  String url = dotenv.get('PAYMENT_URL');
  final Map<String, dynamic> requestData = {
    'id': id,
    "snum": "0",
    "count": "16",
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
        final List<PaymentData> paymentDataList =
            (resultList['data'] as List).map((json) => PaymentData.fromJson(json)).toList();
        paymentData.setPaymentDataList(paymentDataList);

        Get.to(() => PaymentScreen());
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        failDialog1('안내', '납부 내역이 없습니다.');
      }
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
