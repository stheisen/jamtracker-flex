package com.rollerderbyproductions.jamtracker.presentation.popup
{
	
	
	import com.rollerderbyproductions.jamtracker.events.MenuEvent;
	import com.rollerderbyproductions.jamtracker.presentation.AbstractPresentationModel;
	import com.rollerderbyproductions.jamtracker.presentation.input.SettingsConfigPresentationModel;
	import com.rollerderbyproductions.jamtracker.views.popup.About;
	
	import flash.display.DisplayObject;
	
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.PopUpManager;
	
	import spark.components.TitleWindow;

	public class AboutPresentationModel extends AbstractPresentationModel
	{
		
		private var _LOG:ILogger = Log.getLogger("AboutPresentationModel"); 
		private var _view:TitleWindow = null;
		
		[Inject] public var settingsConfig:SettingsConfigPresentationModel;	


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
		[EventHandler("MenuEvent.OPEN_ABOUT")]
		public function showConfigMView(event:MenuEvent):void 
		{			
			_view = TitleWindow(PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, About, true));
			PopUpManager.centerPopUp(_view);
			// Setting isPopUp to false prevents it from being moved.
			_view.isPopUp = false;
		}

		public function closeWindow():void {
			// Remove the popup, and resume keyboard shortcuts
			PopUpManager.removePopUp(_view);
			settingsConfig.resumeKeyboardShortcuts();
		}
		

		
	}
}