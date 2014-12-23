package com.rollerderbyproductions.jamtracker.model
{
	import com.rollerderbyproductions.jamtracker.domain.PersitedObject;

	[RemoteClass]
	public class ClosingStateModel
	{
		// This is the version number of this object
		public static var OBJECT_VERSION:String = "3.0"; // Reflect this change in TeamRepository
		
		
		// NOTE: Any time any of these properties are updated you MUST change the OBJECT_VERSION number, and load the
		//       object accordingly in the TeamRepository 
		
		// Version 1.0 //////////////////////////////////////////////////////////////////////////////
		public var scoreboardModelPersitedObject:PersitedObject;
		public var settingsModelPersitedObject:PersitedObject;
		public var homeTeamPersitedObject:PersitedObject;
		public var visitorTeamPersitedObject:PersitedObject;
		
		// Version 2.0 (introduced in v0.4.0) ///////////////////////////////////////////////////////
		public var scoringModelPersistedObject:PersitedObject;

		// Version 3.0 //////////////////////////////////////////////////////////////////////////////
		public var customViewsPersistedObject:PersitedObject;
		
		// Version 4.0 //////////////////////////////////////////////////////////////////////////////

		
		// Constructors ---------------------------------------------------------------------------
		/* NOTE: An empty constructor is required to export/import this object to/from filesystem */
		public function ClosingStateModel(){}
		
	}
}