import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/bookstore/main/main_widgets/books_center.dart';
import 'package:flutter_application/screens/bookstore/main/main_widgets/books_payment.dart';
import 'package:flutter_application/screens/bookstore/main/main_widgets/books_class_info.dart';
import 'package:flutter_application/screens/bookstore/main/main_widgets/books_main_btn.dart';
import 'package:flutter_application/screens/bookstore/main/main_widgets/books_recent_list.dart';
import 'package:flutter_application/screens/mypage/my_page_screen.dart';
import 'package:get/get.dart';

class BookstoreMain extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final UserDataController userData = Get.find<UserDataController>();

  BookstoreMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Image.asset(
            'assets/images/book_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        leadingWidth: 130,
        actions: [
          GestureDetector(
            onTap: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Image.asset(
                'assets/images/icon/menu.png',
                scale: 2.5,
              ),
            ),
          )
        ],
      ),
      endDrawer: MyPageScreen(),
      body: Column(
        children: [
          BooksClassInfo(),
          BooksRecentList(),
          userData.userData.isBookstoreOnly ? BooksPayment() : BooksCenter(),
          Spacer(flex: 5),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}
