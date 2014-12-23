package com.rollerderbyproductions.jamtracker.model
{
	import com.rollerderbyproductions.jamtracker.domain.AppImage;

	[RemoteClass]
	[Bindable]
	public class SettingsModel
	{
		// **************************************************************************************
		// NOTE :: In order to support persistance do NOT remove any of the properties on this
		//         object. In the case that any are added, be sure to add them to the persistance
		//         classes
		// **************************************************************************************
		
		// This is the version number of this object
		public static var OBJECT_VERSION:String = "5.0"; // Reflect this change in TeamRepository
		
		
		// NOTE: Any time any of these properties are updated you MUST change the OBJECT_VERSION number, and load the
		//       object accordingly in the SettingsModelRepository 
		
		// Version 1.0 //////////////////////////////////////////////////////////////////////////////
		// The scorekeeper stops the jam, that should start the break  
		public var breakClockAutostartOnJamStop:Boolean = true;
				
		// This is true because that jam will not start automatically if the break clock happens to expire.  
		// The scoreboard operator must start each jam manually using the ref's whistle as a signal 
		// This accounts for situations where the scoreboard break clock is slightly off from the NSO's official stopwatch
		public var breakClockAutostartOnTimeoutExpire:Boolean = false;

		// Check for occassional updates from rollerderbproductions.com
		public var checkForUpdates:Boolean = true;	
		
		// Disable all keyboard shortcuts for the application
		public var disableKeyboardShortcuts:Boolean = false;

		// How many periods are in the bout
		public var finalPeriodNumber:int = 2; 
		
		// When the jam stops, should the jammer indicators be removed (during the break)
		public var hideLeadJammerIndicatorAtStop:Boolean = true;
			
		// When the jam stops, should the selected player be reset?
		public var resetSelectedJammersAtStop:Boolean = true;

		// Version 2.0 //////////////////////////////////////////////////////////////////////////////
		
		// The number of timeouts assigned to each team by default
		public var resetTeamTimeoutCount:int = 3;
		
		// Should team timeouts be reset each period?
		public var resetTimeoutsEachPeriod:Boolean = false;
		
		// If there is less time on the period clock than the break clock, then synchronize the two
		public var synchBreakClockwithGameClock:Boolean = true;
		
		// Version 3.0 (introduced in v0.3.0) ///////////////////////////////////////////////////////
		
		// This is false by default so that the scorekeeper will use the ref's whistle to signal the end of a Jam.
		// This accounts for situations where the scoreboard jam clock is slightly off from the NSO's official stopwatch
		public var breakClockAutostartOnJamExpire:Boolean = false;
		
		// This is the AppImage used for the curtain
		// No longer used as of v0.4.0
		public var curtainImage:AppImage;
		
		// This is false by default so that the scorekeeper will use the ref's whistle to signal the start of a Jam.
		// This accounts for situations where the scoreboard jam clock is slightly off from the NSO's official stopwatch
		public var jamClockAutostartOnBreakExpire:Boolean = false;

		// Setting this to true will reset the jam count on the scoreboard each time there is a period change
		public var resetJamCountAtNewPeriod:Boolean = true;
		
		// Version 4.0 (introduced in v0.4.0) //////////////////////////////////////////////////////
		
		// If true, then the PREVIEW, INTERMISSION and POSTGAME views will automatically activate based on the
		// state of the scoreboard.
		public var customViewsAutoSwitch:Boolean = false;

		// Version 5.0 (introduced in v0.5.0) //////////////////////////////////////////////////////

		// Disable right click as the primary scoreboard action
		public var disableRightClickPrimaryAction:Boolean = false;

		// Display the official timeout duration in the secondary clock when an offiial timeout is called
		public var displayOfficialTimeoutDuration:Boolean = true;
		
		// Log activity to a file
		public var activeDebugLog:Boolean = true;

		// Version 6.0 (introduced in vx.x.x) //////////////////////////////////////////////////////

		// Constructors ---------------------------------------------------------------------------
		/* NOTE: An empty constructor is required to export/import this object to/from filesystem */
		public function SettingsModel(){}
		
		public function init():void {
			// Version 1.0 //////////////////////////////////////////////////////////////////////////////
			breakClockAutostartOnJamStop = true;
			breakClockAutostartOnTimeoutExpire = false;
			checkForUpdates = true;	
			disableKeyboardShortcuts = false;
			finalPeriodNumber = 2; 
			hideLeadJammerIndicatorAtStop = true;
			resetSelectedJammersAtStop = true;
			
			// Version 2.0 //////////////////////////////////////////////////////////////////////////////
			resetTeamTimeoutCount = 3;
			resetTimeoutsEachPeriod = false;
			synchBreakClockwithGameClock = true;
			
			// Version 3.0 (introduced in v0.3.0) ///////////////////////////////////////////////////////
			breakClockAutostartOnJamExpire = false;	
			jamClockAutostartOnBreakExpire = false;
			resetJamCountAtNewPeriod = true;
			
			// Version 4.0 (introduced in v0.4.0) //////////////////////////////////////////////////////
			customViewsAutoSwitch = false;
			
			// Version 5.0 (introduced in v0.5.0) //////////////////////////////////////////////////////
			disableRightClickPrimaryAction = false;
			displayOfficialTimeoutDuration = true;
			activeDebugLog = true;
		}
		
	}
}