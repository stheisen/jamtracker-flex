package com.rollerderbyproductions.jamtracker.persistance
{
	import com.rollerderbyproductions.jamtracker.domain.AppImage;
	import com.rollerderbyproductions.jamtracker.domain.Clock;
	import com.rollerderbyproductions.jamtracker.domain.Team;
	import com.rollerderbyproductions.jamtracker.events.ControllerEvent;
	import com.rollerderbyproductions.jamtracker.events.PlayerEvent;
	import com.rollerderbyproductions.jamtracker.model.ApplicationModel;
	import com.rollerderbyproductions.jamtracker.model.AssetModel;
	import com.rollerderbyproductions.jamtracker.model.ClosingStateModel;
	import com.rollerderbyproductions.jamtracker.model.ScoreboardModel;
	import com.rollerderbyproductions.jamtracker.model.ScoringModel;
	import com.rollerderbyproductions.jamtracker.model.SettingsModel;
	import com.rollerderbyproductions.jamtracker.model.TeamsModel;
	import com.rollerderbyproductions.jamtracker.model.ViewsModel;
	import com.rollerderbyproductions.jamtracker.presentation.AbstractPresentationModel;
	
	import flash.filesystem.File;
	
	import mx.core.ByteArrayAsset;
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class PersistanceManager extends AbstractPresentationModel
	{
		
		[Bindable][Inject] public var applicationModel:ApplicationModel;		
		[Bindable][Inject] public var controllerSettings:SettingsModel;
		
		[Bindable][Inject] public var teamsModel:TeamsModel;
		[Bindable][Inject] public var scoring:ScoringModel;
		[Bindable][Inject] public var scoreboardModel:ScoreboardModel;
		[Bindable][Inject] public var viewsModel:ViewsModel;
		[Bindable] public var prevStateAvailable:Boolean = false;

		private var _LOG:ILogger = Log.getLogger("PersistanceManager"); 
		
		/**
		 * Initialize all the objects for their first time use, and load the default values
		 */
		public function initalizeModels():void {
			
			_LOG.debug("Initalize Home Team");
			teamsModel.homeTeam = new Team();
			teamsModel.homeTeam.shortName="HOME";
			teamsModel.homeTeam.controllerBackgroundColor=0x00FF33;			
			teamsModel.homeTeam.logoImage = new AppImage();
			// If there is no previously loaded/set home logo then use the embeded default
			if (teamsModel.homeTeam.logoImage.data == null){
				teamsModel.homeTeam.logoImage.data = new AssetModel.LOGO_DEFAULTHOME_CLASS() as ByteArrayAsset;
			}
			
			_LOG.debug("Initalize Visitor Team");
			teamsModel.visitorTeam = new Team();
			teamsModel.visitorTeam.shortName="VISITOR";
			teamsModel.visitorTeam.controllerBackgroundColor=0x6666FF;
			teamsModel.visitorTeam.logoImage = new AppImage();
			// If there is no previously loaded/set home visitor then use the embeded default
			if (teamsModel.visitorTeam.logoImage.data == null){
				teamsModel.visitorTeam.logoImage.data = new AssetModel.LOGO_DEFAULTVISITOR_CLASS() as ByteArrayAsset;
			}

			
			_LOG.debug("Initialize Scoring Model");
			scoring.init();
			
			_LOG.debug("Initialize Scoreboard Settings");
			scoreboardModel.init();
			scoreboardModel.leadJammerIndicatorImage = new AppImage();
			if (scoreboardModel.leadJammerIndicatorImage.data == null){
				scoreboardModel.leadJammerIndicatorImage.data = new AssetModel.IMAGE_DEFAULTLEADJAMMER_CLASS() as ByteArrayAsset;
			}
			scoreboardModel.homeDefaultJammerImage = new AppImage();
			if (scoreboardModel.homeDefaultJammerImage.data == null){
				scoreboardModel.homeDefaultJammerImage.data = new AssetModel.IMAGE_DEFAULTPLAYERIMG_CLASS() as ByteArrayAsset;
			}
			scoreboardModel.visitorDefaultJammerImage = new AppImage();
			if (scoreboardModel.visitorDefaultJammerImage.data == null){
				scoreboardModel.visitorDefaultJammerImage.data = new AssetModel.IMAGE_DEFAULTPLAYERIMG_CLASS() as ByteArrayAsset;
			}
			scoreboardModel.overlayImage = new AppImage();
			if (scoreboardModel.overlayImage.data == null){
				scoreboardModel.overlayImage.data = new AssetModel.IMAGE_DEFAULTSCOREBOARDOVERLAY_CLASS() as ByteArrayAsset;
			}
			scoreboardModel.backgroundImage = new AppImage();
			if (scoreboardModel.backgroundImage.data == null){
				scoreboardModel.backgroundImage.data = new AssetModel.IMAGE_DEFAULTSCOREBOARDBACKGROUND_CLASS() as ByteArrayAsset;
			}
			
			_LOG.debug("Initialize Views");
			viewsModel.init();
			
			_LOG.debug("Initialize Settings");
			controllerSettings.init();
			
			// dispatch model update events
			dispatchUpdatedModelEvents();
		}
		
		
		/**
		 * Attempts to load the most recent closing state of the application
		 *
		 */
		public function loadPreviousState(fileName:String=null, readDir:File=null):String {
			
			var previousClosingState:ClosingStateModel = new ClosingStateModel();
			var lastAppVerion:String;
			
			if (fileName == null){
				_LOG.debug("Attemping to load JamTracker configuration from Closing State");
				fileName = ApplicationModel.FILENAME_CLOSINGSTATE;
				readDir = applicationModel.stateDir;
			} else {
				_LOG.debug("Attemping to load JamTracker configuration from file ["+fileName+"]");				
			}
			
			lastAppVerion = ClosingStateModelRepository.loadPersistedObject(fileName, readDir, previousClosingState);			
			
			// As long as the hometeam is not null, then we must have a previously saved state to load
			if (previousClosingState.homeTeamPersitedObject != null){
				ScoreboardModelRepository.loadScoreboardModelObject(previousClosingState.scoreboardModelPersitedObject, scoreboardModel);
				SettingsModelRepository.loadSettingsModelObject(previousClosingState.settingsModelPersitedObject, controllerSettings);
				TeamRepository.loadTeamObject(previousClosingState.homeTeamPersitedObject, teamsModel.homeTeam);
				TeamRepository.loadTeamObject(previousClosingState.visitorTeamPersitedObject, teamsModel.visitorTeam);
				// v0.4.0 - Added to load saved clock settings
				// as long as the previously saved state has a scoringModel, then load it up
				if (previousClosingState.scoringModelPersistedObject != null){
					ScoringModelRepository.loadScoringModelObject(previousClosingState.scoringModelPersistedObject, scoring);					
				}
				if (previousClosingState.customViewsPersistedObject != null) {
					ViewsModelRepository.loadViewsModelObject(previousClosingState.customViewsPersistedObject, viewsModel);
				}
				prevStateAvailable = true;
				// dispatch model update events
				dispatchUpdatedModelEvents();				
			}
			return lastAppVerion;
			
		}
		
		
		/**
		 * This method saves the current state of all the object models. This is typically done
		 * when the application closes, so that that exact state can be loaded the next time the
		 * application is opened.
		 */
		public function saveCurrentState(fileSavePath:File=null):void {
			var closingState:ClosingStateModel = new ClosingStateModel();
			
			if (fileSavePath == null){
				_LOG.debug("Attemping to save JamTracker configuration Closing State");
				fileSavePath = applicationModel.stateDir.resolvePath(ApplicationModel.FILENAME_CLOSINGSTATE);
			} else {
				_LOG.debug("Attemping to save JamTracker configuration ["+fileSavePath.toString()+"]");

			}
			
			// deactivate the lead jammers
			swizDispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.JAMMER_DESELECT, TeamsModel.HOME_TEAM, null));
			swizDispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.JAMMER_DESELECT, TeamsModel.VISITING_TEAM, null));			
			
			_LOG.debug("Attemping to save the current application state");
			// Construct the closing state model to be saved
			closingState.scoreboardModelPersitedObject = ScoreboardModelRepository.buildPersistedObject(applicationModel.versionNumber, scoreboardModel);
			closingState.settingsModelPersitedObject = SettingsModelRepository.buildPersistedObject(applicationModel.versionNumber, controllerSettings);
			closingState.homeTeamPersitedObject = TeamRepository.buildPersistedObject(applicationModel.versionNumber, teamsModel.homeTeam);
			closingState.visitorTeamPersitedObject = TeamRepository.buildPersistedObject(applicationModel.versionNumber, teamsModel.visitorTeam);
			closingState.scoringModelPersistedObject = ScoringModelRepository.buildPersistedObject(applicationModel.versionNumber, scoring);
			closingState.customViewsPersistedObject = ViewsModelRepository.buildPersistedObject(applicationModel.versionNumber, viewsModel);
			// write the closing state to the filesystem
			ClosingStateModelRepository.writePersistedObject(applicationModel.versionNumber, closingState, fileSavePath);
			
		}
		
		// ----------------------------------------------------------------------------------------
		// Private Methods
		// ----------------------------------------------------------------------------------------
		/**
		 * Dispatch an event to views that need to reinitialize data models when they are updated
		 */
		private function dispatchUpdatedModelEvents():void{
			// Since the team models are stored in two seperate presentation model instances, dispatch an event to update each instance 
			swizDispatcher.dispatchEvent(new ControllerEvent(ControllerEvent.RESET_TEAMMODELS));
			// Since the view models are stored in prototype beans, dispatch an event to update each instance of the bean
			swizDispatcher.dispatchEvent(new ControllerEvent(ControllerEvent.RESET_VIEWMODELS));

		}
		
	}
}