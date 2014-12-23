package com.rollerderbyproductions.jamtracker.domain
{
	[RemoteClass]
	[Bindable]
	public class ViewElement
	{
		
		public var backgroundColor:uint = 0x000000;
		public var color:uint = 0x000000;
		public var alpha:Number = 1;
		public var scale:Number = 1;
		public var visible:Boolean = true;
		public var x:Number = -1;
		public var y:Number = -1;
		
		// Constructors ---------------------------------------------------------------------------
		/* NOTE: An empty constructor is required to export/import this object to/from filesystem */
		public function ViewElement(){}
		
	}
}