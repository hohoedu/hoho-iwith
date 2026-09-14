import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_reservation_data.dart';

/// 같은 일정으로 반복 예약 카드
class ReservationRepeatSection extends StatelessWidget {
  const ReservationRepeatSection({
    super.key,
    required this.enabled,
    required this.loading,
    required this.items,
    required this.selectedIds,
    required this.fallbackTimeLabel,
    required this.onToggle,
    required this.onItemTap,
  });

  final bool enabled;
  final bool loading;
  final List<BatchPreviewItem> items;
  final Set<int> selectedIds;
  final String fallbackTimeLabel;
  final VoidCallback onToggle;
  final ValueChanged<BatchPreviewItem> onItemTap;

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
                const Icon(Icons.repeat, size: 20, color: Color(0xFF9E9E9E)),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    '같은 일정으로 반복 예약',
                    style: TextStyle(
                      fontFamily: 'Pretendard-Bold',
                      fontSize: 16,
                      color: Color(0xFF363636),
                    ),
                  ),
                ),
                _RepeatSwitch(value: enabled, onChanged: onToggle),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '같은 일정으로 남은 이용권을 모두 예약해요.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                ),
              ),
            ),
            if (!enabled)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  '시간대를 먼저 선택하면 반복 예약 가능 날짜를 보여드릴게요',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                ),
              )
            else if (loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: CircularProgressIndicator(color: Color(0xFF00B093))),
              )
            else
              for (int i = 0; i < items.length; i++)
                _BatchPreviewTile(
                  item: items[i],
                  fallbackTimeLabel: fallbackTimeLabel,
                  checked: selectedIds.contains(items[i].slotInstanceId),
                  isLast: i == items.length - 1,
                  onTap: () => onItemTap(items[i]),
                ),
          ],
        ),
      ),
    );
  }
}

/// 같은 일정으로 반복 예약 — on/off 스위치. 기존 코드는 정적 Container라 탭해도 반응이 없었다.
class _RepeatSwitch extends StatelessWidget {
  const _RepeatSwitch({required this.value, required this.onChanged});

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

/// 같은 일정으로 반복 예약 - 미리보기 날짜 타일 (batch-preview 응답 기반)
class _BatchPreviewTile extends StatelessWidget {
  const _BatchPreviewTile({
    required this.item,
    required this.fallbackTimeLabel,
    required this.checked,
    required this.isLast,
    this.onTap,
  });

  final BatchPreviewItem item;
  final String fallbackTimeLabel;
  final bool checked;
  final bool isLast;
  final VoidCallback? onTap;

  bool get _unavailable => !item.selectable;

  String get _statusLabel {
    switch (item.targetStatus) {
      case 'ALREADY_RESERVED':
        return '이미 예약됨';
      case 'FULL':
        return '마감';
      case 'CLOSED':
        return '휴무';
      case 'NOT_OPEN':
        return '준비중';
      case 'DAY_CONFLICT':
        return '하루 상한 초과';
      case 'MONTH_FULL':
        return '이용권 소진';
      case 'NO_PASS':
        return '이용권 필요';
      default:
        return '예약 불가';
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(item.serviceDate);
    final dateLabel = date != null ? monthDayWeekdayLabel(date) : item.serviceDate;
    final timeLabel = item.timeLabel.isNotEmpty ? item.timeLabel : fallbackTimeLabel;
    final Color textColor = _unavailable ? const Color(0xFFBDBDBD) : const Color(0xFF363636);

    final Widget checkbox = checked
        ? Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF8F),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.check, size: 18, color: Colors.white),
          )
        : Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFD5D5D5)),
            ),
          );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: _unavailable ? const Color(0xFFF2F2F2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFECECEC), width: 1),
        ),
        child: Row(
          children: [
            checkbox,
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$dateLabel ',
                      style: TextStyle(fontFamily: 'Pretendard-Bold', fontSize: 14, color: textColor),
                    ),
                    TextSpan(
                      text: '${item.seq}회차 $timeLabel',
                      style: TextStyle(fontSize: 13, color: textColor),
                    ),
                  ],
                ),
              ),
            ),
            if (_unavailable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel,
                  style: const TextStyle(fontFamily: 'Pretendard-Bold', fontSize: 10, color: Color(0xFF9E9E9E)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
