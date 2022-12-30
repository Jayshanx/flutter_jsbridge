import 'package:flutter/material.dart';

import '../login_page.dart';
import 'mixin.dart';
import 'model.dart';

///
/// 单例-普通方法调用
///
class WebViewFunctionHandler {
  static final WebViewFunctionHandler _instance = WebViewFunctionHandler._();

  final Map<String, WebViewContextProvider> _clients = {};

  WebViewFunctionHandler._();

  late Map<String, WebViewNormalFunction> normalFunctions = {
    'getUserInfo': getUserInfo,
    'login': login,
    'setAppbar': setAppbar,
  };

  factory WebViewFunctionHandler.of(WebViewContextProvider client) {
    if (_instance._clients[client.host] == null) {
      _instance._clients[client.host] = client;
    }
    return _instance;
  }

  ///获取用户信息
  Future<R> getUserInfo(WebViewContextProvider client, Map<String, dynamic> args) async {
    return R.success(
      data: {
        'userId': '1231',
        'userName': 'hello',
      },
    );
  }

  ///跳转页面
  Future<R> login(WebViewContextProvider client, Map<String, dynamic> args) async {
    var context = client.context;
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const LoginPage();
    }));
    return R.success();
  }

  ///设置样式
  Future<R> setAppbar(WebViewContextProvider client, Map<String, dynamic> args) async {
    // var context = client.context;
    // bool mounted = client.mounted;

    bool show = (args['show'] as bool?) ?? true;

    client.webContext.setAppbar(show);
    return R.success();
  }

  void dispose(WebViewContextProvider client) {
    _clients.remove(client.host);
  }
}
