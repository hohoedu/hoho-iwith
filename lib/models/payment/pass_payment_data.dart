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

  /// 상품 코드에서 'BOOK_' 접두어를 뗀 뒤 첫 글자로 종류를 가른다.
  /// 예: 'BOOK_T01' → 'T', 'BOOK_M12' → 'M'.
  String get _typeChar {
    final code = productCode.startsWith('BOOK_') ? productCode.substring(5) : productCode;
    return code.isEmpty ? '' : code[0].toUpperCase();
  }

  /// 체험권(T) — 등록 전 체험용.
  bool get isTrial => _typeChar == 'T';

  /// 정규 이용권(M).
  bool get isRegular => _typeChar == 'M';
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

/// 보유 이용권 한 건 — `POST /app/pass/list`
///
/// 잔여(/pass/remain)가 합산 한 값만 주는 것과 달리, 이건 결제 건마다 한 줄씩 온다.
/// 건별 환불은 이 단위로 이뤄지므로, 환불 시트에 필요한 값(결제일/등록일/사용기한/금액)을 함께 담는다.
class PassItem {
  final int paymentId;
  final String productName;
  final int totalCount; // 이 건의 총 횟수
  final int remainCount; // 이 건의 남은 횟수
  final int amount; // 결제 금액
  final int? refundableAmount; // 서버가 계산해 주면 그 값을 쓰고, 없으면 화면에서 계산
  final DateTime? paidAt; // 결제일 — 서버는 'yyyy-MM-dd HH:mm'로 보낸다
  final DateTime? registeredAt; // 이용권 등록일 (서버가 결제일로 메워 보낸다)
  final String? validUntil; // yyyy-MM-dd — 사용기한(=환불 가능 기간 끝)

  PassItem({
    required this.paymentId,
    required this.productName,
    required this.totalCount,
    required this.remainCount,
    required this.amount,
    required this.refundableAmount,
    required this.paidAt,
    required this.registeredAt,
    required this.validUntil,
  });

  PassItem.fromJson(Map<String, dynamic> json)
      : paymentId = _toInt(json['paymentId']),
        productName = json['productName'] ?? '',
        totalCount = _toInt(json['totalCount']),
        remainCount = _toInt(json['remainCount']),
        amount = _toInt(json['amount']),
        refundableAmount =
            json['refundableAmount'] == null ? null : _toInt(json['refundableAmount']),
        paidAt = _toDateTime(json['paidAt']),
        registeredAt = _toDateTime(json['registeredAt']),
        validUntil = json['validUntil']?.toString();

  bool get inUse => remainCount > 0;

  /// '2026.08.14' — 없으면 '-'
  String get paidAtLabel => _dotted(paidAt);

  /// 등록일이 따로 안 오면 결제일과 같게 본다.
  String get registeredAtLabel => _dotted(registeredAt ?? paidAt);

  /// '2026.08.14 ~ 2026.11.30' — 결제일/사용기한이 있어야 범위를 만든다.
  String get refundPeriodLabel {
    final until = _dottedYmd(validUntil);
    if (paidAt != null && until != '-') return '${_dotted(paidAt)} ~ $until';
    return until;
  }

  /// 환불 가능 금액 — 서버 값이 있으면 그대로, 없으면 결제금액에서 사용한 횟수만큼 차감한 잔여.
  /// 회당 단가(내림)를 사용한 횟수에만 곱해 빼므로, 안 쓴 이용권은 결제금액 그대로 환불된다.
  int get refundAmount {
    if (refundableAmount != null) return refundableAmount!;
    if (totalCount <= 0) return 0;
    final usedCount = totalCount - remainCount;
    return amount - (amount ~/ totalCount) * usedCount;
  }

  String get refundAmountLabel => formatWon(refundAmount);

  static String _dotted(DateTime? d) {
    if (d == null) return '-';
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}.$m.$day';
  }

  static String _dottedYmd(String? ymd) {
    if (ymd == null) return '-';
    final p = ymd.split('-');
    if (p.length != 3) return ymd;
    return '${p[0]}.${p[1].padLeft(2, '0')}.${p[2].padLeft(2, '0')}';
  }
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
///
/// 예약(ReservationActionResult/BatchPreviewResult)과 같은 결과 객체 방식 —
/// 실패해도 예외로 던지지 않고 [success]/[message]로 알려, 화면이 안내를 띄운다.
class PassPrepareResult {
  final bool success;
  final String? message;
  final String orderNo;
  final int amount;
  final String productName;

  PassPrepareResult({
    this.success = true,
    this.message,
    required this.orderNo,
    required this.amount,
    required this.productName,
  });

  /// 결제 시작에 실패했을 때 — 사유는 [message]에 담고 화면이 그대로 보여준다.
  PassPrepareResult.failed(this.message)
      : success = false,
        orderNo = '',
        amount = 0,
        productName = '';
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
  List<PassItem> _passes = <PassItem>[];
  int _remain = 0;
  bool _loading = false;
  bool _manageLoading = false;
  bool _failed = false;

  List<PassProduct> get products => _products;

  List<PassPaymentHistory> get histories => _histories;

  /// 건별 보유 이용권. 서버(/app/pass/list)가 주면 채워지고, 못 주면 비어 있다.
  List<PassItem> get passes => _passes;

  int get remain => _remain;

  bool get isLoading => _loading;

  /// 관리 탭(잔여/내역) 데이터 로딩 여부. 구매 탭(isLoading)과 분리해,
  /// 상품이 먼저 도착하면 구매 탭을 열고 관리 탭만 따로 로딩을 보인다.
  bool get isManageLoading => _manageLoading;

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

  void setPasses(List<PassItem> passes) {
    _passes = List.from(passes);
    update();
  }

  void setManageLoading(bool loading) {
    _manageLoading = loading;
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
