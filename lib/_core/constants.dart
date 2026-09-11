import 'dart:ui';

const List<Color> profileColors = [
  Color(0xFFFFE42F),
  Color(0xFF5BD5F8),
  Color(0xFF84E73C),
  Color(0xFF03B3AD),
];

const Map<String, Color> bubbleColors = {
  '이해': Color(0xFFDAF7BE),
  '표현': Color(0xFFBBE5F8),
  '어휘': Color(0xFFE9D7F4),
  '감정': Color(0xFFF8EAB4),
  '사고': Color(0xFFC0F3DC),
  '논리': Color(0xFFFAE3E0),
  '지식': Color(0xFFBEC9FB),
};
const Map<String, Color> bubbleTextColors = {
  '이해': Color(0xFF629A2C),
  '표현': Color(0xFF49849E),
  '어휘': Color(0xFF8B60A5),
  '감정': Color(0xFFAE8012),
  '사고': Color(0xFF2FA26E),
  '논리': Color(0xFFA56860),
  '지식': Color(0xFF586ABC),
};

const Map<String, String> classResultIcons = {
  '1': 'assets/images/icon/reaction_1.png',
  '2': 'assets/images/icon/reaction_2.png',
  '3': 'assets/images/icon/reaction_3.png',
  '4': 'assets/images/icon/reaction_4.png',
  '5': 'assets/images/icon/reaction_5.png',
};

const List<Color> fullColors = [
  Color(0xFFDAF7BE),
  Color(0xFFBBE5F8),
  Color(0xFFE9D7F4),
  Color(0xFFF8EAB4),
  Color(0xFFC0F3DC),
  Color(0xFFFAE3E0),
  Color(0xFFBEC9FB)
];

const Map<String, String> preferencesIcon = {
  '예리한 인간로봇': 'report_ico01.png',
  '직관형 독서가': 'report_ico02.png',
  '표현의 연금술사': 'report_ico03.png',
  '표현의 마술사': 'report_ico04.png',
  '걸어 다니는 어휘사전': 'report_ico05.png',
  '똑똑한 어휘박사': 'report_ico06.png',
  '감성적인 독서가': 'report_ico07.png',
  '따뜻한 공감주의자': 'report_ico08.png',
  '주제를 찾는 탐구자': 'report_ico09.png',
  '깊이 생각하는 사색가': 'report_ico10.png',
  '냉철한 분석가': 'report_ico11.png',
  '꼼꼼한 논리주의자': 'report_ico12.png',
  '호기심 많은 지식인': 'report_ico13.png',
  '사려 깊은 추론가': 'report_ico14.png',
  '완벽한 독서가': 'report_ico15.png',
};

/// 문제 유형(erp_bookstore_code gubun='T') → 독서 성향 라벨 [기본, 상위].
///
/// 서버에 성향 라벨 마스터가 없어 앱에서 조립한다. 짝은 preferencesIcon 의 아이콘 순서
/// (report_ico01~14)를 그대로 따른다 — 유형당 2개씩, 이해→표현→어휘→감정→사고→논리→지식.
///
/// 어느 쪽을 쓸지는 정답률 90% 이상이면 상위 라벨이다. 문구 정책이 정해지면 이 임계값과
/// 라벨을 서버 코드 테이블로 옮기면 된다(화면은 라벨 문자열만 받으므로 그대로 동작한다).
const Map<String, List<String>> tendencyLabels = {
  '이해': ['예리한 인간로봇', '직관형 독서가'],
  '표현': ['표현의 연금술사', '표현의 마술사'],
  '어휘': ['걸어 다니는 어휘사전', '똑똑한 어휘박사'],
  '감정': ['감성적인 독서가', '따뜻한 공감주의자'],
  '사고': ['주제를 찾는 탐구자', '깊이 생각하는 사색가'],
  '논리': ['냉철한 분석가', '꼼꼼한 논리주의자'],
  '지식': ['호기심 많은 지식인', '사려 깊은 추론가'],
};

Map<int, String> weekday = {
  1: '월',
  2: '화',
  3: '수',
  4: '목',
  5: '금',
  6: '토',
  7: '일',
};

const Map<String, String> noticeIcon = {
  '1': "notice_01.png",
  '2': "notice_02.png",
  '3': "notice_03.png",
  '4': "notice_04.png",
  '5': "notice_05.png",
};
const Map<String, Color> noticeColor = {
  '1': Color(0xFFF1E6F8),
  '2': Color(0xFFFEF7E3),
  '3': Color(0xFFD7F4E7),
  '4': Color(0xFFDDEFF7),
  '5': Color(0xFFFEEFED),
};

const List<String> hanLabels = [
  '뜻소리 구별하기',
  '한자어 읽기',
  '어휘 이해',
  '어휘 활용',
  '한자의 쓰임 알기',
  '의미 이해',
  '문장읽기',
  '문장 이해',
];
const List<String> bookLabels = [
  '표현법 이해',
  '문장적용',
  '주제이해',
  '의미연계',
  '개념인지',
  '지식확장',
  '시대, 역사이해',
  '실생활 연계',
];

const List<Color> infantMonthlyCategoryColors = [
  Color(0xFFC8E2FD),
  Color(0xFFFFD08C),
  Color(0xFFFFC0E2),
  Color(0xFFD3C0FF),
  Color(0xFFC2EACE),
];
const List<Color> infantMonthlyNoteColors = [
  Color(0xFF438EDD),
  Color(0xFFD7631E),
  Color(0xFFBA4D88),
  Color(0xFF7F60C6),
  Color(0xFF3B9A4F),
];
