import 'dart:convert';
import 'dart:io';

import 'package:flutter_application/models/version_data.dart';
import 'package:flutter_application/utils/network_check.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

///////////////////
//  앱 버전 확인   //
///////////////////

// DB에 저장된 앱 버전 가져오기
Future<void> versionCheck() async {
  // 컨트롤러
  final connectivityController = Get.put(ConnectivityController());

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('VERSION_CHECK_URL');

    // HTTP POST 요청
    var response = await http.post(Uri.parse(url));

    if (response.headers['content-type']
            ?.toLowerCase()
            .contains('charset=utf-8') !=
        true) {
      response.headers['content-type'] = 'application/json; charset=utf-8';
    }
    try {
      if (response.statusCode == 200) {
        final resultList = json.decode(response.body);

        // 응답 데이터가 성공일 때
        if (resultList[0]['result'] == "0000") {
          VersionData versionData = VersionData.fromJson(resultList[0]);
          final VersionDataController versionDataController =
              Get.put(VersionDataController());
          versionDataController.setVersionData(versionData);

          initPackageInfo();
        }
        // 응답 데이터가 없을 때
        else {
          failDialog1("버전확인 실패", "버전 확인 중 오류 발생");
        }
      }
    } catch (e) {}
  } else {
    failDialog1("연결 실패", "인터넷 연결을 확인해주세요");
  }
}

// 디바이스의 앱 정보 가져오기
Future<void> initPackageInfo() async {
  final VersionDataController versionDataController =
      Get.put(VersionDataController());
  final info = await PackageInfo.fromPlatform();
  if (info.version != versionDataController.versionData!.ver) {
    failDialog3("버전 불일치", "최신버전을 설치해 주세요", () {
      call();
    });
  }
}

// 스토어로 이동
Future<void> call() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String appStoreID = "6504266908";
  Uri storeUrl = Platform.isAndroid
      ? Uri.parse(
          'https://play.google.com/store/apps/details?id=${packageInfo.packageName}')
      : Uri.parse('https://apps.apple.com/us/app/id$appStoreID');
  if (await canLaunchUrl(storeUrl)) {
    await launchUrl(storeUrl);
  }

  exit(0);
}
