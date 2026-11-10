import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_reservation_data.dart';

/// 매주 자동 예약 카드 (2026-10-27).
///
/// 위쪽 스위치는 지금 고른 시간대로 "매주 ○요일 ○회차"를 새로 켜는 것이고(예약하기를 눌러야 저장),
/// 아래 목록은 이미 켜 둔 자동 예약을 바로 켜고 끄는 것이다.
class ReservationAutoSection extends StatelessWidget {
  const ReservationAutoSection({
    super.key,
    required this.enabled,
    required this.selectedLabel,
    required this.patterns,
    required this.onToggle,
    required this.onPatternToggle,
  });

  /// 지금 고른 시간대로 자동 예약을 켤지
  final bool enabled;

  /// 고른 시간대 '화요일 2회차'. 아직 안 골랐으면 null
  final String? selectedLabel;
  final List<AutoPattern> patterns;
  final VoidCallback onToggle;
  final ValueChanged<AutoPattern> onPatternToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.autorenew, size: 20, color: Color(0xFF9E9E9E)),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    '매주 자동 예약',
                    style: TextStyle(
                      fontFamily: 'Pretendard-Bold',
                      fontSize: 16,
                      color: Color(0xFF363636),
                    ),
                  ),
                ),
                AutoSwitch(value: enabled, onChanged: onToggle),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Text(
                selectedLabel == null
                    ? '시간대를 먼저 선택하면 매주 같은 시간으로 자동 예약할 수 있어요'
                    : '매주 $selectedLabel를 자동으로 예약해요.\n새 일정이 열릴 때마다 이어서 예약해 드려요.',
                style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
              ),
            ),
            if (patterns.isNotEmpty) ...[
              const Divider(height: 1, color: Color(0xFFECECEC)),
              const Padding(
                padding: EdgeInsets.only(top: 12, bottom: 8),
                child: Text(
                  '내 자동 예약',
                  style: TextStyle(fontFamily: 'Pretendard-Bold', fontSize: 14, color: Color(0xFF363636)),
                ),
              ),
              for (final p in patterns) _PatternTile(pattern: p, onToggle: () => onPatternToggle(p)),
            ],
          ],
        ),
      ),
    );
  }
}

class _PatternTile extends StatelessWidget {
  const _PatternTile({required this.pattern, required this.onToggle});

  final AutoPattern pattern;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              pattern.label,
              style: TextStyle(
                fontSize: 14,
                color: pattern.isOn ? const Color(0xFF363636) : const Color(0xFFBDBDBD),
              ),
            ),
          ),
          if (pattern.isNoPass)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1E6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '이용권 필요',
                style: TextStyle(fontFamily: 'Pretendard-Bold', fontSize: 10, color: Color(0xFFE07A2E)),
              ),
            ),
          AutoSwitch(value: pattern.isOn, onChanged: onToggle),
        ],
      ),
    );
  }
}

/// on/off 스위치 — 반복 예약 카드의 스위치와 같은 모양
class AutoSwitch extends StatelessWidget {
  const AutoSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 46,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF4CAF8F) : const Color(0xFFD5D5D5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
