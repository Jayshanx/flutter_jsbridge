import 'package:flutter/material.dart';
import 'package:jsbridge_demo/common/mixin.dart' show WebViewContextStateMixin;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'webview_bridge_dispatcher.dart';
import 'webview_init_js.dart';

///
///  flutter 官方提供的webview封装
///  提供jssdk注入
///
class WebViewPage extends StatefulWidget {
  final String? title;
  final String baseUrl;

  const WebViewPage({Key? key, this.title, required this.baseUrl}) : super(key: key);

  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> with WebViewContextStateMixin<WebViewPage> {
  @override
  late String baseUrl = widget.baseUrl;
  late WebViewController _controller;
  late WebViewBridgeDispatcher webViewDispatcher = WebViewBridgeDispatcher.of(this);

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            _controller.runJavaScript(webViewInitJs);
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: webViewDispatcher.onMessageReceived,
      )
      // ..loadRequest(Uri.parse(baseUrl));
      ..loadFlutterAsset('assets/index.html');
    webViewDispatcher.setController(_controller);
  }

  bool showAppbar = true;

  @override
  void setAppbar(bool show) {
    setState(() {
      showAppbar = show;
    });
  }

  @override
  void dispose() {
    super.dispose();
    webViewDispatcher.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showAppbar
          ? AppBar(
              title: const Text('官方插件 webview_flutter'),
            )
          : null,
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
