(function () {
    var root = window;
    if (window.JSSDK) {
        return;
    }

    //  普通方法列表
    var JS_SDK_FUNCTION_LIST = [
        'getUserInfo',
        'login',
        'setAppbar',
        'stopNetworkStatusChange',
        'uploadFile'
    ];

    // 监听方法列表
    var JS_SDK_LISTEN_LIST = [
        'onNetworkStatusChange'
    ];

    // 待Dart端调用的方法
    var JS_SDK_DART_CALL = [
        'getJsInfo'
    ]


    var _isFunction = function (obj) {
        return typeof obj == 'function' || false;
    }

    /**
     * 调用原生flutter方法入口
     */
    var _invoke = function (method, obj = {}) {
        if (!method) return
        if (root.jsBridge && root.jsBridge.callFlutterFunc) {
            let success = obj.success;
            let fail = obj.fail;
            if (success && _isFunction(success)) {
                delete obj.success;
            }
            if (fail && _isFunction(fail)) {
                delete obj.fail;
            }

            if (success || fail) {
                //回调方法
                return root.jsBridge.callFlutterFunc(method, obj, success, fail);
            } else {
                //异步方法
                return root.jsBridge.callFlutterFunc(method, obj);
            }
        } else {
            obj && obj.fail && _isFunction(obj.fail) && obj.fail({
                code: 1000, msg: 'jsBridge not exist'
            });
        }
    }

    class JSSDK {
        constructor(obj) {
            if (obj instanceof JSSDK)
                return obj;
            if (!(this instanceof JSSDK))
                return new JSSDK(obj);
        }

        /**
          * 方法注册
          */
        static register() {
            ///注册普通方法
            JS_SDK_FUNCTION_LIST.forEach(function (name) {
                JSSDK[name] = function (obj) {
                    return _invoke(name, obj)
                }
            });

            ///注册监听方法
            JS_SDK_LISTEN_LIST.forEach(function (name) {
                (JSSDK[name] = function (callback) {
                    if (_isFunction(callback)) {
                        root.jsBridge.on(name, (res) => {
                            callback(res)
                        })
                    }
                });
            });

            ///注册Dart端调用方法
            JS_SDK_DART_CALL.forEach(function (name) {
                JSSDK[name] = function (callback) {
                    root.jsBridge.registerFuncForJs(name, (param, responseCall)=>{
                        if (_isFunction(callback)) {
                            var res = callback(param)
                            responseCall(name, res)
                        }
                    })
                };
            });
        }
    }

    JSSDK.register();
    JSSDK.VERSION = '0.0.1';
    window.JSSDK = JSSDK;
})()
