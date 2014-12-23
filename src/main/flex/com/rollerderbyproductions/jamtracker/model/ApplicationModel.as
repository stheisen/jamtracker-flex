package com.rollerderbyproductions.jamtracker.model
{
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.logging.ILogger;
	import mx.logging.Log;

	[Bindable]
	public class ApplicationModel
	{
		
		// These values constant throughout the life of the application
	
		public static const isEvaluationCopy:Boolean = false;
		
		public static const DIR_ROOT:String = "\JamTracker"; 
		public static const DIR_STATE_STORAGE:String = ""; 
		public static const DIR_TEAM_STORAGE:String = "\Teams"; 
		public static const DIR_EXPORT_STORAGE:String = "\Export"; 
		public static const DIR_CONFIG_STORAGE:String = "\Config"; 
		public static const DIR_LOG_STORAGE:String = "\Log"; 
		public static const FILEEXT_TEAM_STORAGE:String = ".jtt"; 
		public static const FILEEXT_CONFIG_STORAGE:String = ".jcs"; 

		public static const HEIGHT_OF_IMAGE_AND_LOGO:Number = 390;
		
		public static const FILENAME_CLOSINGSTATE:String = "cst.jcs";
		public static const UPDATE_URL:String = "http://www.rollerderbyproductions.com/dist/jamtracker/update.xml";
		
		public static const CURTAIN_IMAGE_MAX_KBSIZE:Number = 1000; // in KB		
		public static const MESSAGE_CURTAIN_IMAGE_EXCEED_MAX_SIZE:String = 
			"The curtain image exceeds the recommended maximum file size of "+CURTAIN_IMAGE_MAX_KBSIZE+"KB. "+
			"If as a result this system experiences a degradation of performance, "+
			"please consider replacing this image with one of a smaller size."

		
		public static const PLAYER_IMAGE_MAX_KBSIZE:Number = 700; // in KB
		public static const MESSAGE_PLAYER_IMAGE_EXCEED_MAX_SIZE:String = 
							  "This player's image exceeds the recommended maximum file size of "+PLAYER_IMAGE_MAX_KBSIZE+"KB. "+
							  "If as a result this system experiences a degradation of performance, "+
							  "please consider replacing this image with one of a smaller size."
		
		public static const PREGAME_IMAGE_MAX_KBSIZE:Number = 1000; // in KB		
		public static const MESSAGE_PREGAME_IMAGE_EXCEED_MAX_SIZE:String = 
			"The pregame image exceeds the recommended maximum file size of "+PREGAME_IMAGE_MAX_KBSIZE+"KB. "+
			"If as a result this system experiences a degradation of performance, "+
			"please consider replacing this image with one of a smaller size."		
							  
							  
		public static const TEAMLOGO_IMAGE_MAX_KBSIZE:Number = 1000; // in KB		
		public static const MESSAGE_TEAMLOGO_IMAGE_EXCEED_MAX_SIZE:String = 
			"This team's logo exceeds the recommended maximum file size of "+TEAMLOGO_IMAGE_MAX_KBSIZE+"KB. "+
			"If as a result this system experiences a degradation of performance, "+
			"please consider replacing this image with one of a smaller size."


		public static const DEFAULTJAMMERIMAGE_IMAGE_MAX_KBSIZE:Number = 500; // in KB		
		public static const MESSAGE_DEFAULTJAMMERIMAGE_IMAGE_EXCEED_MAX_SIZE:String = 
			"This default jammer image exceeds the recommended maximum file size of "+DEFAULTJAMMERIMAGE_IMAGE_MAX_KBSIZE+"KB. "+
			"If as a result this system experiences a degradation of performance, "+
			"please consider replacing this image with one of a smaller size."
			
			
		public static const LEADINDICATOR_IMAGE_MAX_KBSIZE:Number = 500; // in KB		
		public static const MESSAGE_LEADINDICATOR_IMAGE_EXCEED_MAX_SIZE:String = 
			"This lead jammer indicator image exceeds the recommended maximum file size of "+LEADINDICATOR_IMAGE_MAX_KBSIZE+"KB. "+
			"If as a result this system experiences a degradation of performance, "+
			"please consider replacing this image with one of a smaller size."


		public static const BACKGROUND_IMAGE_MAX_KBSIZE:Number = 1500; // in KB		
		public static const MESSAGE_BACKGROUND_IMAGE_EXCEED_MAX_SIZE:String = 
			"This background image exceeds the recommended maximum file size of "+BACKGROUND_IMAGE_MAX_KBSIZE+"KB. "+
			"If as a result this system experiences a degradation of performance, "+
			"please consider replacing this image with one of a smaller size."
		
		
		public static const OVERLAY_IMAGE_MAX_KBSIZE:Number = 1500; // in KB		
		public static const MESSAGE_OVERLAY_IMAGE_EXCEED_MAX_SIZE:String = 
			"This background overlay image exceeds the recommended maximum file size of "+OVERLAY_IMAGE_MAX_KBSIZE+"KB. "+
			"If as a result this system experiences a degradation of performance, "+
			"please consider replacing this image with one of a smaller size."
						
		// These values are loaded at runtime
		public var applicationName:String;
		public var versionNumber:String;
		public var rootDir:File;
		public var stateDir:File;
		public var teamsDir:File;
		public var exportsDir:File;
		public var configDir:File;
		public var logDir:File;
		
		private static const _LOG:ILogger = Log.getLogger("ApplicationModel");

		// Public Methods -------------------------------------------------------------------------
		/**
		 * Displays a common fatal error message
		 * 
		 * @param message - Message to display to the user
		 * @param title - The title of the alert box [default = Fatal Error]
		 */
		public static function fatalErrorMsg(message:String, title:String = "Fatal Error"):void {
			_LOG.fatal(message);
			Alert.show(message, title, Alert.OK, null, null, AssetModel.ICON_ERROR32_CLASS, Alert.OK, null);
		}

		/**
		 * Displays a common error message
		 * 
		 * @param message - Message to display to the user
		 * @param title - The title of the alert box [default = Error]
		 */
		public static function errorMsg(message:String, title:String = "Error"):void {
			_LOG.error(message);
			Alert.show(message, title, Alert.OK, null, null, AssetModel.ICON_ERROR32_CLASS, Alert.OK, null);
		}
		
	}
}