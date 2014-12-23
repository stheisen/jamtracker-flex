package com.rollerderbyproductions.jamtracker.events
{
	import flash.events.Event;
	
	public class ScoreboardEvent extends Event
	{
		
		public static const UPDATE_LEAD_JAMMER:String			= "ScoreboardEvent.UPDATE_LEAD_JAMMER";
		public static const HIDE_JAMMER_IMAGES:String     	= "ScoreboardEvent.HIDE_JAMMER_IMAGES";
		public static const RESTORE_JAMMER_IMAGES:String  	= "ScoreboardEvent.RESTORE_JAMMER_IMAGES";
		public static const VIEW_CUSTOM:String		    	= "ScoreboardEvent.VIEW_CUSTOM";
		public static const VIEW_CUSTOM_PREVIEW:String		= "ScoreboardEvent.VIEW_CUSTOM_PREVIEW";
		public static const VIEW_MAIN:String		    		= "ScoreboardEvent.VIEW_MAIN";
		public static const VIEW_MAIN_PREVIEW:String		    = "ScoreboardEvent.VIEW_MAIN_PREVIEW";
		public static const GLOW_EFFECT_ON:String				= "ScoreboardEvent.GLOW_EFFECT_ON";
		public static const GLOW_EFFECT_OFF:String			= "ScoreboardEvent.GLOW_EFFECT_OFF";
		
		private var _viewName:String;

		
		public function ScoreboardEvent(type:String, viewName:String=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._viewName = viewName;

		}
			
		public function get viewName():String {
			return _viewName;
		}


		override public function clone() : Event
		{
			return new ScoreboardEvent(type, _viewName, bubbles, cancelable);
		}	

	}
}