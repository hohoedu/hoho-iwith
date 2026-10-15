import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/bookstore/bookstore_report_data.dart';
import 'package:flutter_application/utils/logout.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

/// 책 소개('어떤 책일까요?') 상세 조회.
///
/// 리포트 표지를 누른 시점에 contentId 로 한 권만 불러온다. 성공하면
/// [ReportBookDetail] 을, 실패/예외면 null 을 돌려준다 — 팝업이 null 을 받으면
/// 소개 없이 표지만 띄운다.
///
/// 세션이 끊겨 401 이 오면 소개를 못 띄우는 게 문제가 아니라 책방 세션 자체가
/// 만료된 것이므로 [logout] 으로 로그인 화면으로 돌려보낸다(팝업째 걷힌다).
/// 기본 Dio 는 401 에서 [DioException] 을 던지므로 catch 에서도 상태코드를 본다.
Future<ReportBookDetail?> bookstoreBookDetailService(int contentId) async {
  final String url = dotenv.get('BOOKSTORE_BOOK_DETAIL_URL', fallback: '/bookstore/book/detail');
  try {
    final response = await bookstoreDio.post(
      url,
      data: jsonEncode({'contentId': contentId}),
    );
    Logger().d('bookstoreBookDetail Response = $response');

    if (response.statusCode == 401) {
      _handleUnauthorized();
      return null;
    }
    if (response.statusCode == 200) {
      final Map<String, dynamic> body =
          response.data is String ? json.decode(response.data) : response.data;

      if (body['success'] == true && body['response'] != null) {
        return ReportBookDetail.fromJson(body['response'] as Map<String, dynamic>);
      }
      Logger().d('bookstoreBookDetailService: ${body['error']}');
      return null;
    }
    Logger().d('bookstoreBookDetailService: HTTP error ${response.statusCode}');
    return null;
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      _handleUnauthorized();
      return null;
    }
    Logger().d('bookstoreBookDetailService dio exception: $e');
    return null;
  } catch (e) {
    Logger().d('bookstoreBookDetailService exception: $e');
    return null;
  }
}

/// 세션 만료(401) 처리 — 저장된 로그인 정보를 지우고 로그인 화면으로 보낸다.
void _handleUnauthorized() {
  Logger().d('bookstoreBookDetailService: 401 세션 만료 → 로그인 이동');
  clearBookstoreSession();
  logout();
}
