import 'package:flutter/material.dart';
import 'package:flutter_application/screens/notice_view/notice_view_screen.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:get/get.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> items = [
      {
        'title': '5월 19일 학부모님 간단회 안내',
        'date': '2025.04.08',
        'content': '우리 아이를 위한\n학부모 간담회에 참여해\n주세요',
        'color': '0xFFF1E6F8',
      },
      {
        'title': '4월 7일 호호데이 이벤트 안내',
        'date': '2025.03.15',
        'content': '호호데이 참석하고\n선물 받아가자!',
        'color': '0xFFFEF7E3',
      },
      {
        'title': '1~2월 겨울방학 특강 안내',
        'date': '2024.12.28',
        'content': '예비초, 초1~3을 위한\n겨울방학 특강 안내',
        'color': '0xFFD7F4E7',
      }
    ];

    return Scaffold(
      appBar: MainAppBar(title: '공지사항'),
      body: ListView(
        children: List.generate(
          3,
          (index) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => NoticeViewScreen());
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 115,
                        decoration: BoxDecoration(
                            color: Color(
                              int.parse(items[index]['color']!),
                            ),
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                items[index]['content']!,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Image.asset(
                                'assets/images/attendance.png',
                                scale: 3,
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          items[index]['title']!,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        items[index]['date']!,
                        style: TextStyle(
                          color: Color(0xFF939393),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
