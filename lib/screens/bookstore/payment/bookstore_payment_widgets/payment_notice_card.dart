import 'package:flutter/material.dart';

/// 결제 전 유의사항 안내 카드.
class PaymentNoticeCard extends StatelessWidget {
  const PaymentNoticeCard({super.key});

  static const List<String> _notices = [
    // 서버 정책과 맞춘 문구(2026-10-22) — 사용기한: PassService.VALID_DAYS, 환불: PaymentService.calculateRefund
    '이용권은 첫 예약한 수업일부터 90일 동안 사용할 수 있습니다.',
    '예약할 때 이용권 1회가 차감되며, 수업 24시간 전까지 취소하면 다시 돌려받습니다.',
    '여러 이용권을 보유한 경우, 사용기한이 짧은 이용권부터 먼저 사용됩니다.',
    '결제 후 바로 예약할 수 있습니다. (당일은 직접 예약 불가)',
    '환불은 [이용권 관리]에서 신청할 수 있으며, 결제일로부터 3개월 이내에 가능합니다.',
    '환불 금액은 남은 이용권 1회당 3,000원이며, 환불하면 남은 이용권은 모두 소멸됩니다.',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4.0,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 2.0),
              child: Text(
                '이용 전 확인해 주세요',
                style: TextStyle(fontSize: 16.0, fontFamily: 'Pretendard-Bold'),
              ),
            ),
            ..._notices.map((text) => _Bullet(text)),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  static const _style = TextStyle(
    fontSize: 13.0,
    color: Color(0xFF363636),
    letterSpacing: -1.4,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('- ', style: _style),
        Expanded(child: Text(text, style: _style)),
      ],
    );
  }
}
