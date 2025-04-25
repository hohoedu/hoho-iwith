import 'package:get/get.dart';


class NoticeViewData {
  final String title;
  final String subTitle;
  final String subIcon;
  final String date;
  final String imagePath;
  final String linkUrl;
  final String note;
  final String index;

  NoticeViewData({
    required this.title,
    required this.subTitle,
    required this.subIcon,
    required this.date,
    required this.imagePath,
    required this.linkUrl,
    required this.note,
    required this.index,
  });

  NoticeViewData.fromJson(Map<String, dynamic> json)
      : title = json['title'] ?? '',
        subTitle = json['subtitle'] ?? '',
        subIcon = json['subicon'] ?? '',
        date = json['sdate'] ?? '',
        imagePath = json['imgpath'] ?? '',
        linkUrl = json['linkurl'] ?? '',
        note = json['note'] ?? '',
        index = json['idx'] ?? '';
}


class NoticeViewDataController extends GetxController {
  List<NoticeViewData> _noticeViewDataList = <NoticeViewData>[];

  void setNoticeViewDataList(List<NoticeViewData> noticeViewDataList) {
    _noticeViewDataList = List.from(noticeViewDataList);
    update();
  }


  List<NoticeViewData> get noticeViewDataList => _noticeViewDataList;
}
