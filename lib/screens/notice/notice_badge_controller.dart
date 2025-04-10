import 'package:flutter_application/constants.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

///////////////////////////////
// 알림장 알림 배지 컨트롤러  //
///////////////////////////////

class NoticeBadgeController extends GetxController {
  // 총 알림 배지
  /// true: 알림이 없거나 모든 알림을 읽음
  /// false: 읽지 않은 알림 존재
  late RxBool isNoticeAllRead;
  // 개별 알림 배지
  /// true: 안읽음
  /// false: 읽음
  late RxList<bool> noticeBadgeList; 
  
  @override
  void onInit() {
    super.onInit();
    noticeBadgeList = List.filled(noticeTabs.length, false).obs;
    isNoticeAllRead = true.obs;

    updateIsNoticeAllRead(); 
    noticeBadgeList.listen((_) {
      updateIsNoticeAllRead();
    });
  }
  
  void updateIsNoticeAllRead() {
    if (noticeBadgeList.every((element) => element == false)) {
      isNoticeAllRead.value = true;
    } else {
      isNoticeAllRead.value = false;
    }
  }
}

// 알림 배지 정보를 기기의 로컬 저장소에 저장
/// 새로운 알림: false => true / 알림 클릭: true => false
Future<void> storeNoticeBadge(int index, value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('noticeBadge$index', value);
}

// 알림 배지 정보를 기기의 로컬 저장소에서 로드
Future<void> loadNoticeBadge() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.reload();

  final noticeBadgeController = Get.put(NoticeBadgeController());

  for (int i=0; i<noticeBadgeController.noticeBadgeList.length; i++) {
    noticeBadgeController.noticeBadgeList[i] = prefs.getBool('noticeBadge$i') ?? false; 
  }
}