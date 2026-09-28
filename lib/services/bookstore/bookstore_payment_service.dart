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
///
/// 예약 서비스(bookstore_reservation_service.dart)와 같은 방식으로 맞춘다 —
/// 응답 봉투는 각 함수에서 인라인으로 벗기고, 화면에 알려야 하는 실패는 결과 객체로 돌려준다.

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
    await _loadManage(controller, studentId);
  } catch (e) {
    Logger().d('passManageInitService exception: $e');
  } finally {
    controller.setManageLoading(false);
  }
}

/// 관리 탭 데이터(건별 이용권 / 합산 잔여 / 결제 내역)를 한 번에 읽는다.
/// 각 조회는 실패해도 기본값(0/빈 목록)으로 돌아오므로, 한 건이 막혀도 나머지는 그대로 채운다.
Future<void> _loadManage(PassPaymentController controller, String studentId) async {
  final results = await Future.wait([
    passRemainService(studentId),
    passHistoryService(studentId),
    passListService(studentId),
  ]);
  controller.setRemain(results[0] as int);
  controller.setHistories(results[1] as List<PassPaymentHistory>);
  controller.setPasses(results[2] as List<PassItem>);
}

/// 결제 완료 후 새로고침 — 상품 목록은 바뀌지 않으므로 잔여/내역만 다시 읽는다.
Future<void> passPaymentRefreshService(String studentId) async {
  final controller = Get.put(PassPaymentController(), permanent: true);
  try {
    await _loadManage(controller, studentId);
  } catch (e) {
    Logger().d('passPaymentRefreshService exception: $e');
  }
}

/// 판매 중인 이용권 상품 목록.
/// 구매 탭의 필수 데이터라, 실패하면 예외를 던져 진입 화면이 오류 상태를 보이게 한다.
Future<List<PassProduct>> passProductsService() async {
  final String url = dotenv.get('PASS_PRODUCTS_URL', fallback: '/payment/products');
  final response = await bookstorePaymentDio.get(
    url,
    queryParameters: {'serviceCode': passServiceCode},
  );
  Logger().d('passProducts Response = $response');

  if (response.statusCode == 200) {
    final Map<String, dynamic> body =
        response.data is String ? json.decode(response.data) : response.data;
    if (body['success'] == true && body['response'] != null) {
      return (body['response'] as List)
          .whereType<Map>()
          .map((e) => PassProduct.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    Logger().d('passProductsService: ${body['error']}');
  } else {
    Logger().d('passProductsService: HTTP error ${response.statusCode}');
  }
  throw Exception('이용권 상품 목록을 불러오지 못했습니다.');
}

/// 잔여 이용 횟수. 실패하면 0으로 돌아온다(관리 탭은 값이 없어도 화면을 유지한다).
Future<int> passRemainService(String studentId) async {
  final String url = dotenv.get('PASS_REMAIN_URL', fallback: '/pass/remain');
  try {
    final response = await bookstorePaymentDio.get(
      url,
      queryParameters: {'studentId': studentId, 'serviceCode': passServiceCode},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> body =
          response.data is String ? json.decode(response.data) : response.data;
      if (body['success'] == true && body['response'] is Map) {
        final remain = (body['response'] as Map)['remainCount'];
        if (remain is int) return remain;
        return int.tryParse('${remain ?? ''}') ?? 0;
      }
    }
  } catch (e) {
    Logger().d('passRemainService exception: $e');
  }
  return 0;
}

/// 건별 보유 이용권 목록.
///
/// 서버가 아직 이 엔드포인트를 안 가진 상태(404/500)면 빈 목록을 돌려준다 —
/// 화면은 목록이 비면 합산 잔여 카드로 폴백하므로, 여기서 막지 않는다.
Future<List<PassItem>> passListService(String studentId) async {
  final String url = dotenv.get('PASS_LIST_URL', fallback: '/app/pass/list');
  try {
    // book_clinic `POST /app/pass/list` {serviceCode} — studentId는 서버가 세션에서 꺼낸다.
    final response = await bookstorePaymentDio.post(
      url,
      data: jsonEncode({'serviceCode': passServiceCode}),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> body =
          response.data is String ? json.decode(response.data) : response.data;
      if (body['success'] == true && body['response'] != null) {
        return (body['response'] as List)
            .whereType<Map>()
            .map((e) => PassItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
  } catch (e) {
    Logger().d('passListService exception (합산 잔여로 폴백): $e');
  }
  return <PassItem>[];
}

/// 결제 내역 — 형제 묶음결제 건은 형제 전체가 함께 나온다.
/// 실패하면 빈 목록으로 돌아온다.
Future<List<PassPaymentHistory>> passHistoryService(String studentId) async {
  final String url = dotenv.get('PASS_HISTORY_URL', fallback: '/payment/history');
  try {
    final response = await bookstorePaymentDio.get(
      url,
      queryParameters: {'studentId': studentId},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> body =
          response.data is String ? json.decode(response.data) : response.data;
      if (body['success'] == true && body['response'] != null) {
        return (body['response'] as List)
            .whereType<Map>()
            .map((e) => PassPaymentHistory.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
  } catch (e) {
    Logger().d('passHistoryService exception: $e');
  }
  return <PassPaymentHistory>[];
}

/// 형제 목록 (본인 포함). 1건뿐이면 형제가 없다는 뜻이라 단건 결제로 가면 되고,
/// 2건 이상이면 선택 UI를 보여준 뒤 passPrepareGroupService를 쓴다.
/// 실패하면 빈 목록으로 돌아와, 화면은 단건 결제로 진행한다.
Future<List<PassSibling>> passSiblingsService(String studentId) async {
  final String url = dotenv.get('PASS_SIBLINGS_URL', fallback: '/payment/siblings');
  try {
    final response = await bookstorePaymentDio.get(
      url,
      queryParameters: {'studentId': studentId},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> body =
          response.data is String ? json.decode(response.data) : response.data;
      if (body['success'] == true && body['response'] != null) {
        return (body['response'] as List)
            .whereType<Map>()
            .map((e) => PassSibling.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
  } catch (e) {
    Logger().d('passSiblingsService exception: $e');
  }
  return <PassSibling>[];
}

/// 결제 시작 — 서버가 주문번호를 발급한다.
///
/// 앱이 결제창을 열기 전에 orderNo를 먼저 알아야, 사용자가 결제창을 닫았을 때
/// passAbandonService로 그 주문을 정확히 지목해 정리할 수 있다.
/// 실패는 예외가 아니라 PassPrepareResult.failed로 돌려줘, 화면이 사유를 보여준다.
Future<PassPrepareResult> passPrepareService(
    String studentId, PassProduct product) async {
  final String url = dotenv.get('PASS_PREPARE_URL', fallback: '/payment/prepare');
  try {
    final response = await bookstorePaymentDio.post(
      url,
      data: jsonEncode({'studentId': studentId, 'productCode': product.productCode}),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> body =
          response.data is String ? json.decode(response.data) : response.data;
      if (body['success'] == true && body['response'] is Map) {
        final data = body['response'] as Map;
        return PassPrepareResult(
          orderNo: data['orderNo'] as String,
          amount: data['amount'] is int ? data['amount'] as int : product.price,
          productName: (data['productName'] as String?) ?? product.productName,
        );
      }
      return PassPrepareResult.failed(body['error']?['message']?.toString());
    }
    return PassPrepareResult.failed('요청을 처리하지 못했습니다.');
  } catch (e) {
    Logger().d('passPrepareService exception: $e');
    return PassPrepareResult.failed(_errorMessageFrom(e));
  }
}

/// 형제 묶음결제 시작 — passPrepareService의 그룹 버전.
/// 결제창은 여기서 받은 groupOrderNo를 그대로 orderNo로 써서 연다(이탈 통보도 같은 값).
Future<PassPrepareResult> passPrepareGroupService(
    String studentId, List<String> siblingStudentIds, PassProduct product) async {
  final String url =
      dotenv.get('PASS_PREPARE_GROUP_URL', fallback: '/payment/prepare/group');
  try {
    final response = await bookstorePaymentDio.post(
      url,
      data: jsonEncode({
        'studentId': studentId,
        'siblingStudentIds': siblingStudentIds,
        'productCode': product.productCode,
      }),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> body =
          response.data is String ? json.decode(response.data) : response.data;
      if (body['success'] == true && body['response'] is Map) {
        final data = body['response'] as Map;
        return PassPrepareResult(
          orderNo: data['groupOrderNo'] as String,
          amount: data['amount'] is int
              ? data['amount'] as int
              : product.price * siblingStudentIds.length,
          productName: (data['productName'] as String?) ?? product.productName,
        );
      }
      return PassPrepareResult.failed(body['error']?['message']?.toString());
    }
    return PassPrepareResult.failed('요청을 처리하지 못했습니다.');
  } catch (e) {
    Logger().d('passPrepareGroupService exception: $e');
    return PassPrepareResult.failed(_errorMessageFrom(e));
  }
}

/// 결제창을 닫을 때 호출 — 승인 전 READY 상태로 방치되지 않도록 서버에 알린다.
/// 실패해도 사용자를 막지 않는다(최종 방어선은 서버의 READY 방치분 정리 배치다).
Future<void> passAbandonService(String studentId, String orderNo) async {
  final String url = dotenv.get('PASS_ABANDON_URL', fallback: '/payment/abandon');
  try {
    await bookstorePaymentDio.post(
      url,
      data: jsonEncode({'studentId': studentId, 'orderNo': orderNo}),
    );
  } catch (e) {
    Logger().d('passAbandonService exception: $e');
  }
}

/// book_clinic은 4xx/5xx에도 공통 봉투({success:false, error:{message}})를 내려주므로,
/// Dio가 던진 DioException 안의 응답 바디에서 실제 실패 사유를 꺼내 보여준다.
String _errorMessageFrom(Object e) {
  if (e is dio.DioException) {
    final data = e.response?.data;
    if (data != null) {
      try {
        final Map<String, dynamic> body = data is String
            ? json.decode(data) as Map<String, dynamic>
            : Map<String, dynamic>.from(data as Map);
        final error = body['error'];
        if (error is Map && error['message'] != null) {
          return error['message'].toString();
        }
      } catch (_) {
        // 바디가 공통 봉투 형식이 아니면(예: 서버가 죽어 프록시 에러 페이지가 온 경우) 아래 기본 메시지로.
      }
    }
  }
  return '요청 처리 중 오류가 발생했습니다.';
}

/// 지금은 책방 이용권 하나만 판다. 상품군이 늘면 화면에서 고르게 해야 한다.
const String passServiceCode = 'BOOK';
