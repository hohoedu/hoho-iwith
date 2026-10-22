import 'package:flutter/material.dart';
import 'package:flutter_application/models/payment/pass_payment_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/bookstore/payment/bookstore_checkout_screen.dart';
import 'package:flutter_application/screens/bookstore/payment/bookstore_payment_widgets/bookstore_payment_tab.dart';
import 'package:flutter_application/screens/bookstore/payment/bookstore_payment_widgets/payment_history_list.dart';
import 'package:flutter_application/screens/bookstore/payment/bookstore_payment_widgets/payment_intro_header.dart';
import 'package:flutter_application/screens/bookstore/payment/bookstore_payment_widgets/payment_notice_card.dart';
import 'package:flutter_application/screens/bookstore/payment/bookstore_payment_widgets/payment_pass_card.dart';
import 'package:flutter_application/screens/bookstore/payment/bookstore_payment_widgets/payment_remain_card.dart';
import 'package:flutter_application/screens/bookstore/payment/bookstore_payment_widgets/payment_trial_card.dart';
import 'package:flutter_application/services/bookstore/bookstore_main_service.dart';
import 'package:flutter_application/services/bookstore/bookstore_payment_service.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// 이용권 결제 화면
class BookstorePaymentScreen extends StatefulWidget {
  const BookstorePaymentScreen({super.key});

  @override
  State<BookstorePaymentScreen> createState() => _BookstorePaymentScreenState();
}

class _BookstorePaymentScreenState extends State<BookstorePaymentScreen> {
  static const List<String> _tabs = ['이용권 구매', '이용권 관리'];

  final PassPaymentController controller =
      Get.put(PassPaymentController(), permanent: true);

  int _selectedIndex = 0;
  bool _manageLoaded = false;
  bool _preparing = false;

  String get _studentId => Get.find<UserDataController>().userData.stuId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      passPaymentInitService(_studentId);
      _loadSiblings();
    });
  }

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1 && !_manageLoaded) {
      _manageLoaded = true;
      passManageInitService(_studentId);
    }
  }

  // ── 결제 ──
  //
  // 기본은 각자 결제(구매하기 = 본인 1명)이고, 책방을 이용하는 형제가 있으면 "형제 함께 결제"로
  // 형제 전원을 한 번에 결제한다(2026-10-22). 예전에는 구매하기를 누를 때마다 형제 선택 시트가 떴다.

  /// 책방을 이용하는 형제(본인 포함). 2명 이상일 때만 "형제 함께 결제" 버튼이 보인다
  List<PassSibling> _siblings = const [];

  Future<void> _loadSiblings() async {
    final siblings = await passSiblingsService(_studentId);
    if (!mounted) return;
    // 같은 학생 행이 중복으로 와도(erp_student.student_id 는 유일하지 않다) 인원은 한 번만 센다
    final seen = <String>{};
    setState(() => _siblings = siblings.where((s) => seen.add(s.studentId)).toList());
  }

  Future<void> _onProductTap(PassProduct product) =>
      _startPayment(() => passPrepareService(_studentId, product));

  Future<void> _onSiblingProductTap(PassProduct product) => _startPayment(() => passPrepareGroupService(
        _studentId,
        _siblings.map((s) => s.studentId).toSet().toList(), // 같은 학생이 두 번 오면 두 번 결제되지 않게
        product,
      ));

  Future<void> _startPayment(Future<PassPrepareResult> Function() prepare) async {
    if (_preparing) return;
    setState(() => _preparing = true);
    try {
      final prepared = await prepare();
      if (!prepared.success) {
        failDialog1('결제 안내', prepared.message ?? '잠시 후 다시 시도해주세요.');
        return;
      }
      await _openCheckout(prepared);
    } catch (e) {
      Logger().d('BookstorePaymentScreen._startPayment exception: $e');
      failDialog1('결제 안내', '잠시 후 다시 시도해주세요.');
    } finally {
      if (mounted) setState(() => _preparing = false);
    }
  }

  Future<void> _openCheckout(PassPrepareResult prepared) async {
    final result = await Navigator.of(context).push<PassCheckoutResult>(
      MaterialPageRoute(
        builder: (_) => BookstoreCheckoutScreen(
          studentId: _studentId,
          orderNo: prepared.orderNo,
          amount: prepared.amount,
          productName: prepared.productName,
        ),
      ),
    );
    if (result == null || !mounted) return;

    if (result.isSuccess) {
      await passPaymentRefreshService(_studentId);
      await bookstoreMainService(_studentId);
      failDialog1('결제 완료', '이용권이 충전되었습니다.\n남은 이용권 ${result.remain}회');
    } else if (result.status == 'fail') {
      failDialog1('결제 실패', result.message ?? '결제가 완료되지 않았습니다.');
    }
  }

  // ── 화면 ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEFF7),
      appBar: const MainAppBar(title: '이용권 결제'),
      body: Column(
        children: [
          BookstorePaymentTab(
            tabs: _tabs,
            selectedIndex: _selectedIndex,
            onTabSelected: _onTabSelected,
          ),
          Expanded(
            child: GetBuilder<PassPaymentController>(
              init: controller,
              builder: (c) {
                if (c.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (c.isFailed) {
                  return _errorView();
                }
                return _selectedIndex == 0 ? _purchaseTab(c) : _manageTab(c);
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _purchaseTab(PassPaymentController c) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const PaymentIntroHeader(),
        if (c.products.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Center(
              child: Text(
                '구매할 수 있는 이용권이 없어요',
                style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
              ),
            ),
          )
        else
          ...(List<PassProduct>.from(c.products)
                ..sort((a, b) => b.totalCount.compareTo(a.totalCount)))
              .map(
            (p) => p.isTrial
                ? PaymentTrialCard(
                    product: p,
                    disabled: _preparing,
                    onPurchase: () => _onProductTap(p),
                  )
                : PaymentPassCard(
                    product: p,
                    disabled: _preparing,
                    onPurchase: () => _onProductTap(p),
                    siblingCount: _siblings.length >= 2 ? _siblings.length : null,
                    onSiblingPurchase: () => _onSiblingProductTap(p),
                  ),
          ),
        const PaymentNoticeCard(),
      ],
    );
  }

  Widget _manageTab(PassPaymentController c) {
    if (c.isManageLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return PaymentRemainCard(remain: c.remain);
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '결제 정보를 불러오지 못했습니다.',
            style: TextStyle(fontSize: 16, color: Color(0xFF6C7176)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => passPaymentInitService(_studentId),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
