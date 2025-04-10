import 'package:flutter_application/models/class_info_data.dart';
import 'package:get/get.dart';

///////////////////////////
// 드롭다운 버튼 컨트롤러 //
//////////////////////////

class DropdownButtonController extends GetxController {
  final ClassInfoDataController classInfoDataController = Get.put(ClassInfoDataController());

  Rx<List<String>> nameList = Rx<List<String>>([]); // 드롭다운 목록의 이름 리스트
  Rx<String?> currentItem = Rx<String?>(null);      // 현재 선택된 드롭다운 메뉴

  // 드롭다운 목록에서 다른 버튼을 선택했을 때
  void changeDropDownMenu(int? itemIndex) {
    if (itemIndex != null && itemIndex < nameList.value.length) {
      currentItem.value = nameList.value[itemIndex];
    }
  }

  // classInfoDataController.nameList를 기반으로 드롭다운 메뉴를 업데이트
  void updateDropDownMenus() {
    final newList = classInfoDataController.snamesList;
    nameList.value = newList;

    // 기존 currentItem이 새로운 리스트의 첫 번째 값으로 설정됨
    currentItem.value = newList.isNotEmpty ? newList[0] : null;
  }
}