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
Future<bool> bookstoreLoginService(String appId, String rawPassword) async {
  try {
    final response = await bookstoreDio.post(
      '/login',
      data: jsonEncode({'appId': appId, 'password': rawPassword}),
    );
    final body = response.data is String ? json.decode(response.data) : response.data;
    final ok = response.statusCode == 200 && body is Map && body['success'] == true;
    if (!ok) {
      Logger().d('bookstoreLoginService 실패: ${response.statusCode} $body');
      clearBookstoreSession();
    }
    return ok;
  } catch (e) {
    Logger().d('bookstoreLoginService exception: $e');
    clearBookstoreSession();
    return false;
  }
}
