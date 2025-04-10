import 'package:flutter/material.dart';
import 'package:flutter_application/screens/mypage/mypage1.dart';
import 'package:flutter_application/screens/mypage/mypage2.dart';
import 'package:flutter_application/screens/mypage/mypage3.dart';
import 'package:flutter_application/widgets/app_bar.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("마이페이지"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 상단 내용(노란 박스)
            mypage1(),
            // 중간 내용(리스트 타일)
            mypage2(),
            // 하단 내용(센터 문의, 로그아웃)
            mypage3()
          ],
        ),
      ),
    );
  }
}