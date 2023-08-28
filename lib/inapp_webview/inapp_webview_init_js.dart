var inAppWebViewInitJs = '''
(function () {
    if (window.jsBridge) {
        return;
    }

    const fBridge = window.flutter_inappwebview;
    var _kUploadTaskInstanceId = 0;
    var _kUploadTaskId = 'kUploadTaskId';
    var _kUploadTaskName = 'kUploadTaskName';
    var _kUploadTasks = {};

    // js call Flutter func
    function callFlutterFunc(funcName, params, success, fail) {
        if (funcName) {
            try {
                if (!fBridge) {
                    if (success || fail) {
                        fail && fail({
                            errCode: -1,
                            errMsg: 'please running at host app'
                        })
                    } else {
                        return Promise.reject({
                            errCode: -1,
                            errMsg: 'please running at host app'
                        });
                    }

                    return;
                }

                params = (params == null) ? {} : params;
                if ('uploadFile' == funcName) {
                    ++_kUploadTaskInstanceId;
                    let taskId = 'Task_ID_' + _kUploadTaskInstanceId;
                    let uploadTask = UploadTask();
                    uploadTask.taskId = taskId;
                    _kUploadTasks[taskId] = uploadTask;
                    params[_kUploadTaskId] = taskId;
                    fBridge.callHandler(funcName, params).then(function (res) {
                        if (res) {
                            if (res.code == 0) {
                                success && success(res.data)
                            } else {
                                fail && fail(res.data)
                            }
                        }

                        delete _kUploadTasks[taskId];
                    });
                    return uploadTask;
                }

                if (success || fail) {
                    fBridge.callHandler(funcName, params).then(function (res) {
                        if (res) {
                            if (res.code == 0) {
                                success && success(res.data)
                            } else {
                                fail && fail(res.data)
                            }
                        }
                    });
                } else {
                    //promise
                    return new Promise(function (resolve, reject) {
                        fBridge.callHandler(funcName, params).then(function (res) {
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
                            errMsg: `jsBridge: callFlutterFunc \${funcName} failed >>` + err
                        }))
                    })
                }

            } catch (exception) {
                if (typeof console != 'undefined') {
                    console.log(`jsBridge: callFlutterFunc \${funcName} failed >>` + exception);
                }

                if (success || fail) {
                    fail && fail({
                        errCode: -1,
                        errMsg: `jsBridge: callFlutterFunc \${funcName} failed >>` + exception
                    })
                } else {
                    return Promise.reject({
                        errCode: -1,
                        errMsg: `jsBridge: callFlutterFunc \${funcName} failed >>` + exception
                    });
                }
            }
        }
    }

    let UploadTask = () => {
        return {
            taskId: '',
            fns: {},
            abort() {
                fBridge.callHandler('cancelUploadFile', {
                    'kUploadTaskId': this.taskId
                });
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

    var jsBridge = window.jsBridge = {
        callFlutterFunc: callFlutterFunc
    };

    jsBridge.list = {};
    jsBridge.on = function (key, fn) {
        (this.list[key] || (this.list[key] = [])).push(fn)
        fBridge.callHandler(key, { "key": key });
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

    var doc = document;
    var readyEvent = doc.createEvent('Events');
    readyEvent.initEvent('jsBridgeReady');
    readyEvent.bridge = jsBridge;
    doc.dispatchEvent(readyEvent);
})();
''';
