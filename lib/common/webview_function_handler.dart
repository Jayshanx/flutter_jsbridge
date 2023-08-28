import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
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

  ///上传文件的一些参数
  final _cancelTokens = <String, CancelToken>{};
  final String _kUploadTaskId = 'kUploadTaskId';
  final String _kUploadTaskName = 'kUploadTaskName';

  //--

  late Map<String, WebViewNormalFunction> normalFunctions = {
    'getUserInfo': getUserInfo,
    'login': login,
    'setAppbar': setAppbar,
    'uploadFile': uploadFile,
    'cancelUploadFile': cancelUploadFile,
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

  ///上传文件
  Future<R> uploadFile(WebViewContextProvider client, Map<String, dynamic> args) async {
    print("uploadFile====${args}");

    var url = args['url'] as String?;
    var filePath = args['filePath'] as String?;
    // var name = args['name'] as String?;
    // var header = args['header'] as Map<String, dynamic>?;
    // var formData = args['formData'] as Map<String, dynamic>?;
    String uploadTaskId = (args[_kUploadTaskId] ?? '').toString();

    print("url====$url");
    print("filePath====$filePath");

    if (url == null || url.isEmpty) {
      return R.fail(
        code: -1,
        message: 'params [url, filePath] required',
      );
    }

    //根据url获取真实文件
    // File? file = await FileUtils.getFile(
    //   uri,
    //   host: client.host,
    // );
    // if (file == null || !file.existsSync()) {
    //   return R.fail(
    //     code: -1,
    //     message: 'file not exist',
    //   );
    // }

    var cancelToken = CancelToken();
    _cancelTokens[uploadTaskId] = cancelToken;

    try {
      //自定义写文件上传工具类
      // var res = await FileUploadUtils.uploadFile(
      //   url,
      //   file,
      //   headers: header ?? {},
      //   formData: formData ?? {},
      //   name: name,
      //   cancelToken: cancelToken,
      //   onProgress: (count, total) {
      //     var data = <String, dynamic>{
      //       _kUploadTaskId: uploadTaskId,
      //       _kUploadTaskName: 'onProgressUpdate',
      //       'data': {
      //         'progress': (count / total) * 100,
      //         'totalBytesSent': count,
      //         'totalBytesExpectedToSend': total,
      //       }
      //     };
      //     client.evaluateJavascript("jsBridge.onUploadFile(${jsonEncode(data)})");
      //   },
      // );

      //这个地方模拟一下上传进度
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        var data = <String, dynamic>{
          _kUploadTaskId: uploadTaskId,
          _kUploadTaskName: 'onProgressUpdate',
          'data': {
            'progress': ((i + 1) * 10) / 100,
            'totalBytesSent': i + 1,
            'totalBytesExpectedToSend': 10,
          }
        };
        client.evaluateJavascript("jsBridge.onUploadFile(${jsonEncode(data)})");
      }

      return R.success(
        data: {
          "data": {"urlAddress": "http://your.file.address"},
          "statusCode": 200,
        },
      );
    } on DioException catch (error) {
      if (error.type == DioExceptionType.cancel) {
        return R.fail(
          code: -1,
          message: 'upload canceled',
        );
      }

      return R.fail(
        code: error.response?.statusCode ?? -1,
        message: DioExceptionType.cancel.name,
      );
    } catch (e) {
      return R.fail(
        code: -1,
        message: 'upload fail',
      );
    } finally {
      _cancelTokens.remove(uploadTaskId);
    }
  }

  ///取消文件上传
  Future<R> cancelUploadFile(WebViewContextProvider client, Map<String, dynamic> args) async {
    String? uploadTaskId = args[_kUploadTaskId] as String?;
    if (uploadTaskId != null) {
      _cancelTokens[uploadTaskId]?.cancel();
      _cancelTokens.remove(uploadTaskId);
    }

    return R.success();
  }

  void dispose(WebViewContextProvider client) {
    _clients.remove(client.host);
  }
}
