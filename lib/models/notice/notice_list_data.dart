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
        date = _formatDate(json['sdate']) ?? '',
        index = json['idx'] ?? '';

  static String _formatDate(String rawDate) {
    try {
      String onlyDate = rawDate.split(' ')[0];
      DateTime parsedDate = DateTime.parse(onlyDate);
      return "${parsedDate.year.toString().padLeft(4, '0')}.${parsedDate.month.toString().padLeft(2, '0')}.${parsedDate.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return '';
    }
  }
}

class NoticeListDataController extends GetxController {
  final RxList<NoticeListData> noticeListDataList = <NoticeListData>[].obs;

  void setNoticeListDataList(List<NoticeListData> newList) {
    noticeListDataList.value = newList;
  }
}
