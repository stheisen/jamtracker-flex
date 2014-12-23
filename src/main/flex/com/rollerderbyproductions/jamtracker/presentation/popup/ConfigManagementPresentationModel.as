package com.rollerderbyproductions.jamtracker.presentation.popup
{
	
	import com.rollerderbyproductions.jamtracker.events.ControllerEvent;
	import com.rollerderbyproductions.jamtracker.events.MenuEvent;
	import com.rollerderbyproductions.jamtracker.model.ApplicationModel;
	import com.rollerderbyproductions.jamtracker.model.AssetModel;
	import com.rollerderbyproductions.jamtracker.persistance.PersistanceManager;
	import com.rollerderbyproductions.jamtracker.presentation.AbstractPresentationModel;
	import com.rollerderbyproductions.jamtracker.presentation.input.ScoreboardControlPresentationModel;
	import com.rollerderbyproductions.jamtracker.presentation.input.SettingsConfigPresentationModel;
	import com.rollerderbyproductions.jamtracker.util.FileSystem;
	import com.rollerderbyproductions.jamtracker.views.popup.ConfigManagement;
	
	import flash.display.DisplayObject;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import mx.controls.Alert;
	import mx.core.ByteArrayAsset;
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.events.CloseEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.PopUpManager;
	
	import spark.components.TitleWindow;

	public class ConfigManagementPresentationModel extends AbstractPresentationModel
	{
		
		public static const FILE_FILTER:FileFilter = new FileFilter("JamTracker Config Settings (*.jcs)", "*.jcs");

		[Bindable][Inject] public var persistanceMgr:PersistanceManager;
		[Inject] public var settingsConfig:SettingsConfigPresentationModel;	
		[Bindable][Inject] public var applicationModel:ApplicationModel;
		[Bindable][Inject] public var scoreboardControl:ScoreboardControlPresentationModel;
		
		private var _LOG:ILogger = Log.getLogger("SnapshotManagementPresentationModel"); 
		private var _view:TitleWindow = null;
		private var _ssFileReference:File = new File();
		private var _resetWarningMessage:String = "This action will reset the scoring in progress. Do you want to continue?";
		private var _loadedData:Boolean = false;

		// ----------------------------------------------------------------------------------------
		// Public Methods
		// ----------------------------------------------------------------------------------------
		/**
		 * Initialize the view
		 */
		public function initView():void {
			// Suspend all shortcuts 
			settingsConfig.suspendKeyboardShortcuts();
		}
		
		/**
		 * This creates the Manage Configuration PopUp screen, and loads it onto the stage
		 * 
		 * @param MenuEvent 
		 * 
		 */
		[EventHandler("MenuEvent.OPEN_SAVECONFIG")]
		public function showConfigMView(event:MenuEvent):void 
		{			
			_view = TitleWindow(PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, ConfigManagement, true));
			PopUpManager.centerPopUp(_view);
			// Setting isPopUp to false prevents it from being moved.
			_view.isPopUp = false;
		}

		// ----------------------------------------------------------------------------------------
		// Public Click Handler Methods
		// ----------------------------------------------------------------------------------------
		/**
		 * This clickhandler closes the window 
		 */		
		public function cancelWindow_clickHandler(addDialog:IFlexDisplayObject):void {
			_loadedData = false;
			closeWindow();
		}
		

		
		/**
		 * Loads the last configuration saved when JamTracker was closed 
		 */		
		public function loadConfig_clickHandler(addDialog:IFlexDisplayObject):void {
			if (scoreboardControl.isGameInProgress())
				Alert.show(_resetWarningMessage, "Confirm Cancel", Alert.OK | Alert.CANCEL, null, confirmLoadHandler, AssetModel.ICON_QUESTION32_CLASS, Alert.CANCEL, null);
			else 
				loadConfig();
			
		}
		
		
		
		/**
		 * Loads the last configuration saved when JamTracker was closed 
		 */		
		public function recallConfig_clickHandler(addDialog:IFlexDisplayObject):void {
			if (scoreboardControl.isGameInProgress())
				Alert.show(_resetWarningMessage, "Confirm Cancel", Alert.OK | Alert.CANCEL, null, confirmRecallHandler, AssetModel.ICON_QUESTION32_CLASS, Alert.CANCEL, null);
			else 
				recallConfig();

		}


		
		/**
		 * This clickhandler closes the window without saving any of the changes made
		 */		
		public function resetConfig_clickHandler(addDialog:IFlexDisplayObject):void {
			if (scoreboardControl.isGameInProgress())
				Alert.show(_resetWarningMessage, "Confirm Cancel", Alert.OK | Alert.CANCEL, null, confirmResetHandler, AssetModel.ICON_QUESTION32_CLASS, Alert.CANCEL, null);
			else 
				resetConfig();
		}
		
		
		/**
		 * Launches the process for saving a configuration
		 */
		public function saveConfig_clickHandler():void {
			// open the file browser to the default location for team storage
			_ssFileReference = new File(applicationModel.configDir.nativePath);
			_ssFileReference.browseForSave("Save JamTracker configuration as..");
			// Once the user as selected a file, call the onTeamFileSelected			
			_ssFileReference.addEventListener(Event.SELECT,onSaveConfigSelected, false, 0, true);			
		}
		


		
		// ----------------------------------------------------------------------------------------
		// Persistance methods
		// ----------------------------------------------------------------------------------------		
		/** 
		 * After the team file to be loaded is selected, this method is used to actually kick off
		 * the loading process. 
		 */
		private function onLoadSnapshotFileSelected(event:Event):void
		{			
			// Remove the event listener that fired this method
			_ssFileReference.removeEventListener(Event.SELECT, onLoadSnapshotFileSelected);
			persistanceMgr.loadPreviousState(_ssFileReference.name, _ssFileReference.parent);
			scoreboardControl.resetScoreboard();
			_loadedData = true;
			closeWindow();
		}
		
		
		/**
		 * An event listener fires this method once the save file has been identified
		 */
		private function onSaveConfigSelected(event:Event):void {
			
			// Remove the event listener that fired this method
			_ssFileReference.removeEventListener(Event.SELECT,onSaveConfigSelected);
			
			//Split the returned File native path to retrieve file name
			var tmpArr:Array = File(event.target).nativePath.split(File.separator);
			//remove last array item and return its content
			var fileName:String = tmpArr.pop();
			
			//Check if the extension given by user is valid, if not the default on is put.
			//(for example if user put himself/herself an invalid file extension it is removed in favour of the default one)
			var conformedFileDef:String = FileSystem.conformFileExtension(fileName, ApplicationModel.FILEEXT_CONFIG_STORAGE);
			tmpArr.push(conformedFileDef);
			
			//Create a new file object giving as input our new path with conformed file extension
			var conformedFile:File = new File("file:///" + tmpArr.join(File.separator));
			
			// Write the file
			persistanceMgr.saveCurrentState(conformedFile);
			_loadedData = false;
			closeWindow();
		}
		
		// ----------------------------------------------------------------------------------------
		// Private Methods
		// ----------------------------------------------------------------------------------------		
		private function closeWindow():void {
			// Remove the popup, and resume keyboard shortcuts
			PopUpManager.removePopUp(_view);
			settingsConfig.resumeKeyboardShortcuts();
			if (_loadedData) swizDispatcher.dispatchEvent(new ControllerEvent(ControllerEvent.RESET_MAIN_TAB));
		}
		
		
		
		/**
		 * This method is called when the user answers the "Confirm Cancel Chanes" dialogue for canceling
		 * the open window.
		 * 
		 * @param event - mx.events.CloseEvent
		 */
		private function confirmLoadHandler(event:CloseEvent):void{
			if(event.detail==Alert.OK) {
				_LOG.debug("Load selected JamTracker configuration");
				loadConfig();
			} else {
				_LOG.debug("Load selected JamTracker configuration Canceled");
			}
		}
		
		/**
		 * Launches the process for browsing to and loading a configuration
		 */
		public function loadConfig():void {
			// open the file browser to the default location for team storage
			_ssFileReference = new File(applicationModel.configDir.nativePath);
			_ssFileReference.browse([FILE_FILTER]);
			// Once the user as selected a file, call the onTeamFileSelected			
			_ssFileReference.addEventListener(Event.SELECT,onLoadSnapshotFileSelected, false, 0, true);
		}
		
		
		/**
		 * This method is called when the user answers the "Confirm Cancel Chanes" dialogue for canceling
		 * the open window.
		 * 
		 * @param event - mx.events.CloseEvent
		 */
		private function confirmRecallHandler(event:CloseEvent):void{
			if(event.detail==Alert.OK) {
				_LOG.debug("Recall last JamTracker configuration");
				recallConfig();
			} else {
				_LOG.debug("Recall last JamTracker configuration Canceled");
			}
		}
		
		
		/**
		 * This clickhandler closes the window 
		 */		
		private function recallConfig():void {
			scoreboardControl.resetScoreboard();
			persistanceMgr.loadPreviousState();
			_loadedData = true;
			closeWindow();
		}
		
		
		/**
		 * This method is called when the user answers the "Confirm Cancel Chanes" dialogue for canceling
		 * the open window.
		 * 
		 * @param event - mx.events.CloseEvent
		 */
		private function confirmResetHandler(event:CloseEvent):void{
			if(event.detail==Alert.OK) {
				_LOG.debug("Reset JamTracker configuration");
				resetConfig();
			} else {
				_LOG.debug("Reset JamTracker configuration Canceled");
			}
		}
		
		/**
		 * This clickhandler closes the window 
		 */		
		private function resetConfig():void {
			scoreboardControl.resetScoreboard();
			persistanceMgr.initalizeModels();
			_loadedData=true;
			closeWindow();
		}
		
	}
}