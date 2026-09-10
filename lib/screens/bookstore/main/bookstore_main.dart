import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/screens/bookstore/main/main_widgets/books_bookcase.dart';
import 'package:flutter_application/screens/bookstore/main/main_widgets/books_class_info.dart';
import 'package:flutter_application/screens/bookstore/main/main_widgets/books_main_btn.dart';
import 'package:flutter_application/screens/bookstore/main/main_widgets/books_recent_list.dart';

class BookstoreMain extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      // endDrawer: MyPageScreen(),
      body: Column(
        children: [
          BooksClassInfo(),
          BooksRecentList(),
          BooksMainBtn(),
          BooksBookcase(),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}
