import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/dashed_divider.dart';
import 'package:flutter_application/widgets/imagebox_decoration.dart';
import 'package:get/get.dart';

class SchoolWeeklyResult extends StatelessWidget {
  final int week;
  final bool isValidData;
  final List<Widget> children;
  final bool isVisible;

  const SchoolWeeklyResult({
    super.key,
    required this.week,
    required this.isValidData,
    required this.children,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isValidData) return const SizedBox();

    return Stack(
      children: [
        Row(
          children: [
            // 주차
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  "$week주차",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(Get.context!).colorScheme.secondary,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                margin: const EdgeInsets.all(10),
                child: Visibility(
                  visible: isVisible,
                  replacement: Image.asset(
                    'assets/images/book/book_empty.png',
                    width: 50,
                    height: 50,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                ),
              ),
            ),
          ],
        ),
        // 수직 구분선
        Positioned(
          top: 0,
          bottom: 0,
          left: MediaQuery.of(Get.context!).size.width / 5,
          child: const DashedVerticalDivider(),
        ),
        if (week != 1) const DashedHorizontalDivider()
      ],
    );
  }
}

Widget titleImage(img) {
  return Container(
    height: 80,
    width: 80,
    decoration: imageBoxDecoration('assets/images/book/$img', BoxFit.contain),
  );
}

Widget readingImage(img) {
  return Padding(
    padding: const EdgeInsets.all(25.0),
    child: Container(
      height: 30,
      decoration:
          imageBoxDecoration('assets/images/book/$img', BoxFit.fitHeight),
    ),
  );
}

Widget subTitleImage(img, title, color) {
  return Row(
    children: [
      Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.all(5),
        decoration:
            imageBoxDecoration("assets/images/book/$img", BoxFit.contain),
      ),
      Text(
        title,
        style: TextStyle(color: color, fontFamily: "NotoSansKR-SemiBold"),
      )
    ],
  );
}
