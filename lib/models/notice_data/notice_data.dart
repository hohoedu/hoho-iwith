import 'package:get/get.dart';

/////////////////
// 알림장 데이터 //
////////////////

// 데이터 클래스
class NoticeData {
  final String title; // 제목
  final String body; // 내용
  final int noticeNum; // 구분 번호
  final String ymdTime; // 시간
  final String ymd; // 수업 클릭시 필요(사용X)
  final String teacherId; // ..
  final String sTime; // ..
  final String subjectGb; // ..
  final String stuId2; // ..
  final int idx; // 공지 클릭시 필요(사용X)
  final String reportView;

  NoticeData(
      {required this.title,
      required this.body,
      required this.noticeNum,
      required this.ymdTime,
      required this.ymd,
      required this.teacherId,
      required this.sTime,
      required this.subjectGb,
      required this.stuId2,
      required this.idx,
      required this.reportView});

  factory NoticeData.fromJson(Map<String, dynamic> json) {
    return NoticeData(
      title: json['title'] ?? "",
      body: json['body'] ?? "",
      noticeNum: json['noticeNum'] ?? 0,
      ymdTime: json['ymdtime'] ?? "",
      ymd: json['ymd'] ?? "",
      teacherId: json['teaid'] ?? "",
      sTime: json['stime'] ?? "",
      subjectGb: json['sgb'] ?? "",
      stuId2: json['stuid2'] ?? "",
      idx: json['idx'] ?? 0,
      reportView: json['report_view'] ?? 0,
    );
  }
}

// 데이터 컨트롤러
class NoticeDataController extends GetxController {
  List<NoticeData>? _noticeDataList;

  void setNoticeDataList(List<NoticeData> noticeDataList) {
    _noticeDataList = noticeDataList;
    update();
  }

  List<NoticeData>? get noticeDataList => _noticeDataList;
}
