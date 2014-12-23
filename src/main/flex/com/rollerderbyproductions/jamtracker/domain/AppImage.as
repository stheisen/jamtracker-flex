package com.rollerderbyproductions.jamtracker.domain
{
	import flash.utils.ByteArray;

	[RemoteClass]
	[Bindable]
	public class AppImage
	{
		
		public var data:ByteArray;
		public var fileName:String;
		public var imageHeight:Number;
		public var imageWidth:Number;
		public var maintainAspectRatio:Boolean = true;
		
		// Constructors ---------------------------------------------------------------------------
		/* NOTE: An empty constructor is required to export/import this object to/from filesystem */
		public function AppImage(){}
		
	}
}