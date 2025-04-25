import 'package:get/get.dart';

class NoticeListData {
  final String title;
  final String subTitle;
  final String subIcon;
  final String date;
  final String index;

  NoticeListData({
    required this.title,
    required this.subTitle,
    required this.subIcon,
    required this.date,
    required this.index,
  });

  NoticeListData.fromJson(Map<String, dynamic> json)
      : title = json['title'] ?? '',
        subTitle = json['subtitle'] ?? '',
        subIcon = json['subicon'] ?? '',
        date = json['sdate'] ?? '',
        index = json['idx'] ?? '';
}

class NoticeListDataController extends GetxController {
  List<NoticeListData> _noticeListDataList = <NoticeListData>[];

  void setNoticeListDataList(List<NoticeListData> noticeListDataList) {
    _noticeListDataList = List.from(noticeListDataList);
    update();
  }

  List<NoticeListData> get noticeListDataList => _noticeListDataList;
}
