package com.rollerderbyproductions.jamtracker.domain
{
	[RemoteClass]
	[Bindable]
	public class TeamScore
	{
		public var score:int = 0;
		public var pointsThisJam:int = 0;
		public var pointsPreviousJam:int = 0;
		public var timeoutsLeft:int = 0;
		public var timeout:Boolean = false;
		public var jamsLead:int = 0;
		public var leadJammer:Boolean = false;
		public var lostLead:Boolean = false;
		public var jammerInformationVisible:Boolean = true;
		public var displayLeadJammerIndicator:Boolean = false;
		public var useLeadJammerIndicatorImage:Boolean = false;
		public var currentJammer:Player;

		// Constructors ---------------------------------------------------------------------------
		/* NOTE: An empty constructor is required to export/import this object to/from filesystem */
		public function TeamScore(){}

	}
}