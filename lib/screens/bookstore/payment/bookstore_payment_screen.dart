import 'package:flutter/material.dart';
import 'package:flutter_application/models/payment/pass_payment_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/bookstore/payment/bookstore_checkout_screen.dart';
import 'package:flutter_application/screens/bookstore/payment/bookstore_payment_widgets/bookstore_payment_tab.dart';
import 'package:flutter_application/screens/bookstore/payment/bookstore_payment_widgets/payment_autobuy_card.dart';
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

  /// 자동구매 체크 — 체크하고 구매하면 결제창 대신 카드 등록창을 연다
  bool _autoBuy = false;
  PassSubscription _subscription = PassSubscription();

  String get _studentId => Get.find<UserDataController>().userData.stuId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      passPaymentInitService(_studentId);
      _loadSiblings();
      _loadSubscription();
    });
  }

  Future<void> _loadSubscription() async {
    final sub = await passSubscriptionStatusService(_studentId);
    if (!mounted) return;
    setState(() {
      _subscription = sub;
      if (sub.isLive) _autoBuy = false;
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

  Future<void> _onProductTap(PassProduct product) => _autoBuy
      ? _openBilling(product)
      : _startPayment(() => passPrepareService(_studentId, product));

  // 자동구매는 형제도 같은 카드 등록창으로 연다 — 형제가 있으면 누구를 묶을지 서버 화면이 먼저 묻는다
  Future<void> _onSiblingProductTap(PassProduct product) => _autoBuy
      ? _openBilling(product)
      : _startPayment(() => passPrepareGroupService(
            _studentId,
            _siblings.map((s) => s.studentId).toSet().toList(), // 같은 학생이 두 번 오면 두 번 결제되지 않게
            product,
          ));

  /// 자동구매 카드 등록창. 등록이 끝나면 서버가 바로 첫 결제까지 한다.
  Future<void> _openBilling(PassProduct product) async {
    if (_preparing) return;
    setState(() => _preparing = true);
    try {
      final result = await Navigator.of(context).push<PassCheckoutResult>(
        MaterialPageRoute(
          builder: (_) => BookstoreCheckoutScreen.billing(
            studentId: _studentId,
            productCode: product.productCode,
            amount: product.price,
            productName: product.productName,
          ),
        ),
      );
      if (result == null || !mounted) return;

      if (result.isSuccess || result.status == 'billing_pending' || result.status == 'billing_fail') {
        await Future.wait([passPaymentRefreshService(_studentId), bookstoreMainService(_studentId), _loadSubscription()]);
      }
      if (result.isSuccess) {
        failDialog1('자동구매 등록 완료', '카드가 등록되고 이용권이 충전되었습니다.\n남은 이용권 ${result.remain}회\n이용권을 다 쓰면 같은 카드로 자동 구매돼요.');
      } else if (result.status == 'billing_pending') {
        // 카드 등록 창은 카드만 등록한다 — 첫 결제는 1~2분 뒤 서버 배치가 낸다
        failDialog1('자동구매 등록 완료', '카드가 등록되었습니다.\n1~2분 안에 결제되고 이용권이 충전돼요.');
      } else if (result.status == 'billing_fail') {
        failDialog1('결제 실패', '카드는 등록됐지만 첫 결제가 되지 않았습니다.\n카드 한도나 상태를 확인해주세요.');
      } else if (result.status == 'fail') {
        failDialog1('카드 등록 실패', result.message ?? '카드 등록이 완료되지 않았습니다.');
      }
    } finally {
      if (mounted) setState(() => _preparing = false);
    }
  }

  void _cancelSubscription() {
    final id = _subscription.subscriptionId;
    if (id == null) return;
    confirmDialog(
      '자동구매를 해지할까요?',
      '이미 구매한 이용권은 그대로 쓸 수 있어요.\n해지하면 이용권이 떨어져도 자동으로 구매되지 않아요.',
      () async {
        setState(() => _preparing = true);
        final error = await passSubscriptionCancelService(_studentId, id);
        if (!mounted) return;
        setState(() => _preparing = false);
        if (error != null) {
          failDialog1('자동구매 안내', error);
          return;
        }
        await _loadSubscription();
        failDialog1('자동구매 안내', '자동구매가 해지되었습니다.');
      },
      confirmText: '해지하기',
      cancelText: '아니요',
    );
  }

  Future<void> _retrySubscription() async {
    final id = _subscription.subscriptionId;
    if (id == null || _preparing) return;
    setState(() => _preparing = true);
    final error = await passSubscriptionRetryService(_studentId, id);
    if (!mounted) return;
    setState(() => _preparing = false);
    await Future.wait([passPaymentRefreshService(_studentId), bookstoreMainService(_studentId), _loadSubscription()]);
    failDialog1('자동구매 안내', error ?? '결제가 완료되어 자동구매를 다시 시작했습니다.');
  }

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
                    // 이미 자동구매 중이면 체크박스를 숨긴다 — 같은 학생으로 두 번 등록되지 않게
                    autoBuy: _autoBuy,
                    onAutoBuyChanged: _subscription.isLive ? null : (v) => setState(() => _autoBuy = v),
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
    if (!_subscription.isLive) {
      return PaymentRemainCard(remain: c.remain);
    }
    return Column(
      children: [
        PaymentAutoBuyCard(
          subscription: _subscription,
          disabled: _preparing,
          onCancel: _cancelSubscription,
          onRetry: _retrySubscription,
        ),
        Expanded(child: PaymentRemainCard(remain: c.remain)),
      ],
    );
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
