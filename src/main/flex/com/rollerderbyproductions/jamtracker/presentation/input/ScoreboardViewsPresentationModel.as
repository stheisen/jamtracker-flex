package com.rollerderbyproductions.jamtracker.presentation.input
{
	import com.rollerderbyproductions.jamtracker.domain.AppImage;
	import com.rollerderbyproductions.jamtracker.domain.ViewCollection;
	import com.rollerderbyproductions.jamtracker.events.ScoreboardEvent;
	import com.rollerderbyproductions.jamtracker.model.ApplicationModel;
	import com.rollerderbyproductions.jamtracker.model.SettingsModel;
	import com.rollerderbyproductions.jamtracker.model.ViewsModel;
	import com.rollerderbyproductions.jamtracker.presentation.AbstractPresentationModel;
	import com.rollerderbyproductions.jamtracker.util.ImageUtility;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.HSlider;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import spark.events.IndexChangeEvent;
	
	public class ScoreboardViewsPresentationModel extends AbstractPresentationModel
	{
		
		[Bindable][Inject] public var settingsModel:SettingsModel;
		[Bindable][Inject] public var viewsModel:ViewsModel;
		[Bindable][Inject] public var scoreboardControl:ScoreboardControlPresentationModel;
		
		
		[Bindable] public var previewMode:Boolean = false;
		[Bindable] public var currentViewState:String = "SCOREBOARD_STATE";
		
		private static const _LOG:ILogger = Log.getLogger("ScoreboardViewsPresentationModel");
		
		// Public Methods -------------------------------------------------------------------------		
		/**
		 * This handels the actions requested by the view mode button bar
		 */
		public function btnBar_changeHandler(event:IndexChangeEvent):void
		{
			var tabName:String;
			
			if (event.target.selectedItem != null) {
				
				tabName = event.target.selectedItem;
				_LOG.debug("View Contol button action ["+tabName+"]");
				
				switch (tabName.toLowerCase()){
					case "main":
						currentViewState="SCOREBOARD_STATE";
						scoreboardControl.dispatchSpecifiedScoreboardViewMode(ViewsModel.MAIN_VIEW);
						break;
					case "pregame":
						currentViewState="PREGAME_STATE";
						scoreboardControl.dispatchSpecifiedScoreboardViewMode(ViewsModel.PREGAME_VIEW);
						break;
					case "intermission":
						currentViewState="INTERMISSION_STATE";
						scoreboardControl.dispatchSpecifiedScoreboardViewMode(ViewsModel.INTERMISSION_VIEW);
						break;
					case "postgame":
						currentViewState="POSTGAME_STATE";
						scoreboardControl.dispatchSpecifiedScoreboardViewMode(ViewsModel.POSTGAME_VIEW);
						break;
					case "curtain":
						currentViewState="CURTAIN_STATE";
						scoreboardControl.dispatchSpecifiedScoreboardViewMode(ViewsModel.CURTAIN_VIEW);
						break;
				}
			}
			
		}
	}		
	
}