package com.baidu.utils
{
	public class CommonUtils
	{
		public function CommonUtils()
		{
		}
		public static function format(time:uint):String
		{
			var hour:int = Number((time)/3600);
			time = time % 3600;
			var minute:int= Number((time )/60);
			time = time % 60;
			var second:int = time;
			var strSecond:String = second < 10 ? "0" + second.toString():second.toString();
			var strMinute:String = minute < 10 ? "0" + minute.toString():minute.toString();
			var strHour:String = hour < 10 ? "0" + hour.toString():hour.toString();
			return strHour+":"+strMinute+":"+strSecond;
		}
		
		/**
		 *	转换为需要的字幕对象 
		 */
		public static function srtFormat(obj:Object):Object {
			var srt:Object = {};
			srt.id = obj.id;
			srt.url = obj.file_path;
			srt.name = obj.display_name;
			srt.type = obj.from == 'pcs' ? '网盘字幕' : '在线字幕';
			return srt;
		}
	}
}