import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 상단 일자 탭.
///
/// 탭 하나가 곧 조회 단위다 — 누르면 그 날짜로 서버를 다시 부르고 화면 전체가 갈아끼워진다.
///
/// 칸은 항상 [minSlots] 개를 잡아둔다. 서버가 최근 4일을 내려주지만(AppMapper#selectBookstoreReportDates
/// 의 TOP 4) 정독 기록이 2~3일뿐인 학생은 탭이 화면 폭을 나눠 가지며 뚱뚱해진다 — 남는 칸은
/// 빈 자리로 두고 누를 수 없다. 서버가 일자를 더 내려주면 그만큼 칸을 늘려 잘리는 날짜가 없게 한다.
///
/// 높이도 고정이다. 예전엔 Expanded(flex:1) 로 화면 높이의 10% 를 먹어서 기기마다
/// 탭 두께가 제각각이었다.
class ReportDateTabs extends StatelessWidget {
  const ReportDateTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelect,
  });

  /// '8월 14일' 형태의 탭 라벨. 비어 있으면 탭 줄 자체를 그리지 않는다.
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static const double height = 68;

  static const int minSlots = 4;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();

    final int slots = math.max(minSlots, labels.length);

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: Row(
        children: List.generate(slots, (index) {
          final bool hasLabel = index < labels.length;
          if (!hasLabel) return const Expanded(child: SizedBox.shrink());

          final bool isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(index),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 14.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFD7F1E6) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      labels[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF6EBB9A) : const Color(0xFFB7B6B6),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
