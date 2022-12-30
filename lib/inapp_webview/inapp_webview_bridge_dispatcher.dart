import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../common/mixin.dart';
import '../common/webview_function_handler.dart';
import '../common/webview_listener_handler.dart';

///
///用于分发js端传递
///
class InAppWebViewBridgeDispatcher with WebViewContextProvider {
  ///监听方法
  WebViewListenHandler get listenerHandler => WebViewListenHandler.of(this);

  ///普通方法
  WebViewFunctionHandler get functionHandler => WebViewFunctionHandler.of(this);

  late InAppWebViewController _webController;

  @override
  final WebViewContextStateMixin webContext;

  InAppWebViewBridgeDispatcher._(this.webContext);

  factory InAppWebViewBridgeDispatcher.of(WebViewContextStateMixin webViewContext) {
    return InAppWebViewBridgeDispatcher._(webViewContext);
  }

  void setController(InAppWebViewController controller) {
    _webController = controller;
    initJsHandler();
  }

  ///注册JavaScriptHandler
  void initJsHandler() {
    var functions = {
      ...functionHandler.normalFunctions,
      ...listenerHandler.listenStateFunctions,
    };

    //注册普通方法
    functions.forEach((key, value) {
      _webController.addJavaScriptHandler(
        handlerName: key,
        callback: (args) => value.call(this, args.first),
      );
    });

    //注册监听方法
    listenerHandler.listenFunctions.forEach((key, value) {
      _webController.addJavaScriptHandler(handlerName: key, callback: (_) => value.call());
    });
  }

  @override
  void evaluateJavascript(String script) {
    _webController.evaluateJavascript(source: script);
  }

  @override
  void dispose() {
    listenerHandler.dispose(this);
    functionHandler.dispose(this);
  }
}
