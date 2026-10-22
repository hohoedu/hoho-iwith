import 'package:flutter_application/_core/http.dart';

/// 내 책장 한 권 — book_clinic `POST /app/bookstore/bookcase` 응답 항목.
///
/// 올해 읽은 책 전체다(직원이 발송한 독서일지에 실린 책만, 같은 책은 최근 1건).
/// 예전에는 메인 응답의 최근 4권(bookImg1~4)을 썼기 때문에 책장이 4권을 넘지 못했다.
class BookcaseBook {
  final int? contentId;
  final String title;

  /// 서버가 주는 표지 경로 — '/uploads/...' 처럼 경로만 올 수 있어 그릴 땐 [coverUrl].
  final String? imageUrl;
  final DateTime? readDate;

  /// KING 정독왕 / FRIEND 정독 완료 / RETRY 재도전 필요 / null
  final String? result;

  BookcaseBook({
    this.contentId,
    required this.title,
    this.imageUrl,
    this.readDate,
    this.result,
  });

  factory BookcaseBook.fromJson(Map<String, dynamic> json) {
    final id = json['contentId'];
    return BookcaseBook(
      contentId: id is int ? id : int.tryParse(id?.toString() ?? ''),
      title: json['title']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      readDate: DateTime.tryParse(json['readDate']?.toString() ?? ''),
      result: json['result']?.toString(),
    );
  }

  /// 메인 화면 최근 표지(bookImg1~4)로 만든 임시 항목 — 책장 API를 못 받았을 때만 쓴다.
  factory BookcaseBook.coverOnly(String imageUrl) => BookcaseBook(title: '', imageUrl: imageUrl);

  String? get coverUrl {
    final path = imageUrl?.trim();
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return path.startsWith('/') ? '$bookstoreOrigin$path' : '$bookstoreOrigin/$path';
  }
}
