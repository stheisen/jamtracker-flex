package com.rollerderbyproductions.jamtracker.domain
{

	[RemoteClass]
	[Bindable]
	public class LabelElement extends ViewElement
	{
		
		public var text:String;

		// Constructors ---------------------------------------------------------------------------
		/* NOTE: An empty constructor is required to export/import this object to/from filesystem */
		public function LabelElement(){}
	}
}