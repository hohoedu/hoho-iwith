import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

enum ReservationDayStatus {
  none,
  complete, // 예약 완료 (핑크)
  available, // 예약 가능 (민트)
  closed, // 예약 마감 (회색)
}

class ReservationCalendar extends StatefulWidget {
  const ReservationCalendar({
    super.key,
    required this.dayStatuses,
    this.initialMonth,
    this.selectedDate,
    this.onDateSelected,
  });

  // key: 'yyyy-MM-dd'
  final Map<String, ReservationDayStatus> dayStatuses;
  final DateTime? initialMonth;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;

  @override
  State<ReservationCalendar> createState() => _ReservationCalendarState();
}

class _ReservationCalendarState extends State<ReservationCalendar> {
  late DateTime displayedMonth;
  DateTime? selectedDate;

  static const List<String> weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  void initState() {
    super.initState();
    final base = widget.initialMonth ?? widget.selectedDate ?? DateTime.now();
    displayedMonth = DateTime(base.year, base.month);
    selectedDate = widget.selectedDate;
  }

  String _keyOf(DateTime date) => intl.DateFormat('yyyy-MM-dd').format(date);

  void _changeMonth(int offset) {
    setState(() {
      displayedMonth = DateTime(displayedMonth.year, displayedMonth.month + offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final daysInMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;
    final leadingEmptyCount = firstDayOfMonth.weekday % 7; // 일요일(weekday 7) -> 0
    final totalCells = ((leadingEmptyCount + daysInMonth) / 7).ceil() * 7;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left, color: Color(0xFFB7B6B6)),
              ),
              Text(
                '${displayedMonth.year}년 ${displayedMonth.month}월',
                style: const TextStyle(fontFamily: 'Pretendard-Bold', fontSize: 16),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right, color: Color(0xFFB7B6B6)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(7, (index) {
              final color = index == 0
                  ? const Color(0xFFF0524B)
                  : index == 6
                      ? const Color(0xFF3D7BFF)
                      : const Color(0xFF363636);
              return Expanded(
                child: Center(
                  child: Text(
                    weekdayLabels[index],
                    style: TextStyle(color: color, fontFamily: 'Pretendard-Bold', fontSize: 13),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.3,
            mainAxisSpacing: 6,
            crossAxisSpacing: 4,
            children: List.generate(totalCells, (index) {
              final dayOffset = index - leadingEmptyCount + 1;
              final isCurrentMonth = dayOffset >= 1 && dayOffset <= daysInMonth;

              // dayOffset이 0 이하/daysInMonth 초과여도 DateTime이 자동으로 이전/다음 달로 보정해줌
              final cellDate = DateTime(displayedMonth.year, displayedMonth.month, dayOffset);

              final status = isCurrentMonth ? (widget.dayStatuses[_keyOf(cellDate)] ?? ReservationDayStatus.none) : ReservationDayStatus.none;
              final isSelected = isCurrentMonth && selectedDate != null && _keyOf(cellDate) == _keyOf(selectedDate!);
              final weekdayIndex = cellDate.weekday % 7;

              return _CalendarCell(
                day: cellDate.day,
                isCurrentMonth: isCurrentMonth,
                status: status,
                isSelected: isSelected,
                weekdayIndex: weekdayIndex,
                onTap: isCurrentMonth
                    ? () {
                        setState(() => selectedDate = cellDate);
                        widget.onDateSelected?.call(cellDate);
                      }
                    : null,
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _LegendItem(color: Color(0xFFF291B4), label: '예약 완료'),
              SizedBox(width: 16),
              _LegendItem(color: Color(0xFF00B9A5), label: '예약 가능'),
              SizedBox(width: 16),
              _LegendItem(color: Color(0xFFD9D9D9), label: '예약 마감'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({
    required this.day,
    required this.isCurrentMonth,
    required this.status,
    required this.isSelected,
    required this.weekdayIndex,
    this.onTap,
  });

  final int day;
  final bool isCurrentMonth;
  final ReservationDayStatus status;
  final bool isSelected;
  final int weekdayIndex;
  final VoidCallback? onTap;

  Color? get _fillColor {
    if (isSelected) return const Color(0xFFD5227B);
    switch (status) {
      case ReservationDayStatus.complete:
        return const Color(0xFFF291B4);
      case ReservationDayStatus.available:
        return const Color(0xFF00B9A5);
      case ReservationDayStatus.closed:
        return const Color(0xFFD9D9D9);
      case ReservationDayStatus.none:
        return null;
    }
  }

  Color get _textColor {
    if (!isCurrentMonth) return const Color(0xFFD8D8D8);
    if (isSelected || status == ReservationDayStatus.complete || status == ReservationDayStatus.available) {
      return Colors.white;
    }
    if (status == ReservationDayStatus.closed) return const Color(0xFF9E9E9E);
    if (weekdayIndex == 0) return const Color(0xFFF0524B);
    if (weekdayIndex == 6) return const Color(0xFF3D7BFF);
    return const Color(0xFF363636);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _fillColor,
            shape: isSelected ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: isSelected ? BorderRadius.circular(5) : null,
          ),
          child: Text(
            '$day',
            style: TextStyle(
              color: _textColor,
              fontWeight: isSelected || status != ReservationDayStatus.none ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
        ),
      ],
    );
  }
}
