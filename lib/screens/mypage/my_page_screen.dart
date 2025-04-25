import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainDrawer extends StatelessWidget {
  List<String> items = ['공지사항', '학원비 납부 내역', '알림및 설정', '자주 묻는 질문'];

  MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Icon(CupertinoIcons.back),
          ),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: constraints.maxHeight * 0.4,
                          height: constraints.maxHeight * 0.4,
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 26, color: Color(0xFF383636)),
                              children: [
                                TextSpan(text: '김호호', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: ' 학생'),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration:
                                    BoxDecoration(color: Color(0xFFEDF1F5), borderRadius: BorderRadius.circular(5)),
                                child: Center(
                                    child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    'ID',
                                    style: TextStyle(color: Color(0xFFA2ABB4)),
                                  ),
                                )),
                              ),
                              Text(
                                '  123456781',
                                style: TextStyle(color: Color(0xFF838B93)),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              color: Color(0xFFB0E4E3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.arrow_right_arrow_left,
                                    size: 15,
                                    color: Color(0xFF2B8685),
                                  ),
                                  Text('  '),
                                  Text(
                                    '형제 변경',
                                    style: TextStyle(
                                      color: Color(0xFF2B8685),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      items.length,
                      (index) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 50,
                                decoration:
                                    BoxDecoration(color: Color(0xFFEDF1F5), borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                    child: Text(
                                  items[index],
                                  style: TextStyle(color: Color(0xFF656A6E), fontWeight: FontWeight.bold, fontSize: 20),
                                )),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      4,
                      (index) {
                        List<String> images = ['kakao.png', 'naver.png', 'youtube.png', 'hoho.png'];
                        return Image.asset(
                          'assets/images/shortcut_logo/${images[index]}',
                          scale: 10,
                        );
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 1,
                        color: Color(0xFFD6DCE2),
                      ),
                    ),
                    child: Center(
                        child: Text(
                      '로그아웃',
                      style: TextStyle(color: Color(0xFF656A6E), fontWeight: FontWeight.bold, fontSize: 20),
                    )),
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
