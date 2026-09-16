import 'package:flutter/material.dart';
import 'package:flutter_application/models/bookstore/bookstore_reservation_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/bookstore/reservation/reservation_widgets/reservation_calendar.dart';
import 'package:flutter_application/screens/bookstore/reservation/reservation_widgets/reservation_pass_card.dart';
import 'package:flutter_application/screens/bookstore/reservation/reservation_widgets/reservation_repeat_section.dart';
import 'package:flutter_application/screens/bookstore/reservation/reservation_widgets/reservation_time_slots.dart';
import 'package:flutter_application/services/bookstore/bookstore_main_service.dart';
import 'package:flutter_application/services/bookstore/bookstore_reservation_service.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

/// 책방 예약 화면.
class BookstoreReservationScreen extends StatefulWidget {
  const BookstoreReservationScreen({super.key});

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

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    WidgetsBinding.instance.addPostFrameCallback((_) => bookstoreReservationService());
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
    ]);
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

    final int? seq = controller.data
        ?.slotsOfDate(_dateKey(_selectedDate))
        .firstWhere(
          (s) => s.slotInstanceId == _selectedSlotInstanceId,
          orElse: () => SlotOption(slotInstanceId: 0, serviceDate: '', seq: 0),
        )
        .seq;
    if (seq == null || seq == 0) {
      failDialog1('예약 안내', '선택한 시간대를 찾을 수 없어요');
      return;
    }

    setState(() {
      _repeatEnabled = true;
      _batchLoading = true;
    });

    // dayOfWeek는 ISO 1=월~7=일 — Dart의 DateTime.weekday와 값이 같아 그대로 보낸다.
    final result = await bookstoreReservationBatchPreview(dayOfWeek: _selectedDate.weekday, seq: seq);
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

  String _dateKey(DateTime date) => intl.DateFormat('yyyy-MM-dd').format(date);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F2ED),
      appBar: const MainAppBar(
        title: '예약하기',
        color: Colors.transparent,
      ),
      body: GetBuilder<BookstoreReservationDataController>(
        builder: (_) => _body(),
      ),
    );
  }

  Widget _body() {
    final data = controller.data;

    if (data == null) {
      if (controller.isFailed) {
        return const Center(
          child: Text('예약 정보를 불러오지 못했어요', style: TextStyle(color: Color(0xFF719183))),
        );
      }
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00B093)));
    }

    return Stack(
      children: [
        ListView(
          children: [
            const ReservationPassCard(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ReservationCalendar(
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
            ReservationRepeatSection(
              enabled: _repeatEnabled,
              loading: _batchLoading,
              items: _batchItems,
              selectedIds: _batchSelectedIds,
              fallbackTimeLabel: _selectedSlotTimeLabel,
              onToggle: _toggleRepeat,
              onItemTap: _toggleBatchItem,
            ),
            _submitButton(),
          ],
        ),
        if (controller.isLoading || _submitting)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x66E7F2ED),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF00B093))),
            ),
          ),
      ],
    );
  }

  Widget _submitButton() {
    final bool enabled = !_submitting && (_repeatEnabled ? _batchSelectedIds.isNotEmpty : _selectedSlotInstanceId != null);
    final String label = _repeatEnabled ? '${_batchSelectedIds.length}회 예약하기' : '예약하기';

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
