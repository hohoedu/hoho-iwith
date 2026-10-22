import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/////////////////////////////
//  Firebase Remote Config //
/////////////////////////////

// 콘솔에 등록할 파라미터 키
class RemoteConfigKeys {
  // 점검 모드
  static const maintenanceEnabled = 'maintenance_enabled';
  static const maintenanceMessage = 'maintenance_message';

  // 업데이트 (min_version 미만: 강제, latest_version 미만: 선택)
  static const minVersion = 'min_version';
  static const latestVersion = 'latest_version';
  static const updateMessage = 'update_message';

  // 긴급 공지
  static const emergencyNoticeEnabled = 'emergency_notice_enabled';
  static const emergencyNoticeTitle = 'emergency_notice_title';
  static const emergencyNoticeMessage = 'emergency_notice_message';
}

enum UpdateType { none, optional, force }

class RemoteConfigService {
  static final _logger = Logger();
  static FirebaseRemoteConfig get _rc => FirebaseRemoteConfig.instance;

  // 가져오기에 실패했을 때 사용할 기본값 (앱 진입을 막지 않는 값)
  static const Map<String, dynamic> _defaults = {
    RemoteConfigKeys.maintenanceEnabled: false,
    RemoteConfigKeys.maintenanceMessage: '서비스 점검 중입니다.\n잠시 후 다시 이용해 주세요.',
    RemoteConfigKeys.minVersion: '0.0.0',
    RemoteConfigKeys.latestVersion: '0.0.0',
    RemoteConfigKeys.updateMessage: '새로운 버전이 출시되었습니다.\n업데이트 후 이용해 주세요.',
    RemoteConfigKeys.emergencyNoticeEnabled: false,
    RemoteConfigKeys.emergencyNoticeTitle: '긴급 공지',
    RemoteConfigKeys.emergencyNoticeMessage: '',
  };

  // 디버그 전용 테스트 시나리오 (flutter run --dart-define=RC_TEST=maintenance)
  // maintenance | force | optional | notice  ※ 릴리즈 빌드에서는 무시됨
  static const _testScenario = String.fromEnvironment('RC_TEST');
  static Map<String, Object> get _testOverrides {
    if (!kDebugMode) return const {};
    return switch (_testScenario) {
      'maintenance' => const {RemoteConfigKeys.maintenanceEnabled: true},
      'force' => const {RemoteConfigKeys.minVersion: '9.9.9'},
      'optional' => const {RemoteConfigKeys.latestVersion: '9.9.9'},
      'notice' => const {
          RemoteConfigKeys.emergencyNoticeEnabled: true,
          RemoteConfigKeys.emergencyNoticeMessage: '테스트용 긴급 공지입니다.',
        },
      _ => const {},
    };
  }

  static bool _getBool(String key) => (_testOverrides[key] as bool?) ?? _rc.getBool(key);
  static String _getString(String key) => (_testOverrides[key] as String?) ?? _rc.getString(key);

  static Future<void> init() async {
    try {
      await _rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        // 점검/긴급 공지가 빨리 반영되도록 짧게 설정
        minimumFetchInterval: kDebugMode ? Duration.zero : const Duration(minutes: 5),
      ));
      await _rc.setDefaults(_defaults);
      await _rc.fetchAndActivate();
      _logger.d('[RemoteConfig] 가져오기 완료: ${_rc.lastFetchStatus}');
      if (_testOverrides.isNotEmpty) _logger.w('[RemoteConfig] 테스트 시나리오 적용: $_testScenario');
    } catch (e) {
      // 실패해도 기본값(또는 마지막으로 활성화된 값)으로 진행
      _logger.e('[RemoteConfig] 가져오기 실패: $e');
    }
  }

  // 점검 모드
  static bool get maintenanceEnabled => _getBool(RemoteConfigKeys.maintenanceEnabled);
  static String get maintenanceMessage => _getString(RemoteConfigKeys.maintenanceMessage);

  // 업데이트
  static String get updateMessage => _getString(RemoteConfigKeys.updateMessage);

  static UpdateType checkUpdate(String currentVersion) {
    final minVersion = _getString(RemoteConfigKeys.minVersion);
    final latestVersion = _getString(RemoteConfigKeys.latestVersion);
    _logger.d('[RemoteConfig] 현재: $currentVersion, 최소: $minVersion, 최신: $latestVersion');

    if (_compareVersion(currentVersion, minVersion) < 0) return UpdateType.force;
    if (_compareVersion(currentVersion, latestVersion) < 0) return UpdateType.optional;
    return UpdateType.none;
  }

  // 긴급 공지
  static bool get emergencyNoticeEnabled =>
      _getBool(RemoteConfigKeys.emergencyNoticeEnabled) && emergencyNoticeMessage.trim().isNotEmpty;
  static String get emergencyNoticeTitle => _getString(RemoteConfigKeys.emergencyNoticeTitle);
  static String get emergencyNoticeMessage => _getString(RemoteConfigKeys.emergencyNoticeMessage);

  // '1.3.7' 형식 비교 (a < b: 음수, a == b: 0, a > b: 양수)
  static int _compareVersion(String a, String b) {
    List<int> parse(String v) => v.trim().split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final pa = parse(a);
    final pb = parse(b);
    for (int i = 0; i < 3; i++) {
      final x = i < pa.length ? pa[i] : 0;
      final y = i < pb.length ? pb[i] : 0;
      if (x != y) return x - y;
    }
    return 0;
  }
}
