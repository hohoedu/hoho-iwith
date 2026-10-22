import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/payment/pass_payment_data.dart';
import 'package:flutter_application/services/bookstore/bookstore_main_service.dart';
import 'package:flutter_application/services/bookstore/bookstore_payment_service.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:get/get.dart';

/// 환불 신청 바텀시트.
///
/// 열리면 서버 환불 견적(/payment/refund/quote)을 받아 "환불 가능 금액"과 적용 규정을 보여주고,
/// 신청하면 /payment/refund 로 실제 환불(PG 취소)까지 진행한다. 금액은 앱이 계산하지 않고 서버 견적만 쓴다.
/// 환불에 성공하면 잔여·결제 내역·책방 메인을 새로 읽고 true 로 닫힌다.
Future<bool?> showPaymentRefundSheet({
  required BuildContext context,
  required String studentId,
  required int? paymentId,
  required String productName,
  required int remainCount,
  required int totalCount,
  required String paidAtLabel,
  required String registeredAtLabel,
  required String refundPeriodLabel,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _PaymentRefundSheet(
      studentId: studentId,
      paymentId: paymentId,
      productName: productName,
      remainCount: remainCount,
      totalCount: totalCount,
      paidAtLabel: paidAtLabel,
      registeredAtLabel: registeredAtLabel,
      refundPeriodLabel: refundPeriodLabel,
    ),
  );
}

class _PaymentRefundSheet extends StatefulWidget {
  final String studentId;
  final int? paymentId;
  final String productName;
  final int remainCount;
  final int totalCount;
  final String paidAtLabel;
  final String registeredAtLabel;
  final String refundPeriodLabel;

  const _PaymentRefundSheet({
    required this.studentId,
    required this.paymentId,
    required this.productName,
    required this.remainCount,
    required this.totalCount,
    required this.paidAtLabel,
    required this.registeredAtLabel,
    required this.refundPeriodLabel,
  });

  @override
  State<_PaymentRefundSheet> createState() => _PaymentRefundSheetState();
}

class _PaymentRefundSheetState extends State<_PaymentRefundSheet> {
  PassRefundQuote? _quote; // null = 견적 불러오는 중
  bool _submitting = false;

  String get productName => widget.productName;
  int get remainCount => widget.remainCount;
  int get totalCount => widget.totalCount;
  String get paidAtLabel => widget.paidAtLabel;
  String get registeredAtLabel => widget.registeredAtLabel;
  String get refundPeriodLabel => widget.refundPeriodLabel;

  /// 견적이 환불 가능으로 나왔을 때만 신청할 수 있다
  bool get _canRefund => !_submitting && (_quote?.success ?? false) && _quote!.refundable;

  @override
  void initState() {
    super.initState();
    _loadQuote();
  }

  Future<void> _loadQuote() async {
    final paymentId = widget.paymentId;
    final quote = paymentId == null
        ? PassRefundQuote.failed('환불할 결제 건을 찾지 못했습니다.')
        : await passRefundQuoteService(widget.studentId, paymentId);
    if (!mounted) return;
    setState(() => _quote = quote);
  }

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
            subValue: '(결제일로부터 3개월)',
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
          _quote == null
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _pink),
                )
              : Text(
                  (_quote!.success && _quote!.refundable) ? _quote!.refundAmountLabel : '-',
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFF9AA0A6)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _guideText,
              style: TextStyle(fontSize: 12, color: _quoteBlocked ? _red : const Color(0xFF6C7176)),
            ),
          ),
        ],
      ),
    );
  }

  /// 견적을 받았는데 환불이 안 되는 경우(규정상 불가 / 조회 실패) — 안내 문구를 빨갛게 보여준다
  bool get _quoteBlocked => _quote != null && !(_quote!.success && _quote!.refundable);

  String get _guideText {
    final quote = _quote;
    if (quote == null) return '환불 가능 금액을 확인하고 있습니다.';
    if (!quote.success) return quote.message ?? '환불 가능 금액을 불러오지 못했습니다.';
    if (!quote.refundable) return quote.reason ?? '환불할 수 없는 이용권입니다.';
    final rule = (quote.ruleName == null || quote.ruleName!.isEmpty) ? '' : '[${quote.ruleName}] ';
    return '$rule남은 이용권 $remainCount회 기준 금액입니다. 환불하면 남은 이용권은 모두 소멸됩니다.';
  }

  Widget _actions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _canRefund ? _confirmRefund : null,
            child: _submitting
                ? Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: _pink),
                    child: const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  )
                : _button('환불 신청', _canRefund ? _pink : const Color(0xFFE0E0E0), Colors.white),
          ),
        ),
      ],
    );
  }

  void _confirmRefund() {
    final amountLabel = _quote!.refundAmountLabel;
    AwesomeDialog(
      context: Get.context!,
      width: 400,
      animType: AnimType.scale,
      dialogType: DialogType.noHeader,
      dismissOnTouchOutside: false,
      descTextStyle: const TextStyle(fontSize: 15, fontFamily: 'Pretendard'),
      desc: '$amountLabel이 환불되며\n남은 이용권은 모두 소멸되어 다시 사용할 수 없습니다.\n그래도 환불을 진행하시겠습니까?',
      title: '정말로 환불하시겠습니까?',
      btnOkText: '취소',
      btnOkColor: const Color(0xFF6C7176),
      btnOkOnPress: () {},
      btnCancelText: '환불 신청',
      btnCancelColor: Colors.red[400],
      btnCancelOnPress: _submitRefund,
    ).show();
  }

  Future<void> _submitRefund() async {
    final paymentId = widget.paymentId;
    if (paymentId == null || _submitting) return;
    setState(() => _submitting = true);

    final result = await passRefundService(widget.studentId, paymentId);
    if (!result.success) {
      if (mounted) setState(() => _submitting = false);
      failDialog1('환불', result.message ?? '환불을 처리하지 못했습니다.');
      return;
    }

    // 잔여 이용권·결제 내역·책방 메인(잔여 횟수)이 모두 바뀌었으니 다시 읽는다
    await Future.wait([
      passPaymentRefreshService(widget.studentId),
      bookstoreMainService(widget.studentId),
    ]);
    if (Get.isRegistered<PassPaymentController>()) {
      Get.find<PassPaymentController>().update();
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
    failDialog1('환불 완료', '${formatWon(result.refundAmount)} 환불이 완료되었습니다.\n카드사 사정에 따라 취소 반영까지 며칠 걸릴 수 있습니다.');
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
