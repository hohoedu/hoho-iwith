import 'package:get/get.dart';

class QuestionData {
  final String question;
  final String answer;

  QuestionData({
    required this.question,
    required this.answer,
  });

  QuestionData.fromJson(Map<String, dynamic> json)
      : question = json['question'] ?? '',
        answer = json['answer'] ?? '';
}

class QuestionDataController extends GetxController {
  RxList<QuestionData> questionDataList = <QuestionData>[].obs;

  void setQuestionDataList(List<QuestionData> newList) {
    questionDataList.assignAll(newList);
    update();
  }

  List<QuestionData> get newList => questionDataList;
}
