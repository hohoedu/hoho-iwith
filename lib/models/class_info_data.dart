import 'package:get/get.dart';
import 'package:logger/logger.dart';

/////////////////////
// 수업정보 데이터 //
/////////////////////

// 데이터 클래스
class ClassInfoData {
  final String stuId; // 학생 아이디
  final String sName; // 학생 이름
  final String gubunName; // 수업 구분(서당, 독서)
  final String bookName; // 교재 이름
  final String bookNumber; // 교재 호수
  final String stime; // 수업 시작 시간
  final String etime; // 수업 종료 시간
  final String dateName; // 요일
  final String startYM; // 최초 수업 연월
  final String lastYM; // 최근 수업

  ClassInfoData({
    required this.stuId,
    required this.sName,
    required this.gubunName,
    required this.bookName,
    required this.bookNumber,
    required this.stime,
    required this.etime,
    required this.dateName,
    required this.startYM,
    required this.lastYM,
  });

  factory ClassInfoData.fromJson(Map<String, dynamic> json) {
    return ClassInfoData(
      stuId: json['Stuid'] ?? "",
      sName: json['Sname'] ?? "",
      gubunName: json['gubunName'] ?? "",
      bookName: json['codeName'] ?? "",
      bookNumber: json['codeName2'] ?? "",
      stime: json['stime'] ?? "",
      etime: json['etime'] ?? "",
      dateName: json['DATENAME'] ?? "",
      startYM: json['sym'] ?? "",
      lastYM: json['lastym'] ?? "",
    );
  }
}

// 데이터 컨트롤러
class ClassInfoDataController extends GetxController {
  List<ClassInfoData>? _classInfoDataList;

  void setClassInfoDataList(List<ClassInfoData> classInfoDataList) {
    _classInfoDataList = classInfoDataList;
    update();
  }

  List<ClassInfoData>? get classInfoDataList => _classInfoDataList;

  // 학생 이름 리스트
  late List<String> snamesList = [];
  void setSnamesList(List<ClassInfoData>? classInfoDataList) {
    if (classInfoDataList != null) {
      snamesList = classInfoDataList
          .map((classInfoData) => classInfoData.sName)
          .toSet()
          .toList();
    }
  }

  // 학생이름: 아이디를 가지는 Map
  Map<String, String> getNameId(List<ClassInfoData>? classInfoDataList) {
    Map<String, String> stuNameIdMap = {};
    if (classInfoDataList == null) {
      return stuNameIdMap;
    }

    for (var data in classInfoDataList) {
      String studentName = data.sName;
      String studentId = data.stuId;

      // 이미 해당 학생 이름의 학생 아이디가 Map에 존재하는지 확인, 없으면 추가
      if (!stuNameIdMap.containsKey(studentName)) {
        stuNameIdMap[studentName] = studentId;
      }
    }
    return stuNameIdMap;
  }

  // 학생 이름:[수업정보]를 가지는 Map
  Map<String, List<List<String>>> getSubjectMap(
      List<ClassInfoData>? classInfoDataList) {
    Map<String, List<List<String>>> subjectMap = {};

    if (classInfoDataList == null) {
      return subjectMap;
    }

    for (var data in classInfoDataList) {
      String studentName = data.sName;
      String subjectName = data.bookName;
      String subjectNumber = data.bookNumber;
      String subjectSTime = data.stime;
      String subjectETime = data.etime;
      String subjectDateName = data.dateName;
      String gubunName = data.gubunName;

      if (!subjectMap.containsKey(studentName)) {
        subjectMap[studentName] = [
          [
            subjectName,
            subjectNumber,
            subjectSTime,
            subjectETime,
            subjectDateName,
            gubunName
          ]
        ];
      } else {
        subjectMap[studentName]!.add([
          subjectName,
          subjectNumber,
          subjectSTime,
          subjectETime,
          subjectDateName,
          gubunName
        ]);
      }
    }
    return subjectMap;
  }

  // 학생 이름:[수업 시작 연월]을 가지는 Map
  Map<String, String> getStartYMMap(List<ClassInfoData>? classInfoDataList) {
    Map<String, String> startYMMap = {};

    if (classInfoDataList == null) {
      return startYMMap;
    }

    for (var data in classInfoDataList) {
      String studentName = data.sName;
      String startYM = data.startYM;

      if (!startYMMap.containsKey(studentName)) {
        startYMMap[studentName] = startYM;
      }
    }
    return startYMMap;
  }

  Map<String, String> getLastYMMap(List<ClassInfoData>? classInfoDataList) {
    Map<String, String> lastYMMap = {};

    if (classInfoDataList == null) {
      return lastYMMap;
    }

    for (var data in classInfoDataList) {
      String studentName = data.sName;
      String lastYM = data.lastYM;

      if (!lastYMMap.containsKey(studentName)) {
        lastYMMap[studentName] = lastYM;
      }
    }
    return lastYMMap;
  }

  // 학생 이름:[수업별 시작 연월]을 가지는 Map
  Map<String, List<List<String>>> getSubjectDate(
      List<ClassInfoData>? classInfoDataList) {
    Map<String, List<List<String>>> subjectDateMap = {};

    if (classInfoDataList == null) {
      return subjectDateMap;
    }

    for (var data in classInfoDataList) {
      String studentName = data.sName;
      String gubunName = data.gubunName;
      String startYM = data.startYM;

      if (!subjectDateMap.containsKey(studentName)) {
        subjectDateMap[studentName] = [
          [gubunName, startYM]
        ];
      } else {
        subjectDateMap[studentName]!.add([gubunName, startYM]);
      }
    }
    return subjectDateMap;
  }
}
