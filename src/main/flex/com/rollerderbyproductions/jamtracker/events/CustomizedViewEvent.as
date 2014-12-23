package com.rollerderbyproductions.jamtracker.events
{
	import flash.events.Event;
	
	public class CustomizedViewEvent extends Event
	{
		
		public static const SET_SELECTED_ELEMENT:String		    = "CustomizedViewEvent.SET_SELECTED_ELEMENT";	
		
		private var _elementId:String;
		
		
		public function CustomizedViewEvent(type:String, elementId:String=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._elementId = elementId;
			
		}
		
		public function get elementId():String {
			return _elementId;
		}
		
		
		override public function clone() : Event
		{
			return new CustomizedViewEvent(type, _elementId, bubbles, cancelable);
		}	
		
	}
}