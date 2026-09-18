import 'package:flutter/material.dart';

/// 시스템 12회 이용권 카드 (메인 상품).
class PaymentPassCard extends StatelessWidget {
  final String title;
  final String price;
  final VoidCallback? onPurchase;

  const PaymentPassCard({
    super.key,
    this.title = '시스템 12회 이용권',
    this.price = '60,000',
    this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: Color(0xFFE84D89),
            ),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '$title\n'),
                          TextSpan(
                            text: price,
                            style: TextStyle(
                              color: Color(0xFF008D78),
                            ),
                          ),
                          TextSpan(
                            text: '원',
                            style: TextStyle(color: Color(0xFF008D78), fontSize: 16.0),
                          )
                        ],
                        style: TextStyle(
                          color: Color(0xFF363636),
                          fontSize: 20.0,
                          fontFamily: 'Pretendard-Bold',
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/book_report/ticket.png',
                      scale: 1.5,
                    )
                  ],
                ),
              ),
              Row(
                spacing: 16.0,
                children: const [
                  Expanded(
                    flex: 1,
                    child: _PassBadge(
                      icon: Icons.hourglass_empty,
                      text: '첫사용일로부터\n3개월동안 사용가능',
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _PassBadge(
                      icon: Icons.watch_later_outlined,
                      text: '원하는 날짜에\n자유 예약 가능',
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: GestureDetector(
                  onTap: onPurchase,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFF008D78),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        '구매하기',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Pretendard-ExtraBold'),
                      ),
                    )),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// 이용권 카드 안의 조건 배지 (사용기한 / 예약).
class _PassBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PassBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Color(0xFFFFEFF7),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          spacing: 8.0,
          children: [
            Icon(
              icon,
              color: Color(0xFFE39BB4),
            ),
            Text(
              text,
              style: TextStyle(fontSize: 12, color: Color(0xFFE39BB4), letterSpacing: -0.5),
            ),
          ],
        ),
      ),
    );
  }
}
