var inAppWebViewInitJs = '''
(function () {
    if (window.jsBridge) {
        return;
    }
    
    // js call Flutter func
    function callFlutterFunc(funcName, params, success, fail) {
        if (funcName) {
            try {
                params = (params == null) ? {} : params;
                if (window.flutter_inappwebview) {
                    if (!success && !fail) {
                        //promise
                        return new Promise(function (resolve, reject) {
                            window.flutter_inappwebview.callHandler(funcName, params).then(function (res) {
                                if (res) {
                                    if (res.code == 0) {
                                        resolve(res.data)
                                    } else {
                                        reject(res.data)
                                    }
                                } else {
                                    resolve({})
                                }
                            }).catch(err => reject({
                                errCode: -1,
                                errMsg: 'please running at app'
                            }))
                        })
                    } else {
                        window.flutter_inappwebview.callHandler(funcName, params).then(function (res) {
                            if (res) {
                                if (res.code == 0) {
                                    success && success(res.data)
                                } else {
                                    fail && fail(res.data)
                                }
                            }
                        });
                    }
                } else {
                    if (!success && !fail) {
                        return new Promise(function (resolve, reject) {
                            reject({
                                errCode: -1,
                                errMsg: 'please running at app'
                            })
                        })
                    } else {
                        fail && fail({
                            errCode: -1,
                            errMsg: 'please running at app'
                        })
                    }
                }
            } catch (exception) {
                if (typeof console != 'undefined') {
                    console.log(`jsBridge: callFlutterFunc \${funcName} failed >>` + exception);
                }

                if (!success && !fail) {
                    return new Promise(function (resolve, reject) {
                        reject({
                            errCode: -1,
                            errMsg: 'please running at app'
                        })
                    })
                } else {
                    fail && fail({
                        errCode: -1,
                        errMsg: `jsBridge: callFlutterFunc \${funcName} failed >>` + exception
                    })
                }
            }
        }
    }

    var jsBridge = window.jsBridge = {
        callFlutterFunc: callFlutterFunc
    };

    jsBridge.list = {};
    jsBridge.on = function (key, fn) {
        (this.list[key] || (this.list[key] = [])).push(fn)
        window.flutter_inappwebview.callHandler(key, {});
    }

    jsBridge.emit = function () {
        let _this = this;
        let event = [].shift.call(arguments);
        let fns = [..._this.list[event]];
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
