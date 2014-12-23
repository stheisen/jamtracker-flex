package com.rollerderbyproductions.jamtracker.domain
{
	
	[RemoteClass]
	[Bindable]
	public class JammerDisplay
	{

		public var image:AppImage;
		public var imageBorderColor:uint = 0x000000;
		public var imageBorderWeight:Number = 5; 
		public var imageBorderAlpha:Number = 1; 
		public var imageBorderCornerRadius:Number = 5;
		
		// Constructors ---------------------------------------------------------------------------
		/* NOTE: An empty constructor is required to export/import this object to/from filesystem */
		public function JammerDisplay(){}
	}
}