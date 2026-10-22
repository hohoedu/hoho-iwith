import 'package:flutter/material.dart';

/// 상단 일자 탭.
class ReportDateTabs extends StatelessWidget {
  const ReportDateTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static const double height = 68;

  /// 한 화면에 보이는 탭 수 — 이보다 많으면 옆으로 넘긴다
  static const int _visibleCount = 4;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
        // 바 아래로만 살짝 떨어지는 그림자 — 입체감만 주고 번지지 않게 흐림은 작게.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      // 4개까지는 예전처럼 칸을 나눠 꽉 채우고, 그보다 많으면(2026-10-22 서버가 최근 60개 날짜까지 내림)
      // 한 칸 너비를 1/4로 고정해 옆으로 넘겨 본다. reverse 라 처음엔 가장 최근(오른쪽 끝) 4개가 보인다.
      child: labels.length <= _visibleCount
          ? Row(children: List.generate(labels.length, (i) => Expanded(child: _tab(i))))
          : LayoutBuilder(
              builder: (context, c) => ListView.builder(
                scrollDirection: Axis.horizontal,
                reverse: true,
                itemCount: labels.length,
                itemBuilder: (_, i) => SizedBox(
                  width: c.maxWidth / _visibleCount,
                  child: _tab(labels.length - 1 - i),
                ),
              ),
            ),
    );
  }

  Widget _tab(int labelIndex) {
    final bool isSelected = labelIndex == selectedIndex;
    return GestureDetector(
      onTap: () => onSelect(labelIndex),
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
              labels[labelIndex],
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
    );
  }
}
