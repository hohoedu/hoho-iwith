import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

final Dio dio = Dio(
  BaseOptions(
    // baseUrl: "https://hohocenter.co.kr/app",
    baseUrl: "http://192.168.0.136:8080/app",
    contentType: "application/json; charset=utf-8",
  ),
);

// const String bookstoreOrigin = "https://hohobooks.co.kr";
const String bookstoreOrigin = "https://ffb4-106-246-14-212.ngrok-free.app";

/// 앱 재시작 시엔 자동로그인이 세션을 다시 만들기 떄문에 메모리 보관으로 충분.
String? bookstoreSessionCookie; // 예: "JSESSIONID=abc123"

void clearBookstoreSession() => bookstoreSessionCookie = null;

/// JSESSIONID 값만 (쿠키 이름 제외). 결제 WebView에 심을 때 필요하다.
String? get bookstoreSessionId {
  final cookie = bookstoreSessionCookie;
  if (cookie == null) return null;
  final idx = cookie.indexOf('=');
  return idx < 0 ? null : cookie.substring(idx + 1);
}

InterceptorsWrapper _bookstoreSessionInterceptor() => InterceptorsWrapper(
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
    );

final Dio bookstoreDio = Dio(
  BaseOptions(
    baseUrl: "$bookstoreOrigin/app",
    contentType: "application/json; charset=utf-8",
  ),
)..interceptors.add(_bookstoreSessionInterceptor());

/// 이용권 결제용 Dio.
final Dio bookstorePaymentDio = Dio(
  BaseOptions(
    baseUrl: bookstoreOrigin,
    contentType: "application/json; charset=utf-8",
    validateStatus: (status) => status != null,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
  ),
)..interceptors.add(_bookstoreSessionInterceptor());

