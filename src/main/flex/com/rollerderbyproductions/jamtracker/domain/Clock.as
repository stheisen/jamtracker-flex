package com.rollerderbyproductions.jamtracker.domain
{
	import com.rollerderbyproductions.jamtracker.model.AssetModel;
	import com.rollerderbyproductions.jamtracker.presentation.input.SettingsConfigPresentationModel;
	
	import flash.html.ControlInitializationError;
	
	import mx.controls.Alert;

	[RemoteClass]
	[Bindable]
	public class Clock
	{
		
		public static const LONG_FORMAT:String  = "8:88.88";
		public static const SHORT_FORMAT:String = "88:88";
		
		public static const MAX_GAMECLOCK_MILLIMAX:int = 5940000;
		public static const MAX_JAMCLOCK_MILLIMAX:int = 5940000;
		public static const MAX_BREAKCLOCK_MILLIMAX:int = 5940000;
		public static const MAX_TIMEOUTCLOCK_MILLIMAX:int = 5940000;
		public static const MAX_INTERMISSIONCLOCK_MILLIMAX:int = 5940000;
		public static const MAX_OFFICIALTIMEOUTCLOCK_MILLIMAX:int = 5940000;
		
		public var formattedTimeRemaining:String;
		public var formattedResetTime:String;
		public var formattedHundrethsTrigger:String = "0:00";
		public var isActive:Boolean;
		public var isVisible:Boolean = false;
		public var displayFormat:String;
		private var _timeRemaining:int;
		private var _resetValue:int;
		private var _maxResetValue:int;
		private var _hundrethsTrigger:int = 0;
		private var _maxHundrethsTrigger:int;
		
		// Constructors ---------------------------------------------------------------------------
		/* NOTE: An empty constructor is required to export/import this object to/from filesystem */
		public function Clock(){
		}

		/**
		 * Creates a new clock object
		 * 
		 * @param millisecondsResetValue - The value this clock should be set to at creation time or when
		 *                     it is reset.
		 * @param millisecondsMaxResetValue - The maximum number of miliseconds this clock can be reset to
		 * @param millisecondsHundrethsTrigger - The number of miliseconds remaing on the timer before showing 
		 *                     hundreths of a second. Default is one minute (60000 miliseconds). Set
		 *                     to zero to never show hundreths.
		 * @param millisecondsMaxHundrethsTrigger - The maximum number of miliseconds at which this clock
		 *                     can begin to display milliseconds (599000 milliseconds deault) 
		 */
		public function init(millisecondsResetValue:int, millisecondsMaxValue:int, millisecondsHundrethsTrigger:int=60000, millisecondsMaxHundrethsTrigger:int=599000):void {
			// Use custom setters for all clock properties
			this.resetValue = millisecondsResetValue;
			this.maxResetValue = millisecondsMaxValue;
			this.hundrethsTrigger = millisecondsHundrethsTrigger;
			this.maxHundrethsTrigger = millisecondsMaxHundrethsTrigger;
			// At initilization time, set the time remaining to the reset value
			this.timeRemaining = millisecondsResetValue;
		}
		
		// Custom Setters and Getters -------------------------------------------------------------
		public function get timeRemaining():int {return _timeRemaining;}
		public function set timeRemaining(milliseconds:int):void {			
			if (milliseconds < 0) {
				_timeRemaining = 0;
			} else {
				_timeRemaining = milliseconds;
			}
			this.formattedTimeRemaining = buildFormattedTime(_timeRemaining);
		}

		public function get resetValue():int {return _resetValue;}
		public function set resetValue(milliseconds:int):void {
			_resetValue = milliseconds;
			this.formattedResetTime = buildFormattedTime(_resetValue, SHORT_FORMAT);
		}

		public function get maxResetValue():int {return _maxResetValue;}
		public function set maxResetValue(milliseconds:int):void {
			_maxResetValue = milliseconds;
		}

		public function get hundrethsTrigger():int {return _hundrethsTrigger;}
		public function set hundrethsTrigger(milliseconds:int):void {
			_hundrethsTrigger = milliseconds;
			this.formattedHundrethsTrigger = buildFormattedTime(_hundrethsTrigger, SHORT_FORMAT);
		}
		
		public function get maxHundrethsTrigger():int {return _maxHundrethsTrigger;}
		public function set maxHundrethsTrigger(milliseconds:int):void {
			_maxHundrethsTrigger = milliseconds;
		}

		
		// Public Methods -------------------------------------------------------------------------
		/**
		 * Resets the clock to its preset resetValue
		 */
		public function resetClock():void{
			timeRemaining = _resetValue;
		}
		
		
		/**
		 * Stops the provided clock object by setting its isActive property to false. The 
		 * clock may also be hidden or reset as well.
		 * 
		 * @param hideClock - Sets the visibility property of the clock
		 * @param resetClock - Resets the clock to is reset value by calling its resetClock() method
		 */
		public function stop(hideClock:Boolean = false, resetClock:Boolean = false): void{			
			// Deactivate (stop) the clock 
			this.isActive = false;
			// hide the clock if requested
			if (hideClock) this.isVisible = false else this.isVisible = true;
			// reset the clock if requested
			if (resetClock) this.resetClock();			
		}
		
		
		/**
		 * Stops the provided clock object by setting its isActive property to true. The 
		 * clock may also be hidden as well
		 * 
		 * @param hideClock - Sets the visibility property of the clock
		 */
		public function start(hideClock:Boolean = false): void {
			// Activate (start) this clock
			this.isActive = true;
			// Make this clock visible
			if (hideClock) this.isVisible = false else this.isVisible = true;
		}
		
		// Static Methods -------------------------------------------------------------------------
		/**
		 * Uses milliseconds to construct a String representation of time in a specfified format
		 *  
		 * @param milliseconds - The number of milliseconds to convert from
		 * @param [requestedFormat] - Clock.LONG_FORMAT formats with milliseconds
		 * 				    	      Clock.SHORT_FORMAT (default) formats without milliseconds
		 */
		public static function milisecondsToFormatted(milliseconds:int, requestedFormat:String=null):String {
			var minutes:int = milliseconds / 60000;
			var seconds:int = (milliseconds % 60000) / 1000;
			var hundredths:int = (milliseconds % 1000) / 10;
			// Build the long format of the time if specified, otherwise build the short format
			if (requestedFormat == Clock.LONG_FORMAT){
				return minutes + ':' + (seconds < 10 ? '0' : '') + seconds + '.' + (hundredths < 10 ? '0' : '') + hundredths;
			} else {
				return (minutes < 10 ? ' ' : '') + minutes + ':' + (seconds < 10 ? '0' : '') + seconds;
			}
		}

		
		/**
		 * Parses a string value, and attempts to convert it to milliseconds.  A colon in the string
		 * is optional. After stripping all the non numeric characters, the right most two digits 
		 * will be assumed to be seconds, the remaining characters are assumed minutes
		 * 
		 * @param timeString - The time string to convert to milliseconds
		 * @param [formatMask] - The display format of the time string being validated
		 * 							Clock.LONG_FORMAT formats with milliseconds
		 * 				    	    Clock.SHORT_FORMAT (default) formats without milliseconds
		 */
		public static function parseTime(timeString:String, formatMask:String=Clock.SHORT_FORMAT):int {
			var digits:String = timeString.replace(/[^\d]/, '');
			var minutes:int = 0;
			var seconds:int = 0;
			var hundredths:int = 0;
			
			if (digits.length) {
				if (formatMask == Clock.SHORT_FORMAT){
					digits = digits.replace(':', '');
					// Split the minutes, seconds out of the timeString
					if (digits.length > 2) minutes = int(digits.slice(0, -2));
					seconds = int(digits.slice(-2));
				} else {
					// Remove the markers in the time string
					digits = digits.replace(':', '');
					digits = digits.replace('.', '');
					// Split the minutes, seconds and hundredths out of the timeString
					if (digits.length >= 5)	minutes = int(digits.slice(0, -4)); 
					if ((digits.length <= 5) && (digits.length > 2)) seconds = int(digits.slice(-4, -2));
					hundredths = int(digits.slice(-2));
				}
			}
			return (minutes * 60000) + (seconds * 1000) + (hundredths * 10);
		}

		
		/**
		 * Parses the provided string and validates that is it no longer than the specified maximum number
		 * of millisseconds. If it fails this test, then it is set to the maximum number.
		 * <p>
		 * <b>NOTE: This method may display an Alert Box on conditional failure</b>
		 * <p>
		 * @param timeString - The time string to convert to milliseconds, and validated
		 * @param millisecondsMaxValue - The maximum number of millisecons permitted
		 * @param [formatMask] - The display format of the time string being validated
		 * 							Clock.LONG_FORMAT formats with milliseconds
		 * 				    	    Clock.SHORT_FORMAT (default) formats without milliseconds
		 * @param [zeroTimePermitted] - True: A time of zero milliseconds can be returned
		 *                              False: (default) A time of zero milliseconds will be replaced with 
		 * 									   the millisecondsMaxValue
		 *  
		 * @return Then number of validated milliseconds as represented in the provided timestring 
		 */
		public static function validateTime(timeString:String, millisecondsMaxValue:int, zeroTimePermitted:Boolean=false, formatMask:String=Clock.SHORT_FORMAT):int {
			
			var timeInMilliseconds:int = 0;
			// Parse the passed timestring, and convert to milliseconds
			timeInMilliseconds = Clock.parseTime(timeString, formatMask);
			// If the return value is greater than specified maximum number of milliseconds, then alert the user
			// and set the time to the maximum setting
			if (timeInMilliseconds > millisecondsMaxValue){
				Alert.show("Sorry, this value can be no greater then "+Clock.milisecondsToFormatted(millisecondsMaxValue, Clock.SHORT_FORMAT)+".","Oops!", Alert.OK, null, null, AssetModel.ICON_ERROR32_CLASS);
				timeInMilliseconds = millisecondsMaxValue;
				// If the number if milliseonds is zero, then set the time to the maximum setting (default behavior)
			} else if ((timeInMilliseconds == 0) && (!zeroTimePermitted)) {
				timeInMilliseconds = millisecondsMaxValue;
			} 
			return timeInMilliseconds;
		}
		
		// Private Methods ------------------------------------------------------------------------
		/**
		 * Uses milliseconds to construct a String representation of time in a specfified format
		 * 
		 * @param milliseconds - The number of millisconds to convert to a string
		 * @param [format] - Clock.LONG_FORMAT formats with milliseconds
		 * 				     Clock.SHORT_FORMAT formats without milliseconds 
 		 *                   null - (default) the format is deterined by the clock's hundreth's trigger  
		 */
		private function buildFormattedTime(milliseconds:int, requestedFormat:String=null):String {
			// If no requested format was specified, then determine the format based on the set 
			// hundreths trigger value
			var formatMask:String;
			
			if (requestedFormat == null){
				if ((_hundrethsTrigger > 0) && (milliseconds <= _hundrethsTrigger )){
					formatMask = LONG_FORMAT;
				} else {
					formatMask = SHORT_FORMAT;
				}
				this.displayFormat = formatMask;
			} else {
				formatMask = requestedFormat;
			}
			
			return	milisecondsToFormatted(milliseconds, formatMask);
		}

	}
}