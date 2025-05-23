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

  static Future<Box> _openBox() async {
    if (!Hive.isBoxOpen('badge')) {
      return await Hive.openBox('badge');
    }
    return Hive.box('badge');
  }
}