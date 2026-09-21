// 정독 결과 화면 각 섹션이 스크롤 본문(세로 제약 무한) 안에서 레이아웃되는지 본다.
//
// 카드들이 고정 height 를 버리고 자식이 필요한 높이를 말하는 구조로 바뀌면서, 세로 제약이
// 무한인 자리에 무한 높이를 요구하는 위젯이 섞이면 바로 터진다 — 실제로 보상 카드의
// Row(crossAxisAlignment: stretch) 가 그렇게 터졌다(런타임에는 semantics 단언으로 나타난다).

import 'package:flutter/material.dart';
import 'package:flutter_application/_core/constants.dart';
import 'package:flutter_application/models/bookstore/bookstore_report_data.dart';
import 'package:flutter_application/screens/bookstore/report/report_widgets/bookstore_report_graph.dart';
import 'package:flutter_application/screens/bookstore/report/report_widgets/report_book_result_card.dart';
import 'package:flutter_application/screens/bookstore/report/report_widgets/report_date_tabs.dart';
import 'package:flutter_application/screens/bookstore/report/report_widgets/report_preference_card.dart';
import 'package:flutter_application/screens/bookstore/report/report_widgets/report_reward_card.dart';
import 'package:flutter_application/screens/bookstore/report/report_widgets/report_summary_card.dart';
import 'package:flutter_test/flutter_test.dart';

BookstoreReportData sample({
  int books = 3,
  int tendencies = 6,
  int monthly = 4,
  List<String>? dates,
}) {
  const typeNames = ['이해', '표현', '어휘', '감정', '사고', '논리'];
  return BookstoreReportData(
    studentName: '김호호',
    dates: dates ?? ['2026-08-14', '2026-08-21', '2026-08-28', '2026-09-04'],
    recordDate: '2026-09-04',
    bookCount: books,
    readMinutes: 50,
    correctRate: 82,
    totalBookCount: 32,
    books: List.generate(
      books,
      (i) => ReportBook(
        contentId: i,
        title: '아주아주 긴 책 제목이 들어올 수도 있어요 $i',
        basicCorrect: 12,
        basicTotal: 12,
        advancedCorrect: 3,
        advancedTotal: 6,
        retryCount: i,
        correctRate: 72,
        growthWords: i == 0 ? const ['흉측하다', '가뭄'] : const [],
      ),
    ),
    badges: List.generate(
      5,
      (i) => ReportBadge(
        badgeId: i + 1,
        category: const ['BASIC_FAIL', 'BASIC_PASS', 'BASIC_PERFECT', 'ADV_PASS', 'ADV_PERFECT'][i],
        badgeName: '뱃지 이름이 긴 경우 $i',
        badgeDesc: '설명이 제법 길게 들어오는 경우도 있습니다 $i',
        earned: i.isEven,
        earnedCount: i,
      ),
    ),
    tendencies: List.generate(
      tendencies,
      (i) => ReportTendency(typeCode: '0$i', typeName: typeNames[i], rate: 50.0 + i * 8, answerCount: 10),
    ),
    monthly: List.generate(monthly, (i) => ReportMonthly(year: 2026, month: i + 1, count: 3 + i)),
  );
}

/// 좁은 화면(360x640)과 넓은 화면 양쪽에서 스크롤 본문에 얹어 본다.
Future<void> pumpInList(WidgetTester tester, List<Widget> children, {Size? size}) async {
  tester.view.physicalSize = size ?? const Size(360, 640);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(body: ListView(children: children)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('요약 카드', (t) async {
    await pumpInList(t, [ReportSummaryCard(data: sample())]);
    expect(t.takeException(), isNull);
  });

  testWidgets('책 결과 카드 — 책 3권', (t) async {
    await pumpInList(t, [
      ReportBookResultCard(books: sample().books, selectedIndex: 0, onSelectBook: (_) {}),
    ]);
    expect(t.takeException(), isNull);
  });

  testWidgets('책 결과 카드 — 책 1권(탭 없음)', (t) async {
    await pumpInList(t, [
      ReportBookResultCard(books: sample(books: 1).books, selectedIndex: 0, onSelectBook: (_) {}),
    ]);
    expect(t.takeException(), isNull);
  });

  testWidgets('보상 카드 — 5종', (t) async {
    await pumpInList(t, [ReportRewardCard(data: sample())]);
    expect(t.takeException(), isNull);
  });

  testWidgets('독서 성향 카드', (t) async {
    await pumpInList(t, [ReportPreferenceCard(data: sample())]);
    expect(t.takeException(), isNull);
  });

  testWidgets('독서 성향 카드 — 유형 2개만', (t) async {
    await pumpInList(t, [ReportPreferenceCard(data: sample(tendencies: 2))]);
    expect(t.takeException(), isNull);
  });

  testWidgets('그래프 — 4개월', (t) async {
    await pumpInList(t, [BookstoreReportGraph(monthly: sample().monthly)]);
    expect(t.takeException(), isNull);
  });

  testWidgets('그래프 — 1개월', (t) async {
    await pumpInList(t, [BookstoreReportGraph(monthly: sample(monthly: 1).monthly)]);
    expect(t.takeException(), isNull);
  });

  testWidgets('그래프 — 기록 없음', (t) async {
    await pumpInList(t, [const BookstoreReportGraph(monthly: [])]);
    expect(t.takeException(), isNull);
  });

  testWidgets('일자 탭 — 2개만 내려온 경우', (t) async {
    await pumpInList(t, [
      ReportDateTabs(labels: const ['8월 14일', '8월 21일'], selectedIndex: 1, onSelect: (_) {}),
    ]);
    expect(t.takeException(), isNull);
  });

  testWidgets('전체 섹션 한 화면 — 좁은 기기', (t) async {
    final d = sample();
    await pumpInList(
        t,
        [
          ReportSummaryCard(data: d),
          ReportBookResultCard(books: d.books, selectedIndex: 0, onSelectBook: (_) {}),
          ReportRewardCard(data: d),
          ReportPreferenceCard(data: d),
          BookstoreReportGraph(monthly: d.monthly),
        ],
        size: const Size(320, 568));
    expect(t.takeException(), isNull);
  });

  testWidgets('재도전 유무로 카드 높이가 바뀌지 않는다', (t) async {
    // 책 탭을 옮길 때 아래 점수 박스가 위아래로 튀면 안 된다. 재도전 줄은 라벨이 없어도
    // 자리를 지키고, 라벨이 길어도 한 줄로 고정된다(maxLines: 1).
    ReportBook mk(int retryCount) => ReportBook(
          title: '같은 책',
          basicCorrect: 12,
          basicTotal: 12,
          advancedCorrect: 3,
          advancedTotal: 6,
          retryCount: retryCount,
          correctRate: 72,
        );

    Future<double> heightOf(ReportBook b) async {
      await pumpInList(t, [
        ReportBookResultCard(books: [b], selectedIndex: 0, onSelectBook: (_) {}),
      ]);
      return t.getSize(find.byType(ReportBookResultCard).first).height;
    }

    expect(mk(1).retryCountLabel, isNotNull);
    expect(mk(0).retryCountLabel, isNull);
    expect(await heightOf(mk(0)), await heightOf(mk(1)));
    expect(t.takeException(), isNull);
  });

  Future<void> pumpOneBook(WidgetTester t, ReportBook b) async {
    await pumpInList(t, [
      ReportBookResultCard(books: [b], selectedIndex: 0, onSelectBook: (_) {}),
    ]);
  }

  testWidgets('표지가 있으면 돋보기가 뜨고, 탭하면 확대된다', (t) async {
    await pumpOneBook(t, ReportBook(title: '강아지 똥', imageUrl: '/uploads/book/a.jpeg'));

    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsNothing);

    await t.tap(find.byIcon(Icons.search));
    await t.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget, reason: '확대 뷰어가 떠야 한다');

    // 배경 탭으로 닫힌다
    await t.tapAt(const Offset(10, 10));
    await t.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
  });

  testWidgets('표지가 없으면 돋보기도 없다', (t) async {
    await pumpOneBook(t, ReportBook(title: '표지없음'));
    expect(find.byIcon(Icons.search), findsNothing);
    expect(find.byIcon(Icons.menu_book), findsOneWidget, reason: '자리표시자');
  });

  testWidgets('돋보기가 표지 우하단 밖으로 걸친다', (t) async {
    // 배지는 표지 모서리 밖으로 삐져나온다. Stack 기본값(Clip.hardEdge)이면
    // 삐져나온 부분이 잘려 안 보이므로 clipBehavior 도 함께 고정한다.
    await pumpOneBook(t, ReportBook(title: '강아지 똥', imageUrl: '/uploads/book/a.jpeg'));

    final cover = t.getRect(find.byType(ClipRRect).first);
    final badge = t.getRect(find.byIcon(Icons.search));

    expect(badge.right, greaterThan(cover.right), reason: '오른쪽으로 삐져나와야 한다');
    expect(badge.bottom, greaterThan(cover.bottom), reason: '아래로 삐져나와야 한다');
    expect(badge.left, lessThan(cover.right), reason: '모서리에 걸쳐야 한다(완전히 벗어나면 안 됨)');
    expect(badge.top, lessThan(cover.bottom));

    final stack = t.widget<Stack>(
      find.ancestor(of: find.byIcon(Icons.search), matching: find.byType(Stack)).first,
    );
    expect(stack.clipBehavior, Clip.none, reason: '잘리면 밖으로 나간 게 안 보인다');

    expect(t.takeException(), isNull);
  });

  testWidgets('재도전 줄은 "재도전 N회"만 뜨고 처음점수는 안 뜬다', (t) async {
    // 채점 정책이 바뀌면서 '처음점수 / 최종점수' 개념이 폐지됐다 — 재제출 결과가 곧
    // 그 학생의 점수이고 지난 점수는 어디에도 노출하지 않는다. 재도전 줄에는 횟수만 남는다.
    await pumpOneBook(
      t,
      ReportBook(title: '같은 책', basicCorrect: 12, basicTotal: 12, retryCount: 2, correctRate: 72),
    );

    expect(find.text('재도전 2회'), findsOneWidget);
    expect(
      find.textContaining('처음점수'),
      findsNothing,
      reason: '지난 점수는 화면에 노출되면 안 된다',
    );
    expect(t.takeException(), isNull);
  });

  testWidgets('표지 바닥이 점수 박스 바닥과 맞는다', (t) async {
    // IntrinsicHeight + stretch 로 표지 높이를 오른쪽 칼럼이 정하게 했다.
    // 폭이 바뀌면 칼럼 높이도 바뀌므로 여러 기기 폭에서 확인한다.
    final scoreBox = find.byWidgetPredicate((w) =>
        w is Container &&
        w.decoration is BoxDecoration &&
        (w.decoration as BoxDecoration).color == const Color(0xFFF3F5F8));

    for (final width in [320.0, 360.0, 430.0]) {
      await pumpInList(
        t,
        [ReportBookResultCard(books: sample().books, selectedIndex: 0, onSelectBook: (_) {})],
        size: Size(width, 900),
      );

      final cover = t.getRect(find.byType(ClipRRect).first);
      final score = t.getRect(scoreBox.first);

      expect(cover.bottom, score.bottom, reason: '@$width 바닥이 어긋남');
      expect(cover.height, greaterThan(0), reason: '@$width 표지 높이 0');
    }
    expect(t.takeException(), isNull);
  });

  group('문해력 아이콘', () {
    // 어법(gram)/어휘(voca) 2종을 책마다 다르게 쓰되, 같은 책은 늘 같은 그림이어야 한다.
    // build 안에서 Random 을 돌리면 탭을 옮길 때마다 아이콘이 깜빡여 고장난 것처럼 보인다.
    ReportBook growthBook(int? id, String title) => ReportBook(
          contentId: id,
          title: title,
          basicCorrect: 12,
          basicTotal: 12,
          correctRate: 90,
          growthWords: const ["'흉측하다'", "'가뭄'"],
        );

    Future<String> iconOf(WidgetTester t, ReportBook b) async {
      await pumpOneBook(t, b);
      for (final img in t.widgetList<Image>(find.byType(Image))) {
        final p = img.image;
        final name = p is AssetImage
            ? p.assetName
            : p is ExactAssetImage
                ? p.assetName
                : '';
        if (name.contains('advance_')) return name.split('/').last;
      }
      fail('문해력 아이콘을 못 찾음');
    }

    testWidgets('두 아이콘이 모두 쓰인다', (t) async {
      final picks = <String>{};
      for (var id = 1; id <= 6; id++) {
        picks.add(await iconOf(t, growthBook(id, '책$id')));
      }
      expect(picks, containsAll(['advance_gram.png', 'advance_voca.png']));
    });

    testWidgets('같은 책은 리빌드해도 안 바뀐다', (t) async {
      final b = growthBook(7, '강아지 똥');
      final first = await iconOf(t, b);
      expect(await iconOf(t, b), first);
      expect(await iconOf(t, b), first);
    });

    testWidgets('contentId 가 없어도 제목으로 고른다', (t) async {
      final b = growthBook(null, '아이디 없는 책');
      final first = await iconOf(t, b);
      expect(first, anyOf('advance_gram.png', 'advance_voca.png'));
      expect(await iconOf(t, b), first);
    });
  });

  group('보상 카드', () {
    // 2×2 고정 4칸: 정독왕 / 문해력 챔피언 / 독서기록 / 능력(정답률 1위 유형).
    String plainOf(WidgetTester t, String contains) => t
        .widgetList<RichText>(
            find.descendant(of: find.byType(ReportRewardCard), matching: find.byType(RichText)))
        .map((r) => r.text.toPlainText())
        .firstWhere((p) => p.contains(contains));

    List<String> plainAll(WidgetTester t) => t
        .widgetList<RichText>(
            find.descendant(of: find.byType(ReportRewardCard), matching: find.byType(RichText)))
        .map((r) => r.text.toPlainText())
        .toList();

    // 세트 칸: 그날 받은 것 중 가장 높은 등급 하나만 올라간다.
    // 완독 < 정독 완료 < 정독왕, 문해력 챌린저 < 문해력 챔피언.
    BookstoreReportData withBadges(Map<String, int> earnedCounts) => BookstoreReportData(
          studentName: '테스트',
          recordDate: '2026-09-15',
          badges: const {
            'BASIC_FAIL': '완독',
            'BASIC_PASS': '정독 완료',
            'BASIC_PERFECT': '정독왕',
            'ADV_PASS': '문해력 챌린저',
            'ADV_PERFECT': '문해력 챔피언',
          }
              .entries
              .map((e) => ReportBadge(
                    category: e.key,
                    badgeName: e.value,
                    earned: (earnedCounts[e.key] ?? 0) > 0,
                    earnedCount: earnedCounts[e.key] ?? 0,
                  ))
              .toList(),
        );

    testWidgets('정독 세트 — 정독 완료와 정독왕을 받으면 정독왕만 나온다', (t) async {
      await pumpInList(t, [
        ReportRewardCard(data: withBadges({'BASIC_PASS': 1, 'BASIC_PERFECT': 1}))
      ]);
      expect(plainAll(t), contains('정독왕을 1번\n달성했어요.'));
      expect(plainAll(t).any((p) => p.contains('정독 완료')), isFalse);
    });

    testWidgets('정독 세트 — 정독 완료만 두 번이면 정독 완료가 2번', (t) async {
      await pumpInList(t, [ReportRewardCard(data: withBadges({'BASIC_PASS': 2}))]);
      expect(plainAll(t), contains('정독 완료를 2번\n달성했어요.'));
    });

    testWidgets('정독 세트 — 완독과 정독왕이면 정독왕이 이긴다', (t) async {
      await pumpInList(t, [
        ReportRewardCard(data: withBadges({'BASIC_FAIL': 1, 'BASIC_PERFECT': 1}))
      ]);
      expect(plainAll(t), contains('정독왕을 1번\n달성했어요.'));
    });

    testWidgets('정독 세트 — 완독만 받으면 완독이 나온다', (t) async {
      await pumpInList(t, [ReportRewardCard(data: withBadges({'BASIC_FAIL': 3}))]);
      expect(plainAll(t), contains('완독을 3번\n달성했어요.'));
    });

    testWidgets('문해력 세트 — 챌린저만 받으면 챌린저가 나온다', (t) async {
      await pumpInList(t, [ReportRewardCard(data: withBadges({'ADV_PASS': 1}))]);
      expect(plainAll(t), contains('문해력 챌린저를 1번\n달성했어요.'));
      expect(plainAll(t).any((p) => p.contains('문해력 챔피언을 ')), isFalse);
    });

    testWidgets('문해력 세트 — 챌린저와 챔피언이면 챔피언만 나온다', (t) async {
      await pumpInList(t, [
        ReportRewardCard(data: withBadges({'ADV_PASS': 2, 'ADV_PERFECT': 1}))
      ]);
      expect(plainAll(t), contains('문해력 챔피언을 1번\n달성했어요.'));
    });

    testWidgets('하나도 못 받은 세트는 최상위 뱃지를 수량 없이 깔아 둔다', (t) async {
      await pumpInList(t, [ReportRewardCard(data: withBadges({}))]);
      expect(plainAll(t), contains('정독왕을\n달성했어요.'));
      expect(plainAll(t), contains('문해력 챔피언을\n달성했어요.'));
    });

    testWidgets('서버가 준 rank 가 앱 기본 등급표를 이긴다', (t) async {
      // 앱이 모르는 새 뱃지가 정독 세트 맨 위로 들어온 경우 — 앱을 새로 내보내지 않아도
      // 서버가 rank 만 얹어 보내면 그날의 최고 등급으로 올라와야 한다.
      await pumpInList(t, [
        ReportRewardCard(
          data: BookstoreReportData(
            studentName: '테스트',
            recordDate: '2026-09-15',
            badges: [
              ReportBadge(category: 'BASIC_PASS', badgeName: '정독 완료', earned: true, earnedCount: 3),
              ReportBadge(
                  category: 'BASIC_PERFECT', badgeName: '정독왕', earned: true, earnedCount: 2),
              ReportBadge(
                  category: 'BASIC_SUPER',
                  badgeName: '정독 마스터',
                  rank: 4,
                  earned: true,
                  earnedCount: 1),
            ],
          ),
        )
      ]);
      expect(plainAll(t), contains('정독 마스터를 1번\n달성했어요.'));
    });

    testWidgets('세트는 category 앞머리로 갈리고 순서는 서버가 보낸 순서를 따른다', (t) async {
      await pumpInList(t, [
        ReportRewardCard(
          data: BookstoreReportData(
            studentName: '테스트',
            recordDate: '2026-09-15',
            badges: [
              ReportBadge(category: 'ADV_PASS', badgeName: '문해력 챌린저', earned: true, earnedCount: 1),
              ReportBadge(category: 'BASIC_PASS', badgeName: '정독 완료', earned: true, earnedCount: 1),
            ],
          ),
        )
      ]);
      final all = plainAll(t);
      expect(all.indexOf('문해력 챌린저를 1번\n달성했어요.'),
          lessThan(all.indexOf('정독 완료를 1번\n달성했어요.')));
    });

    testWidgets('능력 칸은 정답률 1위 유형이 나온다', (t) async {
      // 1위가 '논리'(97.6)인 표본 — 목록 순서상 맨 뒤라 순서가 아니라 값으로 골랐음을 보장한다.
      await pumpInList(t, [ReportRewardCard(data: sample())]);
      expect(plainOf(t, '증가했어요'), '논리 능력이\n증가했어요.');
      expect(t.takeException(), isNull);
    });

    testWidgets('1위가 바뀌면 따라 바뀐다', (t) async {
      final data = BookstoreReportData(
        studentName: '테스트',
        recordDate: '2026-09-15',
        tendencies: [
          ReportTendency(typeCode: '01', typeName: '이해', rate: 30, answerCount: 10),
          ReportTendency(typeCode: '04', typeName: '감정', rate: 99, answerCount: 10),
          ReportTendency(typeCode: '06', typeName: '논리', rate: 50, answerCount: 10),
        ],
      );
      await pumpInList(t, [ReportRewardCard(data: data)]);
      expect(plainOf(t, '증가했어요'), '감정 능력이\n증가했어요.');
    });

    testWidgets('유형이 없으면 빈 이름으로 접힌다', (t) async {
      await pumpInList(t, [
        ReportRewardCard(
          data: BookstoreReportData(studentName: '테스트', recordDate: '2026-09-15'),
        ),
      ]);
      expect(t.takeException(), isNull);
    });

    testWidgets('유형 아이콘과 색이 유형을 따라간다', (t) async {
      // 보석 아이콘 7종(comp/expr/voca/emo/think/logic/know)이 유형 이름으로 매핑된다.
      for (final entry in {'감정': 'emo.png', '논리': 'logic.png', '어휘': 'voca.png'}.entries) {
        await pumpInList(t, [
          ReportRewardCard(
            data: BookstoreReportData(
              studentName: '테스트',
              recordDate: '2026-09-15',
              tendencies: [
                ReportTendency(typeCode: '01', typeName: '이해', rate: 10, answerCount: 5),
                ReportTendency(typeCode: '99', typeName: entry.key, rate: 99, answerCount: 5),
              ],
            ),
          ),
        ]);

        final names = t
            .widgetList<Image>(
                find.descendant(of: find.byType(ReportRewardCard), matching: find.byType(Image)))
            .map((i) {
          final p = i.image;
          return p is AssetImage ? p.assetName : (p is ExactAssetImage ? p.assetName : '');
        }).toList();

        expect(names.any((n) => n.endsWith(entry.value)), isTrue,
            reason: '${entry.key} → ${entry.value} 가 없음');
        expect(tendencyTextColors[entry.key], isNotNull, reason: '${entry.key} 색 미정의');
      }
      expect(t.takeException(), isNull);
    });

    testWidgets('아이콘 7종이 모든 유형을 덮는다', (t) async {
      // bubbleColors 에 있는 유형은 보상 칸에도 올 수 있다 — 둘의 키가 어긋나면 그림이 빈다.
      for (final type in bubbleColors.keys) {
        expect(tendencyIcons[type], isNotNull, reason: '$type 아이콘 없음');
        expect(tendencyTextColors[type], isNotNull, reason: '$type 색 없음');
      }
    });
  });
}
