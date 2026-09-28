import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// 환불 신청 바텀시트.
Future<bool?> showPaymentRefundSheet({
  required BuildContext context,
  required String productName,
  required int remainCount,
  required int totalCount,
  required String paidAtLabel,
  required String registeredAtLabel,
  required String refundPeriodLabel,
  required String refundAmountLabel,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _PaymentRefundSheet(
      productName: productName,
      remainCount: remainCount,
      totalCount: totalCount,
      paidAtLabel: paidAtLabel,
      registeredAtLabel: registeredAtLabel,
      refundPeriodLabel: refundPeriodLabel,
      refundAmountLabel: refundAmountLabel,
    ),
  );
}

class _PaymentRefundSheet extends StatelessWidget {
  final String productName;
  final int remainCount;
  final int totalCount;
  final String paidAtLabel;
  final String registeredAtLabel;
  final String refundPeriodLabel;
  final String refundAmountLabel;

  const _PaymentRefundSheet({
    required this.productName,
    required this.remainCount,
    required this.totalCount,
    required this.paidAtLabel,
    required this.registeredAtLabel,
    required this.refundPeriodLabel,
    required this.refundAmountLabel,
  });

  static const Color _pink = Color(0xFFF95C9B);
  static const Color _mint = Color(0xFF21BA82);
  static const Color _title = Color(0xFF363636);
  static const Color _grey = Color(0xFF9E9E9E);
  static const Color _red = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            const SizedBox(height: 16),
            _infoCard(),
            const SizedBox(height: 12),
            _amountCard(),
            const SizedBox(height: 12),
            _guide(),
            const SizedBox(height: 20),
            _actions(context),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '상세 내역',
          style: TextStyle(
            fontFamily: 'Pretendard-Bold',
            fontSize: 20,
            color: _title,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.close, size: 26, color: Color(0xFFBDBDBD)),
        ),
      ],
    );
  }

  Widget _infoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/images/book_report/ticket.png', width: 52, height: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  productName,
                  style: const TextStyle(
                    fontFamily: 'Pretendard-Bold',
                    fontSize: 16,
                    color: _title,
                  ),
                ),
              ),
              _statusBadge(),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFF0F0F0)),
          ),
          _infoRow(Icons.calendar_today_outlined, '결제일', paidAtLabel),
          const SizedBox(height: 14),
          _infoRow(Icons.event_available_outlined, '이용권 등록일', registeredAtLabel),
          const SizedBox(height: 14),
          _infoRow(Icons.receipt_long_outlined, '이용권 남은 횟수', '$remainCount / $totalCount회'),
          const SizedBox(height: 14),
          _infoRow(
            Icons.schedule,
            '환불 가능한 기간',
            refundPeriodLabel,
            subValue: '(사용기한 내)',
          ),
        ],
      ),
    );
  }

  /// 이용권 상태 배지 — 사용 전(회색) / 이용중(초록) / 사용 완료(빨강).
  Widget _statusBadge() {
    final Color color;
    final Color bg;
    final String label;
    if (remainCount <= 0) {
      color = _red;
      bg = const Color(0xFFFDE7E7);
      label = '사용 완료';
    } else if (remainCount >= totalCount) {
      color = _grey;
      bg = const Color(0xFFEEEEEE);
      label = '사용 전';
    } else {
      color = _mint;
      bg = const Color(0xFFD5F6E9);
      label = '이용중';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Pretendard-Bold',
          fontSize: 12,
          color: color,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {String? subValue}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _grey),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6C7176)),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Pretendard-Bold',
                fontSize: 14,
                color: _title,
              ),
            ),
            if (subValue != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  subValue,
                  style: const TextStyle(fontSize: 12, color: _grey),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _amountCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFE9F2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.savings_outlined, size: 20, color: _pink),
              SizedBox(width: 8),
              Text(
                '환불 가능 금액',
                style: TextStyle(
                  fontFamily: 'Pretendard-Bold',
                  fontSize: 15,
                  color: _pink,
                ),
              ),
            ],
          ),
          Text(
            refundAmountLabel,
            style: const TextStyle(
              fontFamily: 'Pretendard-Bold',
              fontSize: 20,
              color: _pink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _guide() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 18, color: Color(0xFF9AA0A6)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '환불 금액은 결제금액을 총 이용 횟수로 나눈 금액 기준으로, 사용한 횟수만큼 차감 후 잔여 금액을 부분 취소합니다.',
              style: TextStyle(fontSize: 12, color: Color(0xFF6C7176)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _confirmRefund(context),
            child: _button('환불 신청', _pink, Colors.white),
          ),
        ),
      ],
    );
  }

  void _confirmRefund(BuildContext context) {
    AwesomeDialog(
      context: Get.context!,
      width: 400,
      animType: AnimType.scale,
      dialogType: DialogType.noHeader,
      dismissOnTouchOutside: false,
      descTextStyle: const TextStyle(fontSize: 15, fontFamily: 'Pretendard'),
      desc: '환불 후에는 남은 이용권이 모두 소멸되어\n다시 사용할 수 없습니다.\n그래도 환불을 진행하시겠습니까?',
      title: '정말로 환불하시겠습니까?',
      btnOkText: '취소',
      // btnOkColor: const Color(0xFF008D78),
      btnOkColor: const Color(0xFF6C7176),
      btnOkOnPress: () {
        Logger().d('취소');
      },
      btnCancelText: '환불 신청',
      btnCancelColor: Colors.red[400],
      btnCancelOnPress: () {
        Logger().d('환불');
      },
    ).show();
  }

  Widget _button(String label, Color bg, Color fg) {
    return Container(
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: bg),
      child: Text(
        label,
        style: TextStyle(fontFamily: 'Pretendard-Bold', fontSize: 16, color: fg),
      ),
    );
  }
}
