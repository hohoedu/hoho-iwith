import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 결제내용- 결제 정보(금액)
Widget paymentCost(cost, isPaid) {
  final textColor = Theme.of(Get.context!).colorScheme.secondary;
  final pointColor = isPaid
      ? textColor
      : Theme.of(Get.context!).colorScheme.onSecondaryContainer;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text("결제금액",
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
      RichText(
          text: TextSpan(children: [
        TextSpan(
            text: cost,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: pointColor)),
        TextSpan(
            text: "원",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: textColor))
      ]))
    ],
  );
}
