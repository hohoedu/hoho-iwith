import 'package:flutter/material.dart';
import 'package:flutter_application/models/payment/pass_payment_data.dart';

/// 이용권 관리 탭 — 자동구매 상태 카드 (2026-10-27).
///
/// 사용 중이면 등록 카드와 해지 버튼을, 결제 실패로 멈췄으면 사유와 다시 시도 버튼을 보여준다.
/// 자동구매가 없으면(NONE) 화면에서 이 카드를 그리지 않는다.
class PaymentAutoBuyCard extends StatelessWidget {
  final PassSubscription subscription;
  final bool disabled;
  final VoidCallback onCancel;
  final VoidCallback onRetry;

  const PaymentAutoBuyCard({
    super.key,
    required this.subscription,
    required this.onCancel,
    required this.onRetry,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final paused = subscription.isPaused;
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, left: 16.0, right: 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: paused ? const Color(0xFFE07A2E) : const Color(0xFF008D78), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(paused ? Icons.error_outline : Icons.autorenew,
                    size: 20, color: paused ? const Color(0xFFE07A2E) : const Color(0xFF008D78)),
                const SizedBox(width: 6),
                Text(
                  paused ? '자동구매가 멈췄어요' : '자동구매 사용 중',
                  style: const TextStyle(fontFamily: 'Pretendard-Bold', fontSize: 16, color: Color(0xFF363636)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              paused
                  ? '카드 결제가 되지 않아 자동구매를 멈췄어요.${_reasonLine()}\n카드를 확인한 뒤 다시 시도해주세요.'
                  : '이용권을 다 쓰면 등록한 카드로 자동 구매돼요.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6C7176)),
            ),
            if (subscription.cardLabel.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(subscription.cardLabel, style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
              ),
            const SizedBox(height: 12),
            Row(
              spacing: 8,
              children: [
                if (paused) Expanded(child: _button('다시 시도', filled: true, onTap: onRetry)),
                Expanded(child: _button('자동구매 해지', filled: false, onTap: onCancel)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _reasonLine() {
    final reason = subscription.failReason;
    return (reason == null || reason.isEmpty) ? '' : '\n($reason)';
  }

  Widget _button(String label, {required bool filled, required VoidCallback onTap}) {
    final color = disabled ? const Color(0xFFB6B6B6) : const Color(0xFF008D78);
    return GestureDetector(
      onTap: disabled ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: filled ? color : Colors.white,
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: filled ? Colors.white : color, fontFamily: 'Pretendard-ExtraBold'),
          ),
        ),
      ),
    );
  }
}
