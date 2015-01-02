hls-player
===========

HLS：（HTTP Live Streaming）

this project based on [osmf](http://blogs.adobe.com/osmf/) and [osmf-hls-plugin](https://github.com/denivip/osmf-hls-plugin)，is used to playback Apple HLS video streams in Flash video player. 

- support： *.m3u8
- platform：win/mac/ipad/iphone (android？)
- browser： ie6+/chrome/safari/firefox
- flash version： > 10.1

##### How To Use

- build a container for player

```html
    <div id="container"></div>
```
- import api file: /PlayerAPI/playerAPI.js

```html
    <script type="text/javascript" src="./playerAPI.js"></script>
```
- init player

```javascript
    var player = diskPlayer({
        //容器id
        containerId: 'container',
        //flash地址
        src: '/PlayerAPI/DiskPlayer.swf?t=1418721152632',
        //资源地址
        file: 'http://xxx.baidu.com/video.m3u8'
    });
```

##### API List

- player.play()
- player.pause()
- player.seek(num)

    @param {Number} num
- player.getState()

    @returns {String}  'playing' || 'paused' || 'buffering'
- player.getVolume()

    @returns {Number}  0 ~ 100
- player.setVolume(num)

    @param {Number} num 0 ~ 100
- player.getPosition()

    @returns {Number} 0 ~ player.getDuration()
- player.getDuration()

    @returns {Number}
- player.destroy()

player callback list: 

- player.onReady(func)

    @param {Function} func()
- player.onLoad(func)

    @param {Function} func()
- player.onError(func)

    @param {Function} func()
- player.onOver()

    @param {Function} func()
- player.onTime(time, total)

    @param {Function} func(time, total)

##### Demo

```html

<!DOCTYPE>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>diskPlayer 播放示例</title>
        <style type="text/css">
            body {
                margin: 0;
                padding: 0;
            }
            #container {
                width: 800px;
                height: 400px;
            }
        </style>
    </head>
    <body>
        <div id="container">
        
        </div>
        <!-- 导入 api 文件 -->
        <script type="text/javascript" src="./playerAPI.js"></script>
        <script type="text/javascript">
            (function() {
                if (!diskPlayer) {
                    return;
                }
                var player = diskPlayer({
                    //容器id
                    containerId: 'container',
                    //flash地址
                    src: '/DiskPlayer.swf?t=1418721152632',
                    //资源地址
                    file: 'http://xxx.baidu.com/video.m3u8'
                }, function(type, info ,msg) {
                    //错误回调
                    if (type === 0) {
                        //标识是 ipad/iphone， 注意相关接口的兼容性
                    } else if (type === 1) {
                        //flash 没有安装 或 版本过低，> 10.1  info 为当前版本
                        //在此处可以添加相关 flash 引导
                    }
                });
                //播放回调
                player.onTime(function(time, total){
                    
                });
                player.onReady(function() {
                    console.log('onReady， 资源文件加载成功');
                });
                player.onLoad(function() {
                    console.log('onLoad， 播放器初始化完成');
                });
                player.onOver(function() {
                    console.log('onOver， 播放结束');
                });
            })();
        </script>
    </body>
</html>

````

##### How To Build

- UI： 

  /PlayerUI/src/PlayerUI.fla
- Source：

  /OSMF   /HLSPlugin   /DiskPlayer
- API：

  PlyerAPI

##### Links

- [osmf] (http://blogs.adobe.com/osmf/)
- [osmf-hls-plugin] (https://github.com/denivip/osmf-hls-plugin)

##### Todo List

- 修复在ipad/iphone 端的接口和以上接口保持一致
- 添加 autostart 参数
