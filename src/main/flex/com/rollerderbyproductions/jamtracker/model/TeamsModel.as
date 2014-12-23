package com.rollerderbyproductions.jamtracker.model
{
	import com.rollerderbyproductions.jamtracker.domain.Team;

	[RemoteClass]
	[Bindable]
	public class TeamsModel
	{
		
		static public const HOME_TEAM:String = "HOME";
		static public const VISITING_TEAM:String = "VISITOR";
		
		// **************************************************************************************
		// NOTE :: In order to support persistance do NOT remove any of the properties on this
		//         object. In the case that any are added, be sure to add them to the persistance
		//         methods below
		// **************************************************************************************
		public var homeTeam:Team;		
		public var visitorTeam:Team;
		
		// Constructors ---------------------------------------------------------------------------
		/* NOTE: An empty constructor is required to export/import this object to/from filesystem */
		public function TeamsModel(){}
				
	}
}