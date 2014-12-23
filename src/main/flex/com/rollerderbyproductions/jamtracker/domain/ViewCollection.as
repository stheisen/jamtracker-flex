package com.rollerderbyproductions.jamtracker.domain
{
	import com.rollerderbyproductions.jamtracker.views.input.ViewControl;
	
	import mx.controls.Label;

	[RemoteClass]
	[Bindable]
	public class ViewCollection
	{
		// This is the version number of this object
		public static var OBJECT_VERSION:String = "1.0"; // Reflect this change in ViewRepository	

		public static var CLOCK:String = "CLOCK";
		public static var FORGROUND_IMAGE:String = "FORGROUND_IMAGE";
		public static var HOME_LOGO:String = "HOME_LOGO";
		public static var LABEL1:String = "LABEL1";
		public static var LABEL2:String = "LABEL2";
		public static var LABEL3:String = "LABEL3";
		public static var LABEL4:String = "LABEL4";
		public static var VISITOR_LOGO:String = "VISITOR_LOGO";

		
		public var backgroundColor:ViewElement = new ViewElement();
		public var backgroundImage:AppImageElement = new AppImageElement();
		public var forgroundImage:AppImageElement  = new AppImageElement();
		public var gameClock:ViewElement = new ViewElement();
		public var homeLogo:ViewElement = new ViewElement();
		public var homeScore:ViewElement = new ViewElement();
		public var label1:LabelElement = new LabelElement();
		public var label2:LabelElement = new LabelElement();
		public var label3:LabelElement = new LabelElement();
		public var label4:LabelElement = new LabelElement();
		public var visitorLogo:ViewElement = new ViewElement();
		public var visitorScore:ViewElement = new ViewElement();

		
		// Constructors ---------------------------------------------------------------------------
		/* NOTE: An empty constructor is required to export/import this object to/from filesystem */
		public function ViewCollection(){}			
		
		
	}
}