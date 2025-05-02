import 'package:flutter/material.dart';
import 'package:flutter_application/models/payment/payment_data.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/dashed_divider.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class PaymentScreen extends StatelessWidget {
  final paymentData = Get.find<PaymentDataController>();

  PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupedList = paymentData.getGroupedPayments();
    return Scaffold(
      appBar: MainAppBar(title: '납부내역'),
      body: ListView(
        children: List.generate(
          groupedList.length,
          (index) {
            final payment = paymentData.paymentDataList[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xFFEDF1F5),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        '${groupedList[index].year}년 ${groupedList[index].month}월 ${groupedList[index].category} '
                        '납부 내역',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFFFFFFFF),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [Text('결제일'), Text(groupedList[index].inDate)],
                                ),
                                DashedHorizontalDivider(
                                  height: 0.5,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Color(0xFFEDF1F5),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                        child: Text(
                                          '수강과목',
                                          style: TextStyle(color: Color(0xFFA2ABB4), fontSize: 12.0),
                                        ),
                                      )),
                                ),
                                Visibility(
                                  visible: groupedList[index].sMoney != null,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('한스쿨 i', style: TextStyle(fontSize: 15.0)),
                                      Text('${groupedList[index].sMoney}', style: TextStyle(fontSize: 15.0)),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: groupedList[index].iMoney != null,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('북스쿨 i', style: TextStyle(fontSize: 15.0)),
                                      Text('${groupedList[index].iMoney}', style: TextStyle(fontSize: 15.0)),
                                    ],
                                  ),
                                ),
                                DashedHorizontalDivider(
                                  height: 0.5,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '결제금액',
                                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      groupedList[index].totalMoney.isNotEmpty
                                          ? '${groupedList[index].totalMoney}원'
                                          : '',
                                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ],
                            ),
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
      ),
    );
  }
}
