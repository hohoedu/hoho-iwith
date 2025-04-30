import 'package:get/get.dart';

class ClassResultViewData {
  final String type;
  final String title;
  final String date;
  final String firstContent;
  final String secondContent;
  final String comment;

  ClassResultViewData({
    required this.type,
    required this.title,
    required this.date,
    required this.firstContent,
    required this.secondContent,
    required this.comment,
  });

  ClassResultViewData.fromJson(Map<String, dynamic> json)
      : type = json['gamok'] ?? '',
        title = json['title'] ?? '',
        date = json['dayname'] ?? '',
        firstContent = json['ju_note1'] ?? '',
        secondContent = json['ju_note2'] ?? '',
        comment = json['review'] ?? '';
}

class ClassResultViewDataController extends GetxController {
  final Rx<ClassResultViewData?> _classResult = Rx<ClassResultViewData?>(null);

  void setClassResultViewData(ClassResultViewData classResultView) {
    _classResult.value = classResultView;
    update();
  }

  ClassResultViewData get classResult => _classResult.value!;
}
