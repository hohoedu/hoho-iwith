import 'package:flutter/material.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('공지사항'),
      ),
      body: ListView(
        children: List.generate(
          5,
          (index) {
            return Container(
              child: Text('$index'),
            );
          },
        ),
      ),
    );
  }
}
