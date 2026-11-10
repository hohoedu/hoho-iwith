import 'package:flutter/material.dart';
import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/models/payment/pass_payment_data.dart';
import 'package:flutter_application/services/bookstore/bookstore_payment_service.dart';
import 'package:flutter_application/widgets/dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 이용권 결제창 (WebView).
///
/// 일반 결제는 미리 발급한 [orderNo]로 결제창을 열고, 자동구매([billingProductCode])는 서버의
/// 카드 등록창을 연다(2026-10-27). 카드 등록창은 형제 선택·주문 발급을 서버가 알아서 하고,
/// 첫 결제는 등록 1~2분 뒤 서버가 낸다. 결과는 둘 다 같은 /payment/done 주소로 돌아온다.
class BookstoreCheckoutScreen extends StatefulWidget {
  final String studentId;
  final String? orderNo;
  final int amount;
  final String productName;

  /// 자동구매 카드 등록이면 상품 코드(BOOK_12 등). null이면 일반 결제
  final String? billingProductCode;

  const BookstoreCheckoutScreen({
    super.key,
    required this.studentId,
    required String this.orderNo,
    required this.amount,
    required this.productName,
  }) : billingProductCode = null;

  const BookstoreCheckoutScreen.billing({
    super.key,
    required this.studentId,
    required String productCode,
    required this.amount,
    required this.productName,
  })  : orderNo = null,
        billingProductCode = productCode;

  @override
  State<BookstoreCheckoutScreen> createState() => _BookstoreCheckoutScreenState();
}

class _BookstoreCheckoutScreenState extends State<BookstoreCheckoutScreen> {
  WebViewController? _controller;
  bool _loading = true;

  /// done 페이지 도달 여부 — true면 닫아도 abandon을 보내지 않는다(이미 끝난 주문이다).
  bool _finished = false;

  String get _doneUrl =>
      '$bookstoreOrigin${dotenv.get('PASS_DONE_URL', fallback: '/payment/done')}';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // 1) 앱이 들고 있는 세션 쿠키를 WebView로 옮긴다
    final sessionId = bookstoreSessionId;
    if (sessionId != null) {
      await WebViewCookieManager().setCookie(
        WebViewCookie(
          name: 'JSESSIONID',
          value: sessionId,
          domain: Uri.parse(bookstoreOrigin).host,
        ),
      );
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: (request) => _onNavigate(request.url),
        ),
      );

    if (widget.billingProductCode != null) {
      // 자동구매 — 서버 카드 등록창. 첫 결제일은 넘기지 않는다(등록 1~2분 뒤 서버가 결제한다)
      final billing = dotenv.get('PASS_BILLING_CHECKOUT_URL', fallback: '/payment/billing/checkout');
      await controller.loadRequest(
        Uri.parse('$bookstoreOrigin$billing?productCode=${Uri.encodeQueryComponent(widget.billingProductCode!)}'),
      );
    } else {
      // 이미 발급된 orderNo로 결제창을 연다 — 여기서 새 주문을 만들지 않는다.
      final checkout = dotenv.get('PASS_CHECKOUT_URL', fallback: '/payment/checkout');
      await controller.loadRequest(
        Uri.parse('$bookstoreOrigin$checkout?orderNo=${widget.orderNo}'),
      );
    }

    if (mounted) setState(() => _controller = controller);
  }

  NavigationDecision _onNavigate(String url) {
    if (url.startsWith(_doneUrl)) {
      _finished = true;
      final params = Uri.parse(url).queryParameters;
      _pop(PassCheckoutResult(
        status: params['status'] ?? 'fail',
        remain: int.tryParse(params['remain'] ?? '') ?? 0,
        message: params['msg'],
      ));
      return NavigationDecision.prevent;
    }

    final scheme = Uri.parse(url).scheme;
    if (scheme != 'http' && scheme != 'https') {
      _launchExternal(url);
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  Future<void> _launchExternal(String url) async {
    try {
      final ok =
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!ok && mounted) failDialog1('결제 안내', '결제 앱을 열 수 없습니다. 설치 여부를 확인해주세요.');
    } catch (_) {
      if (mounted) failDialog1('결제 안내', '결제 앱을 열 수 없습니다. 설치 여부를 확인해주세요.');
    }
  }

  /// 닫기 — 아직 결과 화면에 도달하지 않았으면 서버에 이 주문을 버렸다고 알린다.
  /// 카드 등록창은 앱이 주문번호를 모른다 — 중간에 닫힌 등록 건은 서버 배치가 정리한다.
  Future<void> _close() async {
    if (!_finished && widget.orderNo != null) {
      await passAbandonService(widget.studentId, widget.orderNo!);
    }
    _pop(PassCheckoutResult(status: 'cancel', remain: 0));
  }

  /// 결제창은 Get.to가 아니라 Navigator로 띄운다(결과를 돌려받아야 해서).
  void _pop(PassCheckoutResult result) {
    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // OS 뒤로가기 제스처도 닫기 버튼과 동일하게 abandon을 보내야 한다.
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            '${widget.productName} · ${formatWon(widget.amount)}',
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF6C7176)),
              onPressed: _close,
            ),
          ],
        ),
        body: Stack(
          children: [
            if (_controller != null) WebViewWidget(controller: _controller!),
            if (_loading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
