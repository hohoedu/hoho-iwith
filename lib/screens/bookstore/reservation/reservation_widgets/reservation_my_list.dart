import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_reservation_data.dart';

/// 나의 예약 탭 — 달력에서 고른 날짜의 내 예약 내역과 변경/취소 버튼
class ReservationMyList extends StatelessWidget {
  const ReservationMyList({
    super.key,
    required this.selectedDate,
    required this.items,
    required this.onChange,
    required this.onCancel,
  });

  final DateTime selectedDate;
  final List<ReservationItem> items;
  final ValueChanged<ReservationItem> onChange;
  final ValueChanged<ReservationItem> onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event_note, size: 20, color: Color(0xFF89A5A0)),
                const SizedBox(width: 6),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontFamily: 'Pretendard-Bold', fontSize: 16, color: Color(0xFF363636)),
                    children: [
                      const TextSpan(text: '예약 내역 - '),
                      TextSpan(text: monthDayWeekdayLabel(selectedDate), style: const TextStyle(color: Color(0xFFFF66A2))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text('이 날짜에는 예약 내역이 없어요', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
              )
            else
              for (int i = 0; i < items.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 10),
                  child: _MyReservationTile(item: items[i], onChange: () => onChange(items[i]), onCancel: () => onCancel(items[i])),
                ),
          ],
        ),
      ),
    );
  }
}

class _MyReservationTile extends StatelessWidget {
  const _MyReservationTile({required this.item, required this.onChange, required this.onCancel});

  final ReservationItem item;
  final VoidCallback onChange;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFECECEC)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 52,
                child: Text('${item.seq}회차', style: const TextStyle(fontFamily: 'Pretendard-Bold', fontSize: 15, color: Color(0xFF00B9A5))),
              ),
              Container(width: 1, height: 20, color: const Color(0xFFECECEC)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(item.timeLabel, style: const TextStyle(fontFamily: 'Pretendard-Bold', fontSize: 16, color: Color(0xFF363636))),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: item.isPayWait ? const Color(0xFFFCE3B4) : const Color(0xFFD7F1E6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.isPayWait ? '결제 대기' : '예약 완료',
                  style: TextStyle(
                    fontFamily: 'Pretendard-Bold',
                    fontSize: 12,
                    color: item.isPayWait ? const Color(0xFFB77A16) : const Color(0xFF00B093),
                  ),
                ),
              ),
            ],
          ),
          if (!item.isStarted) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _ActionButton(label: '변경하기', filled: false, onTap: onChange)),
                const SizedBox(width: 8),
                Expanded(child: _ActionButton(label: '취소하기', filled: true, onTap: onCancel)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.filled, required this.onTap});

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: filled ? const Color(0xFFFFE2ED) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: filled ? const Color(0xFFFFE2ED) : const Color(0xFF00B9A5)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Pretendard-Bold',
              fontSize: 14,
              color: filled ? const Color(0xFFE84D89) : const Color(0xFF00B9A5),
            ),
          ),
        ),
      ),
    );
  }
}
