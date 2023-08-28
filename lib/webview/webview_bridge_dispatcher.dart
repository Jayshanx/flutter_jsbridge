import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../common/mixin.dart';
import '../common/model.dart';
import '../common/webview_function_handler.dart';
import '../common/webview_listener_handler.dart';

///
///用于分发js端传递
///
class WebViewBridgeDispatcher with WebViewContextProvider {
  ///监听方法
  WebViewListenHandler get listenerHandler => WebViewListenHandler.of(this);

  ///普通方法
  WebViewFunctionHandler get functionHandler => WebViewFunctionHandler.of(this);

  @override
  final WebViewContextStateMixin webContext;

  late WebViewController _webController;

  WebViewBridgeDispatcher._(this.webContext);

  factory WebViewBridgeDispatcher.of(WebViewContextStateMixin webContext) {
    return WebViewBridgeDispatcher._(webContext);
  }

  void setController(WebViewController controller) {
    _webController = controller;
  }

  @override
  void dispose() {
    listenerHandler.dispose(this);
    functionHandler.dispose(this);
  }

  @override
  void evaluateJavascript(String script) {
    _webController.runJavaScript(script);
  }

  /// 处理javascript的调用函数
  void onMessageReceived(JavaScriptMessage javaScriptMessage) async {
    debugPrint("javaScriptMessage======${javaScriptMessage.message}");
    var request = RequestProtocol.parseJson(javaScriptMessage.message);
    var type = request.type;
    var method = request.method;
    if (type == 'listen') {
      //监听方法
      var listenFun = listenerHandler.listenFunctions[method];
      if (listenFun == null) {
        return;
      }

      listenFun.call();
    } else if (type == 'normal') {
      //普通方法
      WebViewNormalFunction? func = {
        ...functionHandler.normalFunctions,
        ...listenerHandler.listenStateFunctions,
      }[method];

      if (func == null) {
        return;
      }

      try {
        R response = await func.call(this, request.params);
        var res = ResponseProtocol.fromRequest(request, response).encode;
        evaluateJavascript("jsBridge.responseFromFlutter($res)");
      } catch (e) {
        var res = ResponseProtocol.fromRequest(
          request,
          R.fail(
            message: e.toString(),
          ),
        ).encode;
        evaluateJavascript("jsBridge.responseFromFlutter($res)");
      }
    }
  }
}
