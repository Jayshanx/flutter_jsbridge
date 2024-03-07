import 'dart:convert';

import 'mixin.dart';

/// 普通方法定义
/// [client] 调用者
/// [args] js 传递的参数
///
typedef WebViewNormalFunction = Future<R> Function(WebViewContextProvider client, Map<String, dynamic> args);

///监听方法
typedef WebViewListenFunction = void Function();

///flutter内部的参数传递
class R {
  R._({
    this.code = 0,
    this.message = '',
    this.data = const {},
  });

  final int code;
  final String message;
  final Map<String, dynamic> data;

  factory R.success({
    Map<String, dynamic> data = const {},
  }) {
    return R._(
      code: 0,
      message: 'success',
      data: data,
    );
  }

  factory R.fail({
    String message = 'fail',
    int code = -1,
  }) {
    return R._(code: code, message: 'fail', data: {
      'errMsg': message,
      'errCode': code,
    });
  }

  @override
  String toString() {
    return 'code=$code,message=$message,data=$data';
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        'data': data,
      };
}

///js 请求model
class RequestProtocol {
  String type;

  /// 方法名
  String method;

  /// 参数 string map
  Map<String, dynamic> params;

  String? callbackId;

  RequestProtocol({
    required this.type,
    required this.method,
    this.params = const {},
    this.callbackId,
  });

  /// jsonEncode方法中会调用实体类的这个方法。如果实体类中没有这个方法，会报错。
  Map<String, dynamic> toJson() => {
        'type': type,
        'method': method,
        'params': params,
        'callbackId': callbackId,
      };

  /// jsonDecode(jsonStr)方法返回的是Map<String, dynamic>类型，需要这里将map转换成实体类
  factory RequestProtocol.fromMap(Map<String, dynamic> json) {
    RequestProtocol jsonModel = RequestProtocol(
      type: json['type'] as String,
      method: json['method'] as String,
      params: (json['params'] ?? {}).cast<String, dynamic>(),
      callbackId: json['callbackId'] as String?,
    );
    return jsonModel;
  }

  @override
  String toString() {
    return "{type: $type,method: $method, params: $params, callbackId: $callbackId}";
  }

  factory RequestProtocol.parseJson(String jsonString) {
    return RequestProtocol.fromMap(jsonDecode(jsonString));
  }

  String get encode => jsonEncode(this);
}

/// flutter 返回 model
class ResponseProtocol {
  Map<String, dynamic> data;
  int code;
  String? callbackId;
  String? message;

  ResponseProtocol({
    this.data = const {},
    this.code = 0,
    this.callbackId,
    this.message,
  });

  factory ResponseProtocol.fromRequest(RequestProtocol request, R r) {
    return ResponseProtocol(
      data: r.data,
      code: r.code,
      callbackId: request.callbackId,
      message: r.message,
    );
  }

  String get encode => jsonEncode(this);

  @override
  String toString() {
    return "{code: $code, data: $data, callbackId: $callbackId,message: $message}";
  }

  /// jsonEncode方法中会调用实体类的这个方法。如果实体类中没有这个方法，会报错。
  Map<String, dynamic> toJson() => {
        'data': data,
        'code': code,
        'callbackId': callbackId,
        'message': message,
      };
}
