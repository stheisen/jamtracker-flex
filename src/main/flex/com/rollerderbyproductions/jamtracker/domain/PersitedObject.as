package com.rollerderbyproductions.jamtracker.domain
{
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	[RemoteClass]
	[Bindable]
	public class PersitedObject
	{
		
		public static var OBJECT_CLOSINGSTATE:String    = "CLOSINGSTATE_MODEL"; 
		public static var OBJECT_SCOREBOARDMODEL:String = "SCOREBOARD_MODEL"; 
		public static var OBJECT_SCORINGMODEL:String    = "SCORING_MODEL"; 
		public static var OBJECT_TEAM:String            = "TEAM_OBJ"; 
		public static var OBJECT_SETTINGSMODEL:String   = "SETTINGS_MODEL"; 
		public static var OBJECT_VIEWSMODEL:String   = "VIEWS_MODEL"; 
		
		public var objectType:String;
		public var objectVersion:String;
		public var applicationVersion:String;
		public var createDate:Date;
		public var binaryData:ByteArray;
		
		// Constructors ---------------------------------------------------------------------------
		/* NOTE: An empty constructor is required to export/import this object to/from filesystem */
		public function PersitedObject(){}
	}
}