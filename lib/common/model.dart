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

class ProtocolPayload {
  final Map<String, dynamic> data;
  final int code;
  final String? callbackId;
  final String? message;
  final String? type;
  final String? method;

  ProtocolPayload({
    this.data = const {},
    this.code = 0,
    this.callbackId,
    this.message,
    this.method,
    this.type,
  });

  String get encode => jsonEncode(this);

  factory ProtocolPayload.parseJson(String jsonString) {
    return ProtocolPayload.fromMap(jsonDecode(jsonString));
  }

  factory ProtocolPayload.fromMap(Map<String, dynamic> json) {
    ProtocolPayload jsonModel = ProtocolPayload(
      type: json['type'] as String?,
      method: json['method'] as String,
      data: (json['data'] ?? {}).cast<String, dynamic>(),
      callbackId: json['callbackId'] as String?,
      code: (json['code'] as int?) ?? 0,
      message: json['message'],
    );
    return jsonModel;
  }

  factory ProtocolPayload.fromRequest(ProtocolPayload request, R r) {
    return ProtocolPayload(
      data: r.data,
      code: r.code,
      callbackId: request.callbackId,
      message: r.message,
      type: request.type,
      method: request.method,
    );
  }

  @override
  String toString() {
    return "{code: $code, data: $data, callbackId: $callbackId,message: $message,method:$method,type:$type}";
  }

  Map<String, dynamic> toJson() => {
        'data': data,
        'code': code,
        'callbackId': callbackId,
        'message': message,
        'method': method,
        'type': type,
      };
}
