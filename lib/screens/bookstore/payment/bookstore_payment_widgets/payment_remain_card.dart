import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_main_data.dart';
import 'package:flutter_application/models/payment/pass_payment_data.dart';
import 'package:flutter_application/screens/bookstore/payment/bookstore_payment_widgets/payment_refund_sheet.dart';
import 'package:get/get.dart';

/// 보유 이용권 카드 목록. 책방 예약 화면의 보유 이용권 카드와 같은 톤으로 맞춘다.
class PaymentRemainCard extends StatelessWidget {
  final int remain;

  const PaymentRemainCard({super.key, required this.remain});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookstoreMainDataController>(
      init: BookstoreMainDataController(),
      builder: (mainData) => _build(context, mainData.data),
    );
  }

  Widget _build(BuildContext context, BookstoreMainData? main) {
    final passes = Get.isRegistered<PassPaymentController>() ? Get.find<PassPaymentController>().passes : const <PassItem>[];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 12.0, bottom: 12.0, left: 4.0),
            child: Text(
              '보유한 호호책방 이용권',
              style: TextStyle(
                fontFamily: 'Pretendard-Bold',
                fontSize: 18,
                color: Color(0xFF363636),
              ),
            ),
          ),
          Expanded(
            child: passes.isEmpty
                ? ListView(children: [_fallbackCard(context, main)])
                : ListView.separated(
                    itemCount: passes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _passCard(context, passes[i]),
                  ),
          ),
        ],
      ),
    );
  }

  // ── 건별 카드 (/app/pass/list) ──
  Widget _passCard(BuildContext context, PassItem item) {
    return _card(
      context,
      productName: item.productName,
      remainCount: item.remainCount,
      totalCount: item.totalCount,
      validUntilLabel: _untilLabel(item.validUntil),
      onRefund: item.remainCount <= 0
          ? null
          : () => showPaymentRefundSheet(
                context: context,
                productName: item.productName,
                remainCount: item.remainCount,
                totalCount: item.totalCount,
                paidAtLabel: item.paidAtLabel,
                registeredAtLabel: item.registeredAtLabel,
                refundPeriodLabel: item.refundPeriodLabel,
                refundAmountLabel: item.refundAmountLabel,
              ),
    );
  }

  // ── 합산 폴백 카드 (/pass/remain) ──
  Widget _fallbackCard(BuildContext context, BookstoreMainData? main) {
    final passTotal = main?.passTotal;
    final productName = _productNameFor(passTotal);
    return _card(
      context,
      productName: productName,
      remainCount: remain,
      totalCount: passTotal,
      validUntilLabel: main?.passValidUntilLabel,
      onRefund: remain <= 0 ? null : () => _openFallbackRefund(context, productName: productName, passTotal: passTotal, passValidUntil: main?.passValidUntil),
    );
  }

  /// 카드 한 장. 건별/합산 공통 레이아웃.
  Widget _card(
    BuildContext context, {
    required String productName,
    required int remainCount,
    required int? totalCount,
    required String? validUntilLabel,
    required VoidCallback? onRefund,
  }) {
    return GestureDetector(
      onTap: onRefund,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Image.asset('assets/images/book_report/ticket.png', width: 64, height: 64),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          productName,
                          style: const TextStyle(
                            fontFamily: 'Pretendard-Bold',
                            fontSize: 18,
                            color: Color(0xFF363636),
                          ),
                        ),
                      ),
                      _statusBadge(remainCount, totalCount),
                    ],
                  ),
                  if (remainCount <= 0)
                    const Text(
                      '보유한 이용권이 없어요',
                      style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                    )
                  else
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: '남은 이용권   ',
                            style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                          ),
                          TextSpan(
                            text: '$remainCount',
                            style: const TextStyle(
                              fontFamily: 'Pretendard-Bold',
                              fontSize: 15,
                              color: Color(0xFF008D78),
                            ),
                          ),
                          TextSpan(
                            text: ' / ${totalCount ?? '-'}회',
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 13,
                              color: Color(0xFF363636),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (validUntilLabel != null)
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: '사용 기한   ',
                            style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                          ),
                          TextSpan(
                            text: validUntilLabel,
                            style: const TextStyle(
                              fontFamily: 'Pretendard-Bold',
                              fontSize: 15,
                              color: Color(0xFF363636),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 이용권 상태 배지 — 세 가지 상태를 색으로 구분한다.
  /// 이용 전(회색): 아직 한 번도 안 쓴 이용권 / 이용 중(초록): 쓰는 중 / 사용 완료(빨강): 남은 횟수 0.
  Widget _statusBadge(int remainCount, int? totalCount) {
    final Color color;
    final String label;
    if (remainCount <= 0) {
      color = const Color(0xFFE53935);
      label = '사용 완료';
    } else if (totalCount != null && remainCount >= totalCount) {
      color = const Color(0xFF9E9E9E);
      label = '사용 전';
    } else {
      color = const Color(0xFF008D7B);
      label = '이용 중';
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: TextStyle(color: color),
        ),
      ),
    );
  }

  /// 건별 목록이 없을 때(합산 카드)의 환불 시트 — 결제 내역에서 최신 결제 건을 골라 값을 맞춘다.
  void _openFallbackRefund(
    BuildContext context, {
    required String productName,
    required int? passTotal,
    required String? passValidUntil,
  }) {
    final total = passTotal ?? remain;
    final history = _activePaidHistory();

    final paidLabel = _dotted(history?.paidAt) ?? '-';
    final validLabel = _dottedFromYmd(passValidUntil);
    final period = (history?.paidAt != null && validLabel != null) ? '$paidLabel ~ $validLabel' : (validLabel ?? '-');

    final refundAmount = (history != null && total > 0) ? history.amount - (history.amount ~/ total) * (total - remain) : null;

    showPaymentRefundSheet(
      context: context,
      productName: productName,
      remainCount: remain,
      totalCount: total,
      paidAtLabel: paidLabel,
      registeredAtLabel: paidLabel,
      refundPeriodLabel: period,
      refundAmountLabel: refundAmount != null ? formatWon(refundAmount) : '-',
    );
  }

  /// 아직 환불되지 않은(부분환불 포함 X) 최신 결제 완료 건.
  PassPaymentHistory? _activePaidHistory() {
    if (!Get.isRegistered<PassPaymentController>()) return null;
    final paid = Get.find<PassPaymentController>().histories.where((h) => h.status == 'PAID' && h.refundAmount == 0).toList()
      ..sort((a, b) => (b.paidAt ?? DateTime(0)).compareTo(a.paidAt ?? DateTime(0)));
    return paid.isEmpty ? null : paid.first;
  }

  /// 'yyyy-MM-dd' → '2026년 11월 30일까지'
  String? _untilLabel(String? ymd) {
    if (ymd == null) return null;
    final p = ymd.split('-');
    if (p.length != 3) return ymd;
    final y = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    final d = int.tryParse(p[2]);
    if (y == null || m == null || d == null) return ymd;
    return '$y년 $m월 $d일까지';
  }

  /// DateTime → '2026.08.14'
  String? _dotted(DateTime? d) {
    if (d == null) return null;
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}.$m.$day';
  }

  /// 'yyyy-MM-dd' → '2026.11.30'
  String? _dottedFromYmd(String? ymd) {
    if (ymd == null) return null;
    final p = ymd.split('-');
    if (p.length != 3) return ymd;
    return '${p[0]}.${p[1].padLeft(2, '0')}.${p[2].padLeft(2, '0')}';
  }

  String _productNameFor(int? passTotal) {
    if (passTotal == null) return '호호책방 이용권';
    final products = Get.isRegistered<PassPaymentController>() ? Get.find<PassPaymentController>().products : <PassProduct>[];
    for (final p in products) {
      if (p.totalCount == passTotal) return p.productName;
    }
    return '시스템 $passTotal회 이용권';
  }
}
