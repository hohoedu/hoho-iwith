import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/payment/pass_payment_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// 호호책방 이용권 결제 서비스 (일시불).
///
/// [인증] book_clinic 세션(JSESSIONID)으로 본인을 확인한다. 책방 화면 진입 시
/// bookstoreLoginService가 만들어 둔 세션을 그대로 쓴다 — 세션이 없으면 전부 401이다.
///
/// [경로] 결제/이용권 API는 서버 루트에 있어(`/payment/**`, `/pass/**`) `/app`을 쓰는
/// bookstoreDio가 아니라 bookstorePaymentDio를 쓴다.
///
/// [결제창] 결제창을 여는 signature는 signKey로 만드는 값이라 앱이 만들 수 없다
/// (앱에 signKey를 넣으면 디컴파일로 유출된다). 서버가 결제창 페이지를 내려주고
/// 앱은 WebView로 그 주소를 열기만 한다 — 여기서는 그 앞뒤(주문 발급/이탈 통보)만 담당한다.

/// API 한 건을 보내고 응답 봉투를 벗겨 낸다.
///
/// [label] 어느 API인지 — 실패 로그에 남는다. 서버가 500을 던지면 원인은 서버 콘솔에만
/// 남는데, 앱 로그에 경로와 응답 본문이 없으면 어느 엔드포인트가 터졌는지부터 알 수 없다.
Future<dynamic> _send(String label, Future<dio.Response> Function() request) async {
  late final dio.Response response;
  try {
    response = await request();
  } on dio.DioException catch (e) {
    // 여기까지 오는 건 상태 코드가 아니라 연결 자체의 실패다(타임아웃/네트워크 끊김).
    Logger().d('[$label] 연결 실패: ${e.type} ${e.message}');
    throw PassPaymentException('서버에 연결하지 못했습니다. 네트워크를 확인해주세요.');
  }

  if (response.statusCode != 200) {
    Logger().d('[$label] ${response.requestOptions.method} '
        '${response.requestOptions.uri} → ${response.statusCode}\n${response.data}');
  }
  return _unwrap(label, response.data, response.statusCode);
}

/// 응답 봉투({success, response, error})를 벗겨 낸다.
/// 실패면 서버가 준 메시지를 그대로 던져 화면이 사용자에게 보여줄 수 있게 한다.
dynamic _unwrap(String label, dynamic raw, int? statusCode) {
  dynamic body;
  try {
    body = raw is String ? json.decode(raw) : raw;
  } catch (_) {
    // 500이면 스프링이 JSON 대신 오류 HTML을 내려주기도 한다 — 파싱 실패 자체가 정보다.
    body = null;
  }

  if (body is Map && body['success'] == true) {
    return body['response'];
  }

  // 4xx는 {success:false, error:{message}}, 처리되지 않은 500은 스프링 기본 본문
  // ({timestamp, status, error, message, path})로 온다 — 둘 다 읽는다.
  String? message;
  if (body is Map) {
    final error = body['error'];
    if (error is Map && error['message'] is String) {
      message = error['message'] as String;
    } else if (body['message'] is String && (body['message'] as String).isNotEmpty) {
      message = body['message'] as String;
    } else if (error is String && error.isNotEmpty) {
      message = error;
    }
  }

  if (statusCode != null && statusCode >= 500) {
    // 서버 내부 오류는 사용자에게 보여줄 문구가 아니다 — 원인은 서버 로그에 있고,
    // 여기서는 어느 API였는지만 남긴다.
    Logger().d('[$label] 서버 오류($statusCode): ${message ?? body}');
    throw PassPaymentException('서버에서 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
  }

  throw PassPaymentException(message ?? '요청을 처리하지 못했습니다. ($statusCode)');
}

/// 이용권 결제 화면 진입 시엔 첫 화면인 구매 탭에 필요한 상품 목록만 불러온다.
/// 관리 탭용 잔여/내역은 사용자가 그 탭으로 넘어갈 때 passManageInitService로 지연 로딩한다.
Future<void> passPaymentInitService(String studentId) async {
  final controller = Get.put(PassPaymentController(), permanent: true);

  controller.setLoading(true);
  controller.clearFailed();
  try {
    controller.setProducts(await passProductsService());
  } catch (e) {
    Logger().d('passPaymentInitService exception: $e');
    controller.setFailed();
  } finally {
    controller.setLoading(false);
  }
}

/// 관리 탭(잔여 이용권 / 결제 내역)을 처음 열 때 불러온다.
/// 진입 시가 아니라 탭 전환 시점에 부르므로 구매 화면 로딩을 지연시키지 않는다.
Future<void> passManageInitService(String studentId) async {
  final controller = Get.put(PassPaymentController(), permanent: true);

  controller.setManageLoading(true);
  try {
    final results = await Future.wait([
      passRemainService(studentId),
      passHistoryService(studentId),
    ]);
    controller.setRemain(results[0] as int);
    controller.setHistories(results[1] as List<PassPaymentHistory>);
  } catch (e) {
    Logger().d('passManageInitService exception: $e');
  } finally {
    controller.setManageLoading(false);
  }
}

/// 결제 완료 후 새로고침 — 상품 목록은 바뀌지 않으므로 잔여/내역만 다시 읽는다.
Future<void> passPaymentRefreshService(String studentId) async {
  final controller = Get.put(PassPaymentController(), permanent: true);
  try {
    final results = await Future.wait([
      passRemainService(studentId),
      passHistoryService(studentId),
    ]);
    controller.setRemain(results[0] as int);
    controller.setHistories(results[1] as List<PassPaymentHistory>);
  } catch (e) {
    Logger().d('passPaymentRefreshService exception: $e');
  }
}

/// 판매 중인 이용권 상품 목록
Future<List<PassProduct>> passProductsService() async {
  final String url = dotenv.get('PASS_PRODUCTS_URL', fallback: '/payment/products');
  final list = await _send(
    '이용권 상품 목록',
    () => bookstorePaymentDio.get(url, queryParameters: {'serviceCode': passServiceCode}),
  ) as List;
  return list
      .whereType<Map>()
      .map((e) => PassProduct.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

/// 잔여 이용 횟수
Future<int> passRemainService(String studentId) async {
  final String url = dotenv.get('PASS_REMAIN_URL', fallback: '/pass/remain');
  final body = await _send(
    '잔여 이용권',
    () => bookstorePaymentDio.get(
      url,
      queryParameters: {'studentId': studentId, 'serviceCode': passServiceCode},
    ),
  );
  final remain = body is Map ? body['remainCount'] : null;
  if (remain is int) return remain;
  return int.tryParse('${remain ?? ''}') ?? 0;
}

/// 결제 내역 — 형제 묶음결제 건은 형제 전체가 함께 나온다.
Future<List<PassPaymentHistory>> passHistoryService(String studentId) async {
  final String url = dotenv.get('PASS_HISTORY_URL', fallback: '/payment/history');
  final list = await _send(
    '결제 내역',
    () => bookstorePaymentDio.get(url, queryParameters: {'studentId': studentId}),
  ) as List;
  return list
      .whereType<Map>()
      .map((e) => PassPaymentHistory.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

/// 형제 목록 (본인 포함). 1건뿐이면 형제가 없다는 뜻이라 단건 결제로 가면 되고,
/// 2건 이상이면 선택 UI를 보여준 뒤 passPrepareGroupService를 쓴다.
Future<List<PassSibling>> passSiblingsService(String studentId) async {
  final String url = dotenv.get('PASS_SIBLINGS_URL', fallback: '/payment/siblings');
  final list = await _send(
    '형제 목록',
    () => bookstorePaymentDio.get(url, queryParameters: {'studentId': studentId}),
  ) as List;
  return list
      .whereType<Map>()
      .map((e) => PassSibling.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

/// 결제 시작 — 서버가 주문번호를 발급한다.
///
/// 앱이 결제창을 열기 전에 orderNo를 먼저 알아야, 사용자가 결제창을 닫았을 때
/// passAbandonService로 그 주문을 정확히 지목해 정리할 수 있다.
Future<PassPrepareResult> passPrepareService(
    String studentId, PassProduct product) async {
  final String url = dotenv.get('PASS_PREPARE_URL', fallback: '/payment/prepare');
  final body = await _send(
    '결제 시작',
    () => bookstorePaymentDio.post(
      url,
      data: jsonEncode({'studentId': studentId, 'productCode': product.productCode}),
    ),
  ) as Map;
  return PassPrepareResult(
    orderNo: body['orderNo'] as String,
    amount: body['amount'] is int ? body['amount'] as int : product.price,
    productName: (body['productName'] as String?) ?? product.productName,
  );
}

/// 형제 묶음결제 시작 — passPrepareService의 그룹 버전.
/// 결제창은 여기서 받은 groupOrderNo를 그대로 orderNo로 써서 연다(이탈 통보도 같은 값).
Future<PassPrepareResult> passPrepareGroupService(
    String studentId, List<String> siblingStudentIds, PassProduct product) async {
  final String url =
      dotenv.get('PASS_PREPARE_GROUP_URL', fallback: '/payment/prepare/group');
  final body = await _send(
    '형제 묶음결제 시작',
    () => bookstorePaymentDio.post(
      url,
      data: jsonEncode({
        'studentId': studentId,
        'siblingStudentIds': siblingStudentIds,
        'productCode': product.productCode,
      }),
    ),
  ) as Map;
  return PassPrepareResult(
    orderNo: body['groupOrderNo'] as String,
    amount: body['amount'] is int
        ? body['amount'] as int
        : product.price * siblingStudentIds.length,
    productName: (body['productName'] as String?) ?? product.productName,
  );
}

/// 결제창을 닫을 때 호출 — 승인 전 READY 상태로 방치되지 않도록 서버에 알린다.
/// 실패해도 사용자를 막지 않는다(최종 방어선은 서버의 READY 방치분 정리 배치다).
Future<void> passAbandonService(String studentId, String orderNo) async {
  final String url = dotenv.get('PASS_ABANDON_URL', fallback: '/payment/abandon');
  try {
    await _send(
      '결제 이탈 통보',
      () => bookstorePaymentDio.post(
        url,
        data: jsonEncode({'studentId': studentId, 'orderNo': orderNo}),
      ),
    );
  } catch (e) {
    Logger().d('passAbandonService exception: $e');
  }
}

/// 지금은 책방 이용권 하나만 판다. 상품군이 늘면 화면에서 고르게 해야 한다.
const String passServiceCode = 'BOOK';

class PassPaymentException implements Exception {
  final String message;

  PassPaymentException(this.message);

  @override
  String toString() => message;
}
