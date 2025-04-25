import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

////////////////////////////
//  토큰 관리(발급, 전송)  //
////////////////////////////

// Fcm에서 디바이스 등록 토큰 발급
Future<void> getToken() async {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  final token = await firebaseMessaging.getToken();
  // 토큰을 서버로 전송
  // sendToken(token);
}
