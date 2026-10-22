import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/bookstore/bookstore_attendance_data.dart';
import 'package:flutter_application/models/bookstore/bookstore_main_data.dart';
import 'package:flutter_application/models/bookstore/bookstore_reservation_data.dart';
import 'package:flutter_application/models/payment/pass_payment_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/notifications/push_route.dart';
import 'package:flutter_application/notifications/token_management.dart';
import 'package:flutter_application/screens/bookstore/main/bookstore_main.dart';
import 'package:flutter_application/screens/home/home_screen.dart';
import 'package:flutter_application/screens/login/login_screen.dart';
import 'package:flutter_application/services/attendance/attendance_main.service.dart';
import 'package:flutter_application/services/book_info/book_info_main_service.dart';
import 'package:flutter_application/services/bookstore/bookstore_main_service.dart';
import 'package:flutter_application/services/class_info/class_info_services.dart';
import 'package:flutter_application/services/notice/notice_list_service.dart';
import 'package:flutter_application/widgets/date_format.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

/// 학생 한 명이 정해진 뒤 첫 화면으로 들어가는 공통 처리.
///
/// 일반 로그인 · 관리자 로그인 · 형제 선택이 모두 여기로 모인다. 예전에는 경로마다 따로
/// 짜여 있어서 형제 선택과 관리자 로그인에는 책방 데이터 조회와 책방 전용 화면 분기가 빠져 있었다.
///
/// 책방 세션은 호출하는 쪽이 먼저 만든다(일반: bookstoreLoginService, 관리자: bookstoreAdminLoginService,
/// 형제: bookstoreSiblingSwitchService). [replace] 가 true 면 로그인 화면을 지우고(Get.off),
/// false 면 쌓는다(Get.to — 형제 선택 화면·관리자 로그인처럼 뒤로 돌아갈 수 있어야 할 때).
/// [consumePush] 가 true 면 첫 화면에 들어간 뒤, 앱이 알림으로 열렸을 때 보관해 둔 이동을 이어서 처리한다.
Future<void> enterAfterLogin(UserData user, {required bool isAdmin, required bool replace, bool consumePush = true}) async {
  // 토큰 저장은 실제 학부모 기기일 때만 — 관리자가 들어가서 학부모 알림을 가로채면 안 된다
  if (!isAdmin) {
    await getToken(user.stuId);
  }

  // 이전 학생(형제 전환·재로그인) 책방 데이터가 남아 보이지 않게 먼저 비운다.
  // 예약·결제·출석 컨트롤러는 앱 전체에서 유지(permanent)되므로 함께 비워야 한다(2026-10-22) —
  // 안 비우면 다음 화면을 열었을 때 새로 받기 전까지 이전 형제의 데이터가 잠깐 보인다.
  if (Get.isRegistered<BookstoreMainDataController>()) {
    Get.find<BookstoreMainDataController>().clear();
  }
  if (Get.isRegistered<BookstoreReservationDataController>()) {
    Get.find<BookstoreReservationDataController>().clear();
  }
  if (Get.isRegistered<PassPaymentController>()) {
    Get.find<PassPaymentController>().clearStudentData();
  }
  if (Get.isRegistered<BookstoreAttendanceController>()) {
    Get.find<BookstoreAttendanceController>().clear();
  }
  if (user.useBookstore && bookstoreSessionCookie != null) {
    await bookstoreMainService(user.stuId);
  }

  if (user.isBookstoreOnly) {
    // 책방만 이용하는 학생은 책방 화면이 전부라 세션이 없으면 들어가도 빈 화면뿐이다
    if (bookstoreSessionCookie == null) {
      failDialog1('로그인', '호호책방 서버에 연결하지 못했습니다.\n잠시 후 다시 시도해 주세요.');
      return;
    }
    replace ? Get.off(() => BookstoreMain()) : Get.to(() => BookstoreMain());
    if (consumePush) await consumePendingPush();
    return;
  }

  // 서당 이용(서당만 / 서당+책방) → 기존 홈
  await noticeListService(user.stuId);
  await classInfoService(user.stuId);
  await attendanceMainService(user.stuId);
  if (user.bookCode.isNotEmpty) {
    await bookInfoMainService(user.bookCode);
  }
  replace ? Get.off(() => HomeScreen()) : Get.to(() => HomeScreen());
  if (consumePush) await consumePendingPush();
}

/// 로그인 실패 공통 처리 (2026-10-22).
///
/// 자동 로그인은 로딩 화면 위에서 돌기 때문에, 실패하면 로그인 화면으로 보내지 않으면 로딩이 끝나지 않는다.
/// [clearSaved] 가 true 면(아이디·비밀번호가 틀림) 저장된 자동 로그인 정보도 지운다 — 남겨 두면
/// 앱을 켤 때마다 같은 실패를 반복한다. 네트워크 오류처럼 일시적인 실패는 지우지 않는다.
Future<void> handleLoginFailure(String title, String message, {required bool fromAutoLogin, bool clearSaved = false}) async {
  if (clearSaved && Get.isRegistered<FlutterSecureStorage>()) {
    await Get.find<FlutterSecureStorage>().delete(key: "login");
  }
  if (fromAutoLogin) {
    Get.offAll(() => const LoginScreen());
  }
  failDialog1(title, message);
}
