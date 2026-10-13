import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_main_data.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:get/get.dart';

/// 책장 화면
class BookstoreBookcaseScreen extends StatefulWidget {
  const BookstoreBookcaseScreen({super.key});

  @override
  State<BookstoreBookcaseScreen> createState() => _BookstoreBookcaseScreenState();
}

class _BookstoreBookcaseScreenState extends State<BookstoreBookcaseScreen> {
  static const Color _bg = Color(0xFFD9EFE4);

  static const int _booksPerShelf = 4;

  static const int _minShelves = 5;

  bool _newestFirst = true;

  Widget _buildShelf(List<String> images, int shelfIndex) {
    final start = shelfIndex * _booksPerShelf;
    final shelfImages = <String?>[];
    for (var i = 0; i < _booksPerShelf; i++) {
      final idx = start + i;
      final hasBook = idx < images.length;
      shelfImages.add(hasBook ? images[idx] : null);
    }
    return _Shelf(images: shelfImages);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookstoreMainDataController>(
      init: BookstoreMainDataController(),
      builder: (c) {
        final data = c.data;
        final raw = data?.recentBookImages ?? const <String>[];
        final images = _newestFirst ? raw : raw.reversed.toList(growable: false);

        final shelfCount = ((images.length + _booksPerShelf - 1) ~/ _booksPerShelf).clamp(_minShelves, 999);

        return Scaffold(
          backgroundColor: _bg,
          appBar: const MainAppBar(title: '내 책장', color: _bg),
          body: Column(
            children: [
              _BookcaseHeader(
                count: raw.length,
                newestFirst: _newestFirst,
                onSortChanged: (v) => setState(() => _newestFirst = v),
              ),
              Expanded(
                child: Stack(
                  children: [
                    const Positioned.fill(child: ColoredBox(color: _Wood.backPanel)),
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const ClampingScrollPhysics(),
                      itemCount: shelfCount + 2,
                      itemBuilder: (context, i) {
                        if (i == 0) return const _Crown();
                        if (i == shelfCount + 1) return const _Footer();
                        return _buildShelf(images, i - 1);
                      },
                    ),
                    // 장식 잎
                    // const _LeafLeftDecoration(),
                    // const _LeafRightDecoration(),
                    // const _LeafRight2Decoration(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Wood {
  static const double refWidth = 941;
  static const double crownH = 58;
  static const double topH = 26;
  static const double boardH = 30;
  static const double leftInset = 66;
  static const double rightInset = 64;
  static const double gap = 17;
  static const double sink = 2;
  static const double coverAspect = 3 / 4;
  static const Color backPanel = Color(0xFF865A34);
  static const String _dir = 'assets/images/bookcase/';
  static const String crown = '${_dir}bc_crown.png';
  static const String top = '${_dir}bc_top.png';
  static const String mid = '${_dir}bc_mid.png';
  static const String board = '${_dir}bc_board.png';
}

Widget _woodSlice(String asset, double height) {
  return Image.asset(
    asset,
    width: double.infinity,
    height: height,
    fit: BoxFit.fill,
    filterQuality: FilterQuality.medium,
    gaplessPlayback: true,
  );
}

class _Crown extends StatelessWidget {
  const _Crown();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => _woodSlice(_Wood.crown, _Wood.crownH * c.maxWidth / _Wood.refWidth),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final s = c.maxWidth / _Wood.refWidth;
        return Column(
          children: [
            _woodSlice(_Wood.top, _Wood.topH * s),
            Container(
              height: 24 * s,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF8A5C34), Color(0xFF6E4524)],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

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
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
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
              'assets/images/icon/books2.png',
              width: 44,
              height: 44,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.auto_stories_rounded,
                color: Color(0xFF4CAF86),
                size: 38,
              ),
            ),
            const SizedBox(width: 14),
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
                          text: '$count',
                          style: const TextStyle(color: Color(0xFF2BA776), fontSize: 24),
                        ),
                        const TextSpan(text: ' 권'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '스크롤하여 책장을 둘러보세요.',
                    style: TextStyle(fontSize: 12, color: Color(0xFFA0A7AE)),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              newestFirst ? '최신순' : '오래된순',
              style: const TextStyle(fontSize: 13, color: Color(0xFF606972)),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF8A9199)),
          ],
        ),
      ),
    );
  }
}
class _Shelf extends StatelessWidget {
  final List<String?> images;

  const _Shelf({
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final s = c.maxWidth / _Wood.refWidth;
        final topH = _Wood.topH * s;
        final boardH = _Wood.boardH * s;
        final sink = _Wood.sink * s;
        final left = _Wood.leftInset * s;
        final right = _Wood.rightInset * s;
        final gap = _Wood.gap * s;
        final bookW = (c.maxWidth - left - right - gap * (images.length - 1)) / images.length;
        final bookH = bookW / _Wood.coverAspect;
        final midH = bookH - sink;

        return SizedBox(
          height: topH + midH + boardH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 뒤판+기둥: 위/아래 조각과 1px씩 겹쳐서 이음새 틈이 안 보이게 한다.
              Positioned(
                left: 0,
                right: 0,
                top: topH - 1,
                height: midH + 2,
                child: _woodSlice(_Wood.mid, midH + 2),
              ),
              Positioned(left: 0, right: 0, top: 0, height: topH, child: _woodSlice(_Wood.top, topH)),
              Positioned(left: 0, right: 0, top: topH + midH, height: boardH, child: _woodSlice(_Wood.board, boardH)),
              // 책: 선반 윗면 위에 선다
              Positioned(
                left: left,
                top: topH,
                width: c.maxWidth - left - right,
                height: bookH,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(images.length, (i) {
                    return SizedBox(
                      width: bookW,
                      height: bookH,
                      child: _BookCover(url: images[i]),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BookCover extends StatelessWidget {
  final String? url;

  const _BookCover({required this.url});

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
                    color: Color(0x40000000),
                    offset: Offset(2, 1),
                    blurRadius: 3,
                    spreadRadius: -1,
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
    return cover;
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
