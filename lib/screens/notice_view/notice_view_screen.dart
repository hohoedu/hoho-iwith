import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:logger/logger.dart';

class NoticeViewScreen extends StatelessWidget {
  const NoticeViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: '5월 19일 학부모님 간담회 안내'),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFF1E6F8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Text(
                      '우리 아이를 위한 학부모 간담회에\n참여해 주세요!',
                      style: TextStyle(
                        color: Color(0xFF383636),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Image.asset(
                        'assets/images/book.png',
                        scale: 2,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Text(
            '안녕하십니까? 호호서당입니다.\n'
            '어느덧 2학기가 마무리 되어가고 있는 시기,\n'
            '학부모님들꼐서도 바쁘게\n'
            '새 학년, 새학기 시간표를\n'
            '준비하고 계실 거란 생각이 듭니다.\n'
            '\n'
            '특히 이제 막 언어에 관심을 가지기 시작하는 예비 6~7세\n'
            '또 내년에 초등학교에 입학하는 예비 초1\n'
            '고학년 학습을 준비해야 하는 예비 초2\n'
            '학부모님들께서 우리아이를 위해\n'
            '어떤 것을 준비해야 할지 고민이 많으실 것 같습니다.\n'
            '\n'
            '호호스쿨에서 이런 고민 해결을 위해\n'
            '우리 아이를 위한 간담회를 열고자 하오니\n'
            '많은 참석을 부탁드립니다.\n'
            '\n'
            '설명회 참석자를 대상으로 시간표를 우선 접수합니다.\n'
            '아래의 링크를 눌러 일정을 확인하시고\n'
            '참석여부를 알려주세요.',
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Logger().d('클릭됨');
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                    color: Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '상세보기',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
