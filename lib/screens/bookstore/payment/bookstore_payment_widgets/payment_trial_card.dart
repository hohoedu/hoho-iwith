import 'package:flutter/material.dart';
import 'package:flutter_application/models/payment/pass_payment_data.dart';

/// 체험권 카드 (1회권 등 소량 상품 — 등록 전 체험용). 서버 상품 목록으로 렌더한다.
class PaymentTrialCard extends StatelessWidget {
  final PassProduct product;
  final String description;

  /// 결제창을 여는 중이면 true — 중복 탭으로 주문이 두 개 생기는 걸 막는다.
  final bool disabled;
  final VoidCallback? onPurchase;

  const PaymentTrialCard({
    super.key,
    required this.product,
    this.description = '등록 전 체험 시에 사용 가능해요!',
    this.disabled = false,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                          children: [
                            TextSpan(text: '${product.productName}\n'),
                            TextSpan(
                              text: product.priceLabel,
                              style: TextStyle(
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
              ),
              GestureDetector(
                onTap: disabled ? null : onPurchase,
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
