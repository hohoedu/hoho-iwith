import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_report_data.dart';
import 'package:flutter_application/screens/bookstore/bookcase/bookstore_bookcase_screen.dart';
import 'package:flutter_application/screens/bookstore/main/main_widgets/books_recent_list.dart';
import 'package:flutter_application/screens/bookstore/report/bookstore_report_dummy.dart';
import 'package:flutter_application/screens/bookstore/report/report_widgets/bookstore_report_graph.dart';
import 'package:flutter_application/screens/bookstore/report/report_widgets/report_book_result_card.dart';
import 'package:flutter_application/screens/bookstore/report/report_widgets/report_date_tabs.dart';
import 'package:flutter_application/screens/bookstore/report/report_widgets/report_preference_card.dart';
import 'package:flutter_application/screens/bookstore/report/report_widgets/report_reward_card.dart';
import 'package:flutter_application/screens/bookstore/report/report_widgets/report_summary_card.dart';
import 'package:flutter_application/services/bookstore/bookstore_report_service.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:get/get.dart';

/// 정독 결과 화면
class BookstoreReportScreen extends StatefulWidget {
  const BookstoreReportScreen({super.key});

  @override
  State<BookstoreReportScreen> createState() => _BookstoreReportScreenState();
}

class _BookstoreReportScreenState extends State<BookstoreReportScreen> {
  late final BookstoreReportDataController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(BookstoreReportDataController());
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load({String? recordDate}) async {
    if (useReportDummy) {
      controller.setData(reportDummyData(recordDate));
      return;
    }
    await bookstoreReportService(recordDate: recordDate);
  }

  @override
  void dispose() {
    Get.delete<BookstoreReportDataController>();
    super.dispose();
  }

  Future<void> _selectDate(String date) async {
    if (controller.isLoading) return;
    if (controller.data?.recordDate == date) return;
    // 이미 불러온 일자면 통신도 스피너도 없이 즉시 전환한다.
    if (controller.hasCached(date)) {
      controller.showCached(date);
      return;
    }
    await _load(recordDate: date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F2ED),
      // appBar: const MainAppBar(title: '정독 결과'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Image.asset(
              'assets/images/icon/back.png',
              scale: 2.5,
            ),
          ),
        ),
        title: Text(
          '정독 결과',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              Get.to(() => BookstoreBookcaseScreen());
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(
                CupertinoIcons.book_circle_fill,
              ),
            ),
          )
        ],
      ),
      body: Obx(() {
        final data = controller.data;

        return Column(
          children: [
            ReportDateTabs(
              labels: data?.dateLabels ?? const <String>[],
              selectedIndex: data?.selectedDateIndex ?? -1,
              onSelect: (index) => _selectDate(data!.dates[index]),
            ),
            Expanded(child: _body(data)),
          ],
        );
      }),
    );
  }

  Widget _body(BookstoreReportData? data) {
    if (data == null) {
      if (controller.isFailed) {
        return const Center(
          child: Text('결과를 불러오지 못했어요', style: TextStyle(color: Color(0xFF719183))),
        );
      }
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00B093)));
    }

    if (!data.hasRecord) {
      return const Center(
        child: Text('아직 정독 기록이 없어요', style: TextStyle(color: Color(0xFF719183))),
      );
    }

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            ReportSummaryCard(data: data),
            ReportBookResultCard(
              books: data.books,
              selectedIndex: controller.bookIndex,
              onSelectBook: controller.selectBook,
            ),
            ReportRewardCard(data: data),
            ReportPreferenceCard(data: data),
            BookstoreReportGraph(monthly: data.monthly),
            // GestureDetector(
            //   onTap: () {
            //     Get.to(() => BookstoreBookcaseScreen());
            //   },
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            //     child: Container(
            //       width: double.infinity,
            //       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
            //       child: Padding(
            //         padding: const EdgeInsets.all(16.0),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Text('책장 바로가기'),
            //             Icon(Icons.arrow_forward),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // )
          ],
        ),
        if (controller.isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x66E7F2ED),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF00B093))),
            ),
          ),
      ],
    );
  }
}
