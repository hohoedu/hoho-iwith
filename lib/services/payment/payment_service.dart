import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/payment/payment_data.dart';
import 'package:flutter_application/screens/payment/payment_screen.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

Future<void> paymentService(id) async {
  final paymentData = Get.put(PaymentDataController());
  final String url = dotenv.get('PAYMENT_URL');
  final Map<String, dynamic> requestData = {
    'studentId': id,
    'snum': '0',
    'count': '16',
  };

  try {
    final response = await dio.post(url, data: jsonEncode(requestData));

    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = response.data;
      final resultValue = resultList['result'];
      Logger().d('response = $response');

      if (resultValue == '0000') {
        final List<PaymentData> paymentDataList =
        (resultList['data'] as List)
            .map((json) => PaymentData.fromJson(json))
            .toList();
        paymentData.setPaymentDataList(paymentDataList);
        Get.to(() => PaymentScreen());
      } else {
        failDialog1('안내', '납부 내역이 없습니다.');
      }
    }
  } catch (e) {
    Logger().d('e = $e');
  }
}