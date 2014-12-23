package com.rollerderbyproductions.jamtracker.presentation
{
	
	import air.update.ApplicationUpdaterUI;
	import air.update.events.UpdateEvent;
	
	import com.rollerderbyproductions.jamtracker.domain.AppImage;
	import com.rollerderbyproductions.jamtracker.domain.Clock;
	import com.rollerderbyproductions.jamtracker.domain.Team;
	import com.rollerderbyproductions.jamtracker.events.BoutStatsEvent;
	import com.rollerderbyproductions.jamtracker.events.ControllerEvent;
	import com.rollerderbyproductions.jamtracker.events.MenuEvent;
	import com.rollerderbyproductions.jamtracker.events.PlayerEvent;
	import com.rollerderbyproductions.jamtracker.events.ScoreboardEvent;
	import com.rollerderbyproductions.jamtracker.model.ApplicationModel;
	import com.rollerderbyproductions.jamtracker.model.AssetModel;
	import com.rollerderbyproductions.jamtracker.model.ClosingStateModel;
	import com.rollerderbyproductions.jamtracker.model.ScoreboardModel;
	import com.rollerderbyproductions.jamtracker.model.ScoringModel;
	import com.rollerderbyproductions.jamtracker.model.SettingsModel;
	import com.rollerderbyproductions.jamtracker.model.TeamsModel;
	import com.rollerderbyproductions.jamtracker.model.ViewsModel;
	import com.rollerderbyproductions.jamtracker.persistance.ClosingStateModelRepository;
	import com.rollerderbyproductions.jamtracker.persistance.PersistanceManager;
	import com.rollerderbyproductions.jamtracker.persistance.ScoreboardModelRepository;
	import com.rollerderbyproductions.jamtracker.persistance.ScoringModelRepository;
	import com.rollerderbyproductions.jamtracker.persistance.SettingsModelRepository;
	import com.rollerderbyproductions.jamtracker.persistance.TeamRepository;
	import com.rollerderbyproductions.jamtracker.persistance.ViewsModelRepository;
	import com.rollerderbyproductions.jamtracker.presentation.input.ScoreboardControlPresentationModel;
	import com.rollerderbyproductions.jamtracker.presentation.input.ScoreboardViewsPresentationModel;
	import com.rollerderbyproductions.jamtracker.presentation.input.TeamConfigPresentationModel;
	import com.rollerderbyproductions.jamtracker.presentation.input.ViewControlPresentationModel;
	import com.rollerderbyproductions.jamtracker.presentation.popup.ConfigManagementPresentationModel;
	import com.rollerderbyproductions.jamtracker.util.FileSystem;
	import com.rollerderbyproductions.jamtracker.util.LoggingConfig;
	import com.rollerderbyproductions.jamtracker.views.MainView;
	import com.rollerderbyproductions.jamtracker.views.input.ScoreboardControl;
	import com.rollerderbyproductions.jamtracker.views.scoreboard.MainScoreboard;
	import com.rollerderbyproductions.jamtracker.views.scoreboard.PreviewScoreboard;
	import com.rollerderbyproductions.jamtracker.views.window.WindowedScoreboard;
	
	import flash.desktop.NativeApplication;
	import flash.display.Screen;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.net.registerClassAlias;
	import flash.sampler.NewObjectSample;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.ByteArrayAsset;
	import mx.core.FlexGlobals;
	import mx.core.Window;
	import mx.core.mx_internal;
	import mx.events.AIREvent;
	import mx.events.CloseEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.logging.targets.TraceTarget;
	import mx.utils.ObjectUtil;
	import mx.utils.object_proxy;
	
	import org.swizframework.core.ISwiz;
	import org.swizframework.core.ISwizAware;
	
	import spark.events.IndexChangeEvent;

	public class MainPresentationModel extends AbstractPresentationModel implements ISwizAware
	{	
	
		[Inject] public var persistanceManager:PersistanceManager
		[Inject] public var scoreboardControlPresentationModel:ScoreboardControlPresentationModel;
		[Inject] public var teamConfigPresentationModel:TeamConfigPresentationModel;
		[Inject][Bindable] public var viewConfigPresentationModel:ViewControlPresentationModel;

		[Bindable][Inject] public var applicationModel:ApplicationModel;		
		[Bindable][Inject] public var controller:SettingsModel;
		[Bindable][Inject] public var teamsModel:TeamsModel;
		[Bindable][Inject] public var scoring:ScoringModel;
		[Bindable][Inject] public var scoreboard:ScoreboardModel;
		[Bindable][Inject] public var viewsModel:ViewsModel;
		[Bindable][Inject] public var scoreboardViewPresentationModel:ScoreboardViewsPresentationModel;
		[Bindable][Inject] public var scoreboardControl:ScoreboardControlPresentationModel;

		[Bindable] public var windowOpened:Boolean = false;		
		[Bindable] public var lastKeyboardCode:String = "ON";
		[Bindable] public var scoreboardWindowOptions:ArrayCollection = new ArrayCollection;
		[Bindable] public var newInstallDetected:Boolean = false;
		
		public static var suspendShortcuts:Boolean = false;		
		private var _docWindow:WindowedScoreboard;		
		private var _LOG:ILogger;  // Typically this is a const, but this class initilizes it later
		private var _appUpdater:ApplicationUpdaterUI = new ApplicationUpdaterUI();

		private var _prevTabId:String;
		
		/**
		 * This method is called anytime a tab is changed. 
		 */
		public function navTabs_changeHandler(event:IndexChangeEvent):void
		{
			var selectedViewsModel:String;
			var tabId:String = event.target.selectedItem.id;
			
			switch (tabId){
				case "scoring":
					// When the scoreing tab is selected, dispatch an event to set the view state on the main
					// control button bar to the appropriate state
					swizDispatcher.dispatchEvent(new ControllerEvent(ControllerEvent.SET_MAIN_BUTTONBAR, scoreboardControl.scoreboardViewState));
					break;
				case "scoreboard":
					break;
				case "settings":
					break;
				case "views":	
					// When the views tab is selected, dispatch an event to set the view state on the custom
					// view control button bar and the config panel to the appropriate state
					swizDispatcher.dispatchEvent(new ControllerEvent(ControllerEvent.SET_CUSTOMVIEW_STATE, scoreboardControl.scoreboardViewState));
					break;
			}
			_LOG.debug("Main navigation view tab selected ["+tabId+"]");
			// Store the previous tabId
			_prevTabId = tabId;
		}
		
		
		/**
		 * This method is called when a new configuration is loaded.
		 * Its purpose is to refresh the contents of the custom view 
		 */
		[EventHandler( event="ControllerEvent.RESET_MAIN_TAB" )]
		public function resetCustomViewControlObjects(event:ControllerEvent):void {
			swizDispatcher.dispatchEvent(new ControllerEvent(ControllerEvent.SET_CUSTOMVIEW_STATE, "RESET_CUSTOM_VIEWS"));
		}

		
		/**
		 * The postConstructInitalization method is executed by SWIZ after this bean as been setup and 
		 * all the required  injections have completed.  This method is reseposible for the main initilization
		 * of the application.
		 */ 
		[PostConstruct]
		public function postConstructInitalization():void {
			
			var lastStoredVersion:String = "0.0.0";
			
			// Determine and store the path to the application directory, and construct the path to
			// all file directories used by the application
			applicationModel.rootDir = File.documentsDirectory.resolvePath(ApplicationModel.DIR_ROOT);
			applicationModel.stateDir = applicationModel.rootDir.resolvePath(ApplicationModel.DIR_STATE_STORAGE);
			applicationModel.teamsDir = applicationModel.rootDir.resolvePath(ApplicationModel.DIR_TEAM_STORAGE);
			applicationModel.exportsDir = applicationModel.rootDir.resolvePath(ApplicationModel.DIR_EXPORT_STORAGE);
			applicationModel.configDir = applicationModel.rootDir.resolvePath(ApplicationModel.DIR_CONFIG_STORAGE);
			applicationModel.logDir = applicationModel.rootDir.resolvePath(ApplicationModel.DIR_LOG_STORAGE);

			FileSystem.createOutputDir(applicationModel.rootDir);
			FileSystem.createOutputDir(applicationModel.stateDir);
			FileSystem.createOutputDir(applicationModel.teamsDir);
			FileSystem.createOutputDir(applicationModel.exportsDir);
			FileSystem.createOutputDir(applicationModel.configDir);
			FileSystem.createOutputDir(applicationModel.logDir);

			// Set the logging level
			LoggingConfig.setLoggingTarget();
			_LOG = Log.getLogger("MainPresentationModel");
			
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXml.namespace();			
			applicationModel.versionNumber = appXml.ns::versionNumber;
			applicationModel.applicationName = appXml.ns::name;
			
			
			// Initalize all the models with their "default content".
			// Loading an existing exit state may overwrite these settings.
			persistanceManager.initalizeModels();
			// Load the previous state of the application (AKA closing state)
			lastStoredVersion = persistanceManager.loadPreviousState();
			
			if (controller.activeDebugLog){
				LoggingConfig.setLoggingTarget(LoggingConfig.FILE, applicationModel.logDir);
			}

			_LOG.debug("---------------  Start Jamtracker  ---------------");

			// Build the screen resolution options
			_LOG.debug("Building Screen Options");
			buildScreenOptions();
			// Check for any available updates using the built-in update framework
			if ((controller.checkForUpdates) && (! ApplicationModel.isEvaluationCopy)) checkForUpdate();
			
			_LOG.debug("Stored JamTracker Version ["+lastStoredVersion+"] Current JamTracker Version ["+applicationModel.versionNumber+"]");
			if (lastStoredVersion != applicationModel.versionNumber) newInstallDetected = true;

			// Reset all the stats for the teams loaded
			swizDispatcher.dispatchEvent(new BoutStatsEvent(BoutStatsEvent.RESET_STATS));
			
		} //postConstructInitalization
		
		/** 
		 * Initializes and display the maine (or Detached) scoreboard based on the specified windowType
		 * 
		 * @param windowType - If the window type contains a colon (:) then this is a fullscreen view
		 *                     on the specfied screen number For example, windowtype = "fullscreen:2" would 
		 *                     be indicative of a full screen view on display #2.  A windowType that does
		 *                     not contain a colon will result in a resizable window.
		 */
		public function displayDetachedScoreboard(windowType:String):void{			
			
			var screens:Array = Screen.screens;
			var screen:Screen;
			var visibleBounds:Rectangle;

			_docWindow = new WindowedScoreboard();

			// If there is colon in the window type, then we are opening a fullscreen window
			var typeString:Array = (windowType.split(":"));			
			if( typeString.length > 1){
				var fullscreenDisplayNumber:int = parseInt(typeString[length]);
				_LOG.debug("Opening a fullscreen scoreboard on ["+windowType+ "] Display: ["+fullscreenDisplayNumber+"]");
				screen = screens[fullscreenDisplayNumber];
				visibleBounds = screen.visibleBounds;
				_docWindow.height = visibleBounds.height;
				_docWindow.width = visibleBounds.width;
				_docWindow.left = visibleBounds.left;
				_docWindow.scaleX = _docWindow.width/1024;
				_docWindow.scaleY = _docWindow.height/768;
				_docWindow.systemChrome = "none";
				
			// Otherwise, this is a resizable "normal" window that is opened
			} else {
				_LOG.debug("Opening a resizable scoreboard");
				screen = Screen.mainScreen;
				visibleBounds = screen.visibleBounds;
				_docWindow.height = 600;
				_docWindow.width = 800;
				_docWindow.left = 0;
				_docWindow.scaleX = _docWindow.width/1024;
				_docWindow.scaleY = _docWindow.height/768;				
				_docWindow.systemChrome = "standard";
			}
			// Register the new window with SWIZ so that it recieves the required injections, and open it
			_swiz.registerWindow(_docWindow);
			_docWindow.open();
			
			// set the main scoreboard display to match that of the selected view mode.
			scoreboardControl.dispatchSpecifiedScoreboardViewMode(scoreboardControl.scoreboardViewState);
			
			windowOpened = true;

			_LOG.debug("Detacted Scoreboard Created.");
			
		} // displayDetachedScoreboard
	
		

		
		/**
		 * This method closes the windowed scoreboard, and sets a flag indicating it has been closed
		 */
		public function closeWindowedScoreboard():void{
			if (windowOpened){
				_LOG.debug("Scoreboard Window Closed");
				_docWindow.close();
				viewConfigPresentationModel.buttonActive_CurtainToggle=false;
				windowOpened = false;
			}
		}
		

		/**
		 * If the scoreboard window is presently open, this will prompt the user for confirmation of closing the window.
		 */
		public function confirmCloseWindowedScoreboard():void{
			if (windowOpened){
				Alert.show("Close the Detached Scoreboard Screen?", "Confirm Close Window", Alert.OK | Alert.CANCEL, null, confirmCloseWindowHandler, AssetModel.ICON_ALERT32_CLASS, Alert.CANCEL, null);	
			}
		}
		
		/**
		 * This method is called by the keyDown event listener. If keyboard shortcuts are NOT suspended, then 
		 * this method passes the keystrokes to the scoreboard controller to be reviewed for an assigned action.
		 * 
		 * @param event - flash.events.KeyboardEvent
		 */
		public function onKeyDown(event:KeyboardEvent):void {
			if (!suspendShortcuts){
				lastKeyboardCode = scoreboardControlPresentationModel.keyHandler(event);
			}
		}

		
		/**
		 * This method is called by the Mouse Right-Click event listener. If right click is NOT suspended, then 
		 * this method passes the event to the scoreboard controller to execute the primary click handler.
		 * 
		 * @param event - flash.events.KeyboardEvent
		 */
		public function onRightClick(event:MouseEvent):void {
			scoreboardControlPresentationModel.rightClickPrimaryActionHandler(event);
		}
		
		
		/**
		 * Builds a list of available options for displaying the Detached scoreboard.
		 */ 
		public function buildScreenOptions():void {
			var screensArray:Array = Screen.screens;
			
			// Clear the existing array to support rescan
			scoreboardWindowOptions = new ArrayCollection;
			// Loop through all the available displays and create a readble identity and 
			// screen dimensions for each display
			for (var i:String in screensArray)
			{
				var bounds:Rectangle = screensArray[i].bounds
				var screenString:String;
				// If screen dimensions match those of the main screen, then we found our main display
				if (bounds.equals(Screen.mainScreen.bounds)){
					screenString="Main Display" + ' (' + bounds.width + '×' + bounds.height + ')';
				} else {
					screenString="Display #" + (parseInt(i)+1).toString() + ' (' + bounds.width + '×' + bounds.height + ')';
				}
				scoreboardWindowOptions.addItem({label:screenString, data:"fullscreen:"+i});
			}
			// Add an option to the bottom for a resizable window.
			scoreboardWindowOptions.addItem({label:"Resizable Window", data:"resizable"});

		} //buildScreenOptions
		
		
		/**
		 * This method dispatches an event to open the manage config popup
		 */
		public function saveConfigClick():void{
			_LOG.debug("Dispatch MenuEvent.OPEN_SAVECONFIG");
			swizDispatcher.dispatchEvent(new MenuEvent(MenuEvent.OPEN_SAVECONFIG));
		}
		
		/**
		 * This method dispatches an event to open the about popup
		 */
		public function aboutClick():void{
			_LOG.debug("Dispatch MenuEvent.OPEN_ABOUT");
			swizDispatcher.dispatchEvent(new MenuEvent(MenuEvent.OPEN_ABOUT));
		}

		
		// Private Methods ------------------------------------------------------------------------
		/**
		 * This method is called when the user answers the "Confirm Close Window" dialogue for closing
		 * an detached scoreboard window. It analyses the CloseEvent to determin which action the 
		 * user chose, and acts accordingly
		 * 
		 * @param event - mx.events.CloseEvent
		 */
		private function confirmCloseWindowHandler(event:CloseEvent):void{
			if(event.detail==Alert.OK) {
				_LOG.debug("Close Scoreboard Confirm OK'd");
				closeWindowedScoreboard();
			}
			else {
				_LOG.debug("Close Scoreboard Confirm Canceled");
			}
		}
			
		// UPDATE FRAMEWORK -----------------------------------------------------------------------
		/**
		 * Using the built-in update framework, this method is called to search for new versions of JamTracker.
		 * It sets the parameters of the framwork and initializes the process.
		 * 
		 * @param showUpdateDialogue - If true the user will see a prompt asking for verification
		 *                             before an update check is done. Default is false
		 * 
		 */
		public function checkForUpdate(showUpdateDialogue:Boolean = false):void {
			// Server-side XML file describing latest update
			_appUpdater.updateURL = ApplicationModel.UPDATE_URL;
			// Do not ask for permission to check for an update. This is controlled by a user setting
			_appUpdater.isCheckForUpdateVisible = showUpdateDialogue;
			// Set the update interval in days
			_appUpdater.delay = 3;				
			// Add specific event listeners
			_appUpdater.addEventListener(UpdateEvent.INITIALIZED, onUpdate, false, 0, true); 
			_appUpdater.addEventListener(ErrorEvent.ERROR, onError, false, 0, true);
			// Initalize the update framework
			_appUpdater.initialize();
		}
		
		/**
		 * This method is used if any error is incurred while applying an update to the application
		 */
		private function onError(event:ErrorEvent):void {
			_LOG.fatal(event.toString());
		}
		
		/**
		 * This method is called once the application update framework has been initialized
		 */
		private function onUpdate(event:UpdateEvent):void {
			_LOG.debug("Checking for updates to current version ["+_appUpdater.currentVersion+"] using descriptor at: " + ApplicationModel.UPDATE_URL);
			_appUpdater.checkNow(); // Go check for an update now
		}
		
		// SWIZ REFERENCE -------------------------------------------------------------------------
		/**
		 * Creates a reference to the instance of Swiz this bean is in. This
		 * allows us to get a hold of manager beans by using:
		 * <code>var vm:MyViewMediator = swiz.beanFactory.getBeanByName("myViewMediator").source as MyViewMediator;</code>
		 */
		public function set swiz(swiz:ISwiz):void
		{
			this._swiz = swiz;
		}
		public function get swiz():ISwiz
		{
			return this._swiz;
		}
		protected var _swiz:ISwiz;

	}
}