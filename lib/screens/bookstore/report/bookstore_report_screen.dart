import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_report_data.dart';
import 'package:flutter_application/screens/bookstore/report/report_widgets/bookstore_report_bubble_chart.dart';
import 'package:flutter_application/screens/bookstore/report/report_widgets/bookstore_report_graph.dart';
import 'package:flutter_application/screens/bookstore/report/report_widgets/bookstore_report_preferences.dart';
import 'package:flutter_application/services/bookstore/bookstore_report_service.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:get/get.dart';

/// 정독 결과 화면.
///
/// 상단 일자 탭이 조회 단위다 — 탭을 누르면 그 날짜로 서버를 다시 호출해 화면 전체를 갈아끼운다.
/// 첫 진입은 날짜 없이 호출해서 서버가 고른 최근 일자를 받는다.
///
/// 서버에 아직 없는 값(요약 문장, 문해력 낱말)은 null 로 오고, 해당 영역은 통째로 숨긴다 —
/// 빈 자리를 남겨두면 데이터가 빠진 건지 원래 없는 건지 학부모가 알 수 없기 때문이다.
class BookstoreReportScreen extends StatefulWidget {
  const BookstoreReportScreen({super.key});

  @override
  State<BookstoreReportScreen> createState() => _BookstoreReportScreenState();
}

class _BookstoreReportScreenState extends State<BookstoreReportScreen> {
  final BookstoreReportDataController controller = Get.put(BookstoreReportDataController(), permanent: true);

  /// 책 탭(그날 읽은 책) 선택 인덱스. 일자를 바꾸면 0으로 되돌린다.
  int selectedBookIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => bookstoreReportService());
  }

  Future<void> _selectDate(String date) async {
    if (controller.isLoading) return;
    if (controller.data?.recordDate == date) return;
    setState(() => selectedBookIndex = 0);
    await bookstoreReportService(recordDate: date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F2ED),
      appBar: MainAppBar(title: '정독 결과'),
      body: Obx(() {
        final data = controller.data;

        return Column(
          children: [
            Expanded(flex: 1, child: _dateTabs(data)),
            Expanded(
              flex: 9,
              child: _body(data),
            ),
          ],
        );
      }),
    );
  }

  // ── 상단 일자 탭 ──

  Widget _dateTabs(BookstoreReportData? data) {
    final dates = data?.dates ?? const <String>[];
    final labels = data?.dateLabels ?? const <String>[];
    final selected = data?.selectedDateIndex ?? -1;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: dates.isEmpty
          ? const Center(
              child: Text(
                '정독 기록이 아직 없어요',
                style: TextStyle(color: Color(0xFFB7B6B6), fontWeight: FontWeight.bold, fontSize: 16),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(dates.length, (index) {
                final bool isSelected = index == selected;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(dates[index]),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFD7F1E6) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            labels[index],
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

  // ── 본문 ──

  Widget _body(BookstoreReportData? data) {
    // 첫 로딩 — 아직 보여줄 게 없다
    if (data == null) {
      if (controller.isFailed) {
        return const Center(
          child: Text('결과를 불러오지 못했어요', style: TextStyle(color: Color(0xFF719183))),
        );
      }
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00B093)));
    }

    if (!data.hasRecord) {
      return const Center(
        child: Text('이 날의 정독 기록이 없어요', style: TextStyle(color: Color(0xFF719183))),
      );
    }

    // 일자를 바꾸는 동안엔 직전 화면을 깔아두고 위에 로딩만 얹는다(깜빡임 방지)
    return Stack(
      children: [
        ListView(
          children: [
            _summary(data),
            _bookResult(data),
            _reward(data),
            _preferences(data),
            _graph(data),
          ],
        ),
        if (controller.isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x66E7F2ED),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF00B093))),
            ),
          ),
      ],
    );
  }

  // ── 요약 ──

  Widget _summary(BookstoreReportData data) {
    final stats = <String>[
      if (data.readMinutes > 0) '독서 시간 ${data.readMinutes}분',
      if (data.correctRate != null) '평균 정답률 ${data.correctRate}%',
      if (data.totalBookCount > 0) '누적 독서 ${data.totalBookCount}권째',
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: '${data.studentName} 학생은 총 '),
                  TextSpan(
                    text: '${data.bookCount}권',
                    style: const TextStyle(color: Color(0xFF00B093)),
                  ),
                  const TextSpan(text: '의 책을 읽었어요.'),
                ],
                style: const TextStyle(
                  color: Color(0xFF363636),
                  fontSize: 18.0,
                  fontFamily: 'Pretendard-ExtraBold',
                ),
              ),
            ),
          ),
          if (stats.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD4E5DE),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: Text(
                  stats.join(' · '),
                  style: const TextStyle(color: Color(0xFF719183), fontSize: 10.0),
                ),
              ),
            ),
          // 요약 문장은 서버 생성 정책이 정해지기 전까지 내려오지 않는다
          if (data.summaryText != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 26.0),
              child: Text(
                data.summaryText!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF363636),
                  fontSize: 13.0,
                  fontFamily: 'Pretendard',
                ),
              ),
            )
          else
            const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── 책별 문제 풀이 결과 ──

  Widget _bookResult(BookstoreReportData data) {
    final books = data.books;
    final index = selectedBookIndex.clamp(0, books.length - 1);
    final book = books[index];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text('읽은 책의 문제 풀이 결과', style: TextStyle(fontFamily: 'Pretendard-Bold')),
              ),
              if (books.length > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: List.generate(books.length, (i) {
                      final bool isSelected = i == index;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: i == 0 ? 0.0 : 8.0,
                            right: i == books.length - 1 ? 0.0 : 8.0,
                          ),
                          child: GestureDetector(
                            onTap: () => setState(() => selectedBookIndex = i),
                            child: Container(
                              height: 35,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF00B9A5) : const Color(0xFFEDEDED),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                books[i].title,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey,
                                  fontFamily: 'Pretendard-Bold',
                                  fontSize: 13.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://hohobooks.co.kr/uploads/book/f174cf98188f4fb78c0c6dd44eff88f7.jpeg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFEFF3F6),
                          child: const Icon(Icons.menu_book, color: Color(0xFFB7B6B6)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    flex: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontFamily: 'Pretendard-Bold',
                            fontSize: 17,
                          ),
                        ),
                        // 재도전이 없으면 줄 자체를 안 그린다
                        if (book.retryLabel != null)
                          Text(
                            book.retryLabel!,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F5F8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              _scoreCell('정독 문제', '${book.basicCorrect}', '/${book.basicTotal}', const Color(0xFF3D7BFF)),
                              _scoreCell('문해력 문제', '${book.advancedCorrect}', '/${book.advancedTotal}', const Color(0xFF7B5CFA)),
                              _scoreCell('정답률', '${book.correctRate ?? 0}', '%', const Color(0xFF00B9A5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 문해력 낱말은 서버에 낱말 컬럼이 생기기 전까지 항상 비어 있다
              if (book.growthWords.isNotEmpty) _growthWords(book),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreCell(String label, String value, String suffix, Color color) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(label, style: const TextStyle(fontSize: 11.0, color: Colors.grey)),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(fontSize: 20, fontFamily: 'Pretendard-Bold', color: color),
                ),
                TextSpan(
                  text: suffix,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Pretendard-Bold',
                    color: color.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _growthWords(ReportBook book) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/images/icon/advance_gram.png', scale: 20),
              const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Text(
                  '문해력이 자랐어요!',
                  style: TextStyle(
                    fontFamily: 'Pretendard-Bold',
                    fontSize: 13,
                    color: Color(0xFF008D78),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${book.growthWords.join(', ')} 처럼 문맥 속 낱말 뜻을 짐작하며 '
            '낱말 순서를 바르게 배열해 문장을 완성하는 힘이 자랐어요.',
            style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ── 보상 (뱃지 4칸) ──

  Widget _reward(BookstoreReportData data) {
    final badges = data.badges;
    if (badges.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text('이번 독서 활동에서는', style: TextStyle(fontFamily: 'Pretendard-Bold')),
              ),
              // 뱃지는 마스터 4종이 항상 내려와 2×2로 떨어진다
              for (int row = 0; row < (badges.length / 2).ceil(); row++)
                Row(
                  children: List.generate(2, (col) {
                    final i = row * 2 + col;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: col == 0 ? 0.0 : 6.0,
                          right: col == 0 ? 6.0 : 0.0,
                          top: row == 0 ? 0.0 : 6.0,
                          bottom: 6.0,
                        ),
                        child: i < badges.length ? _badgeCell(badges[i]) : const SizedBox(height: 60),
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badgeCell(ReportBadge badge) {
    final bool earned = badge.earned;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: earned ? const Color(0xFFD7F1E6) : const Color(0xFFEFF3F6),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Icon(
            earned ? Icons.check_circle : Icons.circle_outlined,
            size: 20,
            color: earned ? const Color(0xFF00B093) : const Color(0xFFC6CDD2),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.badgeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Pretendard-Bold',
                    fontSize: 13,
                    color: earned ? const Color(0xFF008D78) : const Color(0xFFB7B6B6),
                  ),
                ),
                if (badge.badgeDesc != null)
                  Text(
                    badge.badgeDesc!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: earned ? const Color(0xFF719183) : const Color(0xFFC6CDD2),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 독서 성향 ──

  Widget _preferences(BookstoreReportData data) {
    final bubbleData = data.bubbleData;
    if (bubbleData.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        height: 600,
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookstoreReportBubbleChart(bubbleData: bubbleData),
              const Divider(thickness: 0.5),
              BookstoreReportPreferences(
                bubbleData: bubbleData,
                isPerfect: data.isPerfect,
                resultLabels: data.resultLabels,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 독서량 그래프 ──

  Widget _graph(BookstoreReportData data) {
    final graphData = data.monthly.map((m) => ReportGraphData(year: m.year, month: m.month, count: m.count)).toList();

    // 그래프 헤더가 "…월까지"를 그리려면 마지막 달이 필요하다. 데이터가 없으면 오늘로 채운다.
    final months = graphData.isEmpty ? [DateTime.now()] : graphData.map((g) => DateTime(int.tryParse(g.year) ?? DateTime.now().year, int.tryParse(g.month) ?? 1)).toList();

    return BookstoreReportGraph(
      selectedMonth: months.length - 1,
      months: months,
      graphData: graphData,
    );
  }
}
