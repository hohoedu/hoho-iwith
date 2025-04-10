import 'package:flutter_application/models/class_info_data.dart';
import 'package:flutter_application/models/login_data.dart';
import 'package:flutter_application/widgets/dropdown_button_controller.dart';
import 'package:get/get.dart';

/////////////////////////////////////////
// 로그인 후, 앱 내에서 사용하는 학생 id //
/////////////////////////////////////////
class StudentIdController extends GetxController {
  final LoginDataController loginDataController = Get.put(LoginDataController());                 // 유저의 로그인 데이터 
  final DropdownButtonController dropdownButtonController = Get.put(DropdownButtonController());  // 드롭다운 버튼 
  final ClassInfoDataController classInfoDataController = Get.put(ClassInfoDataController());     // 수업정보 

  RxString id = "".obs;

  getStuId() {
    final nameIdMap = classInfoDataController.getNameId(classInfoDataController.classInfoDataList); // 이름: 아이디
    final dropDownId = dropdownButtonController.currentItem.value;                                  // 드롭다운 선택된 이름
    id.value = nameIdMap[dropDownId] ?? loginDataController.loginData!.id;

    return id.value;
  }
}