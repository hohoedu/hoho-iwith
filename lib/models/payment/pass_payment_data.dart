import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// 호호책방 이용권 결제 데이터.
///
/// book_clinic 결제 API(`/payment/**`, `/pass/**`) 응답을 담는다.
/// 학원비 납부 내역(payment_data.dart)과는 서버도 의미도 다른 별개의 결제다.

/// 판매 중인 이용권 상품 — `GET /payment/products`
class PassProduct {
  final String productCode;
  final String productName;
  final int totalCount; // 이용 가능 횟수
  final int price;

  PassProduct({
    required this.productCode,
    required this.productName,
    required this.totalCount,
    required this.price,
  });

  PassProduct.fromJson(Map<String, dynamic> json)
      : productCode = json['productCode'] ?? '',
        productName = json['productName'] ?? '',
        totalCount = _toInt(json['totalCount']),
        price = _toInt(json['price']);

  String get priceLabel => formatWon(price);

  String get countLabel => '$totalCount회';
}

/// 결제 내역 한 줄 — `GET /payment/history`
class PassPaymentHistory {
  final int paymentId;
  final String studentName;
  final String orderNo;
  final String productName;
  final int amount;
  final int refundAmount;
  final String status; // PAID / CANCELED / FAILED / READY ...
  final String cardName;
  final String cardNo;
  final DateTime? paidAt;

  PassPaymentHistory({
    required this.paymentId,
    required this.studentName,
    required this.orderNo,
    required this.productName,
    required this.amount,
    required this.refundAmount,
    required this.status,
    required this.cardName,
    required this.cardNo,
    required this.paidAt,
  });

  PassPaymentHistory.fromJson(Map<String, dynamic> json)
      : paymentId = _toInt(json['paymentId']),
        studentName = json['studentName'] ?? '',
        orderNo = json['orderNo'] ?? '',
        productName = json['productName'] ?? '',
        amount = _toInt(json['amount']),
        refundAmount = _toInt(json['refundAmount']),
        status = json['status'] ?? '',
        cardName = json['cardName'] ?? '',
        cardNo = json['cardNo'] ?? '',
        paidAt = _toDateTime(json['paidAt'] ?? json['requestedAt']);

  /// 부분환불은 별도 상태값이 없다 — PAID인데 환불액이 있으면 부분환불이다(서버 설계와 같은 규칙).
  String get statusLabel {
    switch (status) {
      case 'PAID':
        return refundAmount > 0 ? '부분환불' : '결제완료';
      case 'CANCELED':
        return '환불완료';
      case 'FAILED':
        return '결제실패';
      case 'READY':
        return '결제대기';
      default:
        return status;
    }
  }

  String get amountLabel => formatWon(amount);

  /// '2026.09.07' — 결제일이 없으면 빈 문자열
  String get paidAtLabel =>
      paidAt == null ? '' : DateFormat('yyyy.MM.dd').format(paidAt!);

  String get cardLabel => '$cardName $cardNo'.trim();
}

/// 형제 목록 한 줄 — `GET /payment/siblings` (본인 포함해서 온다)
class PassSibling {
  final String studentId;
  final String studentName;
  final String school;
  final String gradeKey;

  PassSibling({
    required this.studentId,
    required this.studentName,
    required this.school,
    required this.gradeKey,
  });

  PassSibling.fromJson(Map<String, dynamic> json)
      : studentId = json['studentId'] ?? '',
        studentName = json['studentName'] ?? '',
        school = json['school'] ?? '',
        gradeKey = json['gradeKey'] ?? '';
}

/// 결제 시작 결과 — 단건/형제 묶음 둘 다 이 형태로 맞춰 쓴다.
/// 결제창(WebView)은 여기 orderNo로 이미 만들어진 주문을 열기만 한다.
class PassPrepareResult {
  final String orderNo;
  final int amount;
  final String productName;

  PassPrepareResult({
    required this.orderNo,
    required this.amount,
    required this.productName,
  });
}

/// 결제창이 닫히며 돌려주는 결과.
class PassCheckoutResult {
  final String status; // ok / cancel / fail
  final int remain; // 결제 후 잔여 횟수
  final String? message;

  PassCheckoutResult({required this.status, required this.remain, this.message});

  bool get isSuccess => status == 'ok';
}

/// 이용권 결제 화면 상태.
class PassPaymentController extends GetxController {
  List<PassProduct> _products = <PassProduct>[];
  List<PassPaymentHistory> _histories = <PassPaymentHistory>[];
  int _remain = 0;
  bool _loading = false;
  bool _failed = false;

  List<PassProduct> get products => _products;

  List<PassPaymentHistory> get histories => _histories;

  int get remain => _remain;

  bool get isLoading => _loading;

  bool get isFailed => _failed;

  void setProducts(List<PassProduct> products) {
    _products = List.from(products);
    update();
  }

  void setHistories(List<PassPaymentHistory> histories) {
    _histories = List.from(histories);
    update();
  }

  void setRemain(int remain) {
    _remain = remain;
    update();
  }

  void setLoading(bool loading) {
    _loading = loading;
    update();
  }

  void setFailed() {
    _failed = true;
    update();
  }

  void clearFailed() {
    _failed = false;
    update();
  }
}

/// '25,000원'
String formatWon(int amount) => '${NumberFormat('#,###').format(amount)}원';

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('${value ?? ''}') ?? 0;
}

/// 서버 LocalDateTime이 ISO 문자열로 올 수도, [y,M,d,H,m,s] 배열로 올 수도 있다
/// (Jackson 설정에 따라 달라진다). 어느 쪽이든 깨지지 않게 둘 다 받는다.
DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  if (value is List && value.length >= 3) {
    int at(int i) => i < value.length ? _toInt(value[i]) : 0;
    return DateTime(at(0), at(1), at(2), at(3), at(4), at(5));
  }
  return null;
}
