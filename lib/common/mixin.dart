import 'package:flutter/material.dart';

///
///一些跟ui有关的方法可以放在这里
///
mixin WebViewContextStateMixin<WebViewStatefulWidgetType extends StatefulWidget> on State<WebViewStatefulWidgetType> {
  ///提供baseUrl
  String get baseUrl;

  ///设置顶部appbar样式
  void setAppbar(bool show);
}

///
/// 提供上下文
///
mixin WebViewContextProvider {
  String get host => Uri.parse(webContext.baseUrl).host;

  BuildContext get context => webContext.context;

  bool get mounted => webContext.mounted;

  WebViewContextStateMixin get webContext;

  void evaluateJavascript(String script);

  void dispose();
}
