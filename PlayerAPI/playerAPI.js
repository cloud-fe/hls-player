/**
*   
*   playerAPI.js
*   @author: zhangqian
*   @date: 2014/12/29
*
*/
;(function() {
    
    var doc = document,
        isIE = !!window.ActiveXObject;
    
    var SwfUtil = (function() {
        var uri = '',
            ATTRIBUTES = "width height name id class style title type align tabindex usemap",
            EXPRESS_INSTALL = "expressInstall.swf?" + (+new Date()),
            EXPRESS_INSTALL_ID = 'ExpressInstall',
            isExpressInstallActive = false,
            cacheHTML = '',
            MIN_VERSION = "10.1",
            FLASH_VERSION = (function(){
                var ver, SF = 'ShockwaveFlash', plug;
                if (isIE) {
                    try {
                        ver = new ActiveXObject(SF + '.' + SF).GetVariable('$version');
                        if (ver) ver = ver.split(' ')[1].split(',').join('.');
                    } catch(ex) {}
                } else {
                    plug = navigator.plugins['Shockwave Flash'];
                    if (typeof plug === 'object') ver = plug.description.split(' ')[2];
                }
                return parseFloat(ver);
            })();
        
        /** 生成Flash的HTML(只有src是必传的参数)
         @method: embedSWF
         @param:  {String} id   flash容器的id
         @param:  {Object} opt  参数, 包含src width height id class style align flashvars wmode allowScriptAccess ...
         @return: {String} HTML
         @usage:
            //嵌入
            embedSWF('someId', {
                src: 'path/to/flash.swf',
                width: 640,
                height: 320
            });
            //移除
            embedSWF.destroy('someId');
        **/
        function embedSWF(id, opt){
            var html = '',
                fv,
                dom,
                base,
                error,
                attrs = {
                    type: 'application/x-shockwave-flash',
                    width: '100%',
                    height: '100%'
                },
                params = {
                    wmode: 'transparent',
                    menu: false,
                    allowScriptAccess: 'always'
                };
                
            if (!opt && id) {
                opt = id;
                id = null;
            }
            if (Object.prototype.toString.call(opt) !== '[object Object]' || !opt.src) return;
            if (id) dom = doc.getElementById(id);
        
            (function(arr){
                var i=arr.length, key, obj = {};
                while (i--) {
                    obj[ arr[i] ] = 1;
                }
                for (key in opt) {
                    if (obj[key]) {
                        attrs[key] = opt[key];
                    } else {
                        params[key] = opt[key];
                    }
                }
            })(ATTRIBUTES.split(' '));
            
            //If the flash have not yet been installed.
            if (!FLASH_VERSION) {
                if (!dom || !dom.firstChild) html = placeholder(attrs);
                error = 1;
            } else {
                html = createSWF(attrs, params);
                
                /* Show express Install
                 * From SWFObject (https://github.com/swfobject/swfobject/blob/master/swfobject/src/swfobject.js)
                 */
                if (parseFloat(opt.version || MIN_VERSION) > FLASH_VERSION) {
                    if (isExpressInstallActive) return;
                    error = 2;
                    cacheHTML = html;
                    attrs.id = EXPRESS_INSTALL_ID;
                    
                    base = opt.base || embedSWF.base || '';
                    if (base && base.slice(-1) !== '/') base += '/';
                    params.src = base + EXPRESS_INSTALL;
                    
                    if (!/%$/.test(attrs.width) && parseInt(attrs.width, 10) < 310) {
                        attrs.width = "310";
                    }
                    if (!/%$/.test(attrs.height) && parseInt(attrs.height, 10) < 137) {
                        attrs.height = "137";
                    }
                    fv = "MMredirectURL=" + location.href +
                         "&MMplayerType=" + (isIE ? "ActiveX" : "PlugIn") +
                         "&MMdoctitle=" + encodeURIComponent(doc.title.slice(0, 47) + " - Flash Player Installation");
                    params.flashvars = params.flashvars ? params.flashvars + '&' + fv : fv;
                    
                    html = createSWF(attrs, params);
                    isExpressInstallActive = true;
                }
            }
        
            if (dom && html) dom.innerHTML = html;
            error && typeof opt.fallback === 'function' && opt.fallback(error);
            
            return html;
        }
        
        function placeholder(attrs){
            var aw = attrs.width,
                ah = attrs.height,
                w = typeof aw === 'number' ? aw + 'px' : aw,
                h = typeof ah === 'number' ? ah + 'px' : ah;
            return '<a target="_blank" href="//www.adobe.com/go/getflash">'+
            '<span style="display:block;cursor:pointer;background:#EFEFEF url(//www.adobe.com/images/shared/download_buttons/get_flash_player.gif) center center no-repeat;width:'+ w +';height:'+ h +';" title="Get Adobe Flash player">' +
            '</span></a>';
        }
        
        function createSWF(attrs, params){
            var html = '', key;
            if (isIE) {
                //对于IE，加上codebase参数才可以在没有安装flash的情况下自动提示安装ActiveX控件
                //attrs.codebase = "//download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=" + MIN_VERSION;
                attrs.classid = 'clsid:d27cdb6e-ae6d-11cf-96b8-444553540000';
                html += '<object' + obj2attr(attrs) + '>';
                for (key in params) {
                    html+='<param name="'+ key +'" value="'+ params[key] +'">';
                }
                html += '</object>';
                
            //现代浏览器用embed方式更好(Safari用object装载flash存在很多问题)
            } else {
                //Chrome自带flash10.0+，Firefox、Opera、Safari会自动提示用户安装，所以对于现代浏览器pluginpage参数不用设置
                html += '<embed' + obj2attr(params) + obj2attr(attrs) + '>';
            }
            return html;
        }
        
        function obj2attr(obj){
            var key, str = '';
            for (key in obj ) {
                str += ' ' + key + '="' + obj[key] + '"';
            }
            return str;
        }
        
        //安全移除flash
        function removeSWF(obj){
            if (typeof obj === 'string') {
                obj = doc.getElementById(obj).firstChild;
            }
            if (!obj || !obj.tagName) return;
            if ( !isIE || obj.tagName !== 'OBJECT' ) {
                obj.parentNode.removeChild(obj);
            } else {
                obj.style.display = "none";
                (function(){
                    if (obj.readyState == 4) {
                        //移除相关引用，防止内存泄露
                        for(var i in obj) if (typeof obj[i] === "function") obj[i] = null;
                            
                        obj.parentNode.removeChild(obj);
                    } else {
                        //正在加载中的flash不能直接移除，延时下重新执行
                        setTimeout(arguments.callee, 15);
                    }
                })();
            }
            isExpressInstallActive = false;
        }
        
        embedSWF.destroy = removeSWF;
        embedSWF.flashVersion = FLASH_VERSION;
        embedSWF.base = (function(uri){
            if (!uri) {
                var scripts = doc.getElementsByTagName('script'),
                    script = scripts[ scripts.length - 1 ];
                uri = script.src;
            }
            return uri.split('/').slice(0, -1).join('/');
        })(uri);
        embedSWF.installCallback = function(){
            if (isExpressInstallActive) {
                var dom = doc.getElementById(EXPRESS_INSTALL_ID),
                    prt = dom.parentNode;
                removeSWF(dom);
                prt.innerHTML = cacheHTML;
                cacheHTML = '';
                isExpressInstallActive = false;
            }
        };
        return embedSWF;
    })();
    
    var flashId = '__diskflashplayer',
        isIosPlatform = (navigator.platform.indexOf('iPhone') != -1) || (navigator.platform.indexOf('iPad') != -1),
        notSupport = (!isIosPlatform) && (SwfUtil.flashVersion < 10.1);
    
    var funcs = ['play', 'pause', 'seek', 'getState', 'getVolume', 'setVolume', 'getPosition', 'getDuration',
                 'onReady', 'onLoad', 'onError', 'onOver', 'onTime'];
    
    var playerConfig = null,
        playerInstance = null,
        playerIsReady = false;
    
    var onReady = function() {
        playerIsReady = true;
        if (typeof window[getGlobalFuncNameByType('onReady')] === 'function') {
            window[getGlobalFuncNameByType('onReady')].call(null);
        }
    };
    
    var initGlobalFunc = function() {
        var defaultMethod = function(){},
            result = [],
            method;
        for (var i = 0, len = funcs.length; i < len; i++) {
           if (funcs[i].slice(0, 2) === 'on') {
               method = getGlobalFuncNameByType(funcs[i]);
               result.push(funcs[i] + '=' + encodeURIComponent(method));
               window[method] = defaultMethod;
           }
        }
        method = getGlobalFuncNameByType('onReady1');
        window[method] = onReady;
        result.push('onReady' + '=' + encodeURIComponent(method));
        return result.join('&');
    };
    
    var getGlobalFuncNameByType = function(type) {
        return '___diskplayer_' + type;
    };
    
    var callPlayerFunc = function(type, args) {
        if (!playerInstance) {
            return false;
        }
        var isListenFunc = type.slice(0, 2) === 'on';
        if (!isListenFunc && !playerIsReady) {
            return false;
        }
        var array = Array.prototype.slice.apply(args);
        if (!isListenFunc) {
            if (typeof playerInstance[type] !== 'function') {
                return false;
            }
            //FIXME: 修复调用 Flash 方法问题
            if (array.length === 1) {
                return playerInstance[type](array[0]);
            } else {
                return playerInstance[type]();
            }
        } else {
            window[getGlobalFuncNameByType(type)] = array[0];
            return true;
        }
    };
    
    var filterConfig = ' containerId src ';
    var initPlayerVars = function(config) {
        var result = [];
        for (var i in config) {
            if (filterConfig.indexOf(' ' + i + '') >= 0) {
                continue;
            }
            result.push(i + '=' + encodeURIComponent(config[i]));
        }
        return result.join('&');
    };
    
    var player = (function(isIosPlatform, notSupport) {
        if (isIosPlatform) {
            return function(config, errorCallBack) {
                playerConfig = config;
                operateUtil.installIosVideoHTML(videoWrap, 'flashplayer', url);
                playerInstance = document.getElementById(flashId);
                errorCallBack.call(0, 'ios');
                return player;
            };
        } else if (notSupport) {
            return function(config, errorCallBack) {
                playerConfig = config;
                errorCallBack.call(1, SwfUtil.flashVersion, '未安装 flash 或  flash 版本太低');
                return player;
            };
        } else {
            return function(config) {
                var globalVars = initGlobalFunc(),
                    playerVars = initPlayerVars(config);
                playerVars = globalVars + '&' + playerVars;
                SwfUtil(config.containerId, {
                    id: flashId,
                    src: config.src,
                    flashvars: playerVars,
                    allowFullScreenInteractive: true,
                    allowFullScreen: true,
                    wmode: 'Opaque',
                    quality: 'high'
                });
                playerInstance = document.getElementById(flashId);
                return player;
            };
        }
    })(isIosPlatform, notSupport);
    
    //Flash 装载是否已经ok
    player.isReady = function() {
        return playerIsReady;
    };
    //init player apis
    var initPlayerFuncs = function() {
        for (var i = 0, len = funcs.length; i < len; i++) {
            player[funcs[i]] = (function(type) {
                return function(){
                    var result = callPlayerFunc(type, arguments);
                    if (typeof result === 'undefined') {
                        //增加链式操作
                        //return this;
                    } else {
                        //返回原方法返回的值
                        return result;
                    }
                };
            })(funcs[i]);
        }
    };
    initPlayerFuncs();
    
    //销毁 player
    player.destroy = function() {
        if (playerInstance) {
            SwfUtil.destroy(playerInstance);
            playerInstance = null;
            playerIsReady = false;
        }
    };
    
    if (typeof module !== 'undefined') {
        module.exports = player;
    } else {
        if (typeof window.diskPlayer !== 'undefined') {
            console.error('diskPlayer is exists');
        }
        window.diskPlayer = player; 
    }
})();
