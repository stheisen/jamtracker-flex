package com.rollerderbyproductions.jamtracker.presentation
{	
	import flash.events.IEventDispatcher;
	
	public class AbstractPresentationModel
	{
		[Dispatcher] 
		public var swizDispatcher:IEventDispatcher;
		
		public function AbstractPresentationModel()
		{
		}
	}
}