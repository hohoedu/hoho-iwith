import 'package:flutter_application/models/bookstore/bookstore_report_data.dart';

/// 정독 결과 화면 레이아웃 작업용 더미 데이터.
///
/// 서버 연동 없이 화면만 잡을 때 쓴다. [useReportDummy] 를 false 로 되돌리면
/// 화면은 곧바로 실제 API(`/app/bookstore/report`)를 다시 탄다 — 화면 코드는
/// 더미든 실데이터든 같은 [BookstoreReportData] 만 본다.
///
/// 레이아웃 작업이 끝나면 이 파일과 플래그를 통째로 지우면 된다.
const bool useReportDummy = false;

/// 상단 탭 일자. 과거 → 현재 순이며, 서버 쿼리(TOP 4)와 같은 4개다.
const List<String> _dummyDates = [
  '2026-09-01',
  '2026-09-05',
  '2026-09-10',
  '2026-09-15',
];

/// [recordDate] 가 null 이면 서버와 같게 가장 최근 일자를 고른다.
BookstoreReportData reportDummyData([String? recordDate]) {
  final String selected =
      (recordDate != null && _dummyDates.contains(recordDate)) ? recordDate : _dummyDates.last;

  return BookstoreReportData(
    studentName: '김호호',
    dates: _dummyDates,
    recordDate: selected,
    bookCount: 3,
    readMinutes: 50,
    correctRate: 82,
    totalBookCount: 32,
    // 서버는 접두어 없이 뒷부분만 보낸다. @@…@@ 가 강조 구간.
    summaryText: '@@등장인물과 사건, 행동 등 중요한 내용을 정확하게 파악@@'
        '하는 이해능력이 뛰어났어요.',
    books: _books,
    badges: _badges,
    tendencies: _tendencies,
    monthly: _monthly,
  );
}

final List<ReportBook> _books = [
  ReportBook(
    contentId: 1,
    title: '강아지 똥',
    imageUrl: '/uploads/book/643dcafa650b4b398cbdb843ff4b65bc.jpeg',
    basicCorrect: 12,
    basicTotal: 12,
    advancedCorrect: 3,
    advancedTotal: 6,
    firstBasicCorrect: 7,
    firstBasicTotal: 12,
    retryCount: 1,
    correctRate: 72,
    growthWords: ["'흉측하다'", "'가뭄'", "'쓸모가 없다'"],
  ),
  ReportBook(
    contentId: 2,
    title: '마법의 손 장영실',
    imageUrl: '/uploads/book/f174cf98188f4fb78c0c6dd44eff88f7.jpeg',
    basicCorrect: 10,
    basicTotal: 12,
    advancedCorrect: 5,
    advancedTotal: 6,
    correctRate: 83,
  ),
  ReportBook(
    contentId: 3,
    title: '흥부전',
    imageUrl: '/uploads/book/643dcafa650b4b398cbdb843ff4b65bc.jpeg',
    basicCorrect: 11,
    basicTotal: 12,
    advancedCorrect: 6,
    advancedTotal: 6,
    correctRate: 94,
  ),
];

/// 뱃지 마스터 5종. category 가 아이콘을 고르는 키다.
final List<ReportBadge> _badges = [
  ReportBadge(
    badgeId: 1,
    category: 'BASIC_FAIL',
    badgeName: '완독',
    badgeDesc: '책을 끝까지 읽고 문제풀이를 완료',
  ),
  ReportBadge(
    badgeId: 2,
    category: 'BASIC_PASS',
    badgeName: '정독 완료',
    badgeDesc: '책을 읽고 문제를 합격선 이상 해결',
    earned: true,
    earnedCount: 2,
  ),
  ReportBadge(
    badgeId: 3,
    category: 'BASIC_PERFECT',
    badgeName: '정독왕',
    badgeDesc: '책의 내용을 정확하게 이해',
    earned: true,
    earnedCount: 2,
  ),
  ReportBadge(
    badgeId: 4,
    category: 'ADV_PASS',
    badgeName: '문해력 챌린저',
    badgeDesc: '한 단계 깊은 사고 활동에 도전',
    earned: true,
    earnedCount: 1,
  ),
  ReportBadge(
    badgeId: 5,
    category: 'ADV_PERFECT',
    badgeName: '문해력 챔피언',
    badgeDesc: '어휘력과 문해력의 실력 증가',
    earned: true,
    earnedCount: 1,
  ),
];

final List<ReportTendency> _tendencies = [
  ReportTendency(typeCode: '01', typeName: '이해', rate: 69.9, answerCount: 42),
  ReportTendency(typeCode: '02', typeName: '표현', rate: 51.5, answerCount: 33),
  ReportTendency(typeCode: '03', typeName: '어휘', rate: 92.7, answerCount: 55),
  ReportTendency(typeCode: '04', typeName: '감정', rate: 85.5, answerCount: 28),
  ReportTendency(typeCode: '05', typeName: '사고', rate: 63.1, answerCount: 31),
  ReportTendency(typeCode: '06', typeName: '논리', rate: 97.6, answerCount: 40),
];

final List<ReportMonthly> _monthly = [
  ReportMonthly(year: 2026, month: 6, count: 6),
  ReportMonthly(year: 2026, month: 7, count: 10),
  ReportMonthly(year: 2026, month: 8, count: 7),
  ReportMonthly(year: 2026, month: 9, count: 10),
];
