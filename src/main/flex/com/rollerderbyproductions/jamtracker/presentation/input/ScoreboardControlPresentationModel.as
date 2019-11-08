package com.rollerderbyproductions.jamtracker.presentation.input
{
	import com.rollerderbyproductions.jamtracker.domain.AppImage;
	import com.rollerderbyproductions.jamtracker.domain.Clock;
	import com.rollerderbyproductions.jamtracker.domain.Team;
	import com.rollerderbyproductions.jamtracker.events.BoutStatsEvent;
	import com.rollerderbyproductions.jamtracker.events.ControllerEvent;
	import com.rollerderbyproductions.jamtracker.events.PlayerEvent;
	import com.rollerderbyproductions.jamtracker.events.ScoreboardEvent;
	import com.rollerderbyproductions.jamtracker.jtstats.BoutStatistics;
	import com.rollerderbyproductions.jamtracker.model.ApplicationModel;
	import com.rollerderbyproductions.jamtracker.model.AssetModel;
	import com.rollerderbyproductions.jamtracker.model.ScoreboardModel;
	import com.rollerderbyproductions.jamtracker.model.ScoringModel;
	import com.rollerderbyproductions.jamtracker.model.SettingsModel;
	import com.rollerderbyproductions.jamtracker.model.TeamsModel;
	import com.rollerderbyproductions.jamtracker.model.ViewsModel;
	import com.rollerderbyproductions.jamtracker.presentation.AbstractPresentationModel;
	import com.rollerderbyproductions.jamtracker.presentation.MainPresentationModel;
	import com.rollerderbyproductions.jamtracker.views.input.ScoreboardConfig;
	
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.sampler.stopSampling;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import mx.controls.Alert;
	import mx.core.BitmapAsset;
	import mx.core.ByteArrayAsset;
	import mx.core.FlexGlobals;
	import mx.core.mx_internal;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.graphics.codec.PNGEncoder;
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class ScoreboardControlPresentationModel extends AbstractPresentationModel 
	{
		[Bindable][Inject] public var applicationModel:ApplicationModel;		
		[Bindable][Inject] public var settingsModel:SettingsModel;
		[Bindable][Inject] public var scoring:ScoringModel;
		[Bindable][Inject] public var teamsModel:TeamsModel;
		[Bindable][Inject] public var scoreboard:ScoreboardModel;
		[Bindable][Inject] public var boutStats:BoutStatistics;


		public const JAM_STOPPED:String = "JAM_STOPPED";
		public const JAM_EXPIRED:String = "JAM_EXPIRED";
		public const TIMEOUT_EXPIRED:String = "TIMEOUT_EXPIRED";
		public const NONE:String = "NONE";
		
		private const LABEL_COUNTDOWN:String = "COUNTDOWN";
		private const LABEL_COUNTDOWNEND:String = "PAUSE CNT";
		private const LABEL_COUNTDOWNRESET:String = "RESET CNT";
		private const LABEL_END_JAM:String = "END JAM";
		private const LABEL_INTERMISSION:String = "INTERMISSION";
		private const LABEL_INTERMISSIONEND:String = "PAUSE INT";
		private const LABEL_INTERMISSIONRESET:String = "RESET INT";
		private const LABEL_LEADJAMMER:String = "LEAD JAMMER";
		private const LABEL_LEADJAMMERUNDO:String = "UNDO LEAD";
		private const LABEL_LEADJAMMERNONE:String = "NO LEAD JAMMER";
		private const LABEL_LEADJAMMERNONEUNDO:String = "UNDO NO LEAD";
		private const LABEL_LEADJAMMERLOST:String = "LOST LEAD";
		private const LABEL_OFFICIAL_TIMEOUT:String = "OFFICIAL'S TIMEOUT";
		private const LABEL_OVERTIME:String = "OVERTIME";
		private const LABEL_RESTART_BREAK:String = "RESTART LINEUP";
		private const LABEL_START_BREAK:String = "START LINEUP";
		private const LABEL_START_JAM:String = "START JAM";
		private const LABEL_PREPAREPERIOD:String = "NEXT PERIOD";
		private const LABEL_PREPAREOVERTIME:String = "OVETIME";
		private const LABEL_RESET:String = "RESET";
		private const LABEL_PTSTHISJAM:String = "PTS THIS JAM";
		private const LABEL_PTSPREVJAM:String = "PTS PREV JAM";
		
		public const TOOLTIP_COUNTDOWN:String = "Start Countdown Clock";
		public const TOOLTIP_COUNTDOWNEND:String = "Pause Countdown Clock";
		public const TOOLTIP_COUNTDOWNRESET:String = "Reset Countdown Clock";
		public const TOOLTIP_HOMETIMEOUT:String = "Timeout (C)";
		public const TOOLTIP_HOMEJAMSCORE_INCREMENT:String = "Increment Jam Score (Q)";
		public const TOOLTIP_HOMEJAMSCORE_DECREMENT:String = "Decrement Jam Score (W)";
		public const TOOLTIP_HOMEJAMSCORE_INCREMENT3:String = "Increment Jam Score by 3 (A)";
		public const TOOLTIP_HOMEJAMSCORE_INCREMENT4:String = "Increment Jam Score by 4 (S)";
		public const TOOLTIP_HOMELEADJAMMER:String = "Lead Jammer (G)";
		public const TOOLTIP_INTERMISSION:String = "Start Intermission Clock";
		public const TOOLTIP_INTERMISSIONEND:String = "Pause Intermission Clock";
		public const TOOLTIP_INTERMISSIONRESET:String = "Reset Intermission Clock";
		public const TOOLTIP_NOLEADJAMMER:String = "No Lead Jammer (H)";
		public const TOOLTIP_OFFICIALTIMEOUT:String = "Official's Timeout (N)";
		public const TOOLTIP_PREPARENEXTPERIOD:String = "Prepare Next Period (B)";
		public const TOOLTIP_PREPAREOVERTIME:String = "Prepare for Overtime (B)";
		public const TOOLTIP_RESET:String = "Reset Scoreboard (B)";
		public const TOOLTIP_STARTBREAK:String = "Start/Resume Break (V)";
		public const TOOLTIP_STARTJAM:String = "Start/Stop Jam (B)";
		public const TOOLTIP_VISITORTIMEOUT:String = "Timeout (,)";
		public const TOOLTIP_VISITORJAMSCORE_INCREMENT:String = "Increment Jam Score (])";
		public const TOOLTIP_VISITORJAMSCORE_DECREMENT:String = "Decrement Jam Score ([)";
		public const TOOLTIP_VISITORJAMSCORE_INCREMENT3:String = "Increment Jam Score by 3 (;)";
		public const TOOLTIP_VISITORJAMSCORE_INCREMENT4:String = "Increment Jam Score by 4 (\')";
		public const TOOLTIP_VISITORLEADJAMMER:String = "Lead Jammer (J)";
		
		private const STATE_NEWPERIOD:String = "NEW PERIOD";
		private const STATE_JAM:String = "JAM";
		private const STATE_JAMEXPIRED:String = "JAM EXPIRED";
		private const STATE_JAMSTOPPED:String = "JAM STOPPED";
		private const STATE_BREAK:String = "BREAK";
		private const STATE_INTERMISSION:String = "INTERMISSION";
		private const STATE_INTERMISSION_PAUSE:String = "INTERMISSION PAUSE";
		private const STATE_INTERMISSION_EXPIRED:String = "INTERMISSION EXPIRED";
		private const STATE_OFFICALTIMEOUT_BREAK:String = "OFFICIAL BREAK TIMEOUT";
		private const STATE_OFFICALTIMEOUT_JAM:String = "OFFICIAL JAM TIMEOUT";
		private const STATE_OVERTIMEPREPARE:String = "OVERTIME PREPARE";
		private const STATE_OVERTIMEJAM:String = "OVERTIME JAM";
		private const STATE_OVERTIMEJAMSTOPPED:String = "OVERTIME JAM STOPPED";
		private const STATE_TIMEOUTEXPIRED:String = "TIMEOUT EXPIRED";
		private const STATE_HOMETIMEOUT:String = "HOME TIMEOUT";
		private const STATE_VISITORTIMEOUT:String = "VISITOR TIMEOUT";
		private const STATE_ENDPERIOD:String = "END PERIOD";
		private const STATE_ENDGAME:String = "END GAME";
		
		[Bindable] public var actionActive_modifyJamScore:Boolean = false;
		[Bindable] public var buttonText_breakStartToggle:String = LABEL_START_BREAK;
		[Bindable] public var buttonText_intermissionToggle:String = LABEL_COUNTDOWN;		
		[Bindable] public var buttonText_primaryActionToggle:String = LABEL_START_JAM;
		[Bindable] public var buttonTooltip_primaryActionToggle:String = TOOLTIP_STARTJAM;
		[Bindable] public var buttonText_officialTimeoutToggle:String = LABEL_OFFICIAL_TIMEOUT;
		[Bindable] public var buttonText_visitorLeadJamToggle:String = LABEL_LEADJAMMER; 
		[Bindable] public var buttonText_homeLeadJamToggle:String = LABEL_LEADJAMMER;
		[Bindable] public var buttonText_noLeadJammer:String = LABEL_LEADJAMMERNONE;
		[Bindable] public var buttonToooltip_intermission:String = TOOLTIP_INTERMISSION;
		[Bindable] public var buttonActive_breakStartToggle:Boolean = false;
		[Bindable] public var buttonActive_homeLeadJammer:Boolean = false;
		[Bindable] public var buttonActive_homeTimeout:Boolean = false;
		[Bindable] public var buttonActive_noLeadJammer:Boolean = false;
		[Bindable] public var buttonActive_visitorLeadJammer:Boolean = false;
		[Bindable] public var buttonActive_visitorTimeout:Boolean = false;
		[Bindable] public var buttonActive_officialTimeout:Boolean = false;
		[Bindable] public var buttonActive_intermission:Boolean = false;
		[Bindable] public var buttonActive_primaryActionToggle:Boolean = true;
		[Bindable] public var jamPointsControlEnabled:Boolean = false;		
		[Bindable] public var buttonVisible_breakStartToggle:Boolean = true;
		[Bindable] public var currentStateDescription:String;
		[Bindable] public var currentClockLabel:String;
		[Bindable] public var currentControlViewState:String = "scoring";
		[Bindable] public var scoreboardViewState:String = ViewsModel.MAIN_VIEW;
		[Bindable] public var labelJamPointsType:String = LABEL_PTSTHISJAM;
		[Bindable] public var firstJamEnded:Boolean = false;
		
		private var _lastTick:int = 0;
		private var _timer:Timer;
		private var _currentState:String;
		private var _previousState:String;
		private var _gameClockExpired:Boolean = false;
		private var _setForNextPeriod:Boolean = false;
		private var _gameInOvertime:Boolean = false;
		private var _gameOver:Boolean = false;
		private var _gameInProgress:Boolean = false;
			
		private static const _LOG:ILogger = Log.getLogger("ScoreboardControlPresentationModel");

		
		// ----------------------------------------------------------------------------------------
		// Timer Events 
		// ----------------------------------------------------------------------------------------
		/** 
		 * This is the initilization routine executed after all the SWIZ injections have completed.
		 * This is executed by SWIZ similar to creationComplete
		 **/
		public function initalizeController():void {
			
			_LOG.debug("Initalize Timer/Scoreboard");
			_lastTick = getTimer();
			// this timer event will take place 20 times per second 
			_timer = new Timer(1000/20);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			_timer.start();
			// reset the scoreboard for a new bout
			resetScoreboard();	
		}
		
		/** 
		 * When this module is unloaded, the timer is stopped 
		 **/
		[PreDestroy]
		public function destroyTimer():void {
			_LOG.debug("Stop Timer");
			_timer.stop();
		}
		
		/**
		 * Toggles the view state of the scoring control panel.  This will switch the controller from a
		 * scoring view, to a corrections view
		 */
		public function toggleViewState():void {
			if (currentControlViewState == "scoring") currentControlViewState = "corrections" else currentControlViewState = "scoring";
		}
		
		// ----------------------------------------------------------------------------------------
		// Action handlers
		// ----------------------------------------------------------------------------------------
		
		public function actionHandler_adjustCurrentJamScore(changeValue:int, team:String, adjType:String): void {
			if (jamPointsControlEnabled) actionAdjustCurrentJamScore(changeValue, team, adjType);
			updateUI();
		}
		
		/**
		 * Handles lead jammer button action
		 * @param scoreType - TeamsModel.HOME_TEAM, TeamsModel.VISITING_TEAM, NONE
		 */
		public function actionHandler_leadJammer(scoreType:String):void {
			if (jamPointsControlEnabled) actionLeadJammerChange(scoreType)
			updateUI();
		}
		
		public function actionHandler_noLeadLostLeadJammer(): void {
			actionNoLeadLostLead();
			updateUI();
		}
		
		public function actionHandler_primaryAction():void {
			actionPrimary();
			updateUI();
		}
		
		public function actionHandler_officialTimeout(): void {
			actionOfficialTimeoutStart();
			updateUI();
		}
		
		
		// ----------------------------------------------------------------------------------------
		// Private Methods
		// ----------------------------------------------------------------------------------------
		
		/**
		 * Adjust the specified team current jam score by the specified changeValue (positive or negative)
		 * Changing this value, also influences the total team score by the same changeValue
		 * 
		 * @param adjValue - The amount to change the current jam score by (positive or negative)
		 * @param team - TeamsModel.HOME_TEAM or TeamsModel.VISITING_TEAM
		 * @param adjustmentType - 
		 */
		private function actionAdjustCurrentJamScore(adjValue:int, team:String, adjType:String):void {
			
			switch(team){
				case TeamsModel.HOME_TEAM:
					if (adjType == ScoringModel.SET){
						_LOG.debug("Set the home points This jam ["+scoring.homeTeam.score+"] score to: [" + adjValue +"]");
						// Remove all the points this jam that were added to the total score
						scoring.homeTeam.score = scoring.homeTeam.score - scoring.homeTeam.pointsThisJam;
						// set the new points this jam
						scoring.homeTeam.pointsThisJam = adjValue;
					} else {
						_LOG.debug("Update the home current Jam score ["+scoring.homeTeam.pointsThisJam+"] score by: [" + adjValue +"]");
						scoring.homeTeam.pointsThisJam = scoring.homeTeam.pointsThisJam + adjValue;				
					}
					// If the score goes below zero, then set it to zero.
					if (scoring.homeTeam.pointsThisJam < 0){ 
						scoring.homeTeam.pointsThisJam = 0; 
						adjValue = 0; 
					}
					// If the score is over 99, then make it 99
					if (scoring.homeTeam.pointsThisJam > 99){ 
						scoring.homeTeam.pointsThisJam = 99; 
						adjValue = 0; 
					}
					// update the total score for this team
					adjustTotalScore(adjValue, TeamsModel.HOME_TEAM, adjType);
					// if this is not a jam or official JAM timeout, then we can update the previous jam points as well
					if ((_currentState != STATE_JAM) && (_currentState != STATE_OFFICALTIMEOUT_JAM))
						scoring.homeTeam.pointsPreviousJam = scoring.homeTeam.pointsThisJam;
					break;
				case TeamsModel.VISITING_TEAM:
					if (adjType == ScoringModel.SET){
						_LOG.debug("Set the visitor points This jam ["+scoring.visitorTeam.score+"] score to: [" + adjValue +"]");
						// Remove all the points this jam that were added to the total score
						scoring.visitorTeam.score = scoring.visitorTeam.score - scoring.visitorTeam.pointsThisJam;
						// set the new points this jam
						scoring.visitorTeam.pointsThisJam = adjValue;
					} else {
						_LOG.debug("Update the visitor current Jam score ["+scoring.visitorTeam.pointsThisJam+"] score by: [" + adjValue +"]");
						scoring.visitorTeam.pointsThisJam = scoring.visitorTeam.pointsThisJam + adjValue;				
					}
					// If the score goes below zero, then set it to zero.
					if (scoring.visitorTeam.pointsThisJam < 0){ 
						scoring.visitorTeam.pointsThisJam = 0; 
						adjValue = 0; 
					}
					// If the score is over 99, then make it 99
					if (scoring.visitorTeam.pointsThisJam > 99){ 
						scoring.visitorTeam.pointsThisJam = 99; 
						adjValue = 0; 
					}
					// update the total score for this team
					adjustTotalScore(adjValue, TeamsModel.VISITING_TEAM, adjType);
					// if this is not a jam or official JAM timeout, then we can update the previous jam points as well
					if ((_currentState != STATE_JAM) && (_currentState != STATE_OFFICALTIMEOUT_JAM))
						scoring.visitorTeam.pointsPreviousJam = scoring.visitorTeam.pointsThisJam;
					break;
			}
			// If the game is over, then check for overtime conditions
			if ((_currentState == STATE_ENDGAME) || (_currentState == STATE_OVERTIMEPREPARE)){
				if (scoring.homeTeam.score == scoring.visitorTeam.score){
					setCurrentState(STATE_OVERTIMEPREPARE);
				} else {
					setCurrentState(STATE_ENDGAME);
				}
			}	
		} 
		
		
		
		
		/**
		 * Updates the lead jammer indicator. This will also update the total jams lead
		 * for the cooresponding team.  Setting on for a team will increase the total jams lead,
		 * setting again for the same team will desactivate the indicator, and decrement
		 * the corresponding team's total jams lead
		 * 
		 * @param scoreType - TeamsModel.HOME_TEAM, TeamsModel.VISITING_TEAM, NONE
		 */
		private function actionLeadJammerChange(scoreType:String):void {
			var updateLeadStatus:Boolean = true;
			
			switch (scoreType){
				case TeamsModel.HOME_TEAM: 
					// If home is the lead jammer, then remove their lead status and decrement their total jams lead
					if (scoring.homeTeam.leadJammer) { 
						_LOG.debug("Decrease Home Jams Lead"  + logGameStatus())
						scoring.homeTeam.jamsLead --; 
						scoring.homeTeam.leadJammer = false;						
						// Otherwise activate their lead status and increment their total jams lead
					} else { 
						_LOG.debug("Increase Home Jams Lead"  + logGameStatus())
						scoring.homeTeam.jamsLead ++; 
						scoring.homeTeam.leadJammer = true; 
					}
					break;
				case TeamsModel.VISITING_TEAM:
					// If visitor is the lead jammer, then remove their lead status and decrement their total jams lead
					if (scoring.visitorTeam.leadJammer) {
						_LOG.debug("Decrease Visitor Jams Lead"  + logGameStatus())
						scoring.visitorTeam.jamsLead --; 
						scoring.visitorTeam.leadJammer = false;
						// Otherwise activate their lead status and increment their total jams lead
					} else { 
						_LOG.debug("Increase Visitor Jams Lead"  + logGameStatus())
						scoring.visitorTeam.jamsLead ++;
						scoring.visitorTeam.leadJammer = true; 
					}
					break;
			}
			// update the lead jammer indicators
			if (updateLeadJammerStatus()) updateLeadJammerStatuses();
		} 
		
		
		/**
		 * This action determines what takes place with the "NO LEAD JAMMER" or 
		 * "LOST LEAD" button is pressed.
		 */
		private function actionNoLeadLostLead():void {
			// If there is no lead jammer when this action takes place, then
			// remove the no load jammer status and re-enable the controls
			if (scoring.noLeadJammer){
				_LOG.debug("Re-enable the lead jammer controls");
				scoring.noLeadJammer = false;
				// If the home team had lost the lead jammer status, then re-enabling
				// the lead jammer controls MUST decrement the total jams lead
				if (scoring.homeTeam.lostLead){
					_LOG.debug("Undo lost lead decrement Home Team Jams lead");
					scoring.homeTeam.jamsLead --;
					scoring.homeTeam.lostLead = false;
				}
				// If the visiting team had lost the lead jammer status, then re-enabling
				// the lead jammer controls MUST decrement the total jams lead
				if (scoring.visitorTeam.lostLead){
					_LOG.debug("Undo lost lead decrement Visiting Team Jams lead");
					scoring.visitorTeam.jamsLead --;
					scoring.visitorTeam.lostLead = false;
				}
			} else {
				// If the home team is lead jammer, then they just lost it
				if (scoring.homeTeam.leadJammer){
					_LOG.debug("Lead Jammer Status Lost - Home Team");
					scoring.homeTeam.leadJammer = false;
					scoring.homeTeam.lostLead = true;
					// If the visiting team is lead jammer, then they just lost it
				} else if (scoring.visitorTeam.leadJammer) {
					_LOG.debug("Lead Jammer Status Lost - Visiting Team");
					scoring.visitorTeam.leadJammer = false;
					scoring.visitorTeam.lostLead = true;
					// Otherwise, there truly is no lead jammer for this Jam
				} else {
					_LOG.debug("No lead jammer for this Jam");
				}
				scoring.noLeadJammer = true;
			}
		}
		
		
		/**
		 * This action fires up the official timeout and determines how to behave based
		 * on the state when this action was invoked.
		 */
		private function actionOfficialTimeoutStart():void
		{
			
			// stop the game clock
			scoring.gameClock.stop();
			// Start and display the official timeout clock
			scoring.officialTimeoutClock.start();
			
			switch (_currentState){
				// This is a BREAK Timeout
				case STATE_BREAK:
					setCurrentState(STATE_OFFICALTIMEOUT_BREAK);
					// If we are displaying official timeout duration then do so, otherwise keep the break clock on the screen
					if (settingsModel.displayOfficialTimeoutDuration){				
						scoring.breakClock.stop(true,false);
					} else {
						scoring.breakClock.stop(false,false);					
					}
					break;
				// This is a Jam Timeout ~~ NOTE: The next action must be Stop Jam
				case STATE_JAM:
					setCurrentState(STATE_OFFICALTIMEOUT_JAM)
					// If we are displaying official timeout duration then do so, otherwise keep the jam clock on the screen
					if (settingsModel.displayOfficialTimeoutDuration){				
						// Just stop the clock so it remains on the screen
						scoring.jamClock.stop(true,false);
						// Start and display the official timeout clock
						scoring.officialTimeoutClock.start();
					} else {
						scoring.jamClock.stop(false,false);					
					}
					break;
				case STATE_HOMETIMEOUT:
				case STATE_VISITORTIMEOUT:
				case STATE_TIMEOUTEXPIRED:
					setCurrentState(STATE_OFFICALTIMEOUT_BREAK);
					// Stop, hide and reset the timeout clock
					scoring.timeoutClock.stop(true,true);
					// If we are displaying official timeout duration then do so, otherwise keep the jam clock on the screen
					if (settingsModel.displayOfficialTimeoutDuration){				
						// Start and display the official timeout clock
						scoring.officialTimeoutClock.start();
					} else {
						// Show the break clock
						scoring.breakClock.isVisible=true;
					}
					break;
			}
		} 		
		
		
		/**
		 * This is the primary action of the scoring appliction
		 */
		private function actionPrimary():void {	
			_LOG.debug("Process primary action for current state ["+_currentState+"]"  + logGameStatus());
			// The primary action button launches activities based on the current state of the event			
			switch (_currentState){
				case STATE_JAM:
				case STATE_OVERTIMEJAM:
					actionJamStop();
					break;
				case STATE_OFFICALTIMEOUT_JAM:
					// Hide the official timeout clock first
					scoring.officialTimeoutClock.stop(true,true);
					actionJamStop();
					break;
				case STATE_OFFICALTIMEOUT_BREAK:
					// Hide the official timeout clock first
					scoring.officialTimeoutClock.stop(true,true);
					actionJamStart();
					break;
				case STATE_ENDPERIOD:
					confirmPrepareNextPeriod();
					break;
				case STATE_INTERMISSION:
				case STATE_INTERMISSION_PAUSE:
				case STATE_INTERMISSION_EXPIRED:
					// If the game is over, then prompt the user to reset the scoreboard
					if (_gameOver ){
						confirmScoreboardReset();
						// If the board NOT been set up for a new peroid (and the game is not over), then do so now
					} else if (! _setForNextPeriod) {
						confirmPrepareNextPeriod();
						// Otherwise ...
					} else {
						// Set the current state to a new period
						setCurrentState(STATE_NEWPERIOD);
						// Hide any non period clock being displayed
						hideAllNonPeriodClocks();
						// Start the next jam!
						actionJamStart();	
						// Stop and hide the running intermission clock
						intermissionReset();
					}
					break;
				case STATE_ENDGAME:
					confirmScoreboardReset();
					break;
				case STATE_OVERTIMEPREPARE:
					overtimePrepare();
					break;
				default:
					actionJamStart();
			}
		}
		
		
		private function updateUI():void {
			setLeadJammerButtonState();
			setTimeoutButtonState();
			updateCurrentStateContols();
		}
		

		// ----------------------------------------------------------------------------------------
		// Private UI State Setting Methods
		// ----------------------------------------------------------------------------------------
		
		/**
		 * Determines the state of the lead jammer buttons based on the current bout state
		 */
		private function setLeadJammerButtonState():void {
			_LOG.debug("setLeadJammerButtonState [" + _currentState + "]"); 
			switch (_currentState){
				case STATE_ENDGAME:
				case STATE_NEWPERIOD:
				case STATE_INTERMISSION:
				case STATE_INTERMISSION_PAUSE:
				case STATE_INTERMISSION_EXPIRED:				
				case STATE_OVERTIMEJAM:
				case STATE_OVERTIMEJAMSTOPPED:
					manageJamButtonControls(false, false, false, false);
					break;
				default:
					if (scoring.homeTeam.leadJammer) manageJamButtonControls(true, true, false, true);
					else if (scoring.visitorTeam.leadJammer) manageJamButtonControls(false, true, true, true);
					else if (scoring.homeTeam.lostLead || scoring.visitorTeam.lostLead) manageJamButtonControls(false, true, false, true);
					else if (scoring.noLeadJammer) manageJamButtonControls(false, true, false, true);
					else manageJamButtonControls(true, true, true, true);
					break;
			}		
		}
		
		/**
		 * Determines the state of the timeout buttons based on the current bout state
		 */
		private function setTimeoutButtonState():void {
			_LOG.debug("setTimeoutButtonState [" + _currentState + "]");
			var leftTimeoutActive:Boolean;
			var rightTimeoutActive:Boolean;
			
			switch (_currentState){
				case STATE_BREAK:
				case STATE_TIMEOUTEXPIRED:
				case STATE_JAMSTOPPED:
					if (scoring.homeTeam.timeoutsLeft == 0) leftTimeoutActive = false; else leftTimeoutActive = true;
					if (scoring.visitorTeam.timeoutsLeft == 0) rightTimeoutActive = false; else rightTimeoutActive = true;
					manageTimeoutButtonControl(leftTimeoutActive, true, rightTimeoutActive);
					break;
				case STATE_OFFICALTIMEOUT_BREAK:
					manageTimeoutButtonControl(true, false, true);
					break;
				case STATE_JAM:
				case STATE_HOMETIMEOUT:
				case STATE_VISITORTIMEOUT:
					manageTimeoutButtonControl(false, true, false);
					break;
				default:
					manageTimeoutButtonControl(false, false, false);
					break;
			}
			
			
		}
		
		// ----------------------------------------------------------------------------------------
		// Private UI State Management Methods
		// ----------------------------------------------------------------------------------------
		
		/**
		 * This sets the active/deactive state of the jam points control buttons
		 * 
		 * @param leftLeadActive  [True|False] True to activate or false to deactivate this button
		 * @param noLeadLostLeadActive    [True|False] True to activate or false to deactivate this button 
		 * @param rightLeadActive [True|False] True to activate or false to deactivate this button
		 * @param jamPtsControls  [True|False] True to activate or false to deactivate these buttons
		 */
		private function manageJamButtonControls(homeLeadActive:Boolean , noLeadLostLeadActive:Boolean , visitorLeadActive:Boolean, jamPtsControls:Boolean ): void {
			_LOG.debug("manageJamButtonControls: currentstate["+_currentState+"], homeLeadActive["+homeLeadActive+"], noLeadLostLeadActive["+noLeadLostLeadActive+"], visitorLeadActive["+visitorLeadActive+"], jamPtsControls["+jamPtsControls+"]");
			if (homeLeadActive){
				// If the home team is lead, provide an UNDO button
				if (scoring.homeTeam.leadJammer) buttonText_homeLeadJamToggle = LABEL_LEADJAMMERUNDO else buttonText_homeLeadJamToggle = LABEL_LEADJAMMER;
				buttonActive_homeLeadJammer = true;
			} else {
				if (scoring.homeTeam.lostLead) buttonText_homeLeadJamToggle = LABEL_LEADJAMMERLOST else buttonText_homeLeadJamToggle = LABEL_LEADJAMMER; 
				buttonActive_homeLeadJammer = false;
			}
			if (noLeadLostLeadActive){
				if (scoring.homeTeam.leadJammer || scoring.visitorTeam.leadJammer) buttonText_noLeadJammer = LABEL_LEADJAMMERLOST;
				else if ( scoring.homeTeam.lostLead || scoring.visitorTeam.lostLead ) buttonText_noLeadJammer = LABEL_LEADJAMMERNONEUNDO;
				else if ( scoring.noLeadJammer ) buttonText_noLeadJammer = LABEL_LEADJAMMERNONEUNDO;
				else buttonText_noLeadJammer = LABEL_LEADJAMMERNONE;
				buttonActive_noLeadJammer = true;
			} else {
				buttonText_noLeadJammer = LABEL_LEADJAMMERNONE;
				buttonActive_noLeadJammer = false;
			}
			if (visitorLeadActive){
				// If the home team is lead, provide an UNDO button
				if (scoring.visitorTeam.leadJammer) buttonText_visitorLeadJamToggle = LABEL_LEADJAMMERUNDO else buttonText_visitorLeadJamToggle = LABEL_LEADJAMMER;
				buttonActive_visitorLeadJammer = true;
			} else {
				if (scoring.visitorTeam.lostLead) buttonText_visitorLeadJamToggle = LABEL_LEADJAMMERLOST else buttonText_visitorLeadJamToggle = LABEL_LEADJAMMER; 
				buttonActive_visitorLeadJammer = false;
			}
			if (jamPtsControls) actionActive_modifyJamScore = true; else actionActive_modifyJamScore = false;
		}
		
		
		/**
		 * This sets the active/deactive state of the timeout control buttons
		 * 
		 * @param homeTimeout     [True|False] True to activate or false to deactivate this button
		 * @param officialTimeout [True|False] True to activate or false to deactivate this button
		 * @param visitorTimeout  [True|False] True to activate or false to deactivate this button
		 */
		private function manageTimeoutButtonControl(homeTimeout:Boolean, officialTimeout:Boolean, visitorTimeout:Boolean):void {
			if (homeTimeout) buttonActive_homeTimeout = false; else  buttonActive_homeTimeout = true;
			if (officialTimeout) buttonActive_officialTimeout = false; else  buttonActive_officialTimeout = true;
			if (visitorTimeout) buttonActive_visitorTimeout = false; else  buttonActive_visitorTimeout = true;	
		}

		
		
		// ----------------------------------------------------------------------------------------
		// Other Private Methods
		// ----------------------------------------------------------------------------------------

		/**
		 * Increments/Decrements or sets the total team score for the specified team
		 * 
		 * @param adjustmentValue - the number by which to adjust the total score
		 * @param teamSide - [TeamsModel.HOME_TEAM|TeamsModel.VISITING_TEAM]
		 * @param adjustmentType - [ScoringModel.SET|ScoringModel.INCREMENT] - set or increment adjustment type
		 */
		private function adjustTotalScore(adjValue:int, team:String, adjType:String): void{
			switch(team){
				case TeamsModel.HOME_TEAM:
					if (adjType == ScoringModel.SET){
						_LOG.debug("Set the home team score ["+scoring.homeTeam.score+"] to: [" + adjValue +"]");
						scoring.homeTeam.score = adjValue;
					} else {		
						_LOG.debug("Update the home team score ["+scoring.homeTeam.score+"] adjust by: [" + adjValue +"]");
						scoring.homeTeam.score = scoring.homeTeam.score + adjValue;
					}
					// If the score goes below zero, then set it to zero.
					if (scoring.homeTeam.score < 0) scoring.homeTeam.score = 0;
					if (scoring.homeTeam.score > 999) scoring.homeTeam.score = 999;
					_LOG.debug("Set the home team score ["+scoring.homeTeam.score+"]");			
					break;
				case TeamsModel.VISITING_TEAM:
					if (adjType == ScoringModel.SET){
						_LOG.debug("Set the visitor team score ["+scoring.visitorTeam.score+"] to: [" + adjValue +"]");
						scoring.visitorTeam.score = adjValue;
					} else {
						_LOG.debug("Update the visitor team score ["+scoring.visitorTeam.score+"] adjust by: [" + adjValue +"]");
						scoring.visitorTeam.score = scoring.visitorTeam.score + adjValue;			
					}
					// If the timeout count goes below zero, then set it to zero.
					if (scoring.visitorTeam.score < 0) scoring.visitorTeam.score = 0;
					if (scoring.visitorTeam.score > 999) scoring.visitorTeam.score = 999;
					_LOG.debug("Set the left team score ["+scoring.visitorTeam.score+"]");			
					break;
			}
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		// ----------------------------------------------------------------------------------------
		// Activity based actions
		// ----------------------------------------------------------------------------------------
		/**
		 * This action starts or resumes the break
		 */
		private function actionBreakStart():void {
			// Reset timeout clock
			scoring.timeoutClock.stop(true, true);
			// Set a new current state
			setCurrentState(STATE_BREAK);
			// Hide all the clock but the period clock.
			// We do this because not sure what is showing 
			hideAllNonPeriodClocks();
			// If the game is almost over....
			// If the game clock is less than then length of the break clock reset value, then set the
			// break clock to the length of the game clock so they end together... fancy huh?
			// v0.2.2 :: Added an option to dissable this feature
			if ((scoring.gameClock.timeRemaining < scoring.breakClock.resetValue) &&
				(_previousState != STATE_HOMETIMEOUT && _previousState != STATE_VISITORTIMEOUT) &&
				(settingsModel.synchBreakClockwithGameClock)){
				_LOG.debug("Not enough time for a full break. Break reset value ["+scoring.breakClock.resetValue+"ms]" + " Game Clock Time ["+scoring.gameClock.timeRemaining+"ms]");
				scoring.breakClock.timeRemaining = scoring.gameClock.timeRemaining;		
			} else {
				scoring.breakClock.resetClock();
			}
			
			// Activate the break clock, and make it visible
			scoring.breakClock.start();
			// Deactivate the break start toggle button
			buttonActive_breakStartToggle = false;
			// Clear all timeout indicators
			timeoutsClearAllIndicators();
			// Update controls and scoreboard based on the current state
			updateCurrentStateContols();
			
			// If this is a break start from a team timout, then stop and reset the timout clock
			if (_previousState == STATE_HOMETIMEOUT || _previousState == STATE_VISITORTIMEOUT)
				scoring.timeoutClock.stop(true,true);
			// If we are coming from an official timeout then hide and reset that clock
			if (_previousState == STATE_OFFICALTIMEOUT_JAM || _previousState == STATE_OFFICALTIMEOUT_BREAK) 
				scoring.officialTimeoutClock.stop(true,true);
		}
		
		
		/**
		 * This action starts the next jam
		 */
		public function actionJamStart():void
		{					
			// If this is a new period, then set the controlls appropriatly
			if (_currentState == STATE_NEWPERIOD) periodStart();
			// Set a new current state. Determine if this is an overitime jam, or "normal" jam
			if (_currentState != STATE_OVERTIMEJAMSTOPPED) setCurrentState(STATE_JAM) else setCurrentState(STATE_OVERTIMEJAM);
			// See if this is the end of the period.
			if (!periodHasEnded()){
				// activate game and jam clocks	
				scoring.gameClock.start();
				scoring.jamClock.start();
				// Deactivate and reset the break and timeout clocks
				scoring.breakClock.stop(true, true);
				scoring.timeoutClock.stop(true, true);			
				// Clear timeout indicators
				timeoutsClearAllIndicators();
				// Increment the Jam number
				jamNumberChange(1);
				// Reset the Jam Scores
				currentJamScoreReset();
				// Clear lead jammers
				leadJammerReset();
				// Set break button
				buttonActive_breakStartToggle = false;
				// Set button labels
				buttonText_primaryActionToggle = LABEL_END_JAM
				buttonText_officialTimeoutToggle = LABEL_OFFICIAL_TIMEOUT;
				// Update controls and scoreboard based on the current state
				updateCurrentStateContols();
				labelJamPointsType = LABEL_PTSTHISJAM;
				// If desired, minimze the jammer images
				if (scoreboard.autoMinimizeJammerInfo && scoreboard.hideJammerImageArea){
					scoreboard.hideJammerImageArea = false;
					swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.RESTORE_JAMMER_IMAGES));
				}
				
			}
			determineIntermissionButtonActiveStates();
		} // actionJamStart
		
		/**
		 * This action stops a jam in progress
		 */
		public function actionJamStop():void
		{
			// Set a new current state. Determine if this is an overitime jam, or "normal" jam
			if (_currentState != STATE_OVERTIMEJAM) setCurrentState(STATE_JAMSTOPPED) else setCurrentState(STATE_OVERTIMEJAMSTOPPED);
			// If this is the end of the first jam, then set a flag 
			if (scoring.currentJamNumber == 1) firstJamEnded = true;
			// See if this is the end of the game.
			if (!periodHasEnded()){
				// Deactivate and reset the jam clock			
				scoring.jamClock.stop(false,true);
				// Activate the break clock.
				breakActivate();
				// Update controls and scoreboard based on the current state
				updateCurrentStateContols();
				// Set button lable for next Jam
				buttonText_primaryActionToggle = LABEL_START_JAM;
				buttonTooltip_primaryActionToggle = TOOLTIP_STARTJAM;
			} 
			// Clear timeout indicators
			timeoutsClearAllIndicators();
			// Set button labels
			buttonText_officialTimeoutToggle = LABEL_OFFICIAL_TIMEOUT;
			// If so configured, hide the lead jammer indicators when the jam stops.
			// Otherwise they will be hidden with the next jam starts
			if (settingsModel.hideLeadJammerIndicatorAtStop) disableLeadJammerIndicators();	
			
			// For the jammer selected in this jam, then increase their jammerAppearance count
			if (scoring.visitorTeam.currentJammer != null) {					
				swizDispatcher.dispatchEvent(new BoutStatsEvent(BoutStatsEvent.INCR_JAMAPPEARENCE, scoring.visitorTeam.currentJammer));
			}
			if (scoring.homeTeam.currentJammer != null){
				swizDispatcher.dispatchEvent(new BoutStatsEvent(BoutStatsEvent.INCR_JAMAPPEARENCE, scoring.homeTeam.currentJammer));
			}

			// Clear the selected jammers
			if (settingsModel.resetSelectedJammersAtStop) resetSelectedJammers();
			// If desired, minimze the jammer images
			if (scoreboard.autoMinimizeJammerInfo && (! scoreboard.hideJammerImageArea )){
				scoreboard.hideJammerImageArea = true; 
				swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.HIDE_JAMMER_IMAGES));
			}
			
			// As soon as the jam stops, show the score recorded for this jam. Any adjustments
			// made during the break/timeout should be displayed in the previous jam boxes.
			scoring.homeTeam.pointsPreviousJam = scoring.homeTeam.pointsThisJam;
			scoring.visitorTeam.pointsPreviousJam = scoring.visitorTeam.pointsThisJam;
			labelJamPointsType = LABEL_PTSPREVJAM;
			
		} // actionJamStop
		
		
	
		
		
		/**
		 * This action is invoked by a team timout request
		 */
		public function actionTeamTimoutStart(scoreType:String):void {
			// Stop the game clock
			scoring.gameClock.stop();
			// Stop hide and reset the break clock in accordance to the rules:
			//   2.6.3.1 - At the conclusion of the timeout, the Referees will direct the skaters to return to the track and 
			//   start the next jam as soon as possible. The next jam can start as soon as skaters are lined up, but no more 
			//   than 30 seconds should elapse after a timeout.
			scoring.breakClock.stop(true, true);
			// Start and show the timeout clock
			scoring.timeoutClock.start();			
			// Handle the appropriate team timout actions
			switch (scoreType){
				case TeamsModel.HOME_TEAM:
					setCurrentState(STATE_HOMETIMEOUT);
					actionTimeoutsLeftChange(-1, TeamsModel.HOME_TEAM);
					scoring.homeTeam.timeout = true;
					break;
				case TeamsModel.VISITING_TEAM:
					setCurrentState(STATE_VISITORTIMEOUT);
					actionTimeoutsLeftChange(-1, TeamsModel.VISITING_TEAM);
					scoring.visitorTeam.timeout = true;
					break;
			}
			// Disable the official timeout label, in case this team timout came from an official timeout
			scoring.officialTimeout = false;
			// Enable the start break button
			buttonActive_breakStartToggle = true;
			// Update controls and scoreboard based on the current state
			updateCurrentStateContols();
			if (_previousState == STATE_OFFICALTIMEOUT_JAM || _previousState == STATE_OFFICALTIMEOUT_BREAK) 
				scoring.officialTimeoutClock.stop(true,true);
		} // actionTeamTimoutStart		
		
		
		
		
		// ----------------------------------------------------------------------------------------
		// Scoring actions
		// ----------------------------------------------------------------------------------------
		/**
		 * CORRECTIVE ACTION
		 * Adjust the specified team previous jam score by the specified changeValue (positive or negative)
		 * This will also adjust the specified team's total score as well.
		 * 
		 * @param changeValue - The amount to change the previous jam score by (positive or negative)
		 * @param scoreType - TeamsModel.HOME_TEAM or TeamsModel.VISITING_TEAM
		 */
		public function actionPreviousJamScoreChange(changeValue:int, scoreType:String):void{			
			switch (scoreType){
				case TeamsModel.HOME_TEAM:
					_LOG.debug("Update the home prev jam score ["+scoring.homeTeam.pointsPreviousJam+"] score by: [" + changeValue +"]"  + logGameStatus());
					scoring.homeTeam.pointsPreviousJam += changeValue;
					// If the score goes below zero, then set it to zero.
					if (scoring.homeTeam.pointsPreviousJam < 0){ 
						scoring.homeTeam.pointsPreviousJam = 0; 
						changeValue = 0; 
					}
					if (scoring.homeTeam.pointsPreviousJam > 99){ 
						scoring.homeTeam.pointsPreviousJam = 99; 
						changeValue = 0; 
					}
					// update the total score
					actionTeamScoreChange(changeValue, TeamsModel.HOME_TEAM);
					// if this is not a jam or official JAM timeout, then we can update the points for this jam as well
					if (_currentState != STATE_JAM && _currentState != STATE_OFFICALTIMEOUT_JAM){
						scoring.homeTeam.pointsThisJam = scoring.homeTeam.pointsPreviousJam;
					}
					break;
				case TeamsModel.VISITING_TEAM:
					_LOG.debug("Update the visitor previous ham score ["+scoring.visitorTeam.pointsPreviousJam+"] score by: [" + changeValue +"]"  + logGameStatus());
					scoring.visitorTeam.pointsPreviousJam += changeValue;
					// If the score goes below zero, then set it to zero.
					if (scoring.visitorTeam.pointsPreviousJam < 0){ 
						scoring.visitorTeam.pointsPreviousJam = 0; 
						changeValue = 0; 
					} 
					if (scoring.visitorTeam.pointsPreviousJam > 99){ 
						scoring.visitorTeam.pointsPreviousJam = 99; 
						changeValue = 0;
					} 
					// update the total score
					actionTeamScoreChange(changeValue, TeamsModel.VISITING_TEAM);
					// if this is not a jam or official JAM timeout, then we can update the points for this jam as well
					if (_currentState != STATE_JAM && _currentState != STATE_OFFICALTIMEOUT_JAM){
						scoring.visitorTeam.pointsThisJam = scoring.visitorTeam.pointsPreviousJam;
					}
					break;
			}
			
		} // actionPreviousJamScoreChange	

		
		/**
		 * Adjust the specified team previous jam score to the specified value
		 * Changing this value, also influences the total team score by the same value
		 * 
		 * @param setValue - The amount to change the current jam score to
		 * @param scoreType - TeamsModel.HOME_TEAM or TeamsModel.VISITING_TEAM
		 */
		public function actionPreviousJamScoreSet(setValue:int, scoreType:String):void {
			
			switch (scoreType){
				case TeamsModel.HOME_TEAM:
					_LOG.debug("Set the home previous points ["+scoring.homeTeam.pointsPreviousJam+"] score to: [" + setValue +"]"  + logGameStatus());
					// Remove all the points this jam that were added to the total score
					actionTeamScoreChange(-scoring.homeTeam.pointsPreviousJam, TeamsModel.HOME_TEAM);
					// set the new points this jam
					scoring.homeTeam.pointsPreviousJam = setValue;
					// If the score goes below zero, then set it to zero.
					if (scoring.homeTeam.pointsPreviousJam < 0){ scoring.homeTeam.pointsPreviousJam = 0; }
					if (scoring.homeTeam.pointsPreviousJam > 99){ scoring.homeTeam.pointsPreviousJam = 99; }
					// Add the new points to the total score
					actionTeamScoreChange(scoring.homeTeam.pointsPreviousJam, TeamsModel.HOME_TEAM);
					// if this is not a jam or official JAM timeout, then we can update the points for this jam as well
					if (_currentState != STATE_JAM && _currentState != STATE_OFFICALTIMEOUT_JAM){
						scoring.homeTeam.pointsThisJam = scoring.homeTeam.pointsPreviousJam;
					}
					break;
				case TeamsModel.VISITING_TEAM:
					_LOG.debug("Update the visitor previous jam points ["+scoring.visitorTeam.pointsPreviousJam+"] score to: [" + setValue +"]"  + logGameStatus());
					// Remove all the points this jam that were added to the total score
					actionTeamScoreChange(-scoring.visitorTeam.pointsPreviousJam, TeamsModel.VISITING_TEAM);
					// set the new points this jam
					scoring.visitorTeam.pointsPreviousJam = setValue;
					// If the score goes below zero, then set it to zero.
					if (scoring.visitorTeam.pointsPreviousJam < 0){ scoring.visitorTeam.pointsPreviousJam = 0; }
					if (scoring.visitorTeam.pointsPreviousJam > 99){ scoring.visitorTeam.pointsPreviousJam = 99; }
					// Add the new points to the total score
					actionTeamScoreChange(scoring.visitorTeam.pointsPreviousJam, TeamsModel.VISITING_TEAM);
					// if this is not a jam or official JAM timeout, then we can update the points for this jam as well
					if (_currentState != STATE_JAM && _currentState != STATE_OFFICALTIMEOUT_JAM){
						scoring.visitorTeam.pointsThisJam = scoring.visitorTeam.pointsPreviousJam;
					}
					break;
			}
			
		} // actionPreviousJamScoreSet	
		
		/**
		 * CORRECTIVE ACTION
		 * Adjust the specified team total jams lead by the specified changeValue (positive or negative)
		 * 
		 * @param changeValue - The amount to change the total jams lead by (positive or negative)
		 * @param scoreType - TeamsModel.HOME_TEAM or TeamsModel.VISITING_TEAM
		 */
		public function actionTotalJamsLeadChange(changeValue:int, scoreType:String):void{			
			switch (scoreType){
				case TeamsModel.HOME_TEAM:
					_LOG.debug("Update the home team total jams lead ["+scoring.homeTeam.jamsLead+"] adjust by: [" + changeValue +"]"  + logGameStatus());
					scoring.homeTeam.jamsLead = scoring.homeTeam.jamsLead + changeValue;
					// If the timeout count goes below zero, then set it to zero.
					if (scoring.homeTeam.jamsLead < 0){ scoring.homeTeam.jamsLead = 0; }
					if (scoring.homeTeam.jamsLead > 99){ scoring.homeTeam.jamsLead = 99; }
					_LOG.debug("Set the home team jams lead ["+scoring.homeTeam.jamsLead+"]"  + logGameStatus());
					break;
				case TeamsModel.VISITING_TEAM:
					_LOG.debug("Update the visitor team jams lead ["+scoring.visitorTeam.jamsLead+"] adjust by: [" + changeValue +"]"  + logGameStatus());
					scoring.visitorTeam.jamsLead = scoring.visitorTeam.jamsLead + changeValue;
					// If the timeout count goes below zero, then set it to zero.
					if (scoring.visitorTeam.jamsLead < 0){ scoring.visitorTeam.jamsLead = 0; }
					if (scoring.visitorTeam.jamsLead > 99){ scoring.visitorTeam.jamsLead = 99; }
					_LOG.debug("Set the visitor team jams lead ["+scoring.visitorTeam.jamsLead+"]"  + logGameStatus());
					break;
			}
			
		} // actionTotalJamsLeadChange	
		
		
		/**
		 * CORRECTIVE ACTION
		 * Sets the specified team total jams lead to the specified value 
		 * 
		 * @param changeValue - The total jams lead value to set
		 * @param scoreType - TeamsModel.HOME_TEAM or TeamsModel.VISITING_TEAM
		 */
		public function actionTotalJamsLeadSet(setValue:int, scoreType:String):void {
			
			var requestedSetValue:int = setValue;
			// If the jams lead set value requested is below zero, then set it to zero.
			if (setValue < 0) setValue = 0;
			// If it is more than 99 then set it to 99
			if (setValue > 99) setValue = 99;
			switch (scoreType){
				case TeamsModel.HOME_TEAM:
					scoring.homeTeam.jamsLead = setValue;
					_LOG.debug("Requested set the home team jams lead to: [" + requestedSetValue +"] set to ["+scoring.homeTeam.jamsLead+"]"  + logGameStatus());
					break;
				case TeamsModel.VISITING_TEAM:
					scoring.visitorTeam.jamsLead = setValue;
					_LOG.debug("Requested set the visitor team jams lead to: [" + requestedSetValue +"] set to ["+scoring.visitorTeam.jamsLead+"]"  + logGameStatus());
					break;
			}
			
		} // actionTotalJamsLeadSet
		
		
		/**
		 * CORRECTIVE ACTION
		 * Adjust the specified team score by the specified changeValue (positive or negative)
		 * 
		 * @param changeValue - The amount to change the score by (positive or negative)
		 * @param scoreType - TeamsModel.HOME_TEAM or TeamsModel.VISITING_TEAM
		 */
		public function actionTeamScoreChange(changeValue:int, scoreType:String):void{			
			switch (scoreType){
				case TeamsModel.HOME_TEAM:
					_LOG.debug("Update the home team score ["+scoring.homeTeam.score+"] adjust by: [" + changeValue +"]"  + logGameStatus());
					scoring.homeTeam.score = scoring.homeTeam.score + changeValue;
					// If the timeout count goes below zero, then set it to zero.
					if (scoring.homeTeam.score < 0){ scoring.homeTeam.score = 0; }
					if (scoring.homeTeam.score > 999){ scoring.homeTeam.score = 999; }
					_LOG.debug("Set the home team score ["+scoring.homeTeam.score+"]"  + logGameStatus());
					break;
				case TeamsModel.VISITING_TEAM:
					_LOG.debug("Update the visitor team score ["+scoring.visitorTeam.score+"] adjust by: [" + changeValue +"]"  + logGameStatus());
					scoring.visitorTeam.score = scoring.visitorTeam.score + changeValue;
					// If the timeout count goes below zero, then set it to zero.
					if (scoring.visitorTeam.score < 0){ scoring.visitorTeam.score = 0; }
					if (scoring.visitorTeam.score > 999){ scoring.visitorTeam.score = 999; }
					_LOG.debug("Set the visitor team score ["+scoring.visitorTeam.score+"]"  + logGameStatus());
					break;
			}
			
		} // actionTeamScoreChange	
				
		/**
		 * CORRECTIVE ACTION
		 * Sets the specified team score to the specified value 
		 * 
		 * @param setValue - The score value to set
		 * @param scoreType - TeamsModel.HOME_TEAM or TeamsModel.VISITING_TEAM
		 */
		public function actionTeamScoreSet(setValue:int, scoreType:String):void {
			
			var requestedSetValue:int = setValue;
			// If the score set value requested is below zero, then set it to zero.
			if (setValue < 0) setValue = 0; 
			// If it is more than 999 then set it to 999
			if (setValue > 999) setValue = 999;
			switch (scoreType){
				case TeamsModel.HOME_TEAM:
					scoring.homeTeam.score = setValue;
					_LOG.debug("Requested set the home team score to: [" + requestedSetValue +"] set to ["+scoring.homeTeam.score+"]"  + logGameStatus());
					break;
				case TeamsModel.VISITING_TEAM:
					scoring.visitorTeam.score = setValue;
					_LOG.debug("Requested set the visitor team score to: [" + requestedSetValue +"] set to ["+scoring.visitorTeam.score+"]"  + logGameStatus());
					break;
			}
			
		} // actionTeamScoreSet
		
		
		/**
		 * Adjust the specified team tomeout remaining by the specified changeValue (positive or negative)
		 * 
		 * @param changeValue - The amount to change the timeouts remaining by (positive or negative)
		 * @param scoreType - TeamsModel.HOME_TEAM or TeamsModel.VISITING_TEAM
		 */
		public function actionTimeoutsLeftChange(changeValue:int, scoreType:String):void{			
			switch (scoreType){
				case TeamsModel.HOME_TEAM:
					_LOG.debug("Update the home timeouts ["+scoring.homeTeam.timeoutsLeft+"] adjust by: [" + changeValue +"]"  + logGameStatus());
					scoring.homeTeam.timeoutsLeft = scoring.homeTeam.timeoutsLeft + changeValue;
					// If the timeout count goes below zero, then set it to zero.
					if (scoring.homeTeam.timeoutsLeft < 0){ scoring.homeTeam.timeoutsLeft = 0; }
					if (scoring.homeTeam.timeoutsLeft > 9){ scoring.homeTeam.timeoutsLeft = 9; }
					_LOG.debug("Set the home timeouts ["+scoring.homeTeam.timeoutsLeft+"]"  + logGameStatus());
					break;
				case TeamsModel.VISITING_TEAM:
					_LOG.debug("Update the visitor timeouts ["+scoring.visitorTeam.timeoutsLeft+"] adjust by: [" + changeValue +"]"  + logGameStatus());
					scoring.visitorTeam.timeoutsLeft = scoring.visitorTeam.timeoutsLeft + changeValue;
					// If the timeout count goes below zero, then set it to zero.
					if (scoring.visitorTeam.timeoutsLeft < 0){ scoring.visitorTeam.timeoutsLeft = 0; }
					if (scoring.visitorTeam.timeoutsLeft > 9){ scoring.visitorTeam.timeoutsLeft = 9; }
					_LOG.debug("Set the visitor timeouts ["+scoring.visitorTeam.timeoutsLeft+"]"  + logGameStatus());
					break;
			}
			// Set the timeout button states based on the changes to the remaining number of timeouts
			determineTimeoutButtonsActiveStates();
			
		} // actionTimeoutsLeftChange	
		
		
		/**
		 * CORRECTIVE ACTION
		 * Sets the specified team timeouts remaining to the specified value 
		 * 
		 * @param setValue - The timeout remaining value to set
		 * @param scoreType - TeamsModel.HOME_TEAM or TeamsModel.VISITING_TEAM
		 */
		public function actionTimeoutsLeftSet(setValue:int, scoreType:String):void {
			
			var requestedSetValue:int = setValue;
			// If the timeout set value requested is below zero, then set it to zero.
			// If it is more than 9 then set it to 9
			if (setValue < 0){ setValue = 0; }
			if (setValue > 9){ setValue = 9; }
			switch (scoreType){
				case TeamsModel.HOME_TEAM:
					scoring.homeTeam.timeoutsLeft = setValue;
					_LOG.debug("Requested set the home timeouts remaining to: [" + requestedSetValue +"] set to ["+scoring.homeTeam.timeoutsLeft+"]"  + logGameStatus());
					break;
				case TeamsModel.VISITING_TEAM:
					scoring.visitorTeam.timeoutsLeft = setValue;
					_LOG.debug("Requested set the home timeouts remaining to: [" + requestedSetValue +"] set to ["+scoring.visitorTeam.timeoutsLeft+"]"  + logGameStatus());
					break;
			}
			// Set the timeout button states based on the changes to the remaining number of timeouts
			determineTimeoutButtonsActiveStates();
			
		} // actionTimeoutsLeftSet
		
		
	
		
		
		/**
		 * Adjust the specified team current jam score to the specified value
		 * Changing this value, also influences the total team score by the same value
		 * 
		 * @param setValue - The amount to change the current jam score to
		 * @param scoreType - TeamsModel.HOME_TEAM or TeamsModel.VISITING_TEAM
		 */
		public function currentJamScoreSet(setValue:int, scoreType:String):void {
			
			switch (scoreType){
				case TeamsModel.HOME_TEAM:
					_LOG.debug("Set the home points This JAM ["+scoring.homeTeam.pointsThisJam+"] score to: [" + setValue +"]"  + logGameStatus());
					// Remove all the points this jam that were added to the total score
					scoring.homeTeam.score -= scoring.homeTeam.pointsThisJam;
					// set the new points this jam
					scoring.homeTeam.pointsThisJam = setValue;
					// If the score goes below zero, then set it to zero.
					if (scoring.homeTeam.pointsThisJam < 0){ scoring.homeTeam.pointsThisJam = 0; }
					if (scoring.homeTeam.pointsThisJam > 99){ scoring.homeTeam.pointsThisJam = 99; }
					// Add the new points to the total score
					actionTeamScoreChange(scoring.homeTeam.pointsThisJam, TeamsModel.HOME_TEAM);
					// if this is not a jam or official JAM timeout, then we can update the previous jam points as well
					if (_currentState != STATE_JAM && _currentState != STATE_OFFICALTIMEOUT_JAM){
						scoring.homeTeam.pointsPreviousJam = scoring.homeTeam.pointsThisJam;
					}
					break;
				case TeamsModel.VISITING_TEAM:
					_LOG.debug("Update the visitor points this JAM ["+scoring.visitorTeam.pointsThisJam+"] score to: [" + setValue +"]"  + logGameStatus());
					// Remove all the points this jam that were added to the total score
					scoring.visitorTeam.score -= scoring.visitorTeam.pointsThisJam;
					// set the new points this jam
					scoring.visitorTeam.pointsThisJam = setValue;
					// If the score goes below zero, then set it to zero.
					if (scoring.visitorTeam.pointsThisJam < 0){ scoring.visitorTeam.pointsThisJam = 0; }
					if (scoring.visitorTeam.pointsThisJam > 99){ scoring.visitorTeam.pointsThisJam = 99; }
					// Add the new points to the total score
					actionTeamScoreChange(scoring.visitorTeam.pointsThisJam, TeamsModel.VISITING_TEAM);
					// if this is not a jam or official JAM timeout, then we can update the previous jam points as well
					if (_currentState != STATE_JAM && _currentState != STATE_OFFICALTIMEOUT_JAM){
						scoring.visitorTeam.pointsPreviousJam = scoring.visitorTeam.pointsThisJam;
					}
					break;
			}
			
		} // currentJamScoreSet	

		
		public function dispatchSpecifiedScoreboardViewMode(viewState:String, resetPreviewWindow:Boolean = true):void {
			
			switch (viewState){
				case ViewsModel.MAIN_VIEW:
					swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.VIEW_MAIN));
					if (resetPreviewWindow) swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.VIEW_MAIN_PREVIEW));
					scoreboardViewState = viewState;
					break;
				case ViewsModel.PREGAME_VIEW:
					swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.VIEW_CUSTOM, ViewsModel.PREGAME_VIEW));
					if (resetPreviewWindow) swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.VIEW_CUSTOM_PREVIEW, ViewsModel.PREGAME_VIEW));
					scoreboardViewState = viewState;
					break;
				case ViewsModel.INTERMISSION_VIEW:
					swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.VIEW_CUSTOM, ViewsModel.INTERMISSION_VIEW));
					if (resetPreviewWindow) swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.VIEW_CUSTOM_PREVIEW, ViewsModel.INTERMISSION_VIEW));
					scoreboardViewState = viewState;
					break;
				case ViewsModel.POSTGAME_VIEW:
					swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.VIEW_CUSTOM, ViewsModel.POSTGAME_VIEW));
					if (resetPreviewWindow) swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.VIEW_CUSTOM_PREVIEW, ViewsModel.POSTGAME_VIEW));
					scoreboardViewState = viewState;
					break;
				case ViewsModel.CURTAIN_VIEW:
					swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.VIEW_CUSTOM, ViewsModel.CURTAIN_VIEW));
					if (resetPreviewWindow) swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.VIEW_CUSTOM_PREVIEW, ViewsModel.CURTAIN_VIEW));
					scoreboardViewState = viewState;
					break;
			}
			// Set the view button accordingly
			swizDispatcher.dispatchEvent(new ControllerEvent(ControllerEvent.SET_MAIN_BUTTONBAR, scoreboardViewState));
		}
		
		
		/**
		 * Determines what view should be displayed to the audience based on the state of the scoreboard
		 * 
		 * @resetPreviewWindow - True [Default] will reset the view of the preview window as well
		 *                       False leaves the view in the preview window as is
		 */
		public function dispatchStateAwareScoreboardViewMode(resetPreviewWindow:Boolean = true):void {
			_LOG.debug("Determine the appropriate Scoreboard View Mode ["+_currentState+"]"  + logGameStatus());
			
			// Determine the appropriate view mode based on the state of the scoreboard
			if (settingsModel.customViewsAutoSwitch) {
				switch (_currentState){
					case STATE_ENDPERIOD:
						break;
					case STATE_INTERMISSION_EXPIRED:
						dispatchSpecifiedScoreboardViewMode(ViewsModel.MAIN_VIEW, true);
						break;
					case STATE_INTERMISSION:
					case STATE_INTERMISSION_PAUSE:
						if (_gameInProgress) 
							dispatchSpecifiedScoreboardViewMode(ViewsModel.INTERMISSION_VIEW, true);
						else 
							dispatchSpecifiedScoreboardViewMode(ViewsModel.PREGAME_VIEW, true);
						break;
					case STATE_ENDGAME:
						dispatchSpecifiedScoreboardViewMode(ViewsModel.POSTGAME_VIEW, true);
						break;
					case STATE_NEWPERIOD:
					default:
						dispatchSpecifiedScoreboardViewMode(ViewsModel.MAIN_VIEW, true);
						break;
				}
			}

		} // dispatchScoreboardViewMode
		
		
		public function isGameInProgress():Boolean {
			return _gameInProgress;
		}
		
		
		/**
		 * Alter the jamNumber by the specified (positive or negative) value
		 */
		public function jamNumberChange(changeValue:int):void {
			_LOG.debug("Adjust Jam Number ["+scoring.currentJamNumber+"] by: [" + changeValue +"]"  + logGameStatus());
			scoring.currentJamNumber += changeValue;
			if (scoring.currentJamNumber < 0){ scoring.currentJamNumber = 0; }
		}

		

				
		
		/**
		 * Validates a requested change to the remaining time value for a specified clock object.  It is compared
		 * against the maximim reset value of the provided clock object for validity
		 * 
		 * @param clockObject - The clock object attempting to be reset
		 * @param timeString - A string represeting the time to use as a remaining time
		 * @param [zeroTimePermitted] - True: A time of zero milliseconds can be returned
		 *                              False: (default) A time of zero milliseconds will be replaced with 
		 * 									   the millisecondsMaxValue
		 * @param [gameClockMonitor] - True: Changes to this clock should invoke the gameClock monitor to initate actions
		 *                             		 specific to changes to the game clock
		 *                             False: (default) No monitoring of game clock needed for this change
		 */
		public function validateRemainingTimeValue(clockObject:Clock, timeString:String, zeroTimePermitted:Boolean=false, gameClockMonitor:Boolean=false): void {
			clockObject.timeRemaining = Clock.validateTime(timeString, clockObject.maxResetValue, zeroTimePermitted, clockObject.displayFormat);
			if (gameClockMonitor) gameClockAdjustmentMonitor();
			// resume the Keyboard Shortcuts
			enableKeyboardShortcuts();
		}

		// ----------------------------------------------------------------------------------------
		// Prompts and Confirmation dialogs
		// ----------------------------------------------------------------------------------------		
		/**
		 * This will prompt the user when the game is determined to be over.
		 */
		public function promptGameOver(teamInfo:Team):void {
			Alert.show("The game is over. "+teamInfo.shortName+" is the winner!", "Game Over", Alert.OK, null, null, AssetModel.ICON_ALERT32_CLASS, Alert.OK, null);	
		}
		
		
		/**
		 * This will prompt the user when the game is determined to be over.
		 */
		public function promptOvertime():void {
			Alert.show("The game is tied. Overtime!", "Overtime", Alert.OK, null, null, AssetModel.ICON_ALERT32_CLASS, Alert.OK, null);	
		}
		
		
		/**
		 * This will prompt the user when a period is determined to be over.
		 */
		public function promptPeriodOver():void {
			Alert.show("Period #"+scoring.currentPeriodNumber+" has expired. Use the "+LABEL_PREPAREPERIOD+" action to proceed.", "End of Period", Alert.OK, null, null, AssetModel.ICON_ALERT32_CLASS, Alert.OK, null);	
		}
		
		
		/**
		 * This will prompt the user for confirmation of resetting moving to the next period
		 */
		public function confirmExtendPeriod():void {
			Alert.show("This game clock adjustment will extend the length of period #"+scoring.currentPeriodNumber+". As a result, there will be "+scoring.gameClock.formattedTimeRemaining+" time remaining.\n\nIs this correct?", "Confirm Period Extension", Alert.YES | Alert.NO, null, confirmExtendPeriodHandler, AssetModel.ICON_QUESTION32_CLASS, Alert.YES, null);	
		}
		
		/**
		 * This will prompt the user for confirmation of resetting moving to the next period
		 */
		public function confirmPrepareNextPeriod():void {
			Alert.show("Are you ready to progress to the next period?", "Confirm End Period #"+scoring.currentPeriodNumber, Alert.YES | Alert.NO, null, confirmPrepareNextPeriodHandler, AssetModel.ICON_QUESTION32_CLASS, Alert.NO, null);	
		}
		
		/**
		 * This will prompt the user for confirmation of resetting the scoreboard.
		 */
		public function confirmScoreboardReset():void {
			Alert.show("Are you sure you want to reset the scoreboard?", "Confirm Reset", Alert.YES | Alert.NO, null, confirmScoreboardResetHandler, AssetModel.ICON_QUESTION32_CLASS, Alert.NO, null);	
		}
		
		// ----------------------------------------------------------------------------------------
		// Click Handlers
		// ----------------------------------------------------------------------------------------		
		public function disableKeyboardShortcuts():void {
			MainPresentationModel.suspendShortcuts = true;
		}

		public function enableKeyboardShortcuts():void {
			MainPresentationModel.suspendShortcuts = false;
		}

		public function intermission_clickHandler():void {
			switch(_currentState){
				case STATE_INTERMISSION:
					intermissionPause();
					break;
				case STATE_INTERMISSION_EXPIRED:
					intermissionReset(false);
					setCurrentState(STATE_INTERMISSION_PAUSE);
					break;
				case STATE_INTERMISSION_PAUSE:
				default:
					intermissionActivate();
					break;
			}
		}

		public function startBreak_clickHandler():void {	
			actionBreakStart();
		}


		/**
		 * This function should be called when the game clock is adjusted.  It is used
		 * to determine if an ended period is being extended.
		 */
		public function gameClockAdjustmentMonitor():void {
			_LOG.debug("Game Clock was Manually set  ["+scoring.gameClock.formattedTimeRemaining+"]");
			
			// If the game is ready for the next period or overtime, then the user is trying to adjust 
			// clock settings after a period has ended - perhaps extending the period for some reason
			if ((! _setForNextPeriod) && (! _gameInOvertime) && scoring.gameClock.timeRemaining > 0){
				if ((_currentState == STATE_ENDPERIOD)||(_currentState == STATE_OVERTIMEPREPARE)||(_currentState == STATE_ENDGAME)){
					_LOG.debug("Adding time to the period clock to extend period #"+scoring.currentPeriodNumber);
					confirmExtendPeriod();
				}
			}
			
			if ((_currentState == STATE_JAMSTOPPED) && (scoring.gameClock.timeRemaining == 0)){
				_LOG.debug("Prepare for Next Period");
				periodEndHandler();
			}
			
			// If the game is in overtime, then the clock cannot be reset
			if (_gameInOvertime){
				_LOG.debug("Game Clock CANNOT be adjusted during overtime");
				scoring.gameClock.timeRemaining = 0;
			}
		}

		
		public function keyHandler(event:KeyboardEvent):String {
			var keyTrapped:String = '';
			
			if(! settingsModel.disableKeyboardShortcuts){
				switch (event.keyCode) {
					case 66:  // Toggle Jam Clock
						if (buttonActive_primaryActionToggle) keyTrapped = 'B';
						actionHandler_primaryAction();
						break;
					case 86:  // Start or Resume the Break Clock
						keyTrapped = 'V';
						if (buttonActive_breakStartToggle) startBreak_clickHandler();
						break;
					case 78:  // Official Timeout
						if (buttonActive_officialTimeout) actionHandler_officialTimeout();
						keyTrapped = 'N'; 
						break;
					case 67:  // Home Timeout
						if (buttonActive_homeTimeout) actionTeamTimoutStart(TeamsModel.HOME_TEAM);
						keyTrapped = 'C'; 
						break;
					case 188: // Visitor Timeout
						if (buttonActive_visitorTimeout) actionTeamTimoutStart(TeamsModel.VISITING_TEAM);
						keyTrapped = ','; 
						break;
					case 71:  // Home Lead Jammer
						if (buttonActive_homeLeadJammer) actionHandler_leadJammer(TeamsModel.HOME_TEAM);
						keyTrapped = 'G'; 
						break;
					case 72: // No Lead Jammer
						if (buttonActive_noLeadJammer) actionHandler_noLeadLostLeadJammer();
						keyTrapped = 'H'; 
						break;
					case 74: // Visitor Lead Jammer
						if (buttonActive_visitorLeadJammer) actionHandler_leadJammer(TeamsModel.VISITING_TEAM)
						keyTrapped = 'J'; 
						break;
					case 81: // Increase Home Score 
						if (actionActive_modifyJamScore) actionHandler_adjustCurrentJamScore(1,TeamsModel.HOME_TEAM, ScoringModel.INCREMENT);
						keyTrapped = 'Q'; 
						break;
					case 87: // Decrease Home Score 
						if (actionActive_modifyJamScore) actionHandler_adjustCurrentJamScore(-1,TeamsModel.HOME_TEAM, ScoringModel.INCREMENT);
						keyTrapped = 'W'; 
						break;
					case 83: // Increase Home Score by 4
						if (actionActive_modifyJamScore) actionHandler_adjustCurrentJamScore(4,TeamsModel.HOME_TEAM, ScoringModel.INCREMENT);
						keyTrapped = 'S'; 
						break;
					case 65: // Increase Home Score by 3
						if (actionActive_modifyJamScore) actionHandler_adjustCurrentJamScore(3,TeamsModel.HOME_TEAM, ScoringModel.INCREMENT);
						keyTrapped = 'A'; 
						break;

					case 219: // Decrease Visitor Score 
						if (actionActive_modifyJamScore) actionHandler_adjustCurrentJamScore(-1,TeamsModel.VISITING_TEAM, ScoringModel.INCREMENT);
						keyTrapped = '['; 
						break;
					case 221: // Increase Visitor Score
						if (actionActive_modifyJamScore) actionHandler_adjustCurrentJamScore(1,TeamsModel.VISITING_TEAM, ScoringModel.INCREMENT);
						keyTrapped = ']'; 
						break;
					case 222: // Increase Visitor Score by 4
						if (actionActive_modifyJamScore) actionHandler_adjustCurrentJamScore(4,TeamsModel.VISITING_TEAM, ScoringModel.INCREMENT);
						keyTrapped = '\''; 
						break;
					case 186: // Increase Visitor Score by 3
						if (actionActive_modifyJamScore) actionHandler_adjustCurrentJamScore(3,TeamsModel.VISITING_TEAM, ScoringModel.INCREMENT);
						keyTrapped = ';'; 
						break;
/*
					case 84: // Increment Period Counter
						periodNumberChange(1);
						keyTrapped = 'T'; 
						break;
					case 89: // Decrement Period Counter
						periodNumberChange(-1);						
						keyTrapped = 'Y'; 
						break;
					case 73:  // Increment Jam Counter
						jamNumberChange(1);
						keyTrapped = 'I'; 
						break;
					case 85:  // Decrement Jam Counter
						jamNumberChange(-1);
						keyTrapped = 'U'; 
						break;
					case 90:  // Increment Home Timeout Counter
						timeoutsLeftChange(1,TeamsModel.HOME_TEAM);
						keyTrapped = 'Z'; 
						break;
					case 88:  // Decrement Home Timeout Counter
						timeoutsLeftChange(-1,TeamsModel.HOME_TEAM);						
						keyTrapped = 'X'; 
						break;
					case 190: // Decrement Visitor Timeout Counter
						timeoutsLeftChange(-1,TeamsModel.VISITING_TEAM);
						keyTrapped = '.'; 
						break;
					case 191: // Increment Visitor Timeout Counter
						timeoutsLeftChange(1,TeamsModel.VISITING_TEAM);						
						keyTrapped = '/'; 
						break;
*/					
				}
				_LOG.debug("keyTrapped:" + keyTrapped + " (Keycode:"+event.keyCode+")"  + logGameStatus());
			}
			
			return keyTrapped;
		}
		
		public function rightClickPrimaryActionHandler(event:MouseEvent):void {
			if ((! settingsModel.disableRightClickPrimaryAction) && (buttonActive_primaryActionToggle)) actionHandler_primaryAction();
		}


		// ----------------------------------------------------------------------------------------
		// Private Methods
		// ----------------------------------------------------------------------------------------
		/**
		 * This determines if the break clock should be started, or if the start break action should be enabled
		 */
		private function breakActivate():void {
			// If the break clock is set to autostart then do so. This can be configured
			// for an stopped jam stop, or expired timeout clock.
			if (((_currentState == STATE_JAMSTOPPED) && (settingsModel.breakClockAutostartOnJamStop))      || 
				((_currentState == STATE_TIMEOUTEXPIRED) && (settingsModel.breakClockAutostartOnTimeoutExpire))){
				_LOG.debug("breakActivate AutoStart Break");
				actionBreakStart();
				// Otherwise, just enable the button for the scorekeeper
			} else {
				_LOG.debug("breakActivate AutoStart Break Denied");
				buttonActive_breakStartToggle = true;
			}
		}
		
		/**
		 * This method is called when the user answers the "Confirm Extend Period" dialogue for  
		 * extending the length of an expired period. It analyses the CloseEvent to determine which action the 
		 * user chose, and acts accordingly
		 * 
		 * @param event - mx.events.CloseEvent
		 */
		private function confirmExtendPeriodHandler(event:CloseEvent):void{
			if(event.detail==Alert.YES) {
				_LOG.debug("Period Extension Confirm OK'd");
				periodExtendHandler();
			}
			else {
				_LOG.debug("Period Extension Confirm Canceled");
				periodEndHandler();
			}
		}
		
		/**
		 * This method is called when the user answers the "Confirm Next Period" dialogue for moving 
		 * from one period to the next. It analyses the CloseEvent to determine which action the 
		 * user chose, and acts accordingly
		 * 
		 * @param event - mx.events.CloseEvent
		 */
		private function confirmPrepareNextPeriodHandler(event:CloseEvent):void{
			if(event.detail==Alert.YES) {
				_LOG.debug("Next Period Confirm OK'd");
				periodPrepareNext();
			}
			else {
				_LOG.debug("Next Period Confirm Canceled");
			}
		}

		
		/**
		 * This method is called when the user answers the "Confirm Reset Scoreboard" dialogue for resetting
		 * the scoreboard for another event. It analyses the CloseEvent to determine which action the 
		 * user chose, and acts accordingly
		 * 
		 * @param event - mx.events.CloseEvent
		 */
		private function confirmScoreboardResetHandler(event:CloseEvent):void{
			if(event.detail==Alert.YES) {
				_LOG.debug("Scoreboard Reset Confirm OK'd");
				resetScoreboard();
			}
			else {
				_LOG.debug("Scoreboard Reset Confirm Canceled");
			}
		}

		/**
		 * Reset the current Jam score
		 */
		private function currentJamScoreReset():void {
			scoring.homeTeam.pointsThisJam = 0;
			scoring.visitorTeam.pointsThisJam = 0;			
		}

		/**
		 * These actions are taken when the game clock expires
		 */
		private function gameClockExpires():void {
			_LOG.debug("The game clock as expired!");
			scoring.gameClock.stop(false, false);
			_gameClockExpired = true;
			// check to see if the period is truly over.
			periodHasEnded();
		}

		/**
		 * Determine the appropriate secondary clock lable based on the current state
		 */
		private function determineClockLabel():void {
			switch (_currentState){
				case STATE_BREAK:
					currentClockLabel = "LINEUP CLOCK"
					break;
				case STATE_HOMETIMEOUT:
				case STATE_VISITORTIMEOUT:
					currentClockLabel = "TIMEOUT"
					break;
				case STATE_OFFICALTIMEOUT_BREAK:
				case STATE_OFFICALTIMEOUT_JAM:
					if (settingsModel.displayOfficialTimeoutDuration) currentClockLabel = "OFFICIAL TIMEOUT"
					break;
				case STATE_NEWPERIOD:
				case STATE_JAM:
				case STATE_JAMEXPIRED:
				case STATE_JAMSTOPPED:
				case STATE_OFFICALTIMEOUT_JAM:
				case STATE_ENDPERIOD:
				case STATE_ENDGAME:
				case STATE_INTERMISSION_PAUSE:
				case STATE_INTERMISSION_EXPIRED:
					currentClockLabel = "JAM CLOCK"
					break;
				case STATE_INTERMISSION:
					if (! _gameInProgress)
						currentClockLabel = "COUNTDOWN"
					else 
						currentClockLabel = "INTERMISSION"
					break;
			}
		}
		

		/**
		 * The intermission button is active or inactive based on the current state of the scoreboard
		 */
		private function determineIntermissionButtonActiveStates():void {
			switch (_currentState){
				case STATE_NEWPERIOD:
				case STATE_INTERMISSION:
				case STATE_INTERMISSION_EXPIRED:
				case STATE_INTERMISSION_PAUSE:
				case STATE_ENDPERIOD:
				case STATE_ENDGAME:
					buttonActive_intermission = true;
					break;
				default:
					buttonActive_intermission = false;
					break;
			}
		}
			
		
		/**
		 * The timeout buttons are active or inactive based on the current state of the scoreboard
		 */
		private function determineTimeoutButtonsActiveStates():void {
			_LOG.debug("Determine button state for ["+_currentState+"]");
			switch (_currentState){
				case STATE_BREAK:
				case STATE_TIMEOUTEXPIRED:
				case STATE_JAMSTOPPED:
					if (scoring.homeTeam.timeoutsLeft == 0){ buttonActive_homeTimeout = false; } else { buttonActive_homeTimeout = true; }
					if (scoring.visitorTeam.timeoutsLeft == 0){ buttonActive_visitorTimeout = false; } else { buttonActive_visitorTimeout = true; }
					buttonActive_officialTimeout = true;
					break;
				case STATE_OFFICALTIMEOUT_BREAK:
					buttonActive_homeTimeout = true;
					buttonActive_visitorTimeout = true;
					buttonActive_officialTimeout = false;	
					break;
				case STATE_VISITORTIMEOUT:
				case STATE_HOMETIMEOUT:
				case STATE_JAM:
					buttonActive_homeTimeout = false;
					buttonActive_visitorTimeout = false;
					buttonActive_officialTimeout = true;
					break;
				default:
					buttonActive_homeTimeout = false;
					buttonActive_visitorTimeout = false;
					buttonActive_officialTimeout = false;
					break;
			}
		}
		
	
		/**
		 * This hides all the clocks that are not the period clock
		 */
		private function hideAllNonPeriodClocks():void {
			scoring.jamClock.isVisible = false;
			scoring.timeoutClock.isVisible = false;
			scoring.intermissionClock.isVisible = false;
			scoring.breakClock.isVisible = false;
		}

		
		private function isIntermission():Boolean {
			switch (_currentState){
				case STATE_INTERMISSION:
				case STATE_INTERMISSION_PAUSE:
				case STATE_INTERMISSION_EXPIRED:				
					return true;
					break;
				default:
					return false;
					break;
			}
		}
		
		private function intermissionActivate():void {
			setCurrentState(STATE_INTERMISSION);
			// Hide all the non-perion clocks to make room for the intermission clock
			hideAllNonPeriodClocks();	
			scoring.intermissionClock.start();
			// Update controls and scoreboard based on the current state
			updateCurrentStateContols();
			// Activate buttons accordinly
			if (_gameInProgress) {
				buttonText_intermissionToggle = LABEL_INTERMISSIONEND;
				buttonToooltip_intermission = TOOLTIP_INTERMISSIONEND;
			} else {
				buttonText_intermissionToggle = LABEL_COUNTDOWNEND;
				buttonToooltip_intermission = TOOLTIP_COUNTDOWNEND;
			}
			determineIntermissionButtonActiveStates();
		}

		private function intermissionPause():void {
			setCurrentState(STATE_INTERMISSION_PAUSE);
			scoring.intermissionClock.stop(true, false);
			scoring.jamClock.isVisible=true;
			// Update controls and scoreboard based on the current state
			updateCurrentStateContols();
			
			if (_gameInProgress) {
				buttonText_intermissionToggle = LABEL_INTERMISSION;
				buttonToooltip_intermission = TOOLTIP_INTERMISSION;
			} else {
				buttonText_intermissionToggle = LABEL_COUNTDOWN;
				buttonToooltip_intermission = TOOLTIP_COUNTDOWN;
			}
			determineIntermissionButtonActiveStates();
		}
		
		
		private function intermissionReset(hideClock:Boolean = true):void {
			
			// If this is called after an intermission has expired (as in to
			// perhaps extend the intermission) then we want to hide all clocks
			// and set up as if it were an intermission all over again.
			if (_currentState == STATE_INTERMISSION_EXPIRED) { 
				setCurrentState(STATE_INTERMISSION);
				hideAllNonPeriodClocks(); 
				determineClockLabel();
			}
			
			scoring.intermissionClock.stop(hideClock, true);
			if (_gameInProgress) {
				buttonText_intermissionToggle = LABEL_INTERMISSION;
				buttonToooltip_intermission = TOOLTIP_INTERMISSION;
			} else {
				buttonText_intermissionToggle = LABEL_COUNTDOWN;
				buttonToooltip_intermission = TOOLTIP_COUNTDOWN;
			}
		}
		
		
		/**
		 * This function handles the situation intermission expires
		 */
		private function intermissionExpired():void	{
			setCurrentState(STATE_INTERMISSION_EXPIRED);
			scoring.intermissionClock.stop(true, false);
			if (_gameInProgress) {
				buttonText_intermissionToggle = LABEL_INTERMISSIONRESET;
				buttonToooltip_intermission = TOOLTIP_INTERMISSIONRESET;
			} else {
				buttonText_intermissionToggle = LABEL_COUNTDOWNRESET;
				buttonToooltip_intermission = TOOLTIP_COUNTDOWNRESET;
			}
			determineIntermissionButtonActiveStates();
			
			scoring.jamClock.stop(false, true);
			determineClockLabel();
			// Set the appropriate scoreboard view
		}
		
		/**
		 * This function builds a game status string to be included in the log messages
		 */
		private function logGameStatus():String {
			var gameStatus:String =
					"{" +
						" Gam:" + scoring.gameClock.formattedTimeRemaining + 
				        " Jam:" + scoring.jamClock.formattedTimeRemaining + 
					   	" Prd:" + String(scoring.currentPeriodNumber) + 
					   	" Jct:" + String(scoring.currentJamNumber) +
						//" Hom:" + String(scoring.homeTeam.score) +
						//" Vis:" + String(scoring.visitorTeam.score) +
					 " }";
			return gameStatus;
		}
		

		

				

		
		/**
		 * Based on configured options, determine if the lead jammer status should be displayed
		 */
		private function updateLeadJammerStatus():Boolean {
			// If we are in a jam, then display the leadjammer indicator
			// If we are NOT in a jam and the board is not configured to hide jammer status immediatly at
			// a jam's ending, then display the lead jammer indicator
			if (((! _currentState == STATE_BREAK ) && (! settingsModel.hideLeadJammerIndicatorAtStop))){
				return false;
			// In all other situations the indicator is not displayed
			} else { 
				return true;
			}
			
		}
		

		/**
		 * This hides the jammer information on the scoreboard
		 */
		private function hideJammerInformation():void{
			scoring.homeTeam.jammerInformationVisible = false;
			scoring.visitorTeam.jammerInformationVisible = false;
		}
		
		
		/**
		 * This hides the jammer information on the scoreboard
		 */
		private function showJammerInformation():void{
			scoring.homeTeam.jammerInformationVisible = true;
			scoring.visitorTeam.jammerInformationVisible = true;
		}

		
		/**
		 * This disables the lead jammer indicators to be displayed
		 */
		private function disableLeadJammerIndicators():void{
			scoring.homeTeam.displayLeadJammerIndicator = false;
			scoring.visitorTeam.displayLeadJammerIndicator = false;
			updateLeadJammerStatuses();
		}
		
		/**
		 * This will reset the selected jammers from both home and away rosters
		 */
		private function resetSelectedJammers():void {
			swizDispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.JAMMER_DESELECT, TeamsModel.HOME_TEAM, null));
			swizDispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.JAMMER_DESELECT, TeamsModel.VISITING_TEAM, null));
		}

		/**
		* This enables the lead jammer indicators to be displayed
		*/
		private function enableLeadJammerIndicators():void{
			scoring.homeTeam.displayLeadJammerIndicator = true;
			scoring.visitorTeam.displayLeadJammerIndicator = true;
			updateLeadJammerStatuses();
		}


		/**
		 * Reset the lead jammer buttons, and remove any indicators from the scoreboard
		 */
		private function leadJammerReset():void{
			scoring.homeTeam.leadJammer = false;
			scoring.visitorTeam.leadJammer = false;
			scoring.noLeadJammer = false;
			// Enable the lead jammer indicators on the scoreboard
			enableLeadJammerIndicators();
		}

		
		private function overtimePrepare():void {
			// Jam clock is set to 2 minutes
			scoring.jamClock.resetClock();
			// hide all "non-period" clocks, and show the jam clock
			hideAllNonPeriodClocks();
			scoring.jamClock.isVisible = true;
			// Set the current state to an overtime stopped jam, and set the action button properly
			setCurrentState(STATE_OVERTIMEJAMSTOPPED);
			buttonText_primaryActionToggle = LABEL_START_JAM;
			buttonTooltip_primaryActionToggle = TOOLTIP_STARTJAM;	
			// Each team has NO timeouts in overtime
			scoring.homeTeam.timeoutsLeft=0;
			scoring.visitorTeam.timeoutsLeft=0;
			// Set the overtime flag
			_gameInOvertime = true;
		}
		
		
		/**
		 * This method checks for conditions that indicate the period has ended
		 */
		private function periodHasEnded():Boolean {
			if (_gameClockExpired){
				switch (_currentState){
					case STATE_BREAK:
					case STATE_JAMSTOPPED:
					case STATE_OVERTIMEJAMSTOPPED:
					case STATE_JAMEXPIRED:
						setCurrentState(STATE_ENDPERIOD);
						periodEndHandler();
						return true;
						break;
				}
			}
			return false;
		}
		
		/**
		 * This is used to extend the current period. This is triggered by the user
		 * adding time to the game clock after it has expired.
		 */
		private function periodExtendHandler(): void {
			// Set the state to a stopped jam and reset any flags that indicate the period was copmleted.
			setCurrentState(STATE_JAMSTOPPED);
			_gameClockExpired = false;
			// Update controls and scoreboard based on the current state
			updateCurrentStateContols();
			// Set the label and tooltip of the primary action button
			buttonText_primaryActionToggle = LABEL_START_JAM;
			buttonTooltip_primaryActionToggle = TOOLTIP_STARTJAM;
			// hide all the non-period clocks, and reset and show the jam clock, reset the break clock
			hideAllNonPeriodClocks();
			scoring.jamClock.stop(false, true);
			scoring.breakClock.stop(true, true);
			// Enable the start break button
			buttonActive_breakStartToggle = true;
		}
		
		
		/**
		 * Sets the display properties when the period has ended
		 */
		private function periodEndHandler():void { 
			scoring.gameClock.timeRemaining = 0;
			// set the break and jam clocks to zero this way no matter
			// which was left on the board when the period ended, thay read zero
			scoring.breakClock.timeRemaining = 0;
			scoring.jamClock.timeRemaining = 0;
			// Determine the appropriate timeout button active states.
			determineTimeoutButtonsActiveStates();
			// Set appropriate button properties.
			buttonActive_breakStartToggle = false;
			// Is there another period to be played?
			if ((scoring.currentPeriodNumber+1) <= settingsModel.finalPeriodNumber){
				_LOG.debug("Another Period is expected");
				buttonText_primaryActionToggle = LABEL_PREPAREPERIOD;
				buttonTooltip_primaryActionToggle = TOOLTIP_PREPARENEXTPERIOD;
				buttonActive_primaryActionToggle = true;
				setCurrentState(STATE_ENDPERIOD);
				// alert the user that this period is over, and another is expected
				promptPeriodOver();
			} else {
				// ---- CHECK FOR OVERTIME HERE ----
				if (scoring.homeTeam.score == scoring.visitorTeam.score) {
					_LOG.debug("OVERTIME CONDITION");
					setCurrentState(STATE_OVERTIMEPREPARE);
					buttonText_primaryActionToggle = LABEL_OVERTIME;
					buttonTooltip_primaryActionToggle = TOOLTIP_PREPAREOVERTIME;
					// alert the user that the game has been determined to need overtime
					promptOvertime();
				} else if (scoring.homeTeam.score > scoring.visitorTeam.score) { 
					_LOG.debug("HOME TEAM WINS");
					setCurrentState(STATE_ENDGAME);
					buttonText_primaryActionToggle = LABEL_RESET;
					buttonTooltip_primaryActionToggle = TOOLTIP_RESET;
					// alert the user that the game has been determined to be over
					_gameOver = true;
					promptGameOver(teamsModel.homeTeam);
				} else {
					_LOG.debug("VISITOR TEAM WINS");
					setCurrentState(STATE_ENDGAME);
					buttonText_primaryActionToggle = LABEL_RESET;
					buttonTooltip_primaryActionToggle = TOOLTIP_RESET;
					// alert the user that the game has been determined to be over
					_gameOver = true;
					promptGameOver(teamsModel.visitorTeam);
				}
				buttonActive_primaryActionToggle = true;
			}
			// Determine the state of the intermission button 
			determineIntermissionButtonActiveStates();
			// Set the appropriate scoreboard view

		}
		
		/**
		 * These actions are taken to change the period number
		 */
		public function periodNumberChange(changeValue:int):void {		
			_LOG.debug("Adjust Period Number ["+scoring.currentPeriodNumber+"] by: [" + changeValue +"]");
			scoring.currentPeriodNumber = scoring.currentPeriodNumber + changeValue;
			// If the period number is adjusted below one, then set it to one.
			if (scoring.currentPeriodNumber < 1){ scoring.currentPeriodNumber = 1; }
			if (scoring.currentPeriodNumber > settingsModel.finalPeriodNumber){ scoring.currentPeriodNumber = settingsModel.finalPeriodNumber; }
		} // periodNumberChange	

		
		/**
		 * Actions necessary to start the next period
		 */
		public function periodPrepareNext():void {
			// reset all the clocks
			resetAllClocks();
			// increment the period number
			periodNumberChange(1);
			// if configured to do so, reset the jam count at a new period
			if (settingsModel.resetJamCountAtNewPeriod) scoring.currentJamNumber = 0;
			// Set the action button label, tooltip, and activate it
			buttonText_primaryActionToggle = LABEL_START_JAM;
			buttonTooltip_primaryActionToggle = TOOLTIP_STARTJAM;
			buttonActive_primaryActionToggle = true;
			// Hide all the clock but the period clock.
			// We do this because not sure what clock is showing 
			hideAllNonPeriodClocks();
			// Id this is not intermssion, then show the JAM clock
			if (_currentState == STATE_INTERMISSION) {
				scoring.intermissionClock.isVisible = true; 
			} else {
				// Set the initial state to "new period"
				setCurrentState(STATE_NEWPERIOD);
				scoring.jamClock.isVisible = true;
			}
			// Update controls and scoreboard based on the current state
			updateCurrentStateContols();
			_setForNextPeriod = true;
			currentControlViewState = "scoring";
			// If timeouts are to be reset each period, then do so now...
			if (settingsModel.resetTimeoutsEachPeriod) resetTeamTimeouts();
		}
		
		/**
		 * These actions are taken whan a period begins
		 */
		private function periodStart():void{
			// Jam point controls are enabled at the start of a new period
			jamPointsControlEnabled = true;			
			_setForNextPeriod = false;
			_gameOver = false;
			_gameInProgress = true;
			_gameClockExpired = false;
			// Determine the appropriate intermission button state
			intermissionReset(true);
			determineIntermissionButtonActiveStates();
			// Set the appropriate scoreboard view
		}
		
		/**
		 * Resets all clocks
		 */
		private function resetAllClocks():void {
			var resetIntermissionClock:Boolean = true;
			if (isIntermission()) resetIntermissionClock = false; 
			
			scoring.resetClocks(resetIntermissionClock);
		}
		
		/**
		 * Resets the scoreboard to score a new bout
		 */
		public function resetScoreboard():void{
			
			var resetIntermissionClock:Boolean = false;

			// Reset the scoreboard
			_LOG.debug("Reseting the scoring system.");
			// deactivate the lead jammers
			swizDispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.JAMMER_DESELECT, TeamsModel.HOME_TEAM, null));
			swizDispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.JAMMER_DESELECT, TeamsModel.VISITING_TEAM, null));	
			
			// Reset all the stats for the teams loaded
			swizDispatcher.dispatchEvent(new BoutStatsEvent(BoutStatsEvent.RESET_STATS));

			// Set the initial state to "new period" (as long as we are not in an intermission)
			if (isIntermission()) {
				resetIntermissionClock = false;
			} else {
				setCurrentState(STATE_NEWPERIOD);
				resetIntermissionClock = true;
			}
			scoring.resetScoring(resetIntermissionClock);
			// reset the timeout counts
			resetTeamTimeouts();

			buttonText_primaryActionToggle = LABEL_START_JAM;
			buttonTooltip_primaryActionToggle = TOOLTIP_STARTJAM;
			
			buttonText_intermissionToggle = LABEL_COUNTDOWN;
			buttonToooltip_intermission = TOOLTIP_COUNTDOWN;
			
			// Update controls and scoreboard based on the current state
			updateCurrentStateContols();
			// increment the period number (from zero to one)
			periodNumberChange(1);
			_setForNextPeriod = true;
			_gameInOvertime = false;
			_gameOver = false;
			_gameInProgress = false;
			firstJamEnded = false;
			// set current viewstate to scoring
			currentControlViewState = "scoring";			
			// Determine the appropriate intermission button state
			determineIntermissionButtonActiveStates();
			// Set the appropriate scoreboard view
		}
		
		
		/**
		 * Reset the home and visiting team timeout count.
		 */
		private function resetTeamTimeouts(): void{
			// reset the timeout count for both the home and away teams
			scoring.homeTeam.timeoutsLeft = settingsModel.resetTeamTimeoutCount;
			scoring.visitorTeam.timeoutsLeft = settingsModel.resetTeamTimeoutCount;
		}
		
		
		
		/**
		 * Responsible for managing the current and previous states
		 */
		private function setCurrentState(newState:String): void{			
			_previousState = _currentState;
			_currentState = newState;
			currentStateDescription = newState;			
			_LOG.debug("Previous ["+_previousState+"] Current ["+_currentState+"]"  + logGameStatus());			
			// Set the appropriate scoreboard view
			dispatchStateAwareScoreboardViewMode();
		}
		
		
		/**
		 * Clear all the timout indicators from the scoroboard
		 */
		private function timeoutsClearAllIndicators():void {
			scoring.officialTimeout = false;
			scoring.homeTeam.timeout = false;
			scoring.visitorTeam.timeout = false;
		}
		

		/**
		 * This function handles the situation when a team timout clock expires
		 */
		private function timeoutClockExpired():void	{
			// Set a new current state
			setCurrentState(STATE_TIMEOUTEXPIRED);
			// Stop and reset the timeout clock
			scoring.timeoutClock.stop(false, false);
			// resume the break clock, indicating that a timeout expired
			breakActivate();
			// Enable the timeout buttons
			determineTimeoutButtonsActiveStates();
		}
		
		
		/**
		 * This is called to update the scoreboard and scoreboard controls based on the current state
		 */
		private function updateCurrentStateContols(): void{
			determineClockLabel();
			determineTimeoutButtonsActiveStates();
		}
		
		
		public function updateLeadJammerStatuses():void {
			swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.UPDATE_LEAD_JAMMER));
		}
		


		
		// ----------------------------------------------------------------------------------------
		// Private Timer Methods
		// ----------------------------------------------------------------------------------------		
		/**
		 * This is called each time the timer event is fired
		 * It does some math to calculate how much time has passed since the last 
		 * tick and passes that along.
		 **/
		private function onTimer(event:TimerEvent):void {
			var timer:int = getTimer();
			var millis:int = timer - _lastTick;
			_lastTick = timer;
			onTick(millis);
		}
		
		/** 
		 * Each time the clock "ticks" the active clock values are updated. In some cases, when a
		 * clock expires, a specific function may be called.
		 */
		private function onTick(millis:int):void {
			if (scoring.gameClock.isActive){
				scoring.gameClock.timeRemaining -= millis;
				// if the game clock has expired
				if (scoring.gameClock.timeRemaining <= 0){
					gameClockExpires();
				}
			}
			if (scoring.jamClock.isActive){
				scoring.jamClock.timeRemaining -= millis;
				if (scoring.jamClock.timeRemaining <= 0){
					scoring.jamClock.stop(false, false);
					// If configured to do so, start the break clock immediatly when the jam clock expires.
					if (settingsModel.breakClockAutostartOnJamExpire){
						actionJamStop();
					}
					
				}
			}
			if (scoring.breakClock.isActive){
				scoring.breakClock.timeRemaining -= millis;
				if (scoring.breakClock.timeRemaining <= 0){
					scoring.breakClock.stop(false, false);
					// if configured to do so, start the jam clock immediatly when the break clock expires
					if (settingsModel.jamClockAutostartOnBreakExpire){
						actionJamStart();
					}
				}
			}
			if (scoring.timeoutClock.isActive){
				scoring.timeoutClock.timeRemaining -= millis;
				if (scoring.timeoutClock.timeRemaining <= 0){
					timeoutClockExpired();
				}
			}
			if (scoring.intermissionClock.isActive){
				scoring.intermissionClock.timeRemaining -= millis;
				if (scoring.intermissionClock.timeRemaining <= 0){
					intermissionExpired();
				}
			}
			if (scoring.officialTimeoutClock.isActive){
				scoring.officialTimeoutClock.timeRemaining += millis;
			}

		}

	}
}