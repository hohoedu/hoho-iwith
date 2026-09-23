import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_main_data.dart';
import 'package:flutter_application/models/payment/pass_payment_data.dart';
import 'package:get/get.dart';

/// 남은 이용권 카드. 책방 예약 화면의 보유 이용권 카드와 같은 톤으로 맞춘다.
///
/// 총 횟수/사용기한은 이 화면의 API(잔여 횟수만 내려줌)엔 없어서, 책방 메인 화면 진입 시
/// 이미 로드돼 있는 BookstoreMainDataController(passTotal/passValidUntil)를 그대로 쓴다.
class PaymentRemainCard extends StatelessWidget {
  final int remain;

  const PaymentRemainCard({super.key, required this.remain});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookstoreMainDataController>(
      init: BookstoreMainDataController(),
      builder: (mainData) => _build(context, mainData.data),
    );
  }

  Widget _build(BuildContext context, BookstoreMainData? main) {
    final passTotal = main?.passTotal;
    final passValidUntilLabel = main?.passValidUntilLabel;
    final productName = _productNameFor(passTotal);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 12.0, bottom: 12.0, left: 4.0),
            child: Text(
              '보유한 호호책방 이용권',
              style: TextStyle(
                fontFamily: 'Pretendard-Bold',
                fontSize: 18,
                color: Color(0xFF363636),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Image.asset('assets/images/icon/ticket.png', width: 64, height: 64),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            productName,
                            style: const TextStyle(
                              fontFamily: 'Pretendard-Bold',
                              fontSize: 18,
                              color: Color(0xFF363636),
                            ),
                          ),
                          if (remain > 0)
                            Container(
                              decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF008D7B))),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                child: Text(
                                  '이용 중',
                                  style: TextStyle(color: Color(0xFF008D7B)),
                                ),
                              ),
                            )
                        ],
                      ),
                      if (remain <= 0)
                        const Text(
                          '보유한 이용권이 없어요',
                          style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                        )
                      else
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: '남은 이용권   ',
                                style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                              ),
                              TextSpan(
                                text: '$remain',
                                style: const TextStyle(
                                  fontFamily: 'Pretendard-Bold',
                                  fontSize: 15,
                                  color: Color(0xFF008D78),
                                ),
                              ),
                              TextSpan(
                                text: ' / ${passTotal ?? '-'}회',
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 13,
                                  color: Color(0xFF363636),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (passValidUntilLabel != null)
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: '사용 기한   ',
                                style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                              ),
                              TextSpan(
                                text: passValidUntilLabel,
                                style: const TextStyle(
                                  fontFamily: 'Pretendard-Bold',
                                  fontSize: 15,
                                  color: Color(0xFF363636),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 이 화면엔 보유 이용권의 실제 상품명을 내려주는 API가 없다. 대신 구매 탭에서 이미
  /// 받아 둔 상품 목록(PassPaymentController.products) 중 총 횟수가 같은 상품을 찾아 쓴다.
  String _productNameFor(int? passTotal) {
    if (passTotal == null) return '호호책방 이용권';
    final products = Get.isRegistered<PassPaymentController>()
        ? Get.find<PassPaymentController>().products
        : <PassProduct>[];
    for (final p in products) {
      if (p.totalCount == passTotal) return p.productName;
    }
    return '시스템 $passTotal회 이용권';
  }
}
