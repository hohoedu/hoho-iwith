import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_reservation_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/bookstore/reservation/reservation_widgets/reservation_auto_section.dart';
import 'package:flutter_application/screens/bookstore/reservation/reservation_widgets/reservation_calendar.dart';
import 'package:flutter_application/screens/bookstore/reservation/reservation_widgets/reservation_my_list.dart';
import 'package:flutter_application/screens/bookstore/reservation/reservation_widgets/reservation_pass_card.dart';
import 'package:flutter_application/screens/bookstore/reservation/reservation_widgets/reservation_repeat_section.dart';
import 'package:flutter_application/screens/bookstore/reservation/reservation_widgets/reservation_tab.dart';
import 'package:flutter_application/screens/bookstore/reservation/reservation_widgets/reservation_time_slots.dart';
import 'package:flutter_application/services/bookstore/bookstore_main_service.dart';
import 'package:flutter_application/services/bookstore/bookstore_reservation_service.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

/// 책방 예약 화면. 예약하기 / 나의 예약 두 탭.
class BookstoreReservationScreen extends StatefulWidget {
  const BookstoreReservationScreen({super.key, this.initialTab = 0});

  /// 0 = 예약하기, 1 = 나의 예약
  final int initialTab;

  @override
  State<BookstoreReservationScreen> createState() => _BookstoreReservationScreenState();
}

class _BookstoreReservationScreenState extends State<BookstoreReservationScreen> {
  final BookstoreReservationDataController controller = Get.put(BookstoreReservationDataController(), permanent: true);

  late DateTime _selectedDate;
  int? _selectedSlotInstanceId;

  String _selectedSlotTimeLabel = '';

  bool _repeatEnabled = false;
  bool _batchLoading = false;
  List<BatchPreviewItem> _batchItems = [];
  final Set<int> _batchSelectedIds = {};

  /// 고른 시간대로 매주 자동 예약을 켤지. 반복 예약(4주 일괄)과 동시에 켜지 않는다
  bool _autoEnabled = false;
  List<AutoPattern> _autoPatterns = [];

  bool _submitting = false;

  static const List<String> _tabs = ['예약하기', '나의 예약'];
  late int _tabIndex = widget.initialTab;

  // ── 나의 예약 탭 ──
  /// null이면 아직 못 받음
  List<ReservationItem>? _myReservations;
  late DateTime _mySelectedDate;

  /// 나의 예약에서 '변경하기'를 누른 예약. 있으면 예약하기 탭이 변경 모드가 된다
  ReservationItem? _changingReservation;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _mySelectedDate = _selectedDate;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bookstoreReservationService();
      _loadAutoPatterns();
      _loadMyReservations(jumpToFirst: true);
    });
  }

  Future<void> _loadMyReservations({bool jumpToFirst = false}) async {
    final list = (await bookstoreReservationMy()).where((r) => r.isActive).toList()..sort((a, b) => (a.startsAt ?? DateTime(9999)).compareTo(b.startsAt ?? DateTime(9999)));
    if (!mounted) return;
    setState(() {
      _myReservations = list;
      // 처음 열 때는 가장 가까운 예약 날짜를 골라둔다
      if (jumpToFirst && list.isNotEmpty) {
        final d = DateTime.tryParse(list.first.serviceDate);
        if (d != null) _mySelectedDate = d;
      }
    });
  }

  void _onTabSelected(int index) {
    if (index == _tabIndex) return;
    setState(() {
      _tabIndex = index;
      _changingReservation = null;
      _clearSelection();
    });
  }

  /// 나의 예약 → 변경하기: 예약하기 탭으로 넘어가 같은 날짜에서 새 시간을 고르게 한다
  void _startChange(ReservationItem item) {
    final date = DateTime.tryParse(item.serviceDate);
    setState(() {
      _tabIndex = 0;
      _changingReservation = item;
      if (date != null) _selectedDate = date;
      _clearSelection();
    });
  }

  void _confirmCancelReservation(ReservationItem item) {
    confirmDialog(
      '예약을 취소할까요?',
      '${monthDayWeekdayLabel(DateTime.parse(item.serviceDate))} ${item.seq}회차 ${item.timeLabel}',
      () async {
        setState(() => _submitting = true);
        final result = await bookstoreReservationCancel(item.reservationId);
        if (!mounted) return;
        setState(() => _submitting = false);
        await _applyResult(result, successMessage: '예약이 취소되었어요', failureMessage: '예약 취소에 실패했어요');
      },
      confirmText: '취소하기',
      cancelText: '아니요',
    );
  }

  Future<void> _loadAutoPatterns() async {
    final patterns = await bookstoreAutoList();
    if (!mounted) return;
    setState(() => _autoPatterns = patterns);
  }

  // ── 선택 상태 ──

  void _onDateSelected(DateTime date) {
    if (_dateKey(date) == _dateKey(_selectedDate)) return;
    setState(() {
      _selectedDate = date;
      _clearSelection();
    });
  }

  void _clearSelection() {
    _selectedSlotInstanceId = null;
    _selectedSlotTimeLabel = '';
    _repeatEnabled = false;
    _autoEnabled = false;
    _batchItems = [];
    _batchSelectedIds.clear();
  }

  void _onSlotTapped(SlotOption slot) {
    if (slot.reservedByMe) {
      _confirmCancel(slot);
      return;
    }
    if (!slot.isOpen) return;
    setState(() {
      _selectedSlotInstanceId = slot.slotInstanceId;
      _selectedSlotTimeLabel = slot.timeLabel;
      _repeatEnabled = false;
      _autoEnabled = false;
      _batchItems = [];
      _batchSelectedIds.clear();
    });
  }

  void _toggleBatchItem(BatchPreviewItem item) {
    if (!item.selectable) return;
    setState(() {
      if (_batchSelectedIds.contains(item.slotInstanceId)) {
        _batchSelectedIds.remove(item.slotInstanceId);
      } else {
        _batchSelectedIds.add(item.slotInstanceId);
      }
    });
  }

  // ── 서버 호출 ──
  Future<void> _refreshAfterChange() async {
    final stuId = Get.find<UserDataController>().userData.stuId;
    await Future.wait([
      bookstoreReservationService(),
      bookstoreMainService(stuId),
      _loadAutoPatterns(),
      _loadMyReservations(),
    ]);
  }

  /// 고른 시간대의 회차. 못 찾으면 null
  int? _selectedSeq() {
    final int? seq = controller.data
        ?.slotsOfDate(_dateKey(_selectedDate))
        .firstWhere(
          (s) => s.slotInstanceId == _selectedSlotInstanceId,
          orElse: () => SlotOption(slotInstanceId: 0, serviceDate: '', seq: 0),
        )
        .seq;
    return (seq == null || seq == 0) ? null : seq;
  }

  /// 매주 자동 예약 스위치 — 켜면 예약하기가 "매주 자동 예약하기"로 바뀐다
  void _toggleAuto() {
    if (_selectedSlotInstanceId == null) {
      failDialog1('예약 안내', '먼저 예약 시간을 선택해주세요');
      return;
    }
    setState(() {
      _autoEnabled = !_autoEnabled;
      if (_autoEnabled) {
        _repeatEnabled = false;
        _batchItems = [];
        _batchSelectedIds.clear();
      }
    });
  }

  /// 내 자동 예약 목록의 스위치 — 바로 서버에 켜고 끈다
  Future<void> _togglePattern(AutoPattern pattern) async {
    if (_submitting) return;
    if (pattern.isOn) {
      confirmDialog(
        '자동 예약을 끌까요?',
        '${pattern.label}\n이미 잡힌 예약은 그대로 남아요',
        () async {
          setState(() => _submitting = true);
          final result = await bookstoreAutoOff(pattern.autoId);
          if (!mounted) return;
          setState(() => _submitting = false);
          if (!result.success) {
            failDialog1('예약 안내', result.message ?? '자동 예약을 끄지 못했어요');
            return;
          }
          await _loadAutoPatterns();
        },
        confirmText: '끄기',
        cancelText: '아니요',
      );
      return;
    }
    setState(() => _submitting = true);
    final result = await bookstoreAutoOn(pattern.autoId);
    if (!mounted) return;
    setState(() => _submitting = false);
    await _applyAutoResult(result);
  }

  Future<void> _toggleRepeat() async {
    if (_selectedSlotInstanceId == null) {
      failDialog1('예약 안내', '먼저 예약 시간을 선택해주세요');
      return;
    }
    if (_repeatEnabled) {
      setState(() {
        _repeatEnabled = false;
        _batchItems = [];
        _batchSelectedIds.clear();
      });
      return;
    }

    final int? seq = _selectedSeq();
    if (seq == null) {
      failDialog1('예약 안내', '선택한 시간대를 찾을 수 없어요');
      return;
    }

    setState(() {
      _repeatEnabled = true;
      _autoEnabled = false;
      _batchLoading = true;
    });

    // dayOfWeek는 ISO 1=월~7=일 — Dart의 DateTime.weekday와 값이 같아 그대로 보낸다.
    // 고른 날짜부터 같은 요일 4주 — 고른 날짜를 같이 보내야 오늘 기준으로 잡히지 않는다
    final result = await bookstoreReservationBatchPreview(dayOfWeek: _selectedDate.weekday, seq: seq, startDate: _selectedDate);
    if (!mounted) return;

    if (!result.success) {
      setState(() {
        _repeatEnabled = false;
        _batchLoading = false;
      });
      failDialog1('예약 안내', result.message ?? '반복 예약 정보를 불러오지 못했어요');
      return;
    }

    setState(() {
      _batchLoading = false;
      _batchItems = result.items;
      _batchSelectedIds
        ..clear()
        ..addAll(result.items.where((i) => i.selectable).map((i) => i.slotInstanceId));
    });
  }

  void _confirmCancel(SlotOption slot) {
    confirmDialog(
      '예약을 취소할까요?',
      '${monthDayWeekdayLabel(DateTime.parse(slot.serviceDate))} ${slot.seq}회차 ${slot.timeLabel}',
      () => _cancelSlot(slot),
      confirmText: '취소하기',
      cancelText: '아니요',
    );
  }

  Future<void> _cancelSlot(SlotOption slot) async {
    setState(() => _submitting = true);
    // 슬롯 목록엔 reservationId가 없어서 내 예약 목록에서 같은 슬롯 건을 찾아 취소한다.
    final myReservations = await bookstoreReservationMy();
    final match = myReservations.where((r) => r.slotInstanceId == slot.slotInstanceId);
    if (match.isEmpty) {
      if (!mounted) return;
      setState(() => _submitting = false);
      failDialog1('예약 안내', '예약 내역을 찾을 수 없어요');
      return;
    }

    final result = await bookstoreReservationCancel(match.first.reservationId);
    if (!mounted) return;
    setState(() => _submitting = false);
    await _applyResult(result, successMessage: '예약이 취소되었어요', failureMessage: '예약 취소에 실패했어요');
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final changing = _changingReservation;
    if (changing != null) {
      if (_selectedSlotInstanceId == null) return;
      setState(() => _submitting = true);
      final result = await bookstoreReservationChange(reservationId: changing.reservationId, slotInstanceId: _selectedSlotInstanceId!);
      if (!mounted) return;
      setState(() => _submitting = false);
      if (result.success) setState(() => _changingReservation = null);
      await _applyResult(result, successMessage: '예약이 변경됐어요', failureMessage: '예약 변경에 실패했어요');
      return;
    }

    if (_autoEnabled) {
      final int? seq = _selectedSeq();
      if (seq == null) {
        failDialog1('예약 안내', '선택한 시간대를 찾을 수 없어요');
        return;
      }
      setState(() => _submitting = true);
      // 고른 날짜부터 — dayOfWeek는 ISO 1=월~7=일로 DateTime.weekday와 같다
      final result = await bookstoreAutoRegister(dayOfWeek: _selectedDate.weekday, seq: seq, startDate: _selectedDate);
      if (!mounted) return;
      setState(() => _submitting = false);
      await _applyAutoResult(result);
      return;
    }

    if (_repeatEnabled) {
      if (_batchSelectedIds.isEmpty) return;
      final count = _batchSelectedIds.length;
      setState(() => _submitting = true);
      final result = await bookstoreReservationBatchReserve(_batchSelectedIds.toList());
      if (!mounted) return;
      setState(() => _submitting = false);
      await _applyResult(result, successMessage: '$count회 예약이 완료됐어요', failureMessage: '반복 예약에 실패했어요');
      return;
    }

    if (_selectedSlotInstanceId == null) return;
    setState(() => _submitting = true);
    final result = await bookstoreReservationReserve(_selectedSlotInstanceId!);
    if (!mounted) return;
    setState(() => _submitting = false);
    await _applyResult(result, successMessage: '예약이 완료됐어요', failureMessage: '예약에 실패했어요');
  }

  /// 예약/취소 결과 공통 처리 — 성공하면 선택을 비우고 목록을 다시 받아온다.
  Future<void> _applyResult(ReservationActionResult result, {required String successMessage, required String failureMessage}) async {
    if (!result.success) {
      failDialog1('예약 안내', result.message ?? failureMessage);
      return;
    }
    customDialog('예약 안내', successMessage, () => Get.back());
    setState(_clearSelection);
    await _refreshAfterChange();
  }

  /// 자동 예약 켜기 결과 — 몇 회 잡혔는지(결제대기·이용권 부족 포함) 알려주고 목록을 다시 받는다.
  Future<void> _applyAutoResult(AutoRegisterResult result) async {
    if (!result.success) {
      failDialog1('예약 안내', result.message ?? '자동 예약을 켜지 못했어요');
      return;
    }
    customDialog('예약 안내', result.summary, () => Get.back());
    setState(_clearSelection);
    await _refreshAfterChange();
  }

  String _dateKey(DateTime date) => intl.DateFormat('yyyy-MM-dd').format(date);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F2ED),
      // backgroundColor: Colors.white,
      appBar: const MainAppBar(
        title: '책방 예약',
        color: Colors.white,
      ),
      body: Column(
        children: [
          ReservationTab(tabs: _tabs, selectedIndex: _tabIndex, onTabSelected: _onTabSelected),
          Expanded(
            child: GetBuilder<BookstoreReservationDataController>(
              builder: (_) => Stack(
                children: [
                  _tabIndex == 0 ? _reserveTab() : _myTab(),
                  if (controller.isLoading || _submitting)
                    const Positioned.fill(
                      child: ColoredBox(
                        color: Color(0x66E7F2ED),
                        child: Center(child: CircularProgressIndicator(color: Color(0xFF00B093))),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _myTab() {
    final list = _myReservations;
    if (list == null) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00B093)));
    }
    final selectedKey = _dateKey(_mySelectedDate);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ReservationCalendar(
            key: const ValueKey('my-calendar'),
            initialMonth: DateTime(_mySelectedDate.year, _mySelectedDate.month),
            selectedDate: _mySelectedDate,
            dayStatuses: {for (final r in list) r.serviceDate: ReservationDayStatus.complete},
            showAvailability: false,
            onDateSelected: (d) => setState(() => _mySelectedDate = d),
          ),
        ),
        ReservationMyList(
          selectedDate: _mySelectedDate,
          items: list.where((r) => r.serviceDate == selectedKey).toList(),
          onChange: _startChange,
          onCancel: _confirmCancelReservation,
        ),
      ],
    );
  }

  /// 변경 모드 안내 — 어떤 예약을 바꾸는 중인지 + 그만두기
  Widget _changeBanner(ReservationItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE2ED),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('예약 변경 중', style: TextStyle(fontFamily: 'Pretendard-Bold', fontSize: 13, color: Color(0xFFE84D89))),
                  const SizedBox(height: 4),
                  Text(
                    '${monthDayWeekdayLabel(DateTime.parse(item.serviceDate))} ${item.seq}회차 ${item.timeLabel}',
                    style: const TextStyle(fontFamily: 'Pretendard-Bold', fontSize: 15, color: Color(0xFF363636)),
                  ),
                  const SizedBox(height: 2),
                  const Text('바꿀 날짜와 시간을 선택해주세요', style: TextStyle(fontSize: 12, color: Color(0xFF719183))),
                ],
              ),
            ),
            TextButton(
              onPressed: () => setState(() {
                _changingReservation = null;
                _clearSelection();
              }),
              child: const Text('변경 취소', style: TextStyle(color: Color(0xFFE84D89))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reserveTab() {
    final data = controller.data;
    final changing = _changingReservation;

    if (data == null) {
      if (controller.isFailed) {
        return const Center(
          child: Text('예약 정보를 불러오지 못했어요', style: TextStyle(color: Color(0xFF719183))),
        );
      }
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00B093)));
    }

    return ListView(
      children: [
        if (changing != null) _changeBanner(changing) else const ReservationPassCard(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ReservationCalendar(
            // 변경을 시작하면 날짜가 바뀌므로 달력을 새로 만들어 그 달/날짜로 맞춘다
            key: ValueKey('reserve-calendar-${changing?.reservationId}'),
            initialMonth: DateTime(_selectedDate.year, _selectedDate.month),
            selectedDate: _selectedDate,
            dayStatuses: data.dayStatuses,
            onDateSelected: _onDateSelected,
          ),
        ),
        ReservationTimeSlots(
          selectedDate: _selectedDate,
          slots: data.slotsOfDate(_dateKey(_selectedDate)),
          selectedSlotInstanceId: _selectedSlotInstanceId,
          onSlotTap: _onSlotTapped,
        ),
        // 변경 모드에선 반복/자동 예약을 숨긴다 — 한 건만 옮긴다
        if (changing == null) ...[
          ReservationRepeatSection(
            enabled: _repeatEnabled,
            loading: _batchLoading,
            items: _batchItems,
            selectedIds: _batchSelectedIds,
            fallbackTimeLabel: _selectedSlotTimeLabel,
            onToggle: _toggleRepeat,
            onItemTap: _toggleBatchItem,
          ),
          ReservationAutoSection(
            enabled: _autoEnabled,
            selectedLabel: _selectedSlotInstanceId == null ? null : _selectedAutoLabel(),
            patterns: _autoPatterns,
            onToggle: _toggleAuto,
            onPatternToggle: _togglePattern,
          ),
        ],
        _submitButton(),
      ],
    );
  }

  /// '화요일 2회차' — 자동 예약 카드 설명에 쓴다
  String? _selectedAutoLabel() {
    final seq = _selectedSeq();
    if (seq == null) return null;
    return AutoPattern(autoId: 0, dayOfWeek: _selectedDate.weekday, seq: seq).label;
  }

  Widget _submitButton() {
    final bool enabled = !_submitting && (_repeatEnabled ? _batchSelectedIds.isNotEmpty : _selectedSlotInstanceId != null);
    final String label = _changingReservation != null
        ? '이 시간으로 변경하기'
        : _autoEnabled
            ? '매주 자동 예약하기'
            : _repeatEnabled
                ? '${_batchSelectedIds.length}회 예약하기'
                : '예약하기';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: GestureDetector(
        onTap: enabled ? _submit : null,
        child: Container(
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFF008D78) : const Color(0xFFB7D6CE),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Pretendard-ExtraBold',
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
