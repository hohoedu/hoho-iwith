import 'package:flutter_application/notifications/badge_storage.dart';
import 'package:get/get.dart';

class BadgeController extends GetxController {
  final RxBool badgeInfoVisible = false.obs;
  final RxBool badgeResultVisible = false.obs;
  final RxBool badgeMonthlyVisible = false.obs;
  final RxBool badgeReadingVisible = false.obs;

  Future<void> init() async {
    badgeInfoVisible.value = await BadgeStorageHelper.isUnread('info');
    badgeResultVisible.value = await BadgeStorageHelper.isUnread('result');
    badgeMonthlyVisible.value = await BadgeStorageHelper.isUnread('monthly');
    badgeReadingVisible.value = await BadgeStorageHelper.isUnread('reading');
  }

  void updateBadge(String key, bool visible) {
    if (key == 'info') badgeInfoVisible.value = visible;
    if (key == 'result') badgeResultVisible.value = visible;
    if (key == 'monthly') badgeMonthlyVisible.value = visible;
    if (key == 'reading') badgeReadingVisible.value = visible;
  }
}