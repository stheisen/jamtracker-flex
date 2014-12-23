package com.rollerderbyproductions.jamtracker.persistance
{
	import com.rollerderbyproductions.jamtracker.domain.PersitedObject;
	import com.rollerderbyproductions.jamtracker.events.RosterEvent;
	import com.rollerderbyproductions.jamtracker.model.ApplicationModel;
	import com.rollerderbyproductions.jamtracker.model.ScoreboardModel;
	import com.rollerderbyproductions.jamtracker.util.FileSystem;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.getClassByAlias;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class ScoreboardModelRepository extends Repository
	{
		private static const _LOG:ILogger = Log.getLogger("ScoreboardModelRepository");

		/**
		 * Builds the persisted object for the provided scoreboardModelObj
		 *
		 * @param applicationVersionNumber - The version number of the jamTracker application
		 * @param scoreboardModelObj - the ScoreboardModel object to persist
		 */
		public static function buildPersistedObject(applicationVersionNumber:String, ScoreboardModelObj:ScoreboardModel):PersitedObject {

			// Register the classes to be serialized
			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject", PersitedObject);
			registerClassAlias("com.rollerderbyproductions.jamtracker.model.ScoreboardModel", ScoreboardModel);

			return createPersistedInstance(applicationVersionNumber, ScoreboardModel.OBJECT_VERSION, PersitedObject.OBJECT_SCOREBOARDMODEL, ScoreboardModelObj);
			
		}
		
		
		/**
		 * Writes the supplied ScoreboardModel object to the filesystem
		 * 
		 * @param applicationVersionNumber - The version number of the jamTracker application
		 * @param scoreboardModelObj - the ScoreboardModel object to persist
		 * @param targetFile - the file to write the ScoreboardModel object to
		 */
		public static function writePersistedObject(applicationVersionNumber:String, ScoreboardModelObj:ScoreboardModel, targetFile:File):void {
			// Create and write the object to the filesystem
			writeObjectToFileSystem(buildPersistedObject(applicationVersionNumber, ScoreboardModelObj), targetFile);
		}
		

		/**
		 * This method loads the persisted object from the file system
		 * 
		 * @fileName - The name of the file to load
		 * @readDir - The directory that contains the file to load
		 * @targetObject - The object that contains the ScoreboardModel to be loaded. For some reason if
		 *                 this method returns a ScoreboardModel object, and assignes it to the object
		 *                 currently bound to the view, it does not get refreshed. This fixes this problem
		 */
		public static function loadPersistedObject(fileName:String, readDir:File, targetObject:ScoreboardModel):void {
			
			var readPersistedObject:PersitedObject = null;
			var fileStream:FileStream = new FileStream();
			var readFile:File = readDir.resolvePath(fileName);
			
			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject", PersitedObject);
			registerClassAlias("com.rollerderbyproductions.jamtracker.model.ScoreboardModel", ScoreboardModel);
			getClassByAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject");
			getClassByAlias("com.rollerderbyproductions.jamtracker.model.ScoreboardModel");
		    
			// Load the persisted ScoreboardModel object from the filesystem
			readPersistedObject = loadPersistedObjectFromFileSystem(fileName, readDir);
			
			// If the read object is not null. then load the ScoreboardModel
			if (readPersistedObject == null){
				ApplicationModel.errorMsg("JamTracker was unable to properly load the selected scoreboard settings.", "Scoreboard Loading Error");
			} else {
				loadScoreboardModelObject(readPersistedObject, targetObject);
			}
			
		}
		
		
		/**
		 * This method takes a persistedObject and attempts to load it into a ScoreboardModel object
		 * 
		 * @persistedObject - The persisted object to load into a ScoreboardModel object
		 * @targetObject - The object that contains the ScoreboardModel to be loaded. For some reason if
		 *                 this method returns a ScoreboardModel object, and assignes it to the object
		 *                 currently bound to the view, it does not get refreshed. This fixes this problem
		 */
		public static function loadScoreboardModelObject(persistedObject:PersitedObject, targetObject:ScoreboardModel):void {

			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject", PersitedObject);
			registerClassAlias("com.rollerderbyproductions.jamtracker.model.ScoreboardModel", ScoreboardModel);
			getClassByAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject");
			getClassByAlias("com.rollerderbyproductions.jamtracker.model.ScoreboardModel");

			var stream:ByteArray = persistedObject.binaryData;
			var readScoreboardModel:ScoreboardModel = stream.readObject();
			
			try {
				// Validate the the object type is accurate
				if (persistedObject.objectType != PersitedObject.OBJECT_SCOREBOARDMODEL) throw new Error("Invalid file type ["+persistedObject.objectType+"]");
				_LOG.debug("Loading ScoreboardModel version ["+persistedObject.objectVersion+"]");
				// Load the object based on the version that was loaded
				switch (persistedObject.objectVersion){
					case "5.0":
						// NO BREAK? - May want to let it run through the older loaders...
					case "4.0":
						targetObject.homeDefaultJammerImage		= readScoreboardModel.homeDefaultJammerImage;
						targetObject.visitorDefaultJammerImage  = readScoreboardModel.visitorDefaultJammerImage;
						targetObject.autoMinimizeJammerInfo		= readScoreboardModel.autoMinimizeJammerInfo;
					case "3.0":
						targetObject.clockTitlefontColor        = readScoreboardModel.clockTitlefontColor;
						targetObject.clockTitleFontAlpha        = readScoreboardModel.clockTitleFontAlpha;
					case "2.0":
						targetObject.setJammerImageHeight       = readScoreboardModel.setJammerImageHeight;
						targetObject.currentJammerImageHeight	= readScoreboardModel.currentJammerImageHeight;
						targetObject.currentTeamLogoHeight		= readScoreboardModel.currentTeamLogoHeight;
						targetObject.hideJammerImageArea		= readScoreboardModel.hideJammerImageArea;
					case "1.0":
					default:
						targetObject.backgroundAlpha            = readScoreboardModel.backgroundAlpha;
						targetObject.backgroundColor            = readScoreboardModel.backgroundColor;
						targetObject.backgroundImage            = readScoreboardModel.backgroundImage;
						targetObject.backgroundImageAlpha       = readScoreboardModel.backgroundImageAlpha;
						targetObject.backgroundImageVisible     = readScoreboardModel.backgroundImageVisible;
						targetObject.backgroundMaintainAspect   = readScoreboardModel.backgroundMaintainAspect;
						targetObject.containerBorderAlpha       = readScoreboardModel.containerBorderAlpha;
						targetObject.containerBorderColor       = readScoreboardModel.containerBorderColor;
						//targetObject.defaultJammerImage         = readScoreboardModel.defaultJammerImage;  <<-- No longer used as of v0.5.0
						targetObject.displayJammerImage         = readScoreboardModel.displayJammerImage;		
						targetObject.displayJammerName          = readScoreboardModel.displayJammerName;
						targetObject.fontAlpha                  = readScoreboardModel.fontAlpha;
						targetObject.fontColor                  = readScoreboardModel.fontColor;
						targetObject.glowEnabled                = readScoreboardModel.glowEnabled;
						targetObject.jammerHome                 = readScoreboardModel.jammerHome;
						targetObject.jammerImageBorderColor     = readScoreboardModel.jammerImageBorderColor;
						targetObject.jammerImageLeadBorderColor = readScoreboardModel.jammerImageLeadBorderColor;
						
						// this is here to update the default font size to 25
						if (readScoreboardModel.jammerNameFontSize != 25){
							targetObject.jammerNameFontSize     = 25;
						} else {
							targetObject.jammerNameFontSize     = readScoreboardModel.jammerNameFontSize;
						}

						targetObject.jammerVisitor              = readScoreboardModel.jammerVisitor;
						targetObject.LED_BackColor              = readScoreboardModel.LED_BackColor;
						targetObject.LED_ForeColor              = readScoreboardModel.LED_ForeColor;
						targetObject.LED_GlowAlpha              = readScoreboardModel.LED_GlowAlpha;		
						targetObject.LED_GlowColor              = readScoreboardModel.LED_GlowColor;
						targetObject.LeadJammer_Color           = readScoreboardModel.LeadJammer_Color;
						targetObject.LeadJammer_Alpha           = readScoreboardModel.LeadJammer_Alpha;			
						targetObject.leadJammerIndicatorImage   = readScoreboardModel.leadJammerIndicatorImage;
						targetObject.overlayImage               = readScoreboardModel.overlayImage;
						targetObject.overlayImageAlpha          = readScoreboardModel.overlayImageAlpha;
						targetObject.overlayImageVisible        = readScoreboardModel.overlayImageVisible;
						targetObject.scoreboardScale            = readScoreboardModel.scoreboardScale;
						targetObject.scoreboardX                = readScoreboardModel.scoreboardX;
						targetObject.scoreboardY                = readScoreboardModel.scoreboardY;
						targetObject.timeoutFontColor           = readScoreboardModel.timeoutFontColor;
						targetObject.timeoutFontAlpha           = readScoreboardModel.timeoutFontAlpha;
						targetObject.useDefaultJammerImage      = readScoreboardModel.useDefaultJammerImage;						
						break;
				}
				
			} catch (e:Error){
				ApplicationModel.errorMsg("The provided JamTracker Scoreboard Settings file is corrupt or invalid.", "Invalid File Type");
			}
			
		}
		
	}
}