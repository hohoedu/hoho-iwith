import 'package:flutter/material.dart';
import 'package:flutter_application/models/payment/pass_payment_data.dart';

/// 판매 중인 이용권 상품 목록.
class PassProductList extends StatelessWidget {
  final List<PassProduct> products;

  /// 결제창을 여는 중이면 true — 중복 탭으로 주문이 두 개 생기는 걸 막는다.
  final bool disabled;
  final ValueChanged<PassProduct> onTap;

  const PassProductList({
    super.key,
    required this.products,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 12.0, left: 4.0),
            child: Text(
              '이용권 구매',
              style: TextStyle(
                fontFamily: 'Pretendard-Bold',
                fontSize: 18,
                color: Color(0xFF363636),
              ),
            ),
          ),
          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  '구매할 수 있는 이용권이 없어요',
                  style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                ),
              ),
            )
          else
            ...products.map((p) => _productCard(p)),
        ],
      ),
    );
  }

  Widget _productCard(PassProduct product) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    style: const TextStyle(
                      fontFamily: 'Pretendard-Bold',
                      fontSize: 16,
                      color: Color(0xFF363636),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${product.countLabel} · ${product.priceLabel}',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: disabled ? null : () => onTap(product),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: disabled ? const Color(0xFFE0E0E0) : const Color(0xFFF8EBB4),
                ),
                child: Text(
                  '결제',
                  style: TextStyle(
                    fontFamily: 'Pretendard-Bold',
                    fontSize: 15,
                    color: disabled ? const Color(0xFF9E9E9E) : const Color(0xFF6C7176),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
