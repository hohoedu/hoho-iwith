import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:logger/logger.dart';

/// book_clinic(책방) 서버 세션 로그인.
///
/// all_pass 로그인과 별개다. 책방 API 는 세션(JSESSIONID 쿠키) 인증이라,
/// 책방 화면 진입 전에 이걸로 세션을 먼저 만들어야 한다.
/// 응답의 Set-Cookie 는 bookstoreDio 인터셉터(http.dart)가 자동 저장한다.
///
/// [appId] all_pass 와 동일한 앱 계정 아이디
/// [rawPassword] 평문 비밀번호 (서버가 해시함 — sha 전처리 X)
Future<bool> bookstoreLoginService(String appId, String rawPassword) {
  return _bookstoreLogin('/login', {'appId': appId, 'password': rawPassword}, 'bookstoreLoginService');
}

/// 관리자(직원) 로그인 — all_pass `/login_skip` 과 같은 흐름의 책방 세션.
///
/// 학생 비밀번호 없이 그 학생으로 들어가며, 서버가 세션을 조회 전용으로 표시한다
/// (결제·환불·예약 변경은 403). [password] 는 로그인 화면에 입력한 직원용 값을 그대로 보낸다.
Future<bool> bookstoreAdminLoginService(String appId, String password) {
  return _bookstoreLogin('/login/admin', {'appId': appId, 'password': password}, 'bookstoreAdminLoginService');
}

/// 형제 전환 — 지금 책방 세션을 같은 형제 그룹의 [studentId] 학생으로 바꾼다.
///
/// 형제 계정의 비밀번호는 앱이 모르므로 다시 로그인하지 않고, 이미 로그인한 세션으로
/// 서버가 형제 여부를 확인해 바꿔 준다. 관리자 세션이면 서버가 조회 전용 표시를 유지한다.
/// 세션이 없으면(책방 로그인 실패) 호출하지 않고 false.
Future<bool> bookstoreSiblingSwitchService(String studentId) async {
  if (bookstoreSessionCookie == null) return false;
  final ok = await _bookstoreSessionRequest(
        '/sibling/switch',
        {'studentId': studentId},
        'bookstoreSiblingSwitchService',
      ) !=
      null;
  _sessionStudentId = ok ? studentId : null;
  return ok;
}

/// 책방 세션 로그아웃 — 서버 세션을 끊고 앱에 보관한 쿠키도 지운다.
Future<void> bookstoreLogoutService() async {
  if (bookstoreSessionCookie != null) {
    try {
      await bookstoreDio.post('/logout');
    } catch (e) {
      Logger().d('bookstoreLogoutService exception: $e');
    }
  }
  clearBookstoreSession();
  // 로그아웃 뒤에는 401이 와도 다시 로그인하면 안 된다
  _lastLogin = null;
  _sessionStudentId = null;
  bookstoreReauthHandler = null;
}

// ── 세션 만료 시 자동 재로그인 (2026-10-22) ──
//
// 서버 재시작·세션 만료로 책방 요청이 401을 받으면 http.dart 인터셉터가 bookstoreReauthHandler 를 부른다.
// 마지막에 성공한 로그인 요청(일반/관리자)을 그대로 다시 보내고, 그때 고른 형제가 로그인 계정과 다르면
// 형제 전환까지 다시 해서 "지금 보고 있던 학생"의 세션을 복구한다. 비밀번호는 메모리에만 둔다.

/// 마지막으로 성공한 로그인 요청 (경로 + 본문)
({String path, Map<String, dynamic> data})? _lastLogin;

/// 지금 세션이 가리키는 학생 — 형제 전환까지 반영된 값
String? _sessionStudentId;

Future<bool> _bookstoreLogin(String path, Map<String, dynamic> data, String tag) async {
  final studentId = await _bookstoreSessionRequest(path, data, tag);
  if (studentId == null) return false;
  _lastLogin = (path: path, data: data);
  _sessionStudentId = studentId;
  bookstoreReauthHandler = _reauth;
  return true;
}

Future<bool> _reauth() async {
  final last = _lastLogin;
  if (last == null) return false;
  final target = _sessionStudentId;
  Logger().d('[책방] 세션 만료 → 다시 로그인');
  final loginStudentId = await _bookstoreSessionRequest(last.path, last.data, 'bookstoreReauth');
  if (loginStudentId == null) return false;
  if (target != null && target != loginStudentId) {
    final switched = await _bookstoreSessionRequest('/sibling/switch', {'studentId': target}, 'bookstoreReauthSwitch');
    if (switched == null) return false;
  }
  _sessionStudentId = target ?? loginStudentId;
  return true;
}

/// 세션을 새로 받는 요청 공통 처리 — 실패하면 남아 있던 쿠키를 지워 이전 학생 세션으로
/// 책방 화면이 열리지 않게 한다. 성공하면 응답의 studentId(없으면 빈 문자열), 실패하면 null.
Future<String?> _bookstoreSessionRequest(String path, Map<String, dynamic> data, String tag) async {
  try {
    final response = await bookstoreDio.post(path, data: jsonEncode(data));
    final body = response.data is String ? json.decode(response.data) : response.data;
    final ok = response.statusCode == 200 && body is Map && body['success'] == true;
    if (!ok) {
      Logger().d('$tag 실패: ${response.statusCode} $body');
      clearBookstoreSession();
      return null;
    }
    final res = body['response'];
    return (res is Map ? res['studentId']?.toString() : null) ?? '';
  } catch (e) {
    Logger().d('$tag exception: $e');
    clearBookstoreSession();
    return null;
  }
}
