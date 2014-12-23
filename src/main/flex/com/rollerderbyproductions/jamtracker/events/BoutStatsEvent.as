package com.rollerderbyproductions.jamtracker.events
{
	import com.rollerderbyproductions.jamtracker.domain.Player;
	
	import flash.events.Event;
	
	public class BoutStatsEvent extends Event
	{
		
		public static const INCR_JAMAPPEARENCE:String 	= "BoutStatsEvent.INCR_JAMAPPEARENCE";
		public static const DECR_JAMAPPEARENCE:String 	= "BoutStatsEvent.DECR_JAMAPPEARENCE";
		public static const RESET_STATS:String 			= "BoutStatsEvent.RESET_STATS";
		public static const SORT_BY_JAMAPPEARENCE:String  = "BoutStatsEvent.SORT_BY_JAMAPPEARENCE";
		
		private var _player:Player;


		public function BoutStatsEvent(type:String, player:Player=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._player = player;

		}
		
		public function get player():Player {
			return _player;
		}
		
		override public function clone() : Event
		{
			return new BoutStatsEvent(type, _player, bubbles, cancelable);
		}	

	}
}