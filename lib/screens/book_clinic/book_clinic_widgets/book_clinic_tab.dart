import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class BookClinicTab extends StatelessWidget {
  final List<DateTime> months;
  final int selectedMonth;
  final Function(int) onMonthSelected;

  const BookClinicTab({super.key, required this.months, required this.selectedMonth, required this.onMonthSelected});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            months.length,
            (index) {
              final label = intl.DateFormat('M월').format(months[index]);
              return Expanded(
                child: GestureDetector(
                  onTap: () => onMonthSelected(index),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: selectedMonth == index ? const Color(0xFFD7F1E6) : Colors.transparent,
                          borderRadius: BorderRadius.circular(15)),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: selectedMonth == index ? Color(0xFF6EBB9A) : Color(0xFFB7B6B6),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
