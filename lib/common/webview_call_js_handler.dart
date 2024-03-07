import 'dart:async';

import 'mixin.dart';
import 'model.dart';

final Map<String, Completer<Map<String, dynamic>?>> _callBackIdCompleterMap = {};

class WebViewCallJsHandler {
  final WebViewContextProvider _client;

  WebViewCallJsHandler._(this._client);

  factory WebViewCallJsHandler.of(WebViewContextProvider client) {
    return WebViewCallJsHandler._(client);
  }

  void handleCallBack(WebViewContextProvider client, RequestProtocol requestProtocol) {
    var key = '${requestProtocol.method}_${client.hashCode}';
    var completer = _callBackIdCompleterMap[key];
    if (completer != null) {
      completer.complete(requestProtocol.params);
      _callBackIdCompleterMap.remove(key);
    }
  }

  Future<Map<String, dynamic>?> _evaluateJavascript(String functionName, Map<String, dynamic> params) async {
    final Completer<Map<String, dynamic>?> completer = Completer<Map<String, dynamic>?>();
    var requestProtocol = RequestProtocol(
      method: functionName,
      params: params,
      type: '',
    ).encode;
    _client.evaluateJavascript('jsBridge.callJsFuncFromFlutter("$functionName",$requestProtocol)');
    _callBackIdCompleterMap['${functionName}_${_client.hashCode}'] = completer;
    return completer.future;
  }

  Future<Map<String, dynamic>?> callJsFunc(String functionName, Map<String, dynamic> params) =>
      _evaluateJavascript(functionName, params);

  Future<Map<String, dynamic>?> getJsInfo(Map<String, dynamic> param) {
    return _evaluateJavascript("getJsInfo", param);
  }
}
