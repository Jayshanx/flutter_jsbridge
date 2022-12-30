import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'mixin.dart';
import 'model.dart';

///
/// 单例-监听方法
///
class WebViewListenHandler {
  static final WebViewListenHandler _instance = WebViewListenHandler._();

  final Map<String, WebViewContextProvider> _clients = {};

  WebViewListenHandler._();

  factory WebViewListenHandler.of(WebViewContextProvider client) {
    if (_instance._clients[client.host] == null) {
      _instance._clients[client.host] = client;
    }
    return _instance;
  }

  /// 端用于监听的方法
  late Map<String, WebViewListenFunction> listenFunctions = {
    'onNetworkStatusChange': onNetworkStatusChange,
  };

  /// 用于停止监听或者获取瞬时状态的方法
  late Map<String, WebViewNormalFunction> listenStateFunctions = {
    'stopNetworkStatusChange': _stopNetworkStatusChange,
  };

  ///网络连接
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  ///网路变化
  void onNetworkStatusChange() {
    if (_connectivitySubscription != null) {
      return;
    }

    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((res) {
      if (_clients.isNotEmpty) {
        _clients.forEach((key, client) {
          var r = jsonEncode({'status': res.name});
          client.evaluateJavascript('jsBridge.emit("onNetworkStatusChange",$r)');
        });
      } else {
        _connectivitySubscription?.cancel();
        _connectivitySubscription = null;
      }
    });
  }

  ///停止网络监听
  Future<R> _stopNetworkStatusChange(WebViewContextProvider client, Map<String, dynamic> args) async {
    _clients.remove(client.host);
    if (_clients.isEmpty) {
      _connectivitySubscription?.cancel();
      _connectivitySubscription = null;
    }

    return R.success();
  }


  void dispose(WebViewContextProvider client){
    _clients.remove(client.host);
  }
}
