import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/bookstore/main/main_widgets/books_center.dart';
import 'package:flutter_application/screens/bookstore/main/main_widgets/books_payment.dart';
import 'package:flutter_application/screens/bookstore/main/main_widgets/books_class_info.dart';
import 'package:flutter_application/screens/bookstore/main/main_widgets/books_recent_list.dart';
import 'package:flutter_application/screens/mypage/my_page_screen.dart';
import 'package:flutter_application/services/bookstore/bookstore_main_service.dart';
import 'package:get/get.dart';

class BookstoreMain extends StatefulWidget {
  BookstoreMain({super.key});

  @override
  State<BookstoreMain> createState() => _BookstoreMainState();
}

/// 앱으로 돌아올 때마다(백그라운드 → 포그라운드) 메인 데이터를 다시 읽는다(2026-10-22).
/// 예전엔 로그인 때 한 번만 읽어서, 날짜가 바뀌거나 그 사이 입실·예약·결제가 있어도
/// 다음 예약·이용권 잔여·최근 이용이 로그인 때 값 그대로였다.
class _BookstoreMainState extends State<BookstoreMain> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final UserDataController userData = Get.find<UserDataController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && userData.hasUserData) {
      bookstoreMainService(userData.userData.stuId);
    }
  }

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
