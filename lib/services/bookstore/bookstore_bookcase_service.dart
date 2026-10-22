import 'dart:convert';

import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/bookstore/bookstore_bookcase_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

/// 내 책장 — 올해 읽은 책 전체. book_clinic `POST /app/bookstore/bookcase`.
///
/// 성공하면 최신순 목록(없으면 빈 목록), 요청 자체가 실패하면 null 을 돌려준다 —
/// 화면이 null 일 때만 메인 화면의 최근 표지로 대신 채운다.
Future<List<BookcaseBook>?> bookstoreBookcaseService() async {
  final String url = dotenv.get('BOOKSTORE_BOOKCASE_URL', fallback: '/bookstore/bookcase');
  try {
    final response = await bookstoreDio.post(url, data: jsonEncode(const {}));
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = response.data is String ? json.decode(response.data) : response.data;
      if (body['success'] == true && body['response'] is List) {
        return (body['response'] as List)
            .whereType<Map>()
            .map((e) => BookcaseBook.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      Logger().d('bookstoreBookcaseService: ${body['error']}');
    } else {
      Logger().d('bookstoreBookcaseService: HTTP error ${response.statusCode}');
    }
  } catch (e) {
    Logger().d('bookstoreBookcaseService exception: $e');
  }
  return null;
}
