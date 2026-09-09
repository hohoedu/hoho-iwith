import 'dart:ui';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class PaymentData {
  final String year;
  final String month;
  final String type;
  final String inDate;
  final String inMoney;
  final String state;
  final ({Color bg, Color text}) stateColor;
  final String className;
  final String category;

  PaymentData({
    required this.year,
    required this.month,
    required this.type,
    required this.inDate,
    required this.inMoney,
    required this.state,
    required this.stateColor,
    required this.className,
    required this.category,
  });

  PaymentData.fromJson(Map<String, dynamic> json)
      : year = _getYear(json['inym'] ?? ''),
        month = _getMonth(json['inym'] ?? ''),
        type = json['gb'] ?? '',
        inDate = _formatDate(json['indate'] ?? ''),
        inMoney = _formatMoney(json['inmoney'] ?? ''),
        state = _formatState(json['state'] ?? ''),
        stateColor = _formatStateColor(json['state'] ?? ''),
        className = json['className'] ?? '',
        category = json['gubun'] == 'B' ? '교재비' : '수강료';

  static String _getYear(String text) => text.split('-')[0];

  static String _getMonth(String text) => int.parse(text.split('-')[1]).toString();

  static String _formatDate(String text) {
    if (text.isEmpty) return '';
    return '${text.substring(0, 4)}.${text.substring(4, 6)}.${text.substring(6, 8)}';
  }

  static String _formatMoney(String text) {
    if (text.isEmpty) return '';
    try {
      return NumberFormat('#,###').format(num.parse(text));
    } catch (_) {
      return text;
    }
  }

  static String _formatState(String text) {
    const stateMap = {
      'issued':    '결제대기',
      'partial':   '부분결제',
      'approved':  '결제완료',
      'canceled':  '결제취소',
      'destroyed': '청구서파기',
    };
    return stateMap[text] ?? text;
  }

  static ({Color bg, Color text}) _formatStateColor(String text) {
    final stateColorMap = {
      'issued':    (bg: const Color(0xFFE0E0E0), text: const Color(0xFF757575)), // 결제대기 - 회색 계열
      'partial':   (bg: const Color(0xFFF7C106), text: const Color(0xFF9B5102)), // 부분결제 - 노랑
      'approved':  (bg: const Color(0xFF7ADFD2), text: const Color(0xFF008D7B)), // 결제완료 - 초록
      'canceled':  (bg: const Color(0xFFFF9696), text: const Color(0xFFBE2727)), // 결제취소 - 빨강
      'destroyed': (bg: const Color(0xFFFF9696), text: const Color(0xFFBE2727)), // 청구서파기 - 빨강
    };
    return stateColorMap[text] ?? (bg: const Color(0xFFE0E0E0), text: const Color(0xFF757575));
  }
}

class GroupedPayment {
  final String year;
  final String month;
  final String category;
  final String inDate;
  final String state;
  final ({Color bg, Color text}) stateColor;
  final String? sClassName;
  final String? iClassName;
  final String? sMoney;
  final String? iMoney;

  GroupedPayment({
    required this.year,
    required this.month,
    required this.category,
    required this.inDate,
    required this.state,
    required this.stateColor,
    this.sClassName,
    this.iClassName,
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
          state: data.state,
          stateColor: data.stateColor,
          sClassName: data.type == 'S' ? data.className : null,
          iClassName: data.type == 'I' ? data.className : null,
          sMoney: data.type == 'S' ? data.inMoney : null,
          iMoney: data.type == 'I' ? data.inMoney : null,
        );
      } else {
        final current = groupedMap[key]!;
        groupedMap[key] = GroupedPayment(
          year: current.year,
          month: current.month,
          inDate: current.inDate,
          category: current.category,
          state: current.state,
          stateColor: current.stateColor,
          sClassName: data.type == 'S' ? data.className : current.sClassName,
          iClassName: data.type == 'I' ? data.className : current.iClassName,
          sMoney: data.type == 'S' ? data.inMoney : current.sMoney,
          iMoney: data.type == 'I' ? data.inMoney : current.iMoney,
        );
      }
    }

    return groupedMap.values.toList();
  }
}