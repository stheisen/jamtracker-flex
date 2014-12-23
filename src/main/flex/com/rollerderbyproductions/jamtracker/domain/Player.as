package com.rollerderbyproductions.jamtracker.domain
{
	import mx.utils.StringUtil;

	[RemoteClass]
	[Bindable]
	public class Player
	{
		
		public var number:String = "";
		public var derbyName:String = "";
		public var playerImage:AppImage;
		public var userImageBorder:Boolean = true;
		public var active:Boolean;
		public var currentJammer:Boolean = false;
		public var boutStats:Stats = new Stats();
		
		// Constructors ---------------------------------------------------------------------------
		/* NOTE: An empty constructor is required to export/import this object to/from filesystem */
		public function Player(){}
		
		// Public Methods -------------------------------------------------------------------------
		public function trimWhiteSpace():void {
			this.number = StringUtil.trim(this.number);
			this.derbyName = StringUtil.trim(this.derbyName);
		}
		
		public function get jammerAppearances():Number {return boutStats.jammerAppearances;}
		
	}
}