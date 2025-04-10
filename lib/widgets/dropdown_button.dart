import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/dropdown_button_controller.dart';
import 'package:get/get.dart';

///////////////////
// 드롭다운 버튼 //
//////////////////

class DropDownButtonWidget extends GetView<DropdownButtonController> {
  const DropDownButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Obx(
      () => DropdownButton(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        isExpanded: true,
        style: TextStyle(color: textColor, fontSize: 18),
        underline: Container(height: 2, color: Colors.transparent),
        dropdownColor: Theme.of(context).colorScheme.onSecondary,
        // 현재 선택된 드롭다운 항목의 인덱스
        value: controller.nameList.value.indexOf(controller.currentItem.value ?? ''),
        // 드롭다운 항목을 변경(다른 것을 선택)
        onChanged: (int? index) {
          controller.changeDropDownMenu(index);
        },
        items: controller.nameList.value.map<DropdownMenuItem<int>>(
          (String menuName) {
            return DropdownMenuItem<int>(
              value: controller.nameList.value.indexOf(menuName),
              child: Text(menuName),
            );
          },
        ).toList(),
      ),
    );
  }
}