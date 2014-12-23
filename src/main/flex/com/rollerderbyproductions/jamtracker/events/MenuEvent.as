package com.rollerderbyproductions.jamtracker.events
{
	import flash.events.Event;
	
	public class MenuEvent extends Event
	{
	
		public static const OPEN_SAVECONFIG:String	= "MenuEvent.OPEN_SAVECONFIG";	
		public static const OPEN_ABOUT:String		    = "MenuEvent.OPEN_ABOUT";	

		public function MenuEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone() : Event
		{
			return new MenuEvent(type, bubbles, cancelable);
		}	

	}
}