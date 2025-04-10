import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_icons/lottiefiles.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/notifications/request_noti.dart';
import 'package:flutter_application/services/login/get_is_paymentnotice_exist_.dart';
import 'package:flutter_application/style.dart';
import 'package:flutter_application/utils/load_noti_list_info.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

///////////////
// 알림 설정 //
//////////////

// 알림 토글 버튼 컨트롤러
class SwitchButtonController extends GetxController {
  final isPaymentNoticeExistController = Get.put(IsPaymentNoticeExistController());
  late List<String> buttonNameList;
  late RxList<bool> buttonCheckedList;

  @override
  void onInit() {
    super.onInit();
    final isPaymentNoticeExist = isPaymentNoticeExistController.isPaymentNoticeExist.value;
    buttonNameList = isPaymentNoticeExist ? buttonNameList1 : buttonNameList2;
    buttonCheckedList = List.filled(buttonNameList.length, true).obs;
  }

  // 알림 정보를 기기의 로컬저장소에 저장
  Future<void> storeButtonCheckedInfo(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('buttonChecked$index', buttonCheckedList[index]);
  }

  int get buttonCount => buttonNameList.length;
}


class SettingNotification extends StatefulWidget {
  const SettingNotification({super.key});

  @override
  State<SettingNotification> createState() => _SettingNotificationState();
}

class _SettingNotificationState extends State<SettingNotification> with TickerProviderStateMixin {
  // 컨트롤러
  late AnimationController bellController;        // 알림 아이콘
  final switchButtonController = Get.put(SwitchButtonController());

  // 전체 알림 스위치
  late bool _isNotiChecked;

  // 알림 권한 여부를 체크
  Future<void> checkNotificationPermission() async {
    _isNotiChecked = await requestNotification();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadButtonCheckedInfo();
    _isNotiChecked = false;
    bellController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    checkNotificationPermission();
  }

  @override
  void dispose() {
    bellController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tileColor = colorScheme.surface;

    return Scaffold(
      backgroundColor: colorScheme.onSecondary,
      // 앱 바
      appBar: customAppBar("알림"),
      body: Column(
        children: [
          // 상단 알림 내용
          Container(
            height: 80,
            color: CommonColors.backgroundYellow,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 알림 아이콘
                IconButton(
                  onPressed: () {},
                  icon: Lottie.asset(
                    LottieFiles.$63788_bell_icon_notification,
                    controller: bellController,
                    height: 50,
                  ),
                ),
                // 알림 설명
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isNotiChecked
                        ? "알림을 받고 있어요."
                        : "알림을 받고 있지 않아요.",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      _isNotiChecked
                        ? "방해금지모드나 무음모드에서는 울리지 않아요."
                        : "개별 알림을 받으려면 알림을 켜주세요!",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                )
              ],
            ),
          ),
          // 전체 알림 권한
          ListTile(
            tileColor: tileColor,
            title: const Text("알림"),
            trailing: CupertinoSwitch(
              activeColor: colorScheme.onSecondaryContainer,
              trackColor: colorScheme.secondaryContainer,
              value: _isNotiChecked,
              onChanged: (value) {
                openAppSettings(); // 앱 알림설정으로 이동
              },
            ),
          ),
          // 개별 알림(알림  리스트)
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: switchButtonController.buttonCount,
              itemBuilder: (c, i) {
                return Column(
                  children: [
                    // 각 개별 알림
                    ListTile(
                      tileColor: tileColor,
                      title: Text(switchButtonController.buttonNameList[i]),
                      // 스위치 버튼
                      trailing: Obx(() => CupertinoSwitch(
                        activeColor: colorScheme.onSecondaryContainer,
                        trackColor: colorScheme.secondaryContainer,
                        value: switchButtonController.buttonCheckedList[i],
                        onChanged: _isNotiChecked     // 전체 알림 권한이 true -> 개별 알림 가능
                          ? (value) {
                            setState(() {
                              switchButtonController.buttonCheckedList[i] = value;
                              switchButtonController.storeButtonCheckedInfo(i);  // 알림버튼 상태를 기기에 저장
                            });
                          }
                          : null      // 전체 알림 권한이 false -> 개별 알림 불가능
                      ),),
                    ),
                    // 구분선
                    const Divider(height: 1),
                  ],
                );
              },
            ))
        ],
      ));
  }
}