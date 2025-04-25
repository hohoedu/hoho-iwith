import 'package:get/get.dart';

class NoticeDetailData {
  final String title;
  final String subTitle;
  final String subIcon;
  final String date;
  final String imagePath;
  final String linkUrl;
  final String note;
  final String index;

  NoticeDetailData({
    required this.title,
    required this.subTitle,
    required this.subIcon,
    required this.date,
    required this.imagePath,
    required this.linkUrl,
    required this.note,
    required this.index,
  });

  NoticeDetailData.fromJson(Map<String, dynamic> json)
      : title = json['title'] ?? '',
        subTitle = json['subtitle'] ?? '',
        subIcon = json['subicon'] ?? '',
        date = json['sdate'] ?? '',
        imagePath = json['imgpath'] ?? '',
        linkUrl = json['linkurl'] ?? '',
        note = json['note'] ?? '',
        index = json['idx'] ?? '';
}

class NoticeDetailDataController extends GetxController {
  List<NoticeDetailData> _noticeViewDataList = <NoticeDetailData>[];

  void setNoticeDetailDataList(List<NoticeDetailData> noticeViewDataList) {
    _noticeViewDataList = List.from(noticeViewDataList);
    update();
  }

  List<NoticeDetailData> get noticeViewDataList => _noticeViewDataList;
}
