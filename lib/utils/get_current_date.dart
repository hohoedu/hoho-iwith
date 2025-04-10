/////////////////////////
//  현재 시간 가져오기  //
/////////////////////////
library;

final currentYear = getCurrentYear();
final currentMonth = getCurrentMonth();

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