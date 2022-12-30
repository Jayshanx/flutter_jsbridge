var webViewInitJs = '''(function () {
    if (window.jsBridge) {
        return;
    }

    // response 回调前缀
    var BRIDGE_CALL_KEY = "BRIDGE_CBKEY_";

    var _callbackId = 0;
    // get response from flutter after call flutter
    var responseCallMap = {};

    // js call Flutter func
    function callFlutterFunc(funcName, params, success, fail) {
        if (!funcName) {
            return;
        }

        params = (params == null) ? {} : params;
        ++_callbackId;
        var successCallbackId = BRIDGE_CALL_KEY + 'SUCCESS_' + _callbackId;
        var failCallbackId = BRIDGE_CALL_KEY + 'FAIL_' + _callbackId;
        if (!success && !fail) {
            try {
                FlutterBridge.postMessage(
                    JSON.stringify({
                        type: "normal",
                        method: funcName,
                        params: params,
                        successCallbackId: successCallbackId,
                        failCallbackId: failCallbackId
                    }));
            } catch (exception) {
                if (typeof console != 'undefined') {
                    console.log(`jsBridge: callFlutterFunc \${funcName} failed >>` + exception);
                }

                return Promise.reject(new Error(e));
            }

            return new Promise(function (resolve, reject) {
                responseCallMap[successCallbackId] = resolve;
                responseCallMap[failCallbackId] = reject;
            });
        } else {
            try {
                FlutterBridge.postMessage(
                    JSON.stringify({
                        type: "normal",
                        method: funcName,
                        params: params,
                        successCallbackId: successCallbackId,
                        failCallbackId: failCallbackId
                    }));
            } catch (exception) {
                if (typeof console != 'undefined') {
                    console.log(`jsBridge: callFlutterFunc \${funcName} failed >>` + exception);
                }
            }

            if (success) {
                responseCallMap[successCallbackId] = success;
            }

            if (fail) {
                responseCallMap[failCallbackId] = fail;
            }
        }
    }

    // flutter success response to js
    function successResponseFromFlutter(msgJson) {
        let callbackId = msgJson.successCallbackId;
        let callBack = responseCallMap[callbackId];
        if (callBack) {
            try {
                callBack(msgJson.data);
            } catch (exception) {
                if (typeof console != 'undefined') {
                    console.log(`jsBridge: responseFromFlutter failed >>` + exception);
                }
            }
        }

        if (callbackId) {
            delete responseCallMap[callbackId];
            var failCallbackId = BRIDGE_CALL_KEY + 'FAIL_' + callbackId.split('_').pop();
            delete responseCallMap[failCallbackId];
        }
    }

    // flutter fail response to js
    function failResponseFromFlutter(msgJson) {
        let callbackId = msgJson.failCallbackId;
        let callBack = responseCallMap[callbackId];
        if (callBack) {
            try {
                callBack(msgJson.data);
            } catch (exception) {
                if (typeof console != 'undefined') {
                    console.log(`jsBridge: responseFromFlutter failed >>` + exception);
                }
            }
        }

        if (callbackId) {
            delete responseCallMap[callbackId];
            var successCallbackId = BRIDGE_CALL_KEY + 'SUCCESS_' + callbackId.split('_').pop();
            delete responseCallMap[successCallbackId];
        }
    }


    var jsBridge = window.jsBridge = {
        successResponseFromFlutter: successResponseFromFlutter,
        failResponseFromFlutter: failResponseFromFlutter,
        callFlutterFunc: callFlutterFunc
    };

    jsBridge.list = {};
    jsBridge.on = function (key, fn) {
        FlutterBridge.postMessage(
            JSON.stringify({
                type: "listen",
                method: key,
                params: {}
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
    var readyEvent = doc.createEvent('Events');
    readyEvent.initEvent('jsBridgeReady');
    readyEvent.bridge = jsBridge;
    doc.dispatchEvent(readyEvent);
})();
''';
