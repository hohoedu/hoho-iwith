import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application/_core/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

////////////////////////////
//  토큰 관리(발급, 전송)  //
////////////////////////////

// Fcm에서 디바이스 등록 토큰 발급
Future<void> getToken(id) async {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  final token = await firebaseMessaging.getToken();
  // 토큰을 서버로 전송
  sendToken(id, token);
}

// 클라이언트의 등록 토큰을 서버에 전송
Future<void> sendToken(id, token) async {
  String url = dotenv.get("TOKEN_STORAGE_URL");
  final Map<String, dynamic> requestData = {'id': id, 'token': token, 'state': 'Y'};

  Logger().d('token = $token');
  try {
    await dio.post(url, data: requestData);
  } catch (e) {
    print('Error: $e');
  }
}
