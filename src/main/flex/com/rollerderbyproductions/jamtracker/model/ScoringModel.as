package com.rollerderbyproductions.jamtracker.model
{
	import com.rollerderbyproductions.jamtracker.domain.Clock;
	import com.rollerderbyproductions.jamtracker.domain.TeamScore;
	
	import flash.net.dns.AAAARecord;
	import flash.utils.ByteArray;
    
	[RemoteClass]
	[Bindable]
	public class ScoringModel
	{
		// **************************************************************************************
		// NOTE :: In order to support persistance do NOT remove any of the properties on this
		//         object. In the case that any are added, be sure to add them to the persistance
		//         classes
		// **************************************************************************************		

		// This is the version number of this object
		public static var OBJECT_VERSION:String = "2.0"; // Reflect this change in the ScoringModelRepository
		static public const INCREMENT:String = "INC";
		static public const SET:String = "SET";

		// Version 1.0 //////////////////////////////////////////////////////////////////////////////
		
		public var currentPeriodNumber:int = 0; 
		public var currentJamNumber:int = 0; 
		public var homeTeam:TeamScore;
		public var noLeadJammer:Boolean = false;
		public var officialTimeout:Boolean = false;
		public var visitorTeam:TeamScore;		
		// Clocks
		public var gameClock:Clock;
		public var jamClock:Clock;
		public var breakClock:Clock;
		public var timeoutClock:Clock;
		public var intermissionClock:Clock;
		
		// Version 2.0 (introduced in v0.5.0) //////////////////////////////////////////////////////
		public var officialTimeoutClock:Clock;

		
		// Constructors ---------------------------------------------------------------------------
		/* NOTE: An empty constructor is required to export/import this object to/from filesystem */
		public function ScoringModel(){}
		
		public function init():void {
			gameClock = new Clock();
			jamClock = new Clock();
			breakClock = new Clock();
			timeoutClock = new Clock();
			intermissionClock = new Clock();
			officialTimeoutClock = new Clock();
			// Initalize clock objects
			gameClock.init(1800000,Clock.MAX_GAMECLOCK_MILLIMAX,60000);
			jamClock.init(120000,Clock.MAX_JAMCLOCK_MILLIMAX,120000);
			breakClock.init(30000,Clock.MAX_BREAKCLOCK_MILLIMAX,30000);
			timeoutClock.init(60000,Clock.MAX_TIMEOUTCLOCK_MILLIMAX,0);
			intermissionClock.init(1200000,Clock.MAX_INTERMISSIONCLOCK_MILLIMAX,60000);
			officialTimeoutClock.init(0,Clock.MAX_OFFICIALTIMEOUTCLOCK_MILLIMAX,0);
			// The Jam clock is visible at start-up
			jamClock.isVisible=true;
		}
		
		
		// Public Methods -------------------------------------------------------------------------
		/**
		 * Reset all the clocks 
		 * 
		 * @param includeIntermission - If true the intermission clock will be reset with the others.
		 *                              default: true
		 */
		public function resetClocks(includeIntermission:Boolean = true):void {
			this.gameClock.stop(false, true);
			this.breakClock.stop(true, true);
			this.timeoutClock.stop(true, true);
			this.officialTimeoutClock.stop(true, true);
			// If the intermission clock is being reset, then hide it and show the jam clock
			if (includeIntermission) { 
				this.intermissionClock.stop(true, true);	
				this.jamClock.stop(false, true);
			// Otherwise, reset the jam clock but do not show it.
			} else {
				this.jamClock.stop(true, true);
			}
		}
		
		/**
		 * Reset the scoring model to is default setting. Resetting the intermission clock is optional
		 * because this may take place during an intermission period.
		 * 
 		 * @param resetIntermissionClock - If true the intermission clock will be reset with the other clocks.
		 *                                 default: true
		 */
		public function resetScoring(resetIntermissionClock:Boolean = true): void{
			// Reset all the clocks
			resetClocks(resetIntermissionClock);
			// Reset all the remaining properties
			this.currentPeriodNumber = 0; 
			this.currentJamNumber = 0; 
			this.noLeadJammer = false;
			this.officialTimeout = false;
			this.homeTeam = new TeamScore();
			this.visitorTeam = new TeamScore();
		}
		
	}
}