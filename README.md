# flutter wenview jsbridge

flutter webview js端与flutter端的交互

目前 flutter 相关的 jsbridge 也有很多,  本库也参考了许多前辈的写法，并且自己做了一些封装, 提供了一些其他库没有的方法,
也有一些自己的封装思路, 如果读者有其他的想法和建议，欢迎交流

如果只想支持官方插件 `webview_flutter` , 那么只需要删除 `lib/inapp_webview` 整个目录的代码

暂不支持发布到pub.dev, 测试网页在 `assets/index.html`

#### Feat

 - `flutter 3.3.10`
 - 支持 `flutter_inappwebview: ^6.0.0-beta.22` 和 `webview_flutter: ^4.0.1`
 - `context`,`mounted`上下文感知
 - 支持 `回调` 和 `promise` 写法
 - 支持 `js` 监听 `flutter` 方法
 - 提供简单的 js 压缩打包的脚本 `assets/webpack.config.js`


#### Example

```html
<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no">
    <title>jssdkTest</title>
    //重点在这里，如果你自己定制化需要添加一些方法到jssd.js,
    <script type="text/javascript" src="jssdk.js"></script>
    <script>

        //获取用户信息
        function getUserInfoCallback() {
            JSSDK.getUserInfo({
                success: function (res) {
                    document.getElementById("user_info_callback").innerHTML = "用户信息(回调):" + JSON.stringify(res);
                }
            });
        }

        //获取用户信息(Promise)
        function getUserInfo() {
            JSSDK.getUserInfo({}).then(function (res) {
                document.getElementById("user_info").innerHTML = "用户信息(Promise) :" + JSON.stringify(res);
            });
        }

        //跳转登录
        function login() {
            JSSDK.login({});
        }

        //监听网络变化
        function onNetworkStatusChange() {
            JSSDK.onNetworkStatusChange((res) => {
                document.getElementById("network_status").innerHTML = "网络状态 : " + JSON.stringify(res);
            });
        }
    </script>
</head>

<body>
<div>
    <span id="user_info_callback">用户信息(回调) : </span><br><br>
    <span id="user_info">用户信息(Promise) : </span><br><br>
    <span id="network_status">监听网络状态: </span><br><br>
    <br>
    <button style="margin-top: 20px" onclick="getUserInfoCallback()">获取用户信息(回调)</button>
    <br>
    <button style="margin-top: 20px" onclick="getUserInfo()">获取用户信息(promise)</button>
    <br>
    <button style="margin-top: 20px" onclick="login()">跳转登录页面</button>
    <br>
    <button style="margin-top: 20px" onclick="onNetworkStatusChange()">监听网络变化</button>
    <br>
</div>
</body>

</html>

```


