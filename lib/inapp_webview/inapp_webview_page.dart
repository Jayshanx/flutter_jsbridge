import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:jsbridge_demo/common/mixin.dart' show WebViewContextStateMixin;

import 'inapp_webview_bridge_dispatcher.dart';
import 'inapp_webview_init_js.dart';

///
///  flutter_inappwebview 封装
///  提供jssdk注入
///
class InAppWebViewPage extends StatefulWidget {
  final String? title;
  final String baseUrl;

  const InAppWebViewPage({Key? key, this.title, required this.baseUrl}) : super(key: key);

  @override
  InAppWebViewPageState createState() => InAppWebViewPageState();
}

class InAppWebViewPageState extends State<InAppWebViewPage> with WebViewContextStateMixin {
  GlobalKey webViewKey = GlobalKey();

  @override
  late String baseUrl = widget.baseUrl;

  late final InAppWebViewBridgeDispatcher webViewDispatcher = InAppWebViewBridgeDispatcher.of(this);

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
              title: const Text('社区插件 flutter_inappwebview'),
            )
          : null,
      body: InAppWebView(
        key: webViewKey,
        initialFile: 'assets/index.html',
        // initialUrlRequest: URLRequest(url: WebUri(baseUrl)),
        initialSettings: InAppWebViewSettings(
          applicationNameForUserAgent: 'Custom/1.0.0',
          mediaPlaybackRequiresUserGesture: true,
          useShouldOverrideUrlLoading: false,
          cacheEnabled: true,
          javaScriptEnabled: true,
          javaScriptCanOpenWindowsAutomatically: true,
          allowUniversalAccessFromFileURLs: true,
          useShouldInterceptFetchRequest: false,
          allowFileAccessFromFileURLs: true,
          supportZoom: false,
          clearCache: false,
          textZoom: 100,
          disableContextMenu: true,
          verticalScrollBarEnabled: false,
          preferredContentMode: UserPreferredContentMode.MOBILE,
          useOnDownloadStart: false,
          initialScale: 0,
          databaseEnabled: false,
          useHybridComposition: true,
          allowFileAccess: true,
          allowContentAccess: true,
          useShouldInterceptRequest: false,
          mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          cacheMode: CacheMode.LOAD_DEFAULT,
          //
          allowsInlineMediaPlayback: true,
          allowsPictureInPictureMediaPlayback: true,
          allowsAirPlayForMediaPlayback: true,
          maximumZoomScale: 1,
          minimumZoomScale: 1,
          alwaysBounceVertical: false,
          allowsBackForwardNavigationGestures: false,
          disableLongPressContextMenuOnLinks: true,
        ),
        initialUserScripts: UnmodifiableListView<UserScript>([
          UserScript(
            source: inAppWebViewInitJs,
            injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          ),
        ]),
        onWebViewCreated: (InAppWebViewController controller) {
          webViewDispatcher.setController(controller);
        },
        onConsoleMessage: (controller, consoleMessage) {
          debugPrint("console==${consoleMessage.toJson()}");
        },
      ),
    );
  }
}
