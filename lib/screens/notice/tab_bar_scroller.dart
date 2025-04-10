import 'package:flutter/material.dart';
import 'package:get/get.dart';

////////////////////////
// TabBar 스크롤 이동 //
///////////////////////

void scrollToIndex(int index, scrollController, tabsLength) {
  final screenWidth = MediaQuery.of(Get.context!).size.width;        // 현재 기기의 화면넓이
  const itemWidth = 80 + 10;                                         // tab width + margin
  final maxScroll = (tabsLength - 1) * itemWidth - screenWidth + itemWidth;   // 최대 스크롤 위치
  
  // tab 스크롤 위치 계산
  double targetScroll;      
  if (index == 0) {
    targetScroll = 0;
  } else if (index == tabsLength - 1) {
    targetScroll = maxScroll.toDouble();
  } else {
    targetScroll = ((index * itemWidth) - (screenWidth / 2) + (itemWidth / 2));
  }

  // 목표위치가 해당 범위 내에 있도록 보장
  targetScroll = targetScroll.clamp(0, maxScroll).toDouble(); 

  // 목표위치로 스크롤 이동
  scrollController.animateTo(
    targetScroll,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );
}