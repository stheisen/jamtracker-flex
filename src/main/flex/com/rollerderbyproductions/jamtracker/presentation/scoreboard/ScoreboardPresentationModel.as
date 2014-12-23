package com.rollerderbyproductions.jamtracker.presentation.scoreboard
{
	import com.rollerderbyproductions.jamtracker.domain.JammerDisplay;
	import com.rollerderbyproductions.jamtracker.domain.Player;
	import com.rollerderbyproductions.jamtracker.events.PlayerEvent;
	import com.rollerderbyproductions.jamtracker.events.ScoreboardEvent;
	import com.rollerderbyproductions.jamtracker.model.ScoreboardModel;
	import com.rollerderbyproductions.jamtracker.model.ScoringModel;
	import com.rollerderbyproductions.jamtracker.model.TeamsModel;
	import com.rollerderbyproductions.jamtracker.presentation.AbstractPresentationModel;
	
	import flash.profiler.showRedrawRegions;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.ObjectUtil;

	public class ScoreboardPresentationModel extends AbstractPresentationModel
	{
		
		[Bindable][Inject] public var scoreboard:ScoreboardModel;
		[Bindable][Inject] public var scoring:ScoringModel;

		[Bindable] public var jammerHome:JammerDisplay = new JammerDisplay();
		[Bindable] public var jammerVisitor:JammerDisplay = new JammerDisplay();
		

		private static const _LOG:ILogger = Log.getLogger("ScoreboardPresentationModel");


		// Public Methods -------------------------------------------------------------------------
		
		/**
		 * This function will determine the set glowstate, and dispatch the coresponding event
		 */
		public function determineGlowState():void{
			if (scoreboard.glowEnabled)
				swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.GLOW_EFFECT_ON));
			else 
				swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.GLOW_EFFECT_OFF));
		}
		
		
		[Mediate("PlayerEvent.JAMMER_SELECT")]
		public function displaySelectedJammer(event:PlayerEvent):void {
			_LOG.debug("Mediating PlayerEvent.JAMMER_SELECT");

			// The associated player and the team this jammer was selected for
			var associatedTeamSide:String = event.teamSide;
			var associatedPlayer:Player = event.player;
			// Set the jammer display properties for the selected player
			var jammerDisplay:JammerDisplay = new JammerDisplay();

			// If the selected jammer is now the current jammer, then set their info.  They may not
			// be the current jammer if the player was un selected from the player list as jammer.
			if (associatedPlayer.currentJammer){
				_LOG.debug("["+associatedPlayer.derbyName+"] chosen as the jammer for the ["+associatedTeamSide+"]");
				
				// if the assocaited player does not have an image, then use the default image
				if (associatedPlayer.playerImage != null){
					jammerDisplay.image = associatedPlayer.playerImage;
				} else {
					if (scoreboard.useDefaultJammerImage){
						switch (associatedTeamSide){
							case TeamsModel.HOME_TEAM:
								jammerDisplay.image = scoreboard.homeDefaultJammerImage;
								break;
							case TeamsModel.VISITING_TEAM:
								jammerDisplay.image = scoreboard.visitorDefaultJammerImage;
								break;
						}
						
					} 
				}
				// Should this player's image use the border?				
				if (associatedPlayer.userImageBorder) {
					jammerDisplay.imageBorderAlpha = 1;
				} else {
					jammerDisplay.imageBorderAlpha = 0;
				}
				
				jammerDisplay.imageBorderColor = scoreboard.jammerImageBorderColor;
				jammerDisplay.imageBorderCornerRadius = 5;
				jammerDisplay.imageBorderWeight = 5;
			} 

			// For which team has the jammer been selected
			switch (associatedTeamSide){
				case TeamsModel.HOME_TEAM:
					scoreboard.jammerHome = jammerDisplay;
					break;
				case TeamsModel.VISITING_TEAM:
					scoreboard.jammerVisitor = jammerDisplay;
					break;
			}
			// When a new jammer is selected, we need to verify that the jammer indicator is appropriatly being displayed
			updateLeadJammerIndicator();
		
		}// displaySelectedJammer

		
		[Mediate("ScoreboardEvent.HIDE_JAMMER_IMAGES")]
		public function hideJammerImages():void {
			scoreboard.currentJammerImageHeight = 0;
			scoreboard.currentTeamLogoHeight = scoreboard.currentTeamLogoHeight + scoreboard.setJammerImageHeight;
		}
		
		[Mediate("ScoreboardEvent.RESTORE_JAMMER_IMAGES")]
		public function restoreJammerImages():void {
			scoreboard.currentJammerImageHeight = scoreboard.setJammerImageHeight;
			scoreboard.currentTeamLogoHeight = scoreboard.currentTeamLogoHeight - scoreboard.setJammerImageHeight;
		}
		
		
		
		[Mediate("ScoreboardEvent.UPDATE_LEAD_JAMMER")]
		public function updateLeadJammerIndicator(event:ScoreboardEvent=null):void {
			_LOG.debug("Mediating ScoreboardEvent.UPDATE_LEAD_JAMMER");
			
			// If the visiting team is leadjammer then set up their indicator
			if ((scoring.visitorTeam.leadJammer) && (scoring.visitorTeam.displayLeadJammerIndicator)) {
				// If the visiting jammers image is not null, and we are displaying images then
				// highlight the image, and hide the lead jammer indicator
				if ((scoreboard.jammerVisitor.image != null) && (scoreboard.displayJammerImage)) {
					scoreboard.jammerVisitor.imageBorderColor = scoreboard.jammerImageLeadBorderColor
				}
				scoring.visitorTeam.useLeadJammerIndicatorImage = true;
			// If the visiting team is NOT lead jammer, then dim the border color (if there is an image)
			// or hide the lead jammer indicator
			} else {
				if ((scoreboard.jammerVisitor.image != null) && (scoreboard.displayJammerImage)) 
					scoreboard.jammerVisitor.imageBorderColor = scoreboard.jammerImageBorderColor;
				scoring.visitorTeam.useLeadJammerIndicatorImage = false;
			}
			
			// We do the same for the home team as we did for the visiting team
			if ((scoring.homeTeam.leadJammer) && ((scoring.homeTeam.displayLeadJammerIndicator))) {
				if ((scoreboard.jammerHome.image != null) && (scoreboard.displayJammerImage)) {
					scoreboard.jammerHome.imageBorderColor = scoreboard.jammerImageLeadBorderColor;
				}
				scoring.homeTeam.useLeadJammerIndicatorImage = true;
			} else {
				if ((scoreboard.jammerHome.image != null) && (scoreboard.displayJammerImage)) 
					scoreboard.jammerHome.imageBorderColor = scoreboard.jammerImageBorderColor;
				scoring.homeTeam.useLeadJammerIndicatorImage = false;
				
			}
			
		}// updateLeadJammerIndicator


	}
}