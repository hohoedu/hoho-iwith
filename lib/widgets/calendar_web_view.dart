import 'package:flutter/material.dart';
import 'package:flutter_application/_core/http.dart';
import 'package:flutter_application/widgets/app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 달력 WebView.
///
/// 홈(올패스 수업 달력)과 책방 메인(정독 달력)이 같이 쓴다. 책방 달력은 "내 예약"을 칠해야 해서
/// 서버가 세션의 studentId 를 요구하므로, 결제 WebView와 같은 방식으로 앱이 들고 있는
/// JSESSIONID 를 WebView 쿠키에 옮겨준 뒤 화면을 연다([withBookstoreSession]).
class CalendarWebView extends StatefulWidget {
  final String url;
  final String title;

  /// 호호책방 세션 쿠키를 WebView에 심고 열지 여부. 올패스 달력은 세션이 필요 없다.
  final bool withBookstoreSession;

  const CalendarWebView({
    super.key,
    required this.url,
    this.title = '수업 달력',
    this.withBookstoreSession = false,
  });

  @override
  State<CalendarWebView> createState() => _CalendarWebViewState();
}

class _CalendarWebViewState extends State<CalendarWebView> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final sessionId = bookstoreSessionId;
    if (widget.withBookstoreSession && sessionId != null) {
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
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    if (mounted) setState(() => _controller = controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: widget.title),
      body: Stack(
        children: [
          if (_controller != null) WebViewWidget(controller: _controller!),
          if (_isLoading)
            Container(
              decoration: BoxDecoration(color: Colors.white),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
