package com.rollerderbyproductions.jamtracker.presentation.input
{
	import com.rollerderbyproductions.jamtracker.events.ScoreboardEvent;
	import com.rollerderbyproductions.jamtracker.model.ScoreboardModel;
	import com.rollerderbyproductions.jamtracker.model.ViewsModel;
	import com.rollerderbyproductions.jamtracker.presentation.AbstractPresentationModel;
	
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import spark.events.IndexChangeEvent;
	
	public class ViewControlPresentationModel extends AbstractPresentationModel
	{
		private static const _LOG:ILogger = Log.getLogger("ViewControlPresentationModel");

		
		[Bindable][Inject] public var scoreboard:ScoreboardModel;
		[Bindable][Inject] public var scoreboardControl:ScoreboardControlPresentationModel;

		
		[Bindable] public var buttonText_CurtainToggle:String = "CURTAIN";
		[Bindable] public var buttonActive_CurtainToggle:Boolean = false;
		[Bindable] public var buttonText_JammerImageToggle:String = "JAMMERS";
		
		
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
						scoreboardControl.dispatchSpecifiedScoreboardViewMode(ViewsModel.MAIN_VIEW);
						break;
					case "pregame":
						scoreboardControl.dispatchSpecifiedScoreboardViewMode(ViewsModel.PREGAME_VIEW);
						break;
					case "intermission":
						scoreboardControl.dispatchSpecifiedScoreboardViewMode(ViewsModel.INTERMISSION_VIEW);
						break;
					case "postgame":
						scoreboardControl.dispatchSpecifiedScoreboardViewMode(ViewsModel.POSTGAME_VIEW);
						break;
					case "curtain":
						scoreboardControl.dispatchSpecifiedScoreboardViewMode(ViewsModel.CURTAIN_VIEW);
						break;
				}
			}
		
		}

		/**
		 * This toggles the visibility of the jammer image on the main scoreboard
		 */	
		public function toggleJammerImage_ClickHandler(event:Event):void {
			if (event.target.selected){
				scoreboard.hideJammerImageArea = true;
 			    swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.HIDE_JAMMER_IMAGES));
			} else {
				scoreboard.hideJammerImageArea = false;
				swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.RESTORE_JAMMER_IMAGES));
			}
		}
	
	}
}