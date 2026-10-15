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
      child: Row( 
        children: List.generate(labels.length, (labelIndex) {
          final bool isSelected = labelIndex == selectedIndex;
          return Expanded(
            child: GestureDetector(
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
            ),
          );
        }),
      ),
    );
  }
}
