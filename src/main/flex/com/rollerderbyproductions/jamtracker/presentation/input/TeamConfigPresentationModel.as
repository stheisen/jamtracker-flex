package com.rollerderbyproductions.jamtracker.presentation.input
{
	import com.rollerderbyproductions.jamtracker.domain.AppImage;
	import com.rollerderbyproductions.jamtracker.domain.Player;
	import com.rollerderbyproductions.jamtracker.domain.Team;
	import com.rollerderbyproductions.jamtracker.domain.TeamScore;
	import com.rollerderbyproductions.jamtracker.events.PlayerEvent;
	import com.rollerderbyproductions.jamtracker.events.RosterEvent;
	import com.rollerderbyproductions.jamtracker.model.ApplicationModel;
	import com.rollerderbyproductions.jamtracker.model.ScoreboardModel;
	import com.rollerderbyproductions.jamtracker.model.ScoringModel;
	import com.rollerderbyproductions.jamtracker.model.SettingsModel;
	import com.rollerderbyproductions.jamtracker.model.TeamsModel;
	import com.rollerderbyproductions.jamtracker.presentation.AbstractPresentationModel;
	import com.rollerderbyproductions.jamtracker.util.ImageUtility;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Utils3D;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.ObjectUtil;

	public class TeamConfigPresentationModel extends AbstractPresentationModel
	{

		[Bindable][Inject] public var settingsModel:SettingsModel;
		[Bindable][Inject] public var scoreboard:ScoreboardModel;
		[Bindable][Inject] public var scoringModel:ScoringModel;
		[Bindable][Inject] public var teamsModel:TeamsModel;
		
		[Bindable] public var configTeam:Team; 
		[Bindable] public var teamLogoUploadText:String = "UPDATE LOGO";
		
		private var _fileReference:FileReference = new FileReference();
		private var _image:AppImage = new AppImage();
		
		private static const _LOG:ILogger = Log.getLogger("TeamConfigPresentationModel");

		
		// General Functions ----------------------------------------------------------------------		
		/**
		 * This function is called by the view when the object is created. 
		 */ 
		public function setTeam(teamSide:String):Team {
			var determinedTeamSide:Team = new Team();
			if (teamSide == TeamsModel.HOME_TEAM){
				determinedTeamSide = teamsModel.homeTeam;
			} else if (teamSide == TeamsModel.VISITING_TEAM){
				determinedTeamSide = teamsModel.visitorTeam;
			}
			_LOG.debug("setTeam to:" +determinedTeamSide.shortName );

			// Determine the image warning level for this team
			if (determinedTeamSide.logoImage != null) determineImageWarning(teamSide, determinedTeamSide.logoImage.data);
			
			return determinedTeamSide;
		}
		
		
		// Event Handlers -------------------------------------------------------------------------
		[EventHandler("RosterEvent.SAVE_ROSTER_CHANGES")]
		public function saveTeamChanges(event:RosterEvent):void {
			
			var savedTeam:Team = event.team;
			
			switch (event.teamSide){
				case TeamsModel.HOME_TEAM:
					Team.copyTeam(savedTeam, teamsModel.homeTeam);
					break;
				case TeamsModel.VISITING_TEAM:
					Team.copyTeam(savedTeam, teamsModel.visitorTeam);
					break;
			}
			
		}
		
		// Click Handlers -------------------------------------------------------------------------				
		/**
		 * Launches the file browser allowing the user to select an image to upload
		 */
		public function logoUpload(setTeam:String):void
		{
			_LOG.debug("LogoUpload request for: " + setTeam);

			//Instantiate on loading
			_image = new AppImage();
			_fileReference = new FileReference();
			_fileReference.browse([ImageUtility.SUPPORTED_IMAGE_FILTER]);
			_fileReference.addEventListener(Event.SELECT,onFileSelected, false, 0, true);
			_fileReference.addEventListener(Event.COMPLETE, function(e:Event):void {
				onFileLoadComplete(setTeam);
			}, false, 0, true);  				
		}
		

		/**
		 * Clears the active jammers from the scoring model, as well as the active rosters
		 */
		public function clearActiveJammers():void {
			
			_LOG.debug("Clearing active jammers");
				
			var item:Player
			
			// clear jammer flags from the current home and visiting teams
			for each(item in teamsModel.homeTeam.activeTeamRoster) item.currentJammer = false;
			for each(item in teamsModel.visitorTeam.activeTeamRoster) item.currentJammer = false;
			
			// remove the currentJammers from the scoring model
			if (scoringModel.homeTeam != null) if (scoringModel.homeTeam.currentJammer != null) scoringModel.homeTeam.currentJammer = null;
			if (scoringModel.visitorTeam != null) if (scoringModel.visitorTeam.currentJammer != null) scoringModel.visitorTeam.currentJammer = null;

		}		
		
		/**
		 * Set the current jammer when the active roster is clicked.
		 */
		public function activeRoster_clickHandler(teamSide:String, playerSelected:Player):void {
			
			var activeTeamRoster:ArrayCollection;
			var activeTeamScore:TeamScore;

			// Set the active team roster to the appropriate team			
			switch (teamSide){
				case TeamsModel.HOME_TEAM:
					activeTeamRoster = teamsModel.homeTeam.activeTeamRoster;
					activeTeamScore = scoringModel.homeTeam;
					break;
				case TeamsModel.VISITING_TEAM:
					activeTeamRoster = teamsModel.visitorTeam.activeTeamRoster;
					activeTeamScore = scoringModel.visitorTeam;
					break;
			}
			// Loop through the active team roster and set all the current jammer flags to false (except seleted player).
			for each(var item:Player in activeTeamRoster) {    
				if (item != playerSelected) item.currentJammer = false;
			}			
			// Deal with the selected player appropriatly. Either they are the current 
			// jammer, or they are no longer the current jammer.
			if (playerSelected.currentJammer){ 
				_LOG.debug(teamSide+" Jammer Deactivated: " + playerSelected.derbyName);
				playerSelected.currentJammer = false;
				activeTeamScore.currentJammer = null;
			} else {
				_LOG.debug(teamSide+" Jammer Activated: " + playerSelected.derbyName);
				playerSelected.currentJammer = true;
				activeTeamScore.currentJammer = playerSelected;
			}
			swizDispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.JAMMER_SELECT, teamSide, playerSelected));

		}
		
		
		/**
		 * Resets all the jammers to false for the provided teamSide
		 */
		[Mediate("PlayerEvent.JAMMER_DESELECT")]
		public function activeRoster_deselectJammer(event:PlayerEvent):void {
			
			var associatedTeamSide:String = event.teamSide;
			var activeTeamRoster:ArrayCollection;
			
			// Set the active team roster to the appropriate team			
			switch (associatedTeamSide){
				case TeamsModel.HOME_TEAM:
					activeTeamRoster = teamsModel.homeTeam.activeTeamRoster;
					break;
				case TeamsModel.VISITING_TEAM:
					activeTeamRoster = teamsModel.visitorTeam.activeTeamRoster;
					break;
			}
			
			// Loop through the active team roster and set all the current jammer flags to false.
			for each(var item:Player in activeTeamRoster) {
				// if this is the current jammer, then call the clickhandler to deselect them properly
				if (item.currentJammer) {
					_LOG.debug("Resetting selected jammer for ["+associatedTeamSide+"]" + "["+item.derbyName+"]");					
					activeRoster_clickHandler(associatedTeamSide, item);
					break;
				}
			}	
		}
			
		/**
		 * 
		 */
		[Mediate("PlayerEvent.JAMMERS_RESET_VIEW")]
		public function activeRosters_reselectJammers(event:PlayerEvent):void {
			
			var activeHomeTeamRoster:ArrayCollection = teamsModel.homeTeam.activeTeamRoster;
			var activeVisitorTeamRoster:ArrayCollection = teamsModel.visitorTeam.activeTeamRoster;
			var item:Player;
			
			for each(item in activeHomeTeamRoster) {
				// if this is the current jammer, then call the clickhandler to deselect them properly
				if (item.currentJammer) {
					scoringModel.homeTeam.currentJammer = item;
					swizDispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.JAMMER_SELECT, TeamsModel.HOME_TEAM, item));
					break;
				}
			}	
			
			for each(item in activeVisitorTeamRoster) {
				// if this is the current jammer, then call the clickhandler to deselect them properly
				if (item.currentJammer) {
					scoringModel.visitorTeam.currentJammer = item;
					swizDispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.JAMMER_SELECT, TeamsModel.VISITING_TEAM, item));
					break;
				}
			}	
			
		}
		
		/**
		 * Handles the editRoster action, and launches tha popup window as a reault of this event
		 */
		public function editRoster(teamSide:String):void {
			// Calls the EDIT_ROSTER event, passing the appropriate team
			switch (teamSide){
				case TeamsModel.HOME_TEAM:
					swizDispatcher.dispatchEvent(new RosterEvent(RosterEvent.EDIT_ROSTER, teamsModel.homeTeam, teamSide));
					break;
				case TeamsModel.VISITING_TEAM:
					swizDispatcher.dispatchEvent(new RosterEvent(RosterEvent.EDIT_ROSTER, teamsModel.visitorTeam, teamSide));
					break;
			}
		}
		
		// ----------------------------------------------------------------------------------------
		// Imaging methods
		// ----------------------------------------------------------------------------------------		
		/**
		 * This method enables a warning flag if the provided image data exceeds the 
		 * recommended size.
		 */
		public function determineImageWarning(setTeam:String, imageData:ByteArray):void {
			var imageSizeKB:Number = ImageUtility.bytesToKB(imageData.bytesAvailable);

			// If the image exceeds the maximum bytes, then display ethe image size warning message
			if (imageSizeKB > ApplicationModel.TEAMLOGO_IMAGE_MAX_KBSIZE) {				
				switch (setTeam){
					case TeamsModel.HOME_TEAM:
						_LOG.debug("HOME = TRUE");
						teamsModel.homeTeam.displayImageSizeWarning = true;	
						break;
					case TeamsModel.VISITING_TEAM:
						teamsModel.visitorTeam.displayImageSizeWarning = true;	
						break;
				}				
			} else {
				switch (setTeam){
					case TeamsModel.HOME_TEAM:
						_LOG.debug("HOME = FALSE");
						teamsModel.homeTeam.displayImageSizeWarning = false;	
						break;
					case TeamsModel.VISITING_TEAM:
						teamsModel.visitorTeam.displayImageSizeWarning = false;	
						break;
				}								
			}
		}
		
		/** 
		 * Begin the load if the selected file 
		 */
		private function onFileSelected(event:Event):void
		{
			_fileReference.load();
			// Remove the event listener that fired this method
			_fileReference.removeEventListener(Event.SELECT, onFileSelected);
			
		}


		/**
		 * This function is called by an event listener when the load completes
		 */
		public function onFileLoadComplete(setTeam:String):void{
			_LOG.debug("LogoUpload file selected and loaded for: " + setTeam);

			var loader:Loader = new Loader();
			_image.data = _fileReference.data;
			_image.fileName = _fileReference.name;
			
			// Determine if this image has earned a warning for being too large
			determineImageWarning(setTeam, _image.data);

			// Add a listener event to fire after the image file is laoded
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(event:Event): void {
				var imageBitmap:Bitmap = event.currentTarget.loader.content as Bitmap;
				onFileStoreComplete(setTeam, imageBitmap); 
			}, false, 0, true);				
			loader.loadBytes(_image.data);
		}
		
		/**
		 * This function is called then the loader finished storing the image in the oject
		 */
		public function onFileStoreComplete(setTeam:String, imageBitmap:Bitmap):void{
			_LOG.debug("LogoUpload file stored for: " + setTeam);
			_image = ImageUtility.populateImageDimensions(imageBitmap, _image);
			//_image.imageQuality = ImageUtility.determineImageQualitySingleDimension(_image.imageHeight, IMAGE_GOOD_MIN_HEIGHT, IMAGE_EXCELLENT_MIN_HEIGHT);
			
			_LOG.debug("Storing image for: " + setTeam);
			// Load the image object for into the appropriate team object
			if (setTeam == TeamsModel.HOME_TEAM){
				teamsModel.homeTeam.logoImage = _image;
			} else if (setTeam == TeamsModel.VISITING_TEAM){
				teamsModel.visitorTeam.logoImage = _image;
			}
		}
	}
}