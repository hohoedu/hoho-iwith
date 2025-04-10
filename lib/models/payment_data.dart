import 'package:get/get.dart';

///////////////////////
// 교육비 내역 데이터 //
///////////////////////

class PaymentData {
  final String classDate; // 수업연월
  final String subjectName; // 수업 구분
  final int totalAmount; // 결제금액
  final String paymentDate; // 결제일
  final int cardAmount; // 카드 입금액
  final int transferAmount; // 계좌이체 입금액
  final int cashAmount; // 현금 입금액
  final String cashReceiptsDate; // 현금 영수증 발행일
  final String paymentName; // 교육비/교재비 구분
  final String paymentMethod; // 결제방법 구분

  // 생성자
  PaymentData({
    required this.classDate,
    required this.subjectName,
    required this.totalAmount,
    required this.paymentDate,
    required this.cardAmount,
    required this.transferAmount,
    required this.cashAmount,
    required this.cashReceiptsDate,
    required this.paymentName,
    required this.paymentMethod,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      classDate: json['inym'] ?? "",
      subjectName: json['gb'] ?? "",
      totalAmount: json['originalmoney_2'] ?? 0,
      paymentDate: json['indate'] ?? "",
      cardAmount: json['camount'] ?? 0,
      transferAmount: json['oamount'] ?? 0,
      cashAmount: json['hamount'] ?? 0,
      cashReceiptsDate: json['cashreceiptsdate'] ?? "",
      paymentName: json['amount_gb'] ?? "",
      paymentMethod: json['view_yn'] ?? "",
    );
  }
}

// 데이터 컨트롤러
class PaymentDataController extends GetxController {
  List<PaymentData>? _paymentDataList;

  void setPaymentDataList(List<PaymentData> paymentDataList) {
    _paymentDataList = paymentDataList;
    update();
  }

  List<PaymentData>? get paymentDataList => _paymentDataList;

  // 결제 개수
  get paymentCnt => _paymentDataList == null ? 0 : _paymentDataList!.length;
}
