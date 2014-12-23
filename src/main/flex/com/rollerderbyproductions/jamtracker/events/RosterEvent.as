package com.rollerderbyproductions.jamtracker.events
{
	import com.rollerderbyproductions.jamtracker.domain.Team;
	
	import flash.events.Event;
	
	public class RosterEvent extends Event
	{
		
		public static const SAVE_ROSTER_CHANGES:String   ="RosterEvent.SAVE_ROSTER_CHANGES";
		public static const EDIT_ROSTER:String   ="RosterEvent.EDIT_ROSTER";
		public static const LOADED_ROSTER:String ="RosterEvent.LOAD_ROSTER_COMPLETE";

		private var _team:Team;
		private var _teamSide:String;
		
		public function RosterEvent(type:String, team:Team=null, teamSide:String=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._team = team;
			this._teamSide = teamSide;
		}
		
		public function get team():Team {
			return _team;
		}
		
		public function get teamSide():String {
			return _teamSide;
		}

		override public function clone() : Event
		{
			return new RosterEvent(type,_team,_teamSide,bubbles,cancelable);
		}		
		
	}
}