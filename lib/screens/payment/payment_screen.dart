import 'package:flutter/material.dart';
import 'package:flutter_application/models/payment/payment_data.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/dashed_divider.dart';
import 'package:get/get.dart';

class PaymentScreen extends StatelessWidget {
  final paymentData = Get.find<PaymentDataController>();

  PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupedList = paymentData.getGroupedPayments();
    return Scaffold(
      appBar: MainAppBar(title: '납부내역'),
      body: ListView.builder(
        itemCount: groupedList.length,
        itemBuilder: (context, index) {
          final item = groupedList[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFEDF1F5),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      '${item.year}년 ${item.month}월 ${item.category} 납부 내역',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 결제일
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('결제일'),
                                Text(item.inDate),
                              ],
                            ),
                            const SizedBox(height: 12.0),
                            const DashedHorizontalDivider(height: 0.5),
                            const SizedBox(height: 12.0),

                            // 수강과목 라벨
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: const Color(0xFFEDF1F5),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 2.0,
                                  ),
                                  child: const Text(
                                    '수강과목',
                                    style: TextStyle(
                                      color: Color(0xFFA2ABB4),
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: item.stateColor.bg,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 2.0,
                                  ),
                                  child: Text(
                                    item.state,
                                    style: TextStyle(
                                      color: item.stateColor.text,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 8.0),

                            // 한자 타입 금액
                            if (item.sMoney != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.sClassName ?? '',
                                      style: const TextStyle(fontSize: 15.0),
                                    ),
                                    Text(
                                      '${item.sMoney}원',
                                      style: const TextStyle(fontSize: 15.0),
                                    ),
                                  ],
                                ),
                              ),

                            // 독서 타입 금액
                            if (item.iMoney != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.iClassName ?? '',
                                      style: const TextStyle(fontSize: 15.0),
                                    ),
                                    Text(
                                      '${item.iMoney}원',
                                      style: const TextStyle(fontSize: 15.0),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 8.0),
                            const DashedHorizontalDivider(height: 0.5),
                            const SizedBox(height: 12.0),

                            // 결제금액 합계
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '결제금액',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  item.totalMoney.isNotEmpty ? '${item.totalMoney}원' : '',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
