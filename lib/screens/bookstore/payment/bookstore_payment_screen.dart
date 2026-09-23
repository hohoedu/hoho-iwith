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
import 'package:flutter_application/screens/bookstore/payment/bookstore_payment_widgets/payment_sibling_sheet.dart';
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
    WidgetsBinding.instance
        .addPostFrameCallback((_) => passPaymentInitService(_studentId));
  }

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1 && !_manageLoaded) {
      _manageLoaded = true;
      passManageInitService(_studentId);
    }
  }

  // ── 결제 ──
  Future<void> _onProductTap(PassProduct product) async {
    if (_preparing) return;
    setState(() => _preparing = true);
    try {
      final prepared = await _prepare(product);
      if (prepared == null) return;
      await _openCheckout(prepared);
    } on PassPaymentException catch (e) {
      failDialog1('결제 안내', e.message);
    } catch (e) {
      Logger().d('BookstorePaymentScreen._onProductTap exception: $e');
      failDialog1('결제 안내', '잠시 후 다시 시도해주세요.');
    } finally {
      if (mounted) setState(() => _preparing = false);
    }
  }

  Future<PassPrepareResult?> _prepare(PassProduct product) async {
    final siblings = await passSiblingsService(_studentId);

    if (siblings.length <= 1) {
      return passPrepareService(_studentId, product);
    }
    if (!mounted) return null;

    final selected = await showPaymentSiblingSheet(
      context: context,
      siblings: siblings,
      myStudentId: _studentId,
      unitPrice: product.price,
    );
    if (selected == null || selected.isEmpty) return null;

    if (selected.length == 1) {
      // 본인 한 명만 골랐어도 그룹 주문을 만들 이유가 없다.
      return passPrepareService(selected.first, product);
    }
    return passPrepareGroupService(_studentId, selected, product);
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
            (p) => p.totalCount <= 1
                ? PaymentTrialCard(
                    product: p,
                    disabled: _preparing,
                    onPurchase: () => _onProductTap(p),
                  )
                : PaymentPassCard(
                    product: p,
                    disabled: _preparing,
                    onPurchase: () => _onProductTap(p),
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
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        PaymentRemainCard(remain: c.remain),
        PaymentHistoryList(histories: c.histories),
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
