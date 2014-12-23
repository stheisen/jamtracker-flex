package com.rollerderbyproductions.jamtracker.jtstats
{
	import com.rollerderbyproductions.jamtracker.domain.Player;
	import com.rollerderbyproductions.jamtracker.domain.Stats;
	import com.rollerderbyproductions.jamtracker.events.BoutStatsEvent;
	import com.rollerderbyproductions.jamtracker.model.TeamsModel;
	import com.rollerderbyproductions.jamtracker.presentation.AbstractPresentationModel;
	
	import mx.collections.ArrayCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class BoutStatistics extends AbstractPresentationModel
	{
		
		private static const _LOG:ILogger = Log.getLogger("BoutStatistics");

		[Bindable][Inject] public var teamsModel:TeamsModel;

		
		/**
		 * This function will increase by one the number of jams the specified player has been jammer for
		 */
		[EventHandler( event="BoutStatsEvent.INCR_JAMAPPEARENCE" )]
		public function incrementJamAppearances(event:BoutStatsEvent):void {
			var player:Player = event.player;
			player.boutStats.jammerAppearances++;
			_LOG.debug("increment jamAppearences for ["+player.derbyName+"] to ["+player.boutStats.jammerAppearances+"]");
			swizDispatcher.dispatchEvent(new BoutStatsEvent(BoutStatsEvent.SORT_BY_JAMAPPEARENCE));


		}

		
		/**
		 * This function will decrease by one the number of jams the specified player has been jammer for
		 */
		[EventHandler( event="BoutStatsEvent.DECR_JAMAPPEARENCE" )]
		public function decrementJamAppearances(event:BoutStatsEvent):void {
			var player:Player = event.player;
			player.boutStats.jammerAppearances--;
			_LOG.debug("decrement jamAppearences for ["+player.derbyName+"] to ["+player.boutStats.jammerAppearances+"]");
			swizDispatcher.dispatchEvent(new BoutStatsEvent(BoutStatsEvent.SORT_BY_JAMAPPEARENCE));
			
		}
		
		/**
		 * This event loops through both team rosters, and reset's their bout stats
		 */
		[EventHandler( event="BoutStatsEvent.RESET_STATS" )]
		public function resetPlayerBoutStatistics():void {			
			var player:Player;

			_LOG.debug("Reset bout statisics for the HOME and VISITOR teams");
			for each ( player in teamsModel.homeTeam.teamRoster )    player.boutStats = new Stats();
			for each ( player in teamsModel.visitorTeam.teamRoster ) player.boutStats = new Stats();
			swizDispatcher.dispatchEvent(new BoutStatsEvent(BoutStatsEvent.SORT_BY_JAMAPPEARENCE));
		}

	}
}