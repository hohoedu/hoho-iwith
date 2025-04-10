import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/imagebox_decoration.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/////////////////////////
// 호호에듀 더보기 화면 //
/////////////////////////

class AboutHohoeduScreen extends StatelessWidget {
  const AboutHohoeduScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      appBar: customAppBar("호호에듀 더보기"),
      body: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: shortcutList.length,
        itemBuilder: (c, i) {
          return GestureDetector(
            onTap: (){
              launchUrl(Uri.parse(shortcutList[i]['url'].toString()));
            },
            child: shortcutIcon(shortcutList[i]['title'], shortcutList[i]['url'], shortcutList[i]['imgPath'])
          );
        },
      ),
    );
  }
}

// 바로가기 아이콘
Widget shortcutIcon(title, url, imgPath) {
  return GestureDetector(
    onTap: (){
      launchUrl(Uri.parse(url));
    },
    child: ListTile(
      tileColor: Theme.of(Get.context!).colorScheme.surface,
      title: Text(title, style: const TextStyle(fontSize: 15)),
      leading: Container(
        margin: const EdgeInsets.all(5),
        width: 35,
        height: 35,
        decoration: imageBoxDecoration(imgPath, BoxFit.contain),
      ),
    ),
  );
}