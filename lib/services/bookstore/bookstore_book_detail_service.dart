import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/bookstore/bookstore_report_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

/// 책 소개('어떤 책일까요?') 상세 조회.
///
/// 리포트 표지를 누른 시점에 contentId 로 한 권만 불러온다. 성공하면
/// [ReportBookDetail] 을, 실패/예외면 null 을 돌려준다 — 팝업이 null 을 받으면
/// 소개 없이 표지만 띄운다.
///
/// 세션이 끊겨 401 이 오면 bookstoreDio 인터셉터(http.dart)가 다시 로그인해 한 번 재시도한다.
/// 그래도 실패하면 다른 책방 화면과 똑같이 표지만 띄운다(예전에는 여기서만 강제 로그아웃했다).
Future<ReportBookDetail?> bookstoreBookDetailService(int contentId) async {
  final String url = dotenv.get('BOOKSTORE_BOOK_DETAIL_URL', fallback: '/bookstore/book/detail');
  try {
    final response = await bookstoreDio.post(
      url,
      data: jsonEncode({'contentId': contentId}),
    );
    Logger().d('bookstoreBookDetail Response = $response');

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
    Logger().d('bookstoreBookDetailService dio exception: $e');
    return null;
  } catch (e) {
    Logger().d('bookstoreBookDetailService exception: $e');
    return null;
  }
}
