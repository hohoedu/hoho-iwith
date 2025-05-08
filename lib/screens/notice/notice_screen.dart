import 'package:flutter/material.dart';
import 'package:flutter_application/_core/constants.dart';
import 'package:flutter_application/models/notice/notice_list_data.dart';
import 'package:flutter_application/screens/notice_view/notice_view_screen.dart';
import 'package:flutter_application/services/notice/notice_view_service.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:get/get.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  final notice = Get.find<NoticeListDataController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: '공지사항'),
      body: ListView(
        children: List.generate(
          notice.noticeListDataList.length,
          (index) {
            final items = notice.noticeListDataList;
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: GestureDetector(
                  onTap: () async {
                    await noticeViewService(items[index].index);
                    Get.to(() => NoticeViewScreen());
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 115,
                        decoration: BoxDecoration(
                            color: noticeColor[notice.noticeListDataList[index].subIcon],
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                items[index].title,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Image.asset(
                                'assets/images/notice_icon/${noticeIcon[items[index].subIcon]}',
                                scale: 3,
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          items[index].subTitle,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        items[index].date,
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
