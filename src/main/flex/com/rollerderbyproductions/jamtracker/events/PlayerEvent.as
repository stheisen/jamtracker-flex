package com.rollerderbyproductions.jamtracker.events
{
	import com.rollerderbyproductions.jamtracker.domain.Player;
	
	import flash.events.Event;
	
	public class PlayerEvent extends Event
	{
		
		public static const JAMMER_SELECT:String 		= "PlayerEvent.JAMMER_SELECT";
		public static const JAMMER_DESELECT:String 	= "PlayerEvent.JAMMER_DESELECT";
		public static const JAMMERS_RESET_VIEW:String = "PlayerEvent.JAMMERS_RESET_VIEW";
		
		private var _teamSide:String;
		private var _player:Player;

		
		public function PlayerEvent(type:String, teamSide:String=null, player:Player=null,  bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._teamSide = teamSide;
			this._player = player;
		}
		
		public function get teamSide():String {
			return _teamSide;
		}
		
		public function get player():Player {
			return _player;
		}
		
		override public function clone() : Event
		{
			return new PlayerEvent(type, _teamSide, _player, bubbles, cancelable);
		}	
	}
}