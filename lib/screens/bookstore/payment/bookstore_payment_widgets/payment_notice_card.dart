import 'package:flutter/material.dart';

/// 결제 전 유의사항 안내 카드.
class PaymentNoticeCard extends StatelessWidget {
  const PaymentNoticeCard({super.key});

  static const List<String> _notices = [
    '이용권은 첫 사용일로부터 3개월 동안 사용할 수 있습니다.',
    '예약 1회당 이용권 1회가 차감됩니다.',
    '여러 이용권을 보유한 경우, 사용기한이 짧은 이용권부터 먼저 사용됩니다.',
    '결제 후 바로 예약할 수 있습니다. (당일은 직접 예약 불가)',
    '환불은 호호책방 센터에서 탈퇴 신청 후, 미사용분에 한해 진행됩니다.',
    '환불 금액은 이용권 결제금액을 총 이용 횟수로 나눈 금액을 기준으로,\n사용한 횟수만큼 차감한 뒤 잔여 금액을 부분 취소합니다.',
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
