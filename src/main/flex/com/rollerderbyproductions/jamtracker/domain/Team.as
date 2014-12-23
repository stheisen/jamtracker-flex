package com.rollerderbyproductions.jamtracker.domain
{
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;

	[RemoteClass]
	[Bindable]
	public class Team
	{		
		// This is the version number of this object
		public static var OBJECT_VERSION:String = "1.0"; // Reflect this change in TeamRepository
		
		
		// NOTE: Any time any of these properties are updated you MUST change the OBJECT_VERSION number, and load the
		//       object accordingly in the TeamRepository 
		
		// Version 1.0 //////////////////////////////////////////////////////////////////////////////
		public var shortName:String;
		public var logoImage:AppImage;
		public var displayImageSizeWarning:Boolean;
		public var scoreBoardNameFontColor:uint = 0xFFFFFFF;
		public var controllerBackgroundColor:uint = 0xCCCCCC;
		public var controllerBackgroundAlpha:Number = .5;
		public var teamRoster:ArrayCollection = new ArrayCollection();  		  // ArrayCollection of type Player
		public var activeTeamRoster:ArrayCollection = new ArrayCollection();    // ArrayCollection of type Player
		
		// Version 2.0 //////////////////////////////////////////////////////////////////////////////

		
		// Constructors ---------------------------------------------------------------------------
		/* NOTE: An empty constructor is required to export/import this object to/from filesystem */
		public function Team(){}
		
		static public function copyTeam(sourceTeam:Team, returnTeam:Team):void {
			
			returnTeam.activeTeamRoster = sourceTeam.activeTeamRoster;
			returnTeam.controllerBackgroundAlpha = sourceTeam.controllerBackgroundAlpha;
			returnTeam.controllerBackgroundColor = sourceTeam.controllerBackgroundColor;
			returnTeam.displayImageSizeWarning = sourceTeam.displayImageSizeWarning;
			returnTeam.scoreBoardNameFontColor = sourceTeam.scoreBoardNameFontColor;
			returnTeam.shortName = sourceTeam.shortName;
			returnTeam.teamRoster = sourceTeam.teamRoster;
			returnTeam.logoImage = sourceTeam.logoImage;
			
		}
		
	}
}