import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class PaymentData {
  final String year;
  final String month;
  final String type;
  final String inDate;
  final String inMoney;
  final String category;

  PaymentData({
    required this.year,
    required this.month,
    required this.type,
    required this.inDate,
    required this.inMoney,
    required this.category,
  });

  PaymentData.fromJson(Map<String, dynamic> json)
      : year = _getYear(json['inym'] ?? ''),
        month = _getMonth(json['inym'] ?? ''),
        type = json['gb'] ?? '',
        inDate = _formatDate(json['indate'] ?? ''),
        inMoney = _formatMoney(json['inmoney'] ?? ''),
        category = json['gubun'] == 'B' ? '교재비' : '수강료';

  static String _getYear(String text) {
    return text.split('-')[0];
  }

  static String _getMonth(String text) {
    return int.parse(text.split('-')[1]).toString();
  }

  static String _formatDate(String text) {
    if (text.toString().isEmpty) return '';
    final year = text.substring(0, 4);
    final month = text.substring(4, 6);
    final day = text.substring(6, 8);
    return '$year.$month.$day';
  }

  static String _formatMoney(String text) {
    if (text.toString().isEmpty) return '';
    try {
      final num value = num.parse(text.toString());
      return NumberFormat('#,###').format(value);
    } catch (_) {
      return text.toString();
    }
  }
}

// ✅ 새 모델 추가
class GroupedPayment {
  final String year;
  final String month;
  final String category;
  final String inDate;
  final String? sMoney; // type == 'S'
  final String? iMoney; // type == 'I'

  GroupedPayment({
    required this.year,
    required this.month,
    required this.category,
    required this.inDate,
    this.sMoney,
    this.iMoney,
  });

  String get totalMoney {
    final s = _parseMoney(sMoney);
    final i = _parseMoney(iMoney);
    return NumberFormat('#,###').format(s + i);
  }

  num _parseMoney(String? value) {
    if (value == null || value.isEmpty) return 0;
    return num.tryParse(value.replaceAll(',', '')) ?? 0;
  }
}

class PaymentDataController extends GetxController {
  List<PaymentData> _paymentDataList = <PaymentData>[];

  void setPaymentDataList(List<PaymentData> paymentDataList) {
    _paymentDataList = List.from(paymentDataList);
    update();
  }

  List<PaymentData> get paymentDataList => _paymentDataList;

  // ✅ 그룹핑된 데이터 반환하는 함수
  List<GroupedPayment> getGroupedPayments() {
    final Map<String, GroupedPayment> groupedMap = {};

    for (var data in _paymentDataList) {
      final key = '${data.year}-${data.month}-${data.category}';

      if (!groupedMap.containsKey(key)) {
        groupedMap[key] = GroupedPayment(
          year: data.year,
          month: data.month,
          inDate: data.inDate,
          category: data.category,
        );
      }

      final current = groupedMap[key];

      groupedMap[key] = GroupedPayment(
        year: data.year,
        month: data.month,
        inDate: data.inDate,
        category: data.category,
        sMoney: data.type == 'S' ? data.inMoney : current?.sMoney,
        iMoney: data.type == 'I' ? data.inMoney : current?.iMoney,
      );
    }

    return groupedMap.values.toList();
  }
}
