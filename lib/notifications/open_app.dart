

//////////////////////
// 알림으로 앱 열기 //
////////////////////
//TODO: 미구현되어 있음

// Future<void> openAppByNoti(RemoteMessage message) async {
//   final curretIndex = message.data['noticeNim'];
//
//   Widget page;
//   // 알림 데이터로 페이지를 결정
//   switch (message.data['noticeNum']) {
//     case 0:
//       // await getOfficialNoticeData(curretIndex);
//       page = NoticeDetailScreen(index: curretIndex, noticeNum: curretIndex);
//       break;
//     case 1:
//       // await getClassNoticeData(curretIndex);
//       page = NoticeDetailScreen(index: curretIndex, noticeNum: curretIndex);
//       break;
//     case 2:
//       page = AttendanceScreen();
//       break;
//     case 3:
//       page = BookScreen();
//       break;
//     // case 4:
//     //   page = PaymentDropdownScreen();
//     //   break;
//     default:
//       page = const HomeScreen();
//       return;
//   }
//   Get.to(page, transition: transitionType, duration: transitionDuration);
// }
