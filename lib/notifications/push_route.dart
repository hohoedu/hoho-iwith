import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/user/sibling_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/bookstore/attendance/bookstore_attendance_screen.dart';
import 'package:flutter_application/screens/bookstore/report/bookstore_report_screen.dart';
import 'package:flutter_application/screens/bookstore/reservation/bookstore_reservation_screen.dart';
import 'package:flutter_application/services/bookstore/bookstore_login_service.dart';
import 'package:flutter_application/services/login/enter_after_login.dart';
import 'package:get/get.dart';

/// 푸시 알림을 눌렀을 때 이동 (2026-10-22).
///
/// 서버가 FCM data 에 넣어 보내는 값으로 화면을 고른다. 지금은 호호책방 세 가지다.
///   · BOOKSTORE_REPORT — "독서 결과 도착"(book_clinic AppSendService) → 정독 결과
///   · BOOKSTORE_ATTENDANCE — 입실·퇴실(book_clinic AttendancePushListener) → 책방 출석체크
///   · BOOKSTORE_RESERVATION — 자동 예약 결과 10시 안내(book_clinic AutoReservationService) → 예약하기
///
/// 앱이 꺼져 있다가 알림으로 열리면 아직 로그인 전이라 바로 갈 수 없다 — 그때는 보관해 두었다가
/// 로그인이 끝나 첫 화면에 들어간 뒤([enterAfterLogin] 끝) [consumePendingPush] 로 이어서 연다.
const String pushTypeBookstoreReport = 'BOOKSTORE_REPORT';

/// 호호책방 입실·퇴실 알림(book_clinic AttendancePushListener) — 누르면 책방 출석체크 화면
const String pushTypeBookstoreAttendance = 'BOOKSTORE_ATTENDANCE';

/// 호호책방 자동 예약 결과 안내(book_clinic AutoReservationService, 매일 10시) — 누르면 예약하기 화면
const String pushTypeBookstoreReservation = 'BOOKSTORE_RESERVATION';

/// 앱이 화면 이동을 아는 알림 종류
const Set<String> bookstorePushTypes = {pushTypeBookstoreReport, pushTypeBookstoreAttendance, pushTypeBookstoreReservation};

Map<String, dynamic>? _pending;

Future<void> handlePushTap(Map<String, dynamic> data) async {
  final type = data['type']?.toString();
  if (!bookstorePushTypes.contains(type)) {
    return;
  }
  if (!_loggedIn()) {
    _pending = Map<String, dynamic>.from(data);
    return;
  }
  await _openFor(type!, data['studentId']?.toString());
}

/// 로그인 후 첫 화면에 들어간 직후 호출 — 보관해 둔 알림이 있으면 그 화면을 연다.
Future<void> consumePendingPush() async {
  final data = _pending;
  _pending = null;
  if (data != null) await handlePushTap(data);
}

bool _loggedIn() =>
    Get.isRegistered<UserDataController>() && Get.find<UserDataController>().hasUserData && bookstoreSessionCookie != null;

/// 알림의 학생이 지금 보고 있는 학생과 다르면(형제) 그 학생으로 바꾼 뒤 알림 종류에 맞는 화면을 연다.
/// 이 계정의 형제가 아닌 학생이면(기기를 다른 계정이 쓰는 중 등) 아무것도 하지 않는다.
Future<void> _openFor(String type, String? studentId) async {
  final userController = Get.find<UserDataController>();
  final current = userController.userData;

  if (studentId != null && studentId.isNotEmpty && studentId != current.stuId) {
    final siblings = Get.isRegistered<SiblingDataController>() ? Get.find<SiblingDataController>().siblingDataList : const <SiblingData>[];
    final match = siblings.where((s) => s.stuId == studentId);
    if (match.isEmpty) {
      return;
    }
    final selected = UserData.fromSibling(match.first);
    userController.setUserData(selected);
    await bookstoreSiblingSwitchService(selected.stuId);
    // 형제 선택과 같은 경로로 그 학생의 첫 화면을 깔고, 그 위에 정독 결과를 연다
    await enterAfterLogin(selected, isAdmin: userController.isAdmin, replace: false, consumePush: false);
  }

  if (type == pushTypeBookstoreAttendance) {
    Get.to(() => const BookstoreAttendanceScreen());
    return;
  }
  if (type == pushTypeBookstoreReservation) {
    Get.to(() => const BookstoreReservationScreen());
    return;
  }
  Get.to(() => const BookstoreReportScreen());
}
