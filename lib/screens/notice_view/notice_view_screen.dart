import 'package:flutter/material.dart';
import 'package:flutter_application/_core/constants.dart';
import 'package:flutter_application/models/notice/notice_view_data.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class NoticeViewScreen extends StatefulWidget {
  const NoticeViewScreen({super.key});

  @override
  State<NoticeViewScreen> createState() => _NoticeViewScreenState();
}

class _NoticeViewScreenState extends State<NoticeViewScreen> {
  final noticeView = Get.find<NoticeViewDataController>().noticeViewDataList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: noticeView[0].title),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: noticeColor[noticeView[0].subIcon],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Text(
                      noticeView[0].subTitle,
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
                        noticeView[0].subIcon.isNotEmpty
                            ? 'assets/images/notice_icon/${noticeIcon[noticeView[0].subIcon]}'
                            : 'assets/images/notice_icon/${noticeIcon['1']}',
                        scale: 2,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              noticeView[0].note,
              textAlign: TextAlign.center,
            ),
          ),
          Visibility(
            visible: noticeView[0].imagePath.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(noticeView[0].imagePath)),
            ),
          ),
          Visibility(
            visible: noticeView[0].linkUrl.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    launchUrl(Uri.parse(noticeView[0].linkUrl));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          '상세보기',
                          style: TextStyle(color: Colors.white),
                        ),
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
