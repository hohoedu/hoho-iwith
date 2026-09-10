import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

final Dio dio = Dio(
  BaseOptions(
    // baseUrl: "https://hohocenter.co.kr/app",
    baseUrl: "http://192.168.0.136:8080/app",
    contentType: "application/json; charset=utf-8",
  ),
);

/// 앱 재시작 시엔 자동로그인이 세션을 다시 만들기 떄문에 메모리 보관으로 충분.
String? bookstoreSessionCookie; // 예: "JSESSIONID=abc123"

void clearBookstoreSession() => bookstoreSessionCookie = null;

final Dio bookstoreDio = Dio(
  BaseOptions(
    // baseUrl: "https://hohobooks.co.kr/app",
    baseUrl: "http://192.168.0.136:8000/app",
    contentType: "application/json; charset=utf-8",
  ),
)..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (bookstoreSessionCookie != null) {
          options.headers['Cookie'] = bookstoreSessionCookie;
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        final setCookie = response.headers['set-cookie'];
        if (setCookie != null && setCookie.isNotEmpty) {
          for (final c in setCookie) {
            if (c.startsWith('JSESSIONID=')) {
              bookstoreSessionCookie = c.split(';').first; // "JSESSIONID=xxx"
              Logger().d(bookstoreSessionCookie);
              break;
            }
          }
        }
        handler.next(response);
      },
    ),
  );

// final Dio allPassDio = Dio(_options(dotenv.get("CORE_BASE_URL")));
// final Dio bookStoreDio = Dio(_options(dotenv.get("BOOKS_BASE_URL")));
