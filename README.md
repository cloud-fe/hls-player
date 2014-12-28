hls-player
===========

HLS  （HTTP Live Streaming）

support： *.m3u8

Demo  /PlayerAPI/index.html


<script type="text/javascript" src="./playerAPI.js"></script>
<script type="text/javascript">
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
</script>