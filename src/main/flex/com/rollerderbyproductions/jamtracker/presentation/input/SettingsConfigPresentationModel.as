package com.rollerderbyproductions.jamtracker.presentation.input
{
	import com.rollerderbyproductions.jamtracker.domain.AppImage;
	import com.rollerderbyproductions.jamtracker.domain.Clock;
	import com.rollerderbyproductions.jamtracker.model.ApplicationModel;
	import com.rollerderbyproductions.jamtracker.model.AssetModel;
	import com.rollerderbyproductions.jamtracker.model.ScoringModel;
	import com.rollerderbyproductions.jamtracker.model.SettingsModel;
	import com.rollerderbyproductions.jamtracker.presentation.MainPresentationModel;
	import com.rollerderbyproductions.jamtracker.util.ImageUtility;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class SettingsConfigPresentationModel
	{
		
		private const MILLISECONDS_MAX_HUNDRETHS_TRIGGER:int = 599000;
		
		[Bindable][Inject] public var settingsModel:SettingsModel;
		[Bindable][Inject] public var scoring:ScoringModel;
		
		[Bindable] public var backgroundImageUploadText:String = "UPDATE IMAGE";
		[Bindable] public var displayImageSizeWarning:Boolean = false;		
		
		private static const _LOG:ILogger = Log.getLogger("SettingsConfigPresentationModel");

		
		// Public Methods -------------------------------------------------------------------------
		
		/**
		 * Resumes defined keyboard shortcuts
		 */
		public function resumeKeyboardShortcuts():void{
			_LOG.debug("Resuming Keyboard Shortcuts")
			MainPresentationModel.suspendShortcuts = false;
		}
		
		/**
		 * Suspends defined keyboard shortcuts
		 */
		public function suspendKeyboardShortcuts():void{
			_LOG.debug("Suspending Keyboard Shortcuts")
			MainPresentationModel.suspendShortcuts = true;
		}
				
		/**
		 * Validates a requested reset value for a specified clock object.  It is compared
		 * against the maximim reset value of the provided clock object for validity
		 * 
		 * @param clockObject - The clock object attempting to be reset
		 * @param timeString - A string represeting the time to use as a reset time
		 * @param [zeroTimePermitted] - True: A time of zero milliseconds can be returned
		 *                              False: (default) A time of zero milliseconds will be replaced with 
		 * 									   the millisecondsMaxValue
		 */
		public function validateResetValue(clockObject:Clock, timeString:String,  zeroTimePermitted:Boolean=false): void {
			clockObject.resetValue = Clock.validateTime(timeString, clockObject.maxResetValue, zeroTimePermitted);
			// resume the Keyboard Shortcuts
			resumeKeyboardShortcuts();
		}

		
		/**
		 * Validates a requested hundreths trigger value for a specified clock object.  It is compared
		 * against the maximim hundreths value of the provided clock object for validity
		 * 
		 * @param clockObject - The clock object attempting to be reset
		 * @param timeString - A string represeting the time to use as a reset time
		 * @param [zeroTimePermitted] - True: (default) A time of 0:00 can be returned
		 *                              False: A time of 0:00 will be replaced with 
		 * 									   the clock's defined millisecondsMaxValue
		 */
		public function validateHundrethsTriggerValue(clockObject:Clock, timeString:String, zeroTimePermitted:Boolean=true): void {
			clockObject.hundrethsTrigger = Clock.validateTime(timeString, clockObject.maxHundrethsTrigger, zeroTimePermitted);
			// resume the Keyboard Shortcuts
			resumeKeyboardShortcuts();
		}
		
		/**
		 * Updates the number of periods to be scored for this game
		 * 
		 * @param finalPeriodNumber - The last number of the period to score (typically this is 2)
		 */
		public function setFinalPeriodnumber(finalPeriodNumber:int):void {
			if ((finalPeriodNumber > 0) && (finalPeriodNumber < 10)) {
				
				if ( finalPeriodNumber < scoring.currentPeriodNumber ){
					promptInvalidPeriodNumber();
				} else {				
					settingsModel.finalPeriodNumber = finalPeriodNumber;
					_LOG.debug("Final period number set ["+finalPeriodNumber+"]");
				}
			}
		}
		

		/**
		 * Updates the number of timeouts each team is awarded, when the timeouts are reset
		 * 
		 * @param resetTeamTimeoutCount - The number of timouts to award (typically this is 3)
		 */
		public function setResetTeamTimeoutCount(resetTeamTimeoutCount:int):void {
			if ((resetTeamTimeoutCount > 0) && (resetTeamTimeoutCount < 10)) {
				settingsModel.resetTeamTimeoutCount = resetTeamTimeoutCount;
			}
		}

		
		/**
		 * This will prompt the user when a period is determined to be over.
		 */
		public function promptInvalidPeriodNumber():void {
			Alert.show("Sorry, a final period number less that the current period number("+scoring.currentPeriodNumber+") is invalid.", "Invalid Entry", Alert.OK, null, null, AssetModel.ICON_ALERT32_CLASS, Alert.OK, null);	
		}
		
		
	}
}