import 'package:hive_flutter/hive_flutter.dart';

class BadgeStorageHelper {
  static Future<void> markBadgeAsUnread(String key) async {
    final box = await _openBox();
    await box.put('isRead_$key', false);
  }

  static Future<void> markBadgeAsRead(String key) async {
    final box = await _openBox();
    await box.put('isRead_$key', true);
  }

  static Future<bool> isUnread(String key) async {
    final box = await _openBox();
    return !(box.get('isRead_$key', defaultValue: true));
  }

  /// 임의 키 저장·조회 — 정독 결과 new 표시가 "마지막으로 본 발송 시각"을 학생별로 저장한다
  static Future<void> putValue(String key, String value) async {
    final box = await _openBox();
    await box.put(key, value);
  }

  static Future<String?> getValue(String key) async {
    final box = await _openBox();
    return box.get(key) as String?;
  }

  static Future<Box> _openBox() async {
    if (!Hive.isBoxOpen('badge')) {
      return await Hive.openBox('badge');
    }
    return Hive.box('badge');
  }
}