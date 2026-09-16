// 정독 결과 모델의 파생 값.
//
// 표지는 서버가 '/uploads/book/xxx.jpeg' 처럼 경로만 보낸다 — 오리진 결합을 모델이 맡는다.

import 'package:flutter_application/models/bookstore/bookstore_report_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReportBook.coverUrl', () {
    test('경로만 오면 오리진을 붙인다', () {
      expect(
        ReportBook(title: 'x', imageUrl: '/uploads/book/643dcafa650b4b398cbdb843ff4b65bc.jpeg')
            .coverUrl,
        'https://hohobooks.co.kr/uploads/book/643dcafa650b4b398cbdb843ff4b65bc.jpeg',
      );
    });
    test('앞 슬래시가 없어도 붙인다', () {
      expect(ReportBook(title: 'x', imageUrl: 'uploads/book/a.jpeg').coverUrl,
          'https://hohobooks.co.kr/uploads/book/a.jpeg');
    });
    test('이미 절대 URL 이면 그대로', () {
      expect(ReportBook(title: 'x', imageUrl: 'https://cdn.example.com/a.jpg').coverUrl,
          'https://cdn.example.com/a.jpg');
    });
    test('없거나 비면 null', () {
      expect(ReportBook(title: 'x').coverUrl, isNull);
      expect(ReportBook(title: 'x', imageUrl: '   ').coverUrl, isNull);
    });
  });
}
