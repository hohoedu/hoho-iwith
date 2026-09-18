import 'package:flutter/material.dart';

/// 화면 상단 안내 문구 — 개구리 이미지 + 이용권 설명.
class PaymentIntroHeader extends StatelessWidget {
  const PaymentIntroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/book_report/frog.png',
            scale: 1.4,
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '호호책방 시스템 이용권으로\n'),
                TextSpan(
                  text: '정독&문해력 문제풀이\n시스템',
                  style: TextStyle(
                    color: Color(0xFFDA3374),
                  ),
                ),
                TextSpan(text: '을 이용할 수 있어요.'),
              ],
              style: TextStyle(
                color: Color(0xFF363636),
                fontSize: 18.0,
                fontFamily: 'Pretendard-ExtraBold',
              ),
            ),
          )
        ],
      ),
    );
  }
}
