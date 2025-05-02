import 'package:flutter/material.dart';
import 'package:flutter_application/_core/constants.dart';
import 'package:flutter_application/models/notice/notice_list_data.dart';
import 'package:flutter_application/screens/notice_view/notice_view_screen.dart';
import 'package:flutter_application/services/notice/notice_view_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class HomeNoticeArea extends StatelessWidget {
  final noticeList = Get.put(NoticeListDataController());

  HomeNoticeArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () async {
            await noticeViewService(noticeList.noticeListDataList[0].index);
            Get.to(() => NoticeViewScreen());
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.black26),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        '${noticeList.noticeListDataList[0].title}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(flex: 1, child: Image.asset('assets/images/notice_icon/${noticeIcon['1']}')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
