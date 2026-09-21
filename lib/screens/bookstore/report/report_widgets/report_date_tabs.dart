import 'package:flutter/material.dart';

/// 상단 일자 탭.
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

  @override
  Widget build(BuildContext context) {
    // if (labels.isEmpty) return const SizedBox.shrink();

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
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
