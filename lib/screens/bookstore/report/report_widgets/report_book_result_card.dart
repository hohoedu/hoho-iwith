import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_report_data.dart';

/// 읽은 책의 문제 풀이 결과.
///
/// 책이 2권 이상이면 위에 책 탭이 붙고, 선택 상태는 컨트롤러가 들고 있다
/// ([selectedIndex] / [onSelectBook]) — 일자를 바꾸면 0으로 돌아간다.
class ReportBookResultCard extends StatelessWidget {
  const ReportBookResultCard({
    super.key,
    required this.books,
    required this.selectedIndex,
    required this.onSelectBook,
  });

  final List<ReportBook> books;
  final int selectedIndex;
  final ValueChanged<int> onSelectBook;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();

    final index = selectedIndex.clamp(0, books.length - 1);
    final book = books[index];

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
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text('읽은 책의 문제 풀이 결과', style: TextStyle(fontFamily: 'Pretendard-Bold', color: Color(0xFF363636))),
              ),
              if (books.length > 1) _bookTabs(index),
              const SizedBox(height: 8),
              _bookHeader(context, book),
              // 낱말 컬럼이 생기기 전까지 growthWords 는 비어 온다. 심화 문제를 푼 책이면
              // 칸은 남기고 본문만 준비 중 문구로 대신한다 — 심화를 안 푼 책에까지
              // '문해력이 자랐어요' 를 띄우면 안 되므로 advancedTotal 로 한 번 거른다.
              if (book.growthWords.isNotEmpty || book.advancedTotal > 0) _growthWords(book),
            ],
          ),
        ),
      ),
    );
  }

  // ── 책 탭 ──

  Widget _bookTabs(int index) {
    return Padding(
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
                onTap: () => onSelectBook(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 30,
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
    );
  }

  // ── 표지 + 제목 + 점수 ──

  Widget _bookHeader(BuildContext context, ReportBook book) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 24, child: _cover(context, book)),
          const SizedBox(width: 12),
          Expanded(
            flex: 74,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Pretendard-Bold', fontSize: 15),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: _retryLine(book),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
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
    );
  }

  Widget _retryLine(ReportBook book) {
    // 라벨이 없어도 빈 Text 로 자리를 지킨다 — 재도전 유무로 카드 높이가 튀지 않게.
    return Text(
      book.retryCountLabel ?? '',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _retryCountStyle,
    );
  }

  static const TextStyle _retryCountStyle = TextStyle(
    fontSize: 10,
    fontFamily: 'Pretendard-Bold',
    color: Color(0xFF666666),
  );

  Widget _cover(BuildContext context, ReportBook book) {
    final url = book.coverUrl;
    final bool hasCover = url != null && url.isNotEmpty;

    final Widget image = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: hasCover
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _coverPlaceholder(),
            )
          : _coverPlaceholder(),
    );

    return SizedBox.expand(
      child: hasCover
          ? GestureDetector(
              // 돋보기 배지는 눈에 보이는 표시일 뿐, 탭 영역은 표지 전체다 —
              // 배지만 받으면 손가락으로 누르기엔 너무 작다.
              onTap: () => _openCoverViewer(context, url),
              behavior: HitTestBehavior.opaque,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: image),
                  const Positioned(right: -5, bottom: -5, child: _MagnifierBadge()),
                ],
              ),
            )
          : image,
    );
  }

  void _openCoverViewer(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: InteractiveViewer(
            maxScale: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _coverPlaceholder(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _coverPlaceholder() => Container(
        color: const Color(0xFFEFF3F6),
        child: const Icon(Icons.menu_book, color: Color(0xFFB7B6B6)),
      );

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
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Pretendard-Bold',
                    color: color,
                  ),
                ),
                TextSpan(
                  text: suffix,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Pretendard-Bold',
                    color: color.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 문해력이 자랐어요 ──
  static String _growthIconOf(ReportBook book) {
    final seed = book.contentId ?? book.title.hashCode;
    final name = seed.isEven ? 'advance_gram' : 'advance_voca';
    return 'assets/images/icon/$name.png';
  }

  Widget _growthWords(ReportBook book) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(_growthIconOf(book), scale: 20),
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
          book.growthWords.isEmpty
              ? const Text(
                  '이 책에서 자란 낱말은 준비 중이에요.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF9DB5AA), height: 1.4),
                )
              : Text(
                  '${book.growthWords.join(', ')} 처럼 문맥 속 낱말 뜻을 짐작하며 '
                  '낱말 순서를 바르게 배열해 문장을 완성하는 힘이 자랐어요.',
                  style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
                ),
        ],
      ),
    );
  }
}

/// 표지 우하단 돋보기 배지. 표지를 눌러 크게 볼 수 있다는 표시.
class _MagnifierBadge extends StatelessWidget {
  const _MagnifierBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF9D9D9D),
          ),
          child: const Padding(
            padding: EdgeInsets.all(2.0),
            child: Icon(Icons.search, size: 14, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
