import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/class_info/class_info_data.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// 수업 정보 가져오기
Future<void> classInfoService(String stuId) async {
  final classInfo = Get.put(ClassInfoDataController());
  final nowYear = getCurrentYear();
  final nowMonth = getCurrentMonth();
  String url = dotenv.get('CLASS_INFO_URL');

  for (int offset = 0; offset < 3; offset++) {
    final targetDate = DateTime(nowYear, nowMonth - offset);
    final targetY = targetDate.year;
    final targetM = targetDate.month;

    final Map<String, dynamic> requestData = {
      "id": stuId,
      "yyyy": formatY(targetY, targetM),
      "mm": formatM(targetY, targetM),
    };

    try {
      final response = await dio.post(url, data: jsonEncode(requestData));
      if (response.statusCode == 200) {
        final Map<String, dynamic> resultList = json.decode(response.data);
        final resultValue = resultList['result'];

        if (resultValue == "0000") {
          final List<ClassInfoData> classInfoDataList =
              (resultList['data'] as List).map((json) => ClassInfoData.fromJson(json)).toList();
          classInfo.setClassInfoDataList(classInfoDataList);
          return;
        } else if (resultValue == "9999") {
          continue;
        } else {
          Logger().d('classInfoService: unexpected resultValue = $resultValue');
          return;
        }
      } else {
        Logger().d(
          'classInfoService: HTTP error ${response.statusCode}',
        );
        return;
      }
    } catch (e) {
      Logger().d('classInfoService exception: $e');
      return;
    }
  }
}
