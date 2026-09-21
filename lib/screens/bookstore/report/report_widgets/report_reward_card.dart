import 'package:flutter/material.dart';
import 'package:flutter_application/_core/constants.dart';
import 'package:flutter_application/models/bookstore/bookstore_report_data.dart';

/// 보상 — '이번 독서 활동에서는' 2×2 칸.
class ReportRewardCard extends StatelessWidget {
  const ReportRewardCard({super.key, required this.data});

  final BookstoreReportData data;

  static const double _cellHeight = 72;
  static const double _iconSize = 44;

  @override
  Widget build(BuildContext context) {
    final cells = [
      ..._badgeCells(),
      _recordCell(),
      _abilityCell(),
    ];

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
                padding: EdgeInsets.only(bottom: 12.0),
                child: Text('이번 독서 활동에서는',
                    style: TextStyle(fontFamily: 'Pretendard-Bold', color: Color(0xFF363636))),
              ),
              for (int row = 0; row < 2; row++)
                Row(
                  children: [
                    for (int col = 0; col < 2; col++)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: col == 0 ? 0.0 : 5.0,
                            right: col == 0 ? 5.0 : 0.0,
                            bottom: row == 0 ? 10.0 : 0.0,
                          ),
                          child: _cellBox(cells[row * 2 + col]),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 칸 만들기 ──

  /// 세트 칸 색. 세트를 서버가 늘리면 기본색으로 떨어진다 — 글자는 그대로 나온다.
  static const Map<String, Color> _groupColors = {
    'BASIC': Color(0xFF005CE0), // 완독 / 정독 완료 / 정독왕
    'ADV': Color(0xFF6224B7), // 문해력 챌린저 / 문해력 챔피언
  };

  /// 위 두 칸. 어떤 세트가 어느 자리에 올지는 서버가 뱃지를 보낸 순서가 정한다.
  ///
  /// 세트가 둘보다 적게 와도 2×2 는 유지한다 — 칸이 하나 비는 편이 격자가 무너지는 것보다 낫다.
  List<_RewardCell> _badgeCells() {
    final groups = data.badgeGroups.entries.take(2).toList();
    return [
      for (final group in groups) _setCell(group.key, group.value),
      for (int i = groups.length; i < 2; i++) _emptyCell(),
    ];
  }

  /// 뱃지 세트 칸 — 그날 받은 것 중 가장 높은 등급 하나만 올린다.
  ///
  /// 정독 완료 + 정독왕 → '정독왕을 1번', 정독 완료 두 번 → '정독 완료를 2번'.
  /// 수량은 낮은 등급까지 더하지 않고 뽑힌 등급의 횟수만 센다.
  ///
  /// [ranked] 는 등급 오름차순([BookstoreReportData.badgeGroups])이다. 등급 순서는 서버가
  /// 주는 rank 라, 뱃지가 늘거나 순위가 바뀌어도 앱을 새로 내보낼 일이 없다.
  ///
  /// 세트에서 하나도 못 받았으면 최상위 뱃지를 흑백으로 깔아 둔다 — 칸을 비우는 것보다
  /// 무엇을 더 받을 수 있는지 보이는 쪽이 낫다.
  ///
  /// 이름은 서버가 준 badgeName 을 그대로 쓴다. 뱃지 이미지 안에 이름이 그려져 있어서
  /// (advance_perfect.png = '문해력 챔피언') 임의로 바꿔 쓰면 그림과 글자가 어긋난다.
  _RewardCell _setCell(String groupCode, List<ReportBadge> ranked) {
    if (ranked.isEmpty) return _emptyCell();

    // 낮은 등급부터 훑으며 달성한 것으로 계속 교체한다 → 마지막에 최고 등급이 남는다.
    ReportBadge? top;
    for (final badge in ranked) {
      if (badge.earned || badge.earnedCount > 0) top = badge;
    }

    final badge = top ?? ranked.last;
    final count = top?.earnedCount ?? 0;

    return _RewardCell(
      assetPath: badge.assetPath,
      name: badge.badgeName,
      nameColor: _groupColors[groupCode] ?? _amountColor,
      particle: _objectParticle(badge.badgeName),
      amount: count > 0 ? '$count번' : null,
      tail: '\n달성했어요.',
      earned: top != null,
    );
  }

  /// 채울 세트가 없을 때의 빈 칸. 회색 바닥만 남는다.
  _RewardCell _emptyCell() => const _RewardCell(
        name: '',
        nameColor: Color(0xFFB7B6B6),
        particle: '',
        tail: '',
        earned: false,
      );

  /// 이름 끝 받침에 따른 목적격 조사 — '정독왕을', '정독 완료를'.
  ///
  /// 칸에 오르는 이름이 등급에 따라 바뀌므로 조사를 상수로 박아 둘 수 없다.
  static String _objectParticle(String name) {
    final trimmed = name.trimRight();
    if (trimmed.isEmpty) return '을';
    final code = trimmed.runes.last;
    if (code < 0xAC00 || code > 0xD7A3) return '을'; // 한글 음절이 아니면 기본값
    return (code - 0xAC00) % 28 == 0 ? '를' : '을';
  }

  /// 독서기록 칸.
  _RewardCell _recordCell() {
    final count = data.bookCount;
    return _RewardCell(
      assetPath: 'assets/images/book_report/passport.png',
      name: '독서기록',
      nameColor: const Color(0xFF3D7BFF),
      particle: '이',
      amount: count > 0 ? '$count개' : null,
      tail: '\n누적됐어요.',
      earned: count > 0,
    );
  }

  /// 능력 칸 — 정답률 1위 유형을 내세운다.
  ///
  /// tendencies 는 그 날짜까지의 누적 정답률이라 유형 간 비교가 가능하다. 동률이면 서버가
  /// 준 순서(유형 코드순)에서 앞선 것이 이긴다 — reduce 가 더 큰 값에서만 교체하기 때문이다.
  _RewardCell _abilityCell() {
    final top = data.tendencies.isEmpty
        ? null
        : data.tendencies.reduce((a, b) => b.rate > a.rate ? b : a);

    final name = top?.typeName ?? '';
    return _RewardCell(
      // 유형 아이콘/색은 마스터에 없는 이름(예: 문법)이 오면 비어 있을 수 있다 —
      // 그때는 그림 없이 글자만 나가고 색은 기본값으로 떨어진다.
      assetPath: tendencyIcons[name],
      name: name,
      nameColor: tendencyTextColors[name] ?? _amountColor,
      particle: ' 능력이',
      tail: '\n증가했어요.',
      earned: top != null,
    );
  }

  // ── 칸 그리기 ──
  Widget _cellBox(_RewardCell cell) {
    return Container(
      height: _cellHeight,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _cellIcon(cell),
          const SizedBox(width: 8),
          Expanded(child: _cellText(cell)),
        ],
      ),
    );
  }

  /// 못 받은 칸은 흑백으로 깔아둔다 — 무엇을 더 받을 수 있는지는 보이되 구분되게.
  Widget _cellIcon(_RewardCell cell) {
    Widget child;
    if (cell.assetPath != null) {
      child = Image.asset(
        cell.assetPath!,
        width: _iconSize,
        height: _iconSize,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox(width: _iconSize, height: _iconSize),
      );
    } else if (cell.icon != null) {
      child = SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: Icon(cell.icon, size: 30, color: cell.iconColor),
      );
    } else {
      return const SizedBox(width: _iconSize);
    }

    if (cell.earned) return child;

    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126, 0.7152, 0.0722, 0, 0, //
        0.2126, 0.7152, 0.0722, 0, 0, //
        0.2126, 0.7152, 0.0722, 0, 0, //
        0, 0, 0, 0.45, 0, //
      ]),
      child: child,
    );
  }

  /// '**정독왕**을 **2번**\n달성했어요.'
  ///
  /// 이름은 칸마다 제 색을 쓰고(정독왕 파랑, 문해력 챔피언 보라), 수량은 칸과 무관하게
  /// 늘 같은 진회색이다 — 색이 이름을 가리키는 표시라 수량까지 물들이면 의미가 흐려진다.
  Widget _cellText(_RewardCell cell) {
    final bool on = cell.earned;
    final Color nameColor = on ? cell.nameColor : const Color(0xFFB7B6B6);
    final Color amountColor = on ? _amountColor : const Color(0xFFB7B6B6);
    final Color plain = on ? _amountColor : const Color(0xFFC6CDD2);

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: TextStyle(fontSize: 11, height: 1.35, color: plain, fontFamily: 'Pretendard'),
        children: [
          TextSpan(
            text: cell.name,
            style: TextStyle(color: nameColor, fontFamily: 'Pretendard-Bold'),
          ),
          TextSpan(text: cell.particle),
          if (cell.amount != null) ...[
            const TextSpan(text: ' '),
            TextSpan(
              text: cell.amount,
              style: TextStyle(color: amountColor, fontFamily: 'Pretendard-Bold'),
            ),
          ],
          TextSpan(text: cell.tail),
        ],
      ),
    );
  }

  /// 수량('2번')과 서술부 공통 색.
  static const Color _amountColor = Color(0xFF464646);
}

/// 보상 칸 하나에 필요한 값. 뱃지든 활동 요약이든 화면에는 같은 모양으로 그린다.
class _RewardCell {
  /// 뱃지 PNG. 없으면 [icon] 을 쓴다.
  final String? assetPath;
  final IconData? icon;
  final Color? iconColor;

  final String name;
  final Color nameColor;

  /// 이름 뒤 조사 ('을' / '이' / ' 능력이').
  final String particle;

  /// 강조되는 수량 ('2번' / '2개'). 없으면 통째로 뺀다.
  final String? amount;

  final String tail;
  final bool earned;

  const _RewardCell({
    this.assetPath,
    this.icon,
    this.iconColor,
    required this.name,
    required this.nameColor,
    required this.particle,
    this.amount,
    required this.tail,
    required this.earned,
  });
}
