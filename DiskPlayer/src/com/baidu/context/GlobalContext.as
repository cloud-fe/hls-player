package com.baidu.context
{
	import com.baidu.config.PlayerConfig;
	import com.baidu.player.Player;
	import flash.display.Stage;

	public class GlobalContext
	{
		public function GlobalContext()
		{
			
		}
		private static var _stage:Stage;
		
		public static function get stage():Stage {
			return _stage;
		}
		public static function set stage(s:Stage):void  {
			_stage = s;
		}
		
		private static var _config:PlayerConfig;
		
		public static function get config():PlayerConfig {
			return _config;
		}
		public static function set config(config:PlayerConfig):void  {
			_config = config;
		}
		
		private static var _player:Player;
		
		public static function get player():Player {
			return _player;
		}
		public static function set player(player:Player):void  {
			_player = player;
		}
	}
}