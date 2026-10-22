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
const String bookstoreOrigin = "https://d7a6-106-246-14-212.ngrok-free.app";

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

/// 책방 세션 재발급 — 로그인 서비스(bookstore_login_service.dart)가 로그인에 성공하면 등록한다.
/// 서버 재시작·세션 만료로 401이 오면 인터셉터가 이걸로 같은 방식(일반/관리자 + 형제 전환)으로
/// 다시 로그인한 뒤 원래 요청을 한 번만 재시도한다. 로그아웃하면 null 로 돌아간다.
Future<bool> Function()? bookstoreReauthHandler;

/// 동시에 여러 요청이 401을 받아도 재로그인은 한 번만 하도록 진행 중인 작업을 공유한다.
Future<bool>? _reauthInFlight;

/// 재로그인 자체에 쓰는 경로 — 여기서 401이 나면 재시도하지 않는다(무한 반복 방지).
const List<String> _authPaths = ['/login', '/login/admin', '/sibling/switch', '/logout'];
const String _retriedKey = 'bookstoreReauthRetried';

bool _isAuthPath(RequestOptions options) => _authPaths.any((p) => options.path == p || options.path.endsWith('/app$p'));

Future<bool> _reauth() {
  final handler = bookstoreReauthHandler;
  if (handler == null) return Future.value(false);
  return _reauthInFlight ??= handler().whenComplete(() => _reauthInFlight = null);
}

/// 401이면 재로그인 후 같은 요청을 새 세션으로 다시 보낸다. 재시도할 수 없으면 null.
Future<Response<dynamic>?> _retryAfterReauth(Dio dio, RequestOptions options) async {
  if (options.extra[_retriedKey] == true || _isAuthPath(options)) return null;
  final ok = await _reauth();
  if (!ok) return null;
  options.extra[_retriedKey] = true;
  options.headers.remove('Cookie'); // onRequest 가 새 세션 쿠키를 다시 넣는다
  try {
    return await dio.fetch<dynamic>(options);
  } on DioException catch (e) {
    return e.response;
  }
}

void _saveSessionCookie(Response response) {
  final setCookie = response.headers['set-cookie'];
  if (setCookie != null && setCookie.isNotEmpty) {
    for (final c in setCookie) {
      if (c.startsWith('JSESSIONID=')) {
        bookstoreSessionCookie = c.split(';').first;
        break;
      }
    }
  }
}

InterceptorsWrapper _bookstoreSessionInterceptor(Dio Function() dio) => InterceptorsWrapper(
      onRequest: (options, handler) {
        if (bookstoreSessionCookie != null) {
          options.headers['Cookie'] = bookstoreSessionCookie;
        }
        handler.next(options);
      },
      // validateStatus 가 모든 상태를 받는 결제용 Dio 는 401도 여기로 온다
      onResponse: (response, handler) async {
        _saveSessionCookie(response);
        if (response.statusCode == 401) {
          final retried = await _retryAfterReauth(dio(), response.requestOptions);
          if (retried != null) return handler.resolve(retried);
        }
        handler.next(response);
      },
      // 기본 validateStatus 를 쓰는 bookstoreDio 는 401이 예외로 온다
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final retried = await _retryAfterReauth(dio(), error.requestOptions);
          if (retried != null) {
            if ((retried.statusCode ?? 0) < 400) return handler.resolve(retried);
            // 재시도도 실패면 그 응답을 담아 넘긴다 — 서비스가 서버 오류 문구(error.message)를 그대로 보여준다
            return handler.reject(DioException(
              requestOptions: retried.requestOptions,
              response: retried,
              type: DioExceptionType.badResponse,
            ));
          }
        }
        handler.next(error);
      },
    );

final Dio bookstoreDio = Dio(
  BaseOptions(
    baseUrl: "$bookstoreOrigin/app",
    contentType: "application/json; charset=utf-8",
  ),
)..interceptors.add(_bookstoreSessionInterceptor(() => bookstoreDio));

/// 이용권 결제용 Dio.
final Dio bookstorePaymentDio = Dio(
  BaseOptions(
    baseUrl: bookstoreOrigin,
    contentType: "application/json; charset=utf-8",
    validateStatus: (status) => status != null,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
  ),
)..interceptors.add(_bookstoreSessionInterceptor(() => bookstorePaymentDio));

