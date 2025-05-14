import 'package:flutter/material.dart';
import 'package:flutter_application/_core/constants.dart';
import 'package:flutter_application/models/notice/notice_list_data.dart';
import 'package:flutter_application/models/notice/notice_list_main_data.dart';
import 'package:flutter_application/screens/notice_view/notice_view_screen.dart';
import 'package:flutter_application/services/notice/notice_view_service.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class HomeNoticeArea extends StatelessWidget {
  final noticeData = Get.find<NoticeListDataController>();

  HomeNoticeArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () async {
            if (noticeData.noticeListDataList.isNotEmpty) {
              await noticeViewService(noticeData.noticeListDataList[0].index);
              Get.to(() => NoticeViewScreen());
            } else {
              failDialog1('안내', '공지사항 데이터가 없습니다.');
            }
          },
          child: Obx(
            () => Container(
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
                          noticeData.noticeListDataList.isNotEmpty
                              ? noticeData.noticeListDataList[0].title
                              : '최근 공지 사항이 없습니다.',
                          style: TextStyle(
                            color: Color(0xFF454545),
                            fontSize: 16,
                            fontFamily: 'NotoSansKR-SemiBold',
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: noticeData.noticeListDataList.isNotEmpty
                          ? Image.asset('assets/images/notice_icon/${noticeIcon['1']}')
                          : SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
