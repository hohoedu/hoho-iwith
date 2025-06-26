import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/notifications/token_management.dart';
import 'package:flutter_application/screens/home/home_screen.dart';
import 'package:flutter_application/screens/login/login_screen.dart';
import 'package:flutter_application/screens/login/sibling_screen.dart';
import 'package:flutter_application/services/attendance/attendance_main.service.dart';
import 'package:flutter_application/services/book_clinic/clinic_book_service.dart';
import 'package:flutter_application/services/book_info/book_info_main_service.dart';
import 'package:flutter_application/services/class_info/class_info_services.dart';
import 'package:flutter_application/services/login/sibling_service.dart';
import 'package:flutter_application/services/notice/notice_list_service.dart';
import 'package:flutter_application/utils/login_encryption.dart';
import 'package:flutter_application/utils/network_check.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// 로그인
Future<void> loginService(id, password, autoLoginChecked) async {
  Logger().d('일반 로그인');
  final userDataController = Get.put(UserDataController());
  final storage = Get.find<FlutterSecureStorage>();
  String url = dotenv.get('LOGIN_URL');
  String sha_password = sha256_convertHash(password);
  String method = 'common';
  final Map<String, dynamic> requestData = {
    "id": id,
    "sha_pwd": sha_password,
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
        final UserData userData = UserData.fromJson(resultList['data'][0]);

        userDataController.setUserData(userData);

        if (autoLoginChecked) {
          await storage.write(key: "login", value: "id $id password $password method $method");
        }

        // 토큰 전송
        await getToken(userData.stuId);

        // 형제가 존재할 때
        if (userData.isSibling) {
          await siblingService(userData.sibling);
          Get.off(() => SiblingScreen());
        }
        // 형제가 존재 하지 않을 때
        else {
          // 공지 사항 리스트
          await noticeListService(userData.stuId);
          // 수업 정보
          await classInfoService(userData.stuId);
          // 출석체크 정보
          await attendanceMainService(userData.stuId);
          // 수업 도서 안내
          if (userData.bookCode.isNotEmpty) {
            await bookInfoMainService(userData.bookCode);
          }
          await clinicBookService(userData.stuId, formatYM(currentYear, currentMonth));
          Get.off(() => HomeScreen());
        }
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        failDialog1('로그인', resultList['message']);
      }
    }
  }

  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
  // } else {
  //   failDialog1("연결 실패", "인터넷 연결을 확인해주세요");
  // }
}
