import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application/_core/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

////////////////////////////
//  토큰 관리(발급, 전송)  //
////////////////////////////

StreamSubscription<String>? _tokenRefreshSub;

/// APNs 토큰 대기 상한 — 0.5초 × 240 = 2분
const int _apnsMaxTries = 240;

// Fcm에서 디바이스 등록 토큰 발급
// iOS는 APNs 토큰이 먼저 발급돼야 FCM 토큰을 받을 수 있으므로,
// APNs 토큰이 올 때까지 기다린 뒤 FCM 토큰을 받아 서버에 등록
Future<void> getToken(id) async {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  // 토큰이 갱신되면 갱신된 토큰도 서버에 등록
  _tokenRefreshSub?.cancel();
  _tokenRefreshSub = firebaseMessaging.onTokenRefresh.listen((token) => sendToken(id, token));

  final registration = _registerToken(id);
  // 로그인은 최대 10초까지만 기다리고, 그 뒤에도 등록은 백그라운드에서 끝까지 진행
  await registration.timeout(const Duration(seconds: 10), onTimeout: () {
    Logger().w('[FCM] APNs 토큰 대기 중, 발급되면 이어서 등록합니다.');
    unawaited(registration.catchError((e) => Logger().e('[FCM] 토큰 등록 실패: $e')));
  });
}

Future<void> _registerToken(id) async {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  if (Platform.isIOS) {
    // APNs 토큰이 끝내 안 오는 환경(푸시 미설정 시뮬레이터 등)에서 0.5초마다 영원히 확인하지 않도록
    // 최대 2분까지만 기다린다(2026-10-22). 그 뒤에 토큰이 생기면 onTokenRefresh 가 이어서 등록한다.
    var tries = 0;
    while (await firebaseMessaging.getAPNSToken() == null) {
      if (++tries > _apnsMaxTries) {
        Logger().w('[FCM] APNs 토큰을 받지 못해 등록을 미룹니다(토큰이 생기면 onTokenRefresh 로 등록).');
        return;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  final token = await firebaseMessaging.getToken();
  // 토큰을 서버로 전송
  await sendToken(id, token);
}

// 클라이언트의 등록 토큰을 서버에 전송
Future<void> sendToken(id, token) async {
  String url = dotenv.get("TOKEN_STORAGE_URL");
  final Map<String, dynamic> requestData = {
    'id': id,
    'token': token,
    'state': 'Y',
  };

  try {
    await dio.post(url, data: requestData);
  } catch (e) {
    print('Error: $e');
  }
}
