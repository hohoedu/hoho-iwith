import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_reservation_data.dart';

/// 예약 시간(회차) 선택 카드
class ReservationTimeSlots extends StatelessWidget {
  const ReservationTimeSlots({
    super.key,
    required this.selectedDate,
    required this.slots,
    required this.selectedSlotInstanceId,
    required this.onSlotTap,
  });

  final DateTime selectedDate;
  final List<SlotOption> slots;
  final int? selectedSlotInstanceId;
  final ValueChanged<SlotOption> onSlotTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, size: 20, color: Color(0xFF89A5A0)),
                const SizedBox(width: 6),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Pretendard-Bold',
                      fontSize: 16,
                      color: Color(0xFF363636),
                    ),
                    children: [
                      const TextSpan(text: '예약 시간 선택 - '),
                      TextSpan(
                        text: monthDayWeekdayLabel(selectedDate),
                        style: const TextStyle(color: Color(0xFFFF66A2)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (slots.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text('이 날짜에는 예약 가능한 시간이 없어요', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
              )
            else
              for (int i = 0; i < slots.length; i++)
                _TimeSlotTile(
                  slot: slots[i],
                  isSelected: selectedSlotInstanceId == slots[i].slotInstanceId,
                  isLast: i == slots.length - 1,
                  onTap: () => onSlotTap(slots[i]),
                ),
          ],
        ),
      ),
    );
  }
}

/// 예약 시간 선택 - 회차 타일
class _TimeSlotTile extends StatelessWidget {
  const _TimeSlotTile({
    required this.slot,
    required this.isSelected,
    required this.isLast,
    this.onTap,
  });

  final SlotOption slot;
  final bool isSelected;
  final bool isLast;
  final VoidCallback? onTap;

  static const int _lowRemainingThreshold = 2; // 잔여 인원이 적을 때 강조

  bool get _isClosed => !slot.isOpen;

  @override
  Widget build(BuildContext context) {
    final Color roundColor = _isClosed ? const Color(0xFFA9A9A9) : const Color(0xFF00B9A5);
    final Color timeColor = _isClosed ? const Color(0xFFA9A9A9) : const Color(0xFF363636);
    final int remaining = slot.remaining;

    late final Color badgeBg;
    late final Color badgeText;
    late final String badgeLabel;
    if (slot.reservedByMe) {
      badgeBg = const Color(0xFFD7F1E6);
      badgeText = const Color(0xFF00B093);
      badgeLabel = '예약 완료 · 취소';
    } else if (_isClosed) {
      badgeBg = const Color(0xFFEAEAEA);
      badgeText = const Color(0xFF9E9E9E);
      badgeLabel = '예약 마감';
    } else if (remaining <= _lowRemainingThreshold) {
      badgeBg = const Color(0xFFFCE3B4);
      badgeText = const Color(0xFFB77A16);
      badgeLabel = '잔여 $remaining명';
    } else {
      badgeBg = const Color(0xFFDCEBB6);
      badgeText = const Color(0xFF6E8B2A);
      badgeLabel = '잔여 $remaining명';
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF8F5) : Colors.white,
          borderRadius: BorderRadius.circular(isSelected ? 8 : 12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00B9A5) : const Color(0xFFECECEC),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              child: Text(
                '${slot.seq}회차',
                style: TextStyle(fontFamily: 'Pretendard-Bold', fontSize: 15, color: roundColor),
              ),
            ),
            Container(width: 1, height: 20, color: const Color(0xFFECECEC)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                slot.timeLabel,
                style: TextStyle(fontFamily: 'Pretendard-Bold', fontSize: 16, color: timeColor),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badgeLabel,
                style: TextStyle(fontFamily: 'Pretendard-Bold', fontSize: 13, color: badgeText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
