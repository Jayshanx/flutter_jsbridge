var webViewInitJs = '''
(function () {
    if (window.jsBridge) {
        return;
    }

    const _kNormal = 'normal';
    const _kListen = 'listen';

    const _kUploadTaskId = 'kUploadTaskId';
    const _kUploadTaskName = 'kUploadTaskName';
    var _kUploadTasks = {};
    var _kUploadTaskInstanceId = 0;

    // response callback prefix
    const _kSuccessPrefix = "SuccessKey_";
    const _kFailKeyPrefix = "FailKey_";

    var _kCallbackId = 0;
    var kResponseCallMap = {};
    
    // funcs of javascript registered for native
    var kRegisterJsFuncMap = {};
    
    //[Js] register js func for Flutter call
    function registerFuncForJs(funcName, func) {
        kRegisterJsFuncMap[funcName] = func;
    }
    
    //[Dart] flutter call js func
    function callJsFuncFromFlutter(funcName, msg) {
        console.log(`callJsFuncFromFlutter = \${JSON.stringify(msg)}`);
        var responseCall = null;
        var registerJsFunc = kRegisterJsFuncMap[funcName];
           
        responseCall = function (_thisFuncName, responseData) {
            sendResponseToFlutter(_thisFuncName, responseData);
        }
                
        if (registerJsFunc) {
            try {
                registerJsFunc(msg.data, responseCall);
            } catch (exception) {
                console.log("call registerJsFunc error");
                if (typeof console != 'undefined') {
                    console.log(`jsBridge: callJsFuncFromFlutter \${funcName} failed >>` + exception);
                }
            }
        } else {
          console.log(`jsBridge: callJsFuncFromFlutter \${funcName} not register`);
          FlutterBridge.postMessage(
                JSON.stringify({
                    type: 'response',
                    data: null,
                    method: funcName,
                    code: -1,
                    message: `\${funcName} not register`
                })
            );
        }
    }
    
    //[Js] flutter -> js -> 【flutter】js response data to flutter
    function sendResponseToFlutter(funcName, response) {
        try {
            FlutterBridge.postMessage(
                JSON.stringify({
                    type: 'response',
                    data: response,
                    method: funcName,
                    code: 0
                })
            );
        } catch (e) {
            FlutterBridge.postMessage(
                JSON.stringify({
                    type: 'response',
                    data: null,
                    method: funcName,
                    code: -1,
                    message: e
                })
            );
        }
    }

    //[Js] js call Flutter func
    function callFlutterFunc(funcName, params, success, fail) {
        if (!funcName) {
            return;
        }

        params = (params == null) ? {} : params;
        ++_kCallbackId;
        var successCallbackId = _kSuccessPrefix + _kCallbackId;
        var failCallbackId = _kFailKeyPrefix + _kCallbackId;

        if ('uploadFile' == funcName) {
            ++_kUploadTaskInstanceId;
            let uploadTask = UploadTask();
            _kUploadTasks[_kUploadTaskInstanceId] = uploadTask;
            params[_kUploadTaskId] = _kUploadTaskInstanceId;

            try {
                FlutterBridge.postMessage(
                    JSON.stringify({
                        type: _kNormal,
                        method: funcName,
                        data: params,
                        callbackId: `\${_kCallbackId}`,
                    })
                );

                if (success) {
                    kResponseCallMap[successCallbackId] = success;
                }

                if (fail) {
                    kResponseCallMap[failCallbackId] = fail;
                }
            } catch (exception) {
                if (typeof console != 'undefined') {
                    console.log(`jsBridge: callFlutterFunc \${funcName} failed >>` + exception);
                }
            }

            return uploadTask;
        }

        try {
            FlutterBridge.postMessage(
                JSON.stringify({
                    type: _kNormal,
                    method: funcName,
                    data: params,
                    callbackId: `\${_kCallbackId}`,
                })
            );
        } catch (e) {
            if (typeof console != 'undefined') {
                console.log(`jsBridge: callFlutterFunc \${funcName} failed >>` + exception);
            }

            if (!success && !fail) {
                return Promise.reject({
                    errCode: -1,
                    errMsg: `jsBridge: callFlutterFunc \${funcName} failed >>` + exception
                });
            }
            return;
        }

        if (success || fail) {
            if (success) {
                kResponseCallMap[successCallbackId] = success;
            }

            if (fail) {
                kResponseCallMap[failCallbackId] = fail;
            }
        } else {
            return new Promise(function (resolve, reject) {
                kResponseCallMap[successCallbackId] = resolve;
                kResponseCallMap[failCallbackId] = reject;
            });
        }
    }

    //[Dart] flutter response to js
    function responseFromFlutter(msg) {
        let callbackId = msg.callbackId;
        let code = msg.code;
        let successCallbackId = _kSuccessPrefix + callbackId;
        let failCallbackId = _kFailKeyPrefix + callbackId;

        var callBack;
        if (code == 0) {
            callBack = kResponseCallMap[successCallbackId];
        } else {
            callBack = kResponseCallMap[failCallbackId];
        }

        if (callBack) {
            try {
                callBack(msg.data);
            } catch (exception) {
                if (typeof console != 'undefined') {
                    console.log(`jsBridge: responseFromFlutter failed >>` + exception);
                }
            }
        }

        delete kResponseCallMap[successCallbackId];
        delete kResponseCallMap[failCallbackId];
    }

    var jsBridge = window.jsBridge = {
        callFlutterFunc: callFlutterFunc,
        responseFromFlutter: responseFromFlutter,
        sendResponseToFlutter: sendResponseToFlutter,
        callJsFuncFromFlutter: callJsFuncFromFlutter,
        registerFuncForJs: registerFuncForJs
    };

    let UploadTask = () => {
        return {
            taskId: '',
            fns: {},
            abort() {
                FlutterBridge.postMessage(
                    JSON.stringify({
                        type: _kNormal,
                        method: 'cancelUploadFile',
                        data: {
                            'kUploadTaskId': this.taskId
                        },
                        callbackId: '',
                    })
                );
            },
            onProgressUpdate(listener) {
                this.fns['onProgressUpdate'] = listener;
            },
            offProgressUpdate() {
                delete this.fns['onProgressUpdate'];
            },
            offHeadersReceived() {
                delete this.fns['onHeadersReceived'];
            },
            onHeadersReceived(listener) {
                this.fns['onHeadersReceived'] = listener;
            },
        }
    }

    jsBridge.onUploadFile = function () {
        var args = arguments['0'];
        let id = args[_kUploadTaskId];
        let funName = args[_kUploadTaskName];
        let instance = _kUploadTasks[id];
        if (instance == null) {
            return;
        }
        var fn = instance.fns[funName];
        if (fn == null) {
            return;
        }
        if (typeof fn === 'function') {
            fn(args['data']);
        }
    }

    jsBridge.list = {};
    jsBridge.on = function (key, fn) {
        FlutterBridge.postMessage(
            JSON.stringify({
                type: _kListen,
                method: key,
                data: {}
            })
        );

        (this.list[key] || (this.list[key] = [])).push(fn)
    }

    jsBridge.emit = function () {
        let _this = this;
        let event = [].shift.call(arguments),
            fns = [..._this.list[event]];
        if (!fns || fns.length === 0) {
            return false;
        }
        fns.forEach(fn => {
            fn.apply(_this, arguments);
        });
        return _this;
    }

    var doc = document;
    const readyEvent = new CustomEvent("JSBridgeEvents");
    readyEvent.bridge = jsBridge;
    window.dispatchEvent(readyEvent);
})();
''';
