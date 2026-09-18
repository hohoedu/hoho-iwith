import 'package:flutter/material.dart';

/// 시스템 1회 체험권 카드 (등록 전 체험용).
class PaymentTrialCard extends StatelessWidget {
  final String title;
  final String price;
  final String description;
  final VoidCallback? onPurchase;

  const PaymentTrialCard({
    super.key,
    this.title = '시스템 1회 체험권',
    this.price = '10,000',
    this.description = '등록 전 체험 시에 사용 가능해요!',
    this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                        children: [
                          TextSpan(text: '$title\n'),
                          TextSpan(
                            text: price,
                            style: TextStyle(
                              color: Color(0xFF8362C4),
                            ),
                          ),
                          TextSpan(
                            text: '원',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Color(0xFF8362C4),
                            ),
                          ),
                        ],
                        style: TextStyle(
                          color: Color(0xFF363636),
                          fontSize: 18.0,
                          fontFamily: 'Pretendard-Bold',
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(description),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onPurchase,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFFB6B6B6),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
                    child: Text(
                      '구매하기',
                      style: TextStyle(color: Color(0xFFB6B6B6), fontFamily: 'Pretendard-Bold'),
                    ),
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
