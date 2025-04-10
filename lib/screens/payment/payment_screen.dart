import 'package:flutter/material.dart';
import 'package:flutter_application/models/payment_data.dart';
import 'package:flutter_application/screens/payment/payment_cost.dart';
import 'package:flutter_application/screens/payment/payment_info.dart';
import 'package:flutter_application/services/payment/get_payment_data.dart';
import 'package:flutter_application/utils/get_current_date.dart';
import 'package:flutter_application/widgets/dropdown_button_controller.dart';
import 'package:flutter_application/widgets/dropdown_screen.dart';
import 'package:flutter_application/widgets/theme_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/////////////////////
// 교육비 내역 화면 //
/////////////////////

class PaymentDropdownScreen extends DropDownScreen {
  PaymentDropdownScreen({super.key})
      : super(
          title: "교육비 납부",
          updateData: _updatePaymentData,
          dropdownChildScreenBuilder: const PaymentScreen(),
        );

  static Future<void> _updatePaymentData() async {
    await getPaymentData();
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  final themeController = Get.put(ThemeController());
  final paymentDataController = Get.put(PaymentDataController());
  final dropdownButtonController = Get.put(DropdownButtonController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: ListView.builder(
                itemCount: paymentDataController.paymentCnt,
                itemBuilder: ((context, index) {
                  final classDate = paymentFormatYM(
                      paymentDataController.paymentDataList![index].classDate);
                  final classMonth = int.parse(paymentFormatMonth(
                      paymentDataController.paymentDataList![index].classDate));
                  final subjectName =
                      paymentDataController.paymentDataList![index].subjectName;
                  final paymentDate = paymentFormatYMD(paymentDataController
                      .paymentDataList![index].paymentDate);
                  final cardAmount = NumberFormat('#,###').format(
                      paymentDataController.paymentDataList![index].cardAmount);
                  final transferAmount = NumberFormat('#,###').format(
                      paymentDataController
                          .paymentDataList![index].transferAmount);
                  final cashAmount = NumberFormat('#,###').format(
                      paymentDataController.paymentDataList![index].cashAmount);
                  final paymentName =
                      paymentDataController.paymentDataList![index].paymentName;
                  final paymentMethod = paymentDataController
                      .paymentDataList![index].paymentMethod;

                  // 결제여부
                  final isPaid = paymentDate == "-" ? false : true;

                  // 미납여부 확인
                  final isNonePaid =
                      classMonth < getCurrentMonth() ? false : true;

                  // 실제 결제수단
                  final validPaymentMethod = setValidPaymentMethod(
                      paymentDataController.paymentDataList![index]);

                  // 현금영수증(현금 결제 여부)
                  final bool isValidCashRecipts = setValidPaymentMethod(
                          paymentDataController.paymentDataList![index])
                      .contains("현금결제");
                  final cashReceiptsDate = paymentFormatYMD(
                      paymentDataController
                          .paymentDataList![index].cashReceiptsDate);

                  final isVisibleMethod = paymentMethod == "Y";

                  final String totalAmount;
                  if (cardAmount != '0') {
                    totalAmount = cardAmount;
                  } else if (transferAmount != '0') {
                    totalAmount = transferAmount;
                  } else if (cashAmount != '0') {
                    totalAmount = cashAmount;
                  } else {
                    totalAmount = '0';
                  }

                  // 결제 내용
                  return Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15),
                    decoration: BoxDecoration(
                        color: themeController.isLightTheme.value
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xff3c3c3c),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: themeController.isLightTheme.value
                                ? const Color(0xFFededed)
                                : const Color(0xff2e2e2e),
                            offset: const Offset(10, 10),
                            blurRadius: 22.0,
                          ),
                          BoxShadow(
                            color: themeController.isLightTheme.value
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xff292929),
                            offset: const Offset(-10, -10),
                            blurRadius: 22.0,
                          ),
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 날짜
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  classDate,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  paymentName == "T" ? ' (교육비)' : ' (교재비)',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                            isPaid
                                ? Text(
                                    "결제 완료",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "NotoSansKR-SemiBold",
                                        color: Colors.blueAccent),
                                  )
                                : isNonePaid
                                    ? Text(
                                        "결제 대기 \u{1F6D2}",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: "NotoSansKR-SemiBold",
                                            color: Theme.of(Get.context!)
                                                .colorScheme
                                                .error),
                                      )
                                    : Text(
                                        "미납",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: "NotoSansKR-SemiBold",
                                            color: Colors.redAccent),
                                      )
                          ],
                        ),
                        const SizedBox(height: 5),
                        // 학생 이름
                        paymentInfo("학생 이름",
                            dropdownButtonController.currentItem.value),
                        // 수업 명
                        paymentInfo("수업명", subjectName),
                        // 구분선
                        horiozontalDivider(),
                        // 결제 수단
                        Visibility(
                            visible: isVisibleMethod,
                            child: Column(
                              children: [
                                // 결제 수단
                                paymentInfo("결제 수단", validPaymentMethod),
                                // 현금영수증 발급일
                                isValidCashRecipts
                                    ? paymentInfo("현금영수증 발급일", cashReceiptsDate)
                                    : const SizedBox(),
                                // 결제 완료일
                                paymentInfo("결제 완료일", paymentDate),
                                // 구분선
                                horiozontalDivider()
                              ],
                            )),
                        // 결제 금액
                        paymentCost(totalAmount.toString(), isPaid),
                      ],
                    ),
                  );
                })))
      ],
    );
  }
}

// 구분선
Widget horiozontalDivider() {
  return const Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Divider(
      height: 3,
    ),
  );
}

// 월 포맷팅
String paymentFormatMonth(String date) {
  final month = date.substring(5, 7);
  String formattedDate = month;
  return formattedDate;
}

// 연월 포맷팅
String paymentFormatYM(String date) {
  final year = date.substring(0, 4);
  final month = date.substring(5, 7);
  String formattedDate = "$year년 $month월";
  return formattedDate;
}

// 연월일 포맷팅
String paymentFormatYMD(String date) {
  if (date == "") {
    return "-";
  }
  DateTime dateTime = DateTime.parse(date);
  String formattedDate = DateFormat('yyyy.MM.dd').format(dateTime);
  return formattedDate;
}

// 실제 결제 수단
String setValidPaymentMethod(data) {
  final paymentMethod = [];

  if (data.cardAmount > 0) {
    paymentMethod.add("카드결제");
  } else if (data.transferAmount > 0) {
    paymentMethod.add("계좌이체");
  } else if (data.cashAmount > 0) {
    paymentMethod.add("현금결제");
  }

  final validPaymentMethod =
      paymentMethod.isEmpty ? "-" : paymentMethod.join(", ");

  return validPaymentMethod;
}
