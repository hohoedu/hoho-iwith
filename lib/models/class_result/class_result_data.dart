import 'package:get/get.dart';

class ClassResultData {
  final String type;
  final String title;
  final String date;
  final String gbcd;
  final String mgubun;
  final String week;
  final String year;
  final String month;
  final String icon;
  final String content;

  ClassResultData({
    required this.type,
    required this.title,
    required this.date,
    required this.gbcd,
    required this.mgubun,
    required this.week,
    required this.year,
    required this.month,
    required this.icon,
    required this.content,
  });

  ClassResultData.fromJson(Map<String, dynamic> json)
      : type = json['gamok'] ?? '',
        title = json['title'] ?? '',
        date = json['dayname'] ?? '',
        gbcd = json['gbcd'] ?? '',
        mgubun = json['mgubun'],
        week = json['ju'],
        year = json['yyyy'],
        month = json['mm'],
        icon = json['icon'],
        content = json['snote'];
}

class ClassResultDataController extends GetxController {
  RxList<ClassResultData> classResultDataList = <ClassResultData>[].obs;

  void setClassResultDataList(List<ClassResultData> newList) {
    classResultDataList.assignAll(newList);
  }
  // void setClassResultDataList(List<ClassResultData> newList) {
  //   newList.sort((a, b) {
  //     final subjectCompare = a.type.compareTo(b.type);
  //     if (subjectCompare != 0) return subjectCompare;
  //
  //     final yearCompare = int.parse(a.year).compareTo(int.parse(b.year));
  //     if (yearCompare != 0) return yearCompare;
  //
  //     final monthCompare = int.parse(a.month).compareTo(int.parse(b.month));
  //     if (monthCompare != 0) return monthCompare;
  //
  //     return int.parse(a.week).compareTo(int.parse(b.week));
  //   });
  //
  //   classResultDataList.assignAll(newList);
  // }

  RxList<ClassResultData> get newList => classResultDataList;
}

// 정렬 확장

