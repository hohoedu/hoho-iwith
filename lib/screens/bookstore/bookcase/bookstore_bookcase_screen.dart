import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_main_data.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:get/get.dart';

/// 책장 화면
///
/// 최근 독서 기록의 책 표지를 실제 책장처럼 나무 선반 위에 진열한다.
/// 세로 스크롤이 아니라 좌우 스와이프(PageView)로 책장 한 장씩 넘어가며,
/// 하단 점(Dot) 인디케이터로 현재 페이지를 표시한다.
///
/// 데이터는 [BookstoreMainDataController]의 recentBookImages를 사용한다.
class BookstoreBookcaseScreen extends StatefulWidget {
  const BookstoreBookcaseScreen({super.key});

  @override
  State<BookstoreBookcaseScreen> createState() =>
      _BookstoreBookcaseScreenState();
}

class _BookstoreBookcaseScreenState extends State<BookstoreBookcaseScreen> {
  static const String _host = 'https://hohobooks.co.kr';

  static const Color _bg = Color(0xFFD9EFE4);

  /// 한 선반에 올라가는 책 수
  static const int _booksPerShelf = 4;

  /// 한 페이지(책장 한 장)에 들어가는 선반 수
  static const int _shelvesPerPage = 5;

  /// 한 페이지에 들어가는 총 책 수 (4권 x 5단 = 20권)
  static const int _booksPerPage = _booksPerShelf * _shelvesPerPage;

  /// 최소 페이지 수 (책이 없어도 빈 책장 1장은 보여준다)
  static const int _minPages = 1;

  final PageController _pageController = PageController();

  bool _newestFirst = true;

  int _currentPage = 0;

  String _resolve(String raw) => _host + raw;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // TODO: 책별 뱃지 데이터가 API로 내려오기 전까지 쓰는 더미.
  // 서버가 책마다 획득 뱃지를 주면 이 목록/배정 로직을 실제 데이터로 교체한다.
  static const List<String> _dummyBadges = [
    'assets/images/book_report/basic_perfect.png',
    'assets/images/book_report/advance_perfect.png',
    'assets/images/book_report/basic_pass.png',
    'assets/images/book_report/advance_pass.png',
  ];

  /// 전역 책 인덱스에 대한 더미 뱃지 경로. 일부 책은 뱃지가 없도록(null) 둔다.
  String? _dummyBadgeFor(int globalIndex) {
    if (globalIndex % 4 == 3) return null; // 4권 중 1권은 뱃지 없음
    return _dummyBadges[globalIndex % _dummyBadges.length];
  }

  /// 선반 하나를 만든다.
  _Shelf _buildShelf(List<String> images, int shelfIndex) {
    final start = shelfIndex * _booksPerShelf;
    final shelfImages = <String?>[];
    final shelfBadges = <String?>[];
    for (var i = 0; i < _booksPerShelf; i++) {
      final idx = start + i;
      final hasBook = idx < images.length;
      shelfImages.add(hasBook ? images[idx] : null);
      // 뱃지는 실제 책이 있는 칸에만 (빈 자리는 뱃지 없음)
      shelfBadges.add(hasBook ? _dummyBadgeFor(idx) : null);
    }
    return _Shelf(
      images: shelfImages,
      badges: shelfBadges,
      resolve: _resolve,
    );
  }

  /// 페이지(책장 한 장) 하나를 만든다. 내부에 5단의 선반을 세로로 균등 배치.
  Widget _buildBookcasePage(List<String> images, int pageIndex) {
    final firstShelf = pageIndex * _shelvesPerPage;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      // 책장 바깥 프레임(밝은 오크 테).
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFCBA06C), Color(0xFFB5844F)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 6),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
        border: Border.all(color: const Color(0xFFA6763F), width: 5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: DecoratedBox(
          // 뒤판(back panel) — 밝은 오크 나뭇결 텍스처
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bookcase/back_panel.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              // 좌우 안쪽 음영 (책장 옆판이 만드는 은은한 그늘)
              const Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0x33000000),
                          Color(0x00000000),
                          Color(0x00000000),
                          Color(0x33000000),
                        ],
                        stops: [0.0, 0.1, 0.9, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              // 선반 5단을 세로로 균등 배치 (스크롤 없음)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: Column(
                  children: List.generate(_shelvesPerPage, (i) {
                    return Expanded(
                      child: _buildShelf(images, firstShelf + i),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookstoreMainDataController>(
      init: BookstoreMainDataController(),
      builder: (c) {
        final data = c.data;
        final raw = data?.recentBookImages ?? const <String>[];
        final images =
            _newestFirst ? raw : raw.reversed.toList(growable: false);

        final pageCount = ((images.length + _booksPerPage - 1) ~/ _booksPerPage)
            .clamp(_minPages, 999);

        // 데이터 변동 등으로 현재 페이지가 범위를 벗어난 경우 보정
        final safePage = _currentPage.clamp(0, pageCount - 1);

        return Scaffold(
          backgroundColor: _bg,
          appBar: const MainAppBar(title: '내 책장', color: _bg),
          body: Column(
            children: [
              _BookcaseHeader(
                count: raw.length,
                newestFirst: _newestFirst,
                onSortChanged: (v) => setState(() {
                  _newestFirst = v;
                  // 정렬이 바뀌면 첫 페이지로
                  _currentPage = 0;
                  if (_pageController.hasClients) {
                    _pageController.jumpToPage(0);
                  }
                }),
              ),
              Expanded(
                // 좌우 스와이프로 책장을 한 장씩 넘긴다.
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      // 한 페이지씩 딱딱 걸리며 넘어가도록 기본 물리(페이지 스냅) 사용
                      physics: const PageScrollPhysics(),
                      itemCount: pageCount,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (context, pageIndex) =>
                          _buildBookcasePage(images, pageIndex),
                    ),
                    // 장식용 나뭇잎 — 앱바/책장 좌측 상단��� 자연스럽게 늘어진 효과
                    const _LeafDecoration(),
                  ],
                ),
              ),
              // 하단 점(Dot) 인디케이터
              _PageIndicator(
                count: pageCount,
                current: safePage,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 장식용 나뭇잎 (좌측 상단에서 늘어진 효과)
///
/// Stack 안에서 Positioned로 책장 좌상단에 걸쳐 배치한다.
class _LeafDecoration extends StatelessWidget {
  const _LeafDecoration();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -10,
      left: -6,
      child: IgnorePointer(
        // TODO: 실제 나뭇잎 이미지로 교체
        //  (예: 'assets/images/bookcase/leaf.png')
        //  현재는 임시 아이콘 Placeholder.
        child: Transform.rotate(
          angle: -0.5,
          child: Opacity(
            opacity: 0.85,
            child: const Icon(
              Icons.eco,
              size: 92,
              color: Color(0xFF6FB98F),
            ),
          ),
        ),
      ),
    );
  }
}

/// 상단 헤더 카드 — 올해 읽은 책 권수 + 안내 + 정렬
class _BookcaseHeader extends StatelessWidget {
  final int count;
  final bool newestFirst;
  final ValueChanged<bool> onSortChanged;

  const _BookcaseHeader({
    required this.count,
    required this.newestFirst,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              offset: Offset(0, 2),
              blurRadius: 8,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/icon/bookcase.png',
              width: 34,
              height: 34,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.auto_stories_rounded,
                color: Color(0xFF4CAF86),
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Pretendard-Bold',
                        fontSize: 16,
                        color: Color(0xFF3A3F43),
                      ),
                      children: [
                        const TextSpan(text: '올해 읽은 책 '),
                        TextSpan(
                          text: '$count권',
                          style: const TextStyle(color: Color(0xFF2BA776)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '좌우로 넘겨 책장을 둘러보세요.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF8A9199)),
                  ),
                ],
              ),
            ),
            _SortDropdown(
              newestFirst: newestFirst,
              onChanged: onSortChanged,
            ),
          ],
        ),
      ),
    );
  }
}

/// 정렬 드롭다운 (최신순 / 오래된순)
class _SortDropdown extends StatelessWidget {
  final bool newestFirst;
  final ValueChanged<bool> onChanged;

  const _SortDropdown({required this.newestFirst, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<bool>(
      initialValue: newestFirst,
      onSelected: onChanged,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      itemBuilder: (context) => const [
        PopupMenuItem(value: true, child: Text('최신순')),
        PopupMenuItem(value: false, child: Text('오래된순')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              newestFirst ? '최신순' : '오래된순',
              style: const TextStyle(fontSize: 12, color: Color(0xFF606972)),
            ),
            const Icon(Icons.keyboard_arrow_down,
                size: 18, color: Color(0xFF8A9199)),
          ],
        ),
      ),
    );
  }
}

/// 하단 점(Dot) 페이지 인디케이터 — 현재 페이지 강조
class _PageIndicator extends StatelessWidget {
  final int count;
  final int current;

  const _PageIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final active = i == current;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF2BA776) : const Color(0xFFBFD8CC),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}

/// 나무 선반 한 칸 (책 + 선반 판자)
///
/// 페이지 안에서 Expanded로 쓰이므로 세로로 늘어나도 자연스럽게 보이도록
/// 책 영역은 Expanded, 판자는 고정 높이로 구성한다.
class _Shelf extends StatelessWidget {
  final List<String?> images;
  final List<String?> badges;
  final String Function(String) resolve;

  const _Shelf({
    required this.images,
    required this.badges,
    required this.resolve,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 책들이 선반 판자 위에 서 있도록 아래 정렬
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(images.length, (i) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _BookCover(
                        url: images[i] == null ? null : resolve(images[i]!),
                        badgeAsset: badges[i],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        // 선반 판자 — 가로결 나뭇결 텍스처 + 빛 받는 윗선 + 아래로 드리우는 그림자
        Container(
          height: 16,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bookcase/shelf.png'),
              fit: BoxFit.cover,
            ),
            border: Border(
              top: BorderSide(color: Color(0xFFEAD2AE), width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x4D000000),
                offset: Offset(0, 6),
                blurRadius: 8,
                spreadRadius: -2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 책 표지 한 권 (없으면 빈 자리)
class _BookCover extends StatelessWidget {
  final String? url;

  /// 이 책에서 획득한 뱃지 이미지 경로. 없으면 표시하지 않는다.
  final String? badgeAsset;

  const _BookCover({required this.url, this.badgeAsset});

  @override
  Widget build(BuildContext context) {
    final bool empty = url == null;
    final cover = AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: empty
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x66000000),
                    offset: Offset(2, 3),
                    blurRadius: 5,
                    spreadRadius: -2,
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: empty
              ? const DottedBookSlot()
              : Image.network(
                  url!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/book/book_empty.png',
                    fit: BoxFit.cover,
                  ),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const ColoredBox(
                      color: Color(0xFFEDE3D0),
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF9C6B3F),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );

    if (empty || badgeAsset == null) return cover;

    // 표지 위 오른쪽 상단에 획득 뱃지를 살짝 걸쳐 올린다.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        cover,
        // Positioned(
        //   top: -8,
        //   right: -8,
        //   child: _BadgeSticker(asset: badgeAsset!),
        // ),
      ],
    );
  }
}

/// 표지 위에 얹는 획득 뱃지 스티커
class _BadgeSticker extends StatelessWidget {
  final String asset;

  const _BadgeSticker({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF0E4CC), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59000000),
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: -1,
          ),
        ],
      ),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}

/// 빈 책 자리 (점선 표시)
class DottedBookSlot extends StatelessWidget {
  const DottedBookSlot({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x22FFFFFF),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0x55FFFFFF),
          width: 1,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.menu_book_outlined,
          color: Color(0x66FFFFFF),
          size: 18,
        ),
      ),
    );
  }
}
