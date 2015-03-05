package com.baidu.utils
{
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class AjaxUtils
	{
		public function AjaxUtils(url:String, method:String='get', params:Object=null, callback:Function=null)
		{
			var urlRequest:URLRequest = new URLRequest();
			urlRequest.method = method;
			if (method == 'get' && params != null) {
				url = this.operateUrl(url, params);
			}
			urlRequest.url = url;
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, function(e:Event):void {
				if (callback != null)
					callback(e);
			});
			urlLoader.load(urlRequest);
		}
		
		private function operateUrl(url:String, params:Object):String {
			
			var flagQues:Boolean = false,
				paramStr:String = '';
			
			for (var i:String in params) {
				if (params.hasOwnProperty(i)) {
					paramStr = paramStr + '&' + encodeURIComponent(i) + '=' + encodeURIComponent(params[i]);
				}
			}
			
			if (paramStr) {
				flagQues = url.indexOf('?') > 0 ? true : false;
				if (!flagQues) {
					url = url + '?';
				} else {
					url = url + '&';
				}
				url = url + paramStr.slice(1);
			}
			return url;
		}
	}
}