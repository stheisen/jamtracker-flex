package com.rollerderbyproductions.jamtracker.events
{
	import flash.events.Event;
	
	public class ControllerEvent extends Event
	{
		
		public static const SET_MAIN_BUTTONBAR:String		    = "ControllerEvent.SET_MAIN_BUTTONBAR";	
		public static const RESET_MAIN_TAB:String		    	= "ControllerEvent.RESET_MAIN_TAB";	
		public static const SET_CUSTOMVIEW_STATE:String	 	= "ControllerEvent.SET_CUSTOMVIEW_STATE";	
		public static const RESET_VIEWMODELS:String	 		= "ControllerEvent.RESET_VIEWMODELS";	
		public static const RESET_TEAMMODELS:String	 		= "ControllerEvent.RESET_TEAMMODELS";	
		
		private var _viewName:String;
		
		
		public function ControllerEvent(type:String, viewName:String=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._viewName = viewName;
			
		}
		
		public function get viewName():String {
			return _viewName;
		}
		
		
		override public function clone() : Event
		{
			return new ControllerEvent(type, _viewName, bubbles, cancelable);
		}	
		
	}
}