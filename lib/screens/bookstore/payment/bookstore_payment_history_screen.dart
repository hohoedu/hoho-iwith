import 'package:flutter/material.dart';
import 'package:flutter_application/models/payment/pass_payment_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/bookstore/payment/bookstore_payment_widgets/payment_history_list.dart';
import 'package:flutter_application/services/bookstore/bookstore_payment_service.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:get/get.dart';

/// 이용권 결제 내역 — 드로어 메뉴에서 연다(2026-10-22).
///
/// 책방만 이용하는 학생은 "학원비 납부 내역"(서당 청구) 대신 이 화면을 본다. 이용권 결제 화면의
/// "이용권 관리"는 남은 이용권만 보여주므로(환불·소진 건은 빠짐) 결제·환불 기록은 여기서 확인한다.
class BookstorePaymentHistoryScreen extends StatefulWidget {
  const BookstorePaymentHistoryScreen({super.key});

  @override
  State<BookstorePaymentHistoryScreen> createState() => _BookstorePaymentHistoryScreenState();
}

class _BookstorePaymentHistoryScreenState extends State<BookstorePaymentHistoryScreen> {
  late final Future<List<PassPaymentHistory>> _histories =
      passHistoryService(Get.find<UserDataController>().userData.stuId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEFF7),
      appBar: const MainAppBar(title: '이용권 결제 내역'),
      body: FutureBuilder<List<PassPaymentHistory>>(
        future: _histories,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            children: [PaymentHistoryList(histories: snapshot.data ?? const [])],
          );
        },
      ),
    );
  }
}
