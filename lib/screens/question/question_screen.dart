import 'package:flutter/material.dart';
import 'package:flutter_application/models/question_data.dart';
import 'package:flutter_application/services/question/question_service.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:get/get.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int selectedIndex = 0;
  bool isExpanded = false;
  final controller = Get.put(FAQToggleController());
  final questionData = Get.find<QuestionDataController>().questionDataList;

  @override
  void initState() {
    super.initState();
    controller.initExpandList(questionData.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: '자주 묻는 질문'),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Table(
                    border: TableBorder(
                      horizontalInside: BorderSide(color: Colors.black12),
                      verticalInside: BorderSide(color: Colors.black12),
                      top: BorderSide.none,
                      bottom: BorderSide.none,
                      left: BorderSide.none,
                      right: BorderSide.none,
                    ),
                    children: [
                      TableRow(children: [
                        _buildCell(context, '전체', 0),
                        _buildCell(context, '수업 및 출석', 1),
                        _buildCell(context, '리포트', 2),
                      ]),
                      TableRow(children: [
                        _buildCell(context, '납부 관련', 3),
                        _buildCell(context, '알림 설정', 4),
                        _buildCell(context, '계정 문의', 5),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: Obx(
              () => ListView.builder(
                itemCount: questionData.length,
                itemBuilder: (context, index) {
                  final isExpanded = controller.isExpandedList[index];
                  return Column(
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: ListTile(
                          title: Text(
                            questionData[index].question,
                            style: TextStyle(
                              color: isExpanded ? const Color(0xFF03B3AD) : const Color(0xFF363636),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Icon(
                            isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                          ),
                          onTap: () {
                            setState(() {
                              controller.toggleExpand(index);
                            });
                          },
                        ),
                      ),
                      if (isExpanded)
                        Container(
                          width: double.infinity,
                          color: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                          child: Text(questionData[index].answer),
                        ),
                    ],
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCell(BuildContext context, String text, int index) {
    return GestureDetector(
      onTap: () async {
        controller.closeAll();
        setState(() {
          selectedIndex = index;
        });
        await questionService(selectedIndex);
      },
      child: Container(
        decoration: BoxDecoration(color: selectedIndex == index ? Color(0xFF76D9D7) : Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            text,
            style: TextStyle(fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.w100),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class FAQToggleController extends GetxController {
  RxList<bool> isExpandedList = <bool>[].obs;

  void initExpandList(int length) {
    isExpandedList.value = List.generate(length, (_) => false);
  }

  void toggleExpand(int index) {
    isExpandedList[index] = !isExpandedList[index];
    isExpandedList.refresh();
  }

  void closeAll() {
    isExpandedList.value = List.generate(isExpandedList.length, (_) => false);
  }
}
