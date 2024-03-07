import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../common/mixin.dart';
import '../common/model.dart';
import '../common/webview_call_js_handler.dart';
import '../common/webview_function_handler.dart';
import '../common/webview_listener_handler.dart';

///
///用于分发js端传递
///
class WebViewBridgeDispatcher with WebViewContextProvider {
  ///监听方法
  WebViewListenHandler get _listenerHandler => WebViewListenHandler.of(this);

  ///普通方法
  WebViewFunctionHandler get _functionHandler => WebViewFunctionHandler.of(this);

  WebViewCallJsHandler get jsClient => WebViewCallJsHandler.of(this);

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
    _listenerHandler.dispose(this);
    _functionHandler.dispose(this);
  }

  @override
  void evaluateJavascript(String script) {
    _webController.runJavaScript(script);
  }

  /// 处理javascript的调用函数
  void onMessageReceived(JavaScriptMessage javaScriptMessage) async {
    debugPrint("javaScriptMessage======${javaScriptMessage.message}");
    var request = ProtocolPayload.parseJson(javaScriptMessage.message);
    var type = request.type;
    var method = request.method;
    if (type == 'listen') {
      //监听方法
      var listenFun = _listenerHandler.listenFunctions[method];
      if (listenFun == null) {
        return;
      }

      listenFun.call();
    } else if (type == 'normal') {
      //普通方法
      WebViewNormalFunction? func = {
        ..._functionHandler.normalFunctions,
        ..._listenerHandler.listenStateFunctions,
      }[method];

      if (func == null) {
        return;
      }

      try {
        R response = await func.call(this, request.data);
        var res = ProtocolPayload.fromRequest(request, response).encode;
        evaluateJavascript("jsBridge.responseFromFlutter($res)");
      } catch (e) {
        var res = ProtocolPayload.fromRequest(
          request,
          R.fail(
            message: e.toString(),
          ),
        ).encode;
        evaluateJavascript("jsBridge.responseFromFlutter($res)");
      }
    } else if (type == 'response') {
      jsClient.handleCallBack(this, request);
    }
  }
}
