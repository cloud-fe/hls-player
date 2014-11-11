package com.baidu.utils
{
	import flash.external.ExternalInterface;

	public class PlayerExternalInterface
	{
		public function PlayerExternalInterface()
		{
			
		}
		public static function eval(funcName:String):void
		{
			ExternalInterface.call(funcName);
		}
		
		public static function addEventListen(funcName:String, func:Function):void {
			ExternalInterface.addCallback(funcName, func);
		}
	}
}