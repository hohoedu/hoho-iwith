import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/style.dart';
import 'package:get/get.dart';

//////////////////
// 화면전환 효과 //
//////////////////
const transitionDuration = Duration(milliseconds: 500);
const transitionType = Transition.cupertino;

/////////////
// 홈 화면 //
/////////////
const homeMenuList = [
  ['출석체크', 'assets/images/attendance.png'],
  ['교육비 내역', 'assets/images/payment.png'],
  ['알림장', 'assets/images/notice.png'],
  ['월간 레포트', 'assets/images/book.png'],
];

////////////////
// 알림장 화면 //
////////////////

/// 탭
const noticeTabs = ["공지", "수업", "출석", "월말 평가", "결제"];
// 라이트 테마 알림 색상
const lightNoticeColorList = [
  CommonColors.grey3, // 공지
  LightColors.blue, // 수업
  LightColors.green, // 출석
  LightColors.purple, // 월말 평가
  LightColors.orange, // 결제
];
// 다크 테마 알림 색상
const darkNoticeColorList = [
  CommonColors.grey2,
  DarkColors.blue,
  DarkColors.green,
  DarkColors.purple,
  DarkColors.orange,
];
// 알림 이미지
const noticeImageList = [
  'assets/images/notice_official.png', // 공지
  'assets/images/class.png', // 수업
  'assets/images/attendance.png', // 출석
  'assets/images/book.png', // 월말 평가
  'assets/images/payment.png', // 결제
];

////////////////////
// 마이페이지 화면 //
////////////////////

/// 알림 설정 토글
const buttonNameList1 = [
  "공지 알림",
  "수업 알림",
  "출석 알림",
  "독클 알림",
  "결제 알림",
];
const buttonNameList2 = [
  "공지 알림",
  "수업 알림",
  "출석 알림",
  "독클 알림",
];

/// 호호에듀 더보기
const shortcutList = [
  {
    "title": "홈페이지",
    "imgPath": "assets/images/shortcut_logo/hoho.png",
    "url": "https://hohoedu.co.kr",
  },
  {
    "title": "블로그",
    "imgPath": "assets/images/shortcut_logo/naver.png",
    "url": "https://blog.naver.com/st8898ds",
  },
  {
    "title": "유튜브",
    "imgPath": "assets/images/shortcut_logo/youtube.png",
    "url": "https://youtube.com/@tv-ex4in?si=iiHywF2iEXabR0Sk",
  },
  {
    "title": "카톡채널",
    "imgPath": "assets/images/shortcut_logo/kakao.png",
    "url": "https://pf.kakao.com/_xeexhxkK",
  },
];

///////////////
// 출석 화면 //
///////////////
const attendanceStatusList = {
  "출석": {"icon": EvaIcons.checkmarkCircle2, "color": Color(0xff66bb6a)},
  "결석": {"icon": EvaIcons.closeCircle, "color": Color(0xffef5350)},
  "지각": {"icon": EvaIcons.alertCircle, "color": Color(0xffffa726)},
  "보강": {"icon": EvaIcons.plusCircle, "color": Color(0xff42a5f5)},
};
const subjectImageList = {
  "S": 'assets/images/attendance/attendance_han.png', // 서당(한)
  "I": 'assets/images/attendance/attendance_book.png' // 독서(북)
};

///////////////
// 독클 화면 //
///////////////

/// 점수바 색상
const scoreColorList = [
  Color(0xffff44b2),
  Color(0xff5a60d8),
  Color(0xffff7f4b),
  Color(0xff7acf11),
  Color(0xffffa60c),
  Color(0xffab55e5)
];

/// 점수바 이미지
const scoreImageList = [
  'assets/images/book/book_score_area1.png',
  'assets/images/book/book_score_area2.png',
  'assets/images/book/book_score_area3.png',
  'assets/images/book/book_score_area4.png',
  'assets/images/book/book_score_area5.png',
  'assets/images/book/book_score_area6.png',
];

/// 월말 결과 제목
const hanResultTitle = ["한자 습득", "어휘 활용", "의미 이해", "문장 적용"];
const bookResultTitle = ["표현력", "사고력", "추론력", "분석력"];
