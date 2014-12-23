package com.rollerderbyproductions.jamtracker.util
{
	import flash.filesystem.File;
	
	import mx.controls.DateField;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.logging.targets.TraceTarget;

	public class LoggingConfig
	{
		public static const DEV:String = "DEV";
		public static const FILE:String = "FILE";
		
		public static var logFileName:String = DateField.dateToString(new Date(), "YYYY_MM_DD")+"_JamTracker.log";

		/**
		 * Set the logging target based on the suggested mode
		 * 
		 * @param mode - The mode in which to set the logging target
		 *               i.e. LoggingConfig.DEV
		 */
		public static function setLoggingTarget(mode:String = DEV,logFileDir:File = null):void {

			switch(mode){

				case FILE:
					var logFilePath:String =  logFileDir.nativePath+ "\\"+ logFileName;
					var file:File = new File(logFilePath);
					var fileTarget:FilesystemTarget = new FilesystemTarget(file);
					
					//fileTarget.filters=["mx.rpc.*","mx.messaging.*"];
					fileTarget.level = LogEventLevel.ALL;
					fileTarget.includeDate = true;
					fileTarget.includeTime = true;
					fileTarget.includeCategory = true;
					fileTarget.includeLevel = true;             
					// Get Logging
					Log.addTarget(fileTarget);
					break;
				
				case DEV:			
				default:
					var logTarget:TraceTarget = new TraceTarget();
					
					//logTarget.filters=["mx.rpc.*","mx.messaging.*"];
					// Log all log levels.
					logTarget.level = LogEventLevel.ALL;
					// Add date, time, category, and log level to the output.
					logTarget.includeDate = true;
					logTarget.includeTime = true;
					logTarget.includeCategory = true;
					logTarget.includeLevel = true;
					// Begin logging.
					Log.addTarget(logTarget)
			}
		}
		

		
	}
}