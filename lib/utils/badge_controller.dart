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

/// 정독 결과 "new" 표시 (2026-10-22).
///
/// 서버가 내려주는 가장 최근 발송 시각과, 그 학생이 정독 결과 화면을 마지막으로 열었을 때의 발송 시각을
/// 비교한다. 알림만으로 켜면(예전 noticeNum 6 방식) iOS 백그라운드처럼 알림 처리가 안 도는 경우를
/// 놓치고, 끄는 코드도 구 독서클리닉 화면에만 있었다. 학생별로 따로 저장해 형제 간에 섞이지 않게 한다.
class ReadingBadge {
  static String _key(String stuId) => 'reading_viewed_$stuId';

  /// 메인 데이터를 받을 때마다 부른다 — 본 적 없는 발송이 있으면 표시를 켠다
  static Future<void> refresh(String stuId, String? lastReportSentAt) async {
    if (!Get.isRegistered<BadgeController>()) return;
    final viewed = await BadgeStorageHelper.getValue(_key(stuId));
    final unseen = lastReportSentAt != null && lastReportSentAt != viewed;
    Get.find<BadgeController>().updateBadge('reading', unseen);
  }

  /// 정독 결과 화면을 열었을 때 — 지금 발송분까지 봤다고 기록하고 표시를 끈다
  static Future<void> markViewed(String stuId, String? lastReportSentAt) async {
    if (lastReportSentAt != null) {
      await BadgeStorageHelper.putValue(_key(stuId), lastReportSentAt);
    }
    await BadgeStorageHelper.markBadgeAsRead('reading');
    if (Get.isRegistered<BadgeController>()) {
      Get.find<BadgeController>().updateBadge('reading', false);
    }
  }
}
