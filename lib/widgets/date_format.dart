import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

/////////////////
// 날짜 포맷팅 //
////////////////

// 202406
String formatYM(int year, int month) {
  return DateFormat('yyyyMM').format(DateTime(year, month));
}

// 2024.06
String formatYM_dot(int year, int month) {
  return DateFormat('yyyy.MM').format(DateTime(year, month));
}

// 2024
String formatY(int year, int month) {
  return DateFormat('yyyy').format(DateTime(year, month));
}

// 06
String formatM(int year, int month) {
  return DateFormat('MM').format(DateTime(year, month));
}

// 2024년 06월
String formatYMKorean(int year, int month) {
  return DateFormat('yyyy년 M월').format(DateTime(year, month));
}

final currentYear = getCurrentYear();
final currentMonth = getCurrentMonth();
final currentDay = getCurrentDay();
final currentWeekday = getCurrentWeekday();

// 현재 연도
int getCurrentYear() {
  final now = DateTime.now();
  return now.year;
}

// 현재 월
int getCurrentMonth() {
  final now = DateTime.now();
  return now.month;
}

// 현재 일
int getCurrentDay() {
  final now = DateTime.now();
  return now.day;
}

// 현재 요일
int getCurrentWeekday() {
  final now = DateTime.now();
  return now.weekday;
}
