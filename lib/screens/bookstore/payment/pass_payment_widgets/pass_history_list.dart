import 'package:flutter/material.dart';
import 'package:flutter_application/models/payment/pass_payment_data.dart';

/// 이용권 결제 내역.
///
/// 환불은 아직 넣지 않았다 — 필요해지면 서버의 `/payment/refund/quote`·`/payment/refund`로
/// 이 목록에 버튼만 붙이면 된다.
class PassHistoryList extends StatelessWidget {
  final List<PassPaymentHistory> histories;

  const PassHistoryList({super.key, required this.histories});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 12.0, bottom: 12.0, left: 4.0),
            child: Text(
              '결제 내역',
              style: TextStyle(
                fontFamily: 'Pretendard-Bold',
                fontSize: 18,
                color: Color(0xFF363636),
              ),
            ),
          ),
          if (histories.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  '결제 내역이 없어요',
                  style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                ),
              ),
            )
          else
            ...histories.map((h) => _historyCard(h)),
        ],
      ),
    );
  }

  Widget _historyCard(PassPaymentHistory history) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    history.productName,
                    style: const TextStyle(
                      fontFamily: 'Pretendard-Bold',
                      fontSize: 16,
                      color: Color(0xFF363636),
                    ),
                  ),
                ),
                _statusChip(history),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              history.amountLabel,
              style: const TextStyle(
                fontFamily: 'Pretendard-Bold',
                fontSize: 15,
                color: Color(0xFF363636),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              [
                if (history.studentName.isNotEmpty) history.studentName,
                if (history.paidAtLabel.isNotEmpty) history.paidAtLabel,
                if (history.cardLabel.isNotEmpty) history.cardLabel,
              ].join(' · '),
              style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(PassPaymentHistory history) {
    final colors = _statusColor(history.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: colors.bg,
      ),
      child: Text(
        history.statusLabel,
        style: TextStyle(fontSize: 12, color: colors.text),
      ),
    );
  }

  ({Color bg, Color text}) _statusColor(String status) {
    switch (status) {
      case 'PAID':
        return (bg: const Color(0xFF7ADFD2), text: const Color(0xFF008D7B));
      case 'CANCELED':
        return (bg: const Color(0xFFFF9696), text: const Color(0xFFBE2727));
      case 'FAILED':
        return (bg: const Color(0xFFFF9696), text: const Color(0xFFBE2727));
      default:
        return (bg: const Color(0xFFE0E0E0), text: const Color(0xFF757575));
    }
  }
}
