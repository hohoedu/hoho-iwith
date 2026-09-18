import 'package:flutter/material.dart';
import 'package:flutter_application/screens/bookstore/payment/bookstore_payment_widgets/bookstore_payment_tab.dart';
import 'package:flutter_application/screens/bookstore/payment/bookstore_payment_widgets/payment_intro_header.dart';
import 'package:flutter_application/screens/bookstore/payment/bookstore_payment_widgets/payment_notice_card.dart';
import 'package:flutter_application/screens/bookstore/payment/bookstore_payment_widgets/payment_pass_card.dart';
import 'package:flutter_application/screens/bookstore/payment/bookstore_payment_widgets/payment_trial_card.dart';
import 'package:flutter_application/widgets/app_bar.dart';

class BookstorePaymentScreen extends StatefulWidget {
  const BookstorePaymentScreen({super.key});

  @override
  State<BookstorePaymentScreen> createState() => _BookstorePaymentScreenState();
}

class _BookstorePaymentScreenState extends State<BookstorePaymentScreen> {
  static const List<String> _tabs = ['이용권 구매', '이용권 관리'];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFEFF7),
      appBar: MainAppBar(title: '이용권 결제'),
      body: Column(
        children: [
          BookstorePaymentTab(
            tabs: _tabs,
            selectedIndex: selectedIndex,
            onTabSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: ListView(
              children: [
                PaymentIntroHeader(),
                PaymentPassCard(
                  onPurchase: () {},
                ),
                PaymentTrialCard(
                  onPurchase: () {},
                ),
                PaymentNoticeCard(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
