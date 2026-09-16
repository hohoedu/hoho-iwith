import 'package:flutter/material.dart';
import 'package:flutter_application/models/payment/pass_payment_data.dart';
import 'package:flutter_application/models/user/user_data.dart';
import 'package:flutter_application/screens/bookstore/payment/pass_checkout_screen.dart';
import 'package:flutter_application/screens/bookstore/payment/pass_payment_widgets/pass_history_list.dart';
import 'package:flutter_application/screens/bookstore/payment/pass_payment_widgets/pass_product_list.dart';
import 'package:flutter_application/screens/bookstore/payment/pass_payment_widgets/pass_remain_card.dart';
import 'package:flutter_application/screens/bookstore/payment/pass_payment_widgets/pass_sibling_sheet.dart';
import 'package:flutter_application/services/bookstore/bookstore_main_service.dart';
import 'package:flutter_application/services/bookstore/bookstore_payment_service.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// 호호책방 이용권 결제 화면 (일시불).
///
/// 흐름: 상품 선택 → (형제가 있으면) 결제할 학생 선택 → 주문 발급 → 결제창(WebView)
///      → 승인 결과 수신 → 잔여/내역 새로고침.
class PassPaymentScreen extends StatefulWidget {
  const PassPaymentScreen({super.key});

  @override
  State<PassPaymentScreen> createState() => _PassPaymentScreenState();
}

class _PassPaymentScreenState extends State<PassPaymentScreen> {
  final PassPaymentController controller =
      Get.put(PassPaymentController(), permanent: true);

  /// 결제창을 여는 중 중복 탭을 막는다 — 두 번 누르면 주문이 두 개 생긴다.
  bool _preparing = false;

  String get _studentId => Get.find<UserDataController>().userData.stuId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => passPaymentInitService(_studentId));
  }

  // ── 결제 ──

  Future<void> _onProductTap(PassProduct product) async {
    if (_preparing) return;
    setState(() => _preparing = true);
    try {
      final prepared = await _prepare(product);
      if (prepared == null) return; // 형제 선택에서 취소
      await _openCheckout(prepared);
    } on PassPaymentException catch (e) {
      failDialog1('결제 안내', e.message);
    } catch (e) {
      Logger().d('PassPaymentScreen._onProductTap exception: $e');
      failDialog1('결제 안내', '잠시 후 다시 시도해주세요.');
    } finally {
      if (mounted) setState(() => _preparing = false);
    }
  }

  /// 형제가 없으면 단건, 있으면 선택된 학생들로 묶음결제 주문을 만든다.
  /// 이 갈림길만 빼면 이후 흐름(결제창 → 승인 → 이탈 처리)은 완전히 같다.
  Future<PassPrepareResult?> _prepare(PassProduct product) async {
    final siblings = await passSiblingsService(_studentId);

    if (siblings.length <= 1) {
      return passPrepareService(_studentId, product);
    }
    if (!mounted) return null;

    final selected = await showPassSiblingSheet(
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
        builder: (_) => PassCheckoutScreen(
          studentId: _studentId,
          orderNo: prepared.orderNo,
          amount: prepared.amount,
          productName: prepared.productName,
        ),
      ),
    );
    if (result == null || !mounted) return;

    if (result.isSuccess) {
      // 이용권이 늘었으니 결제 화면과 책방 메인(남은 횟수 표시) 둘 다 갱신한다.
      await passPaymentRefreshService(_studentId);
      await bookstoreMainService(_studentId);
      failDialog1('결제 완료', '이용권이 충전되었습니다.\n남은 이용권 ${result.remain}회');
    } else if (result.status == 'fail') {
      failDialog1('결제 실패', result.message ?? '결제가 완료되지 않았습니다.');
    }
    // cancel: 사용자가 스스로 닫은 것이므로 아무 안내도 띄우지 않는다.
  }

  // ── 화면 ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: const MainAppBar(title: '이용권 결제'),
      body: GetBuilder<PassPaymentController>(
        init: controller,
        builder: (c) {
          if (c.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c.isFailed) {
            return _errorView();
          }
          return RefreshIndicator(
            onRefresh: () => passPaymentInitService(_studentId),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                PassRemainCard(remain: c.remain),
                PassProductList(
                  products: c.products,
                  disabled: _preparing,
                  onTap: _onProductTap,
                ),
                PassHistoryList(histories: c.histories),
              ],
            ),
          );
        },
      ),
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
