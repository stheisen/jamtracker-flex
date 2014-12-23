package com.rollerderbyproductions.jamtracker.persistance
{
	import com.rollerderbyproductions.jamtracker.domain.PersitedObject;
	import com.rollerderbyproductions.jamtracker.events.RosterEvent;
	import com.rollerderbyproductions.jamtracker.model.ApplicationModel;
	import com.rollerderbyproductions.jamtracker.model.ScoringModel;
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

	public class ScoringModelRepository extends Repository
	{
		
		private static const _LOG:ILogger = Log.getLogger("ScoringModelRepository");

		
		/**
		 * Builds the persisted object for the provided ScoringModel
		 *
		 * @param applicationVersionNumber - The version number of the jamTracker application
		 * @param scoringModelObj - the ScoringModel object to persist
		 */
		public static function buildPersistedObject(applicationVersionNumber:String, ScoringModelObj:ScoringModel):PersitedObject {
			
			// Register the classes to be serialized
			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject", PersitedObject);
			registerClassAlias("com.rollerderbyproductions.jamtracker.model.ScoringModel", ScoringModel);
			
			return createPersistedInstance(applicationVersionNumber, ScoringModel.OBJECT_VERSION, PersitedObject.OBJECT_SCORINGMODEL, ScoringModelObj);
				
		}
				

		/**
		 * This method loads the persisted object from the file system
		 * 
		 * @fileName - The name of the file to load
		 * @readDir - The directory that contains the file to load
		 * @targetObject - The object that contains the ScoringModel to be loaded. For some reason if
		 *                 this method returns a ScoringModel object, and assignes it to the object
		 *                 currently bound to the view, it does not get refreshed. This fixes this problem
		 */
		public static function loadPersistedObject(fileName:String, readDir:File, targetObject:ScoringModel):void {
			
			var readPersistedObject:PersitedObject = null;
			var fileStream:FileStream = new FileStream();
			var readFile:File = readDir.resolvePath(fileName);
			
			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject", PersitedObject);
			registerClassAlias("com.rollerderbyproductions.jamtracker.model.ScoringModel", ScoringModel);
			getClassByAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject");
			getClassByAlias("com.rollerderbyproductions.jamtracker.model.ScoringModel");
		    
			// Load the persisted SettingsModel object from the filesystem
			readPersistedObject = loadPersistedObjectFromFileSystem(fileName, readDir);
			
			// If the read object is not null. then load the SettingsModel
			if (readPersistedObject == null){
				ApplicationModel.errorMsg("JamTracker was unable to properly load the selected settings.", "Settings Loading Error");
			} else {
				loadScoringModelObject(readPersistedObject, targetObject);
			}
			
		}
		
		
		/**
		 * This method takes a persistedObject and attempts to load it into a SettingsModel object
		 * 
		 * @persistedObject - The persisted object to load into a ScoringModel object
		 * @targetObject - The object that contains the ScoringModel to be loaded. For some reason if
		 *                 this method returns a ScoringModel object, and assignes it to the object
		 *                 currently bound to the view, it does not get refreshed. This fixes this problem
		 */
		public static function loadScoringModelObject(persistedObject:PersitedObject, targetObject:ScoringModel):void {

			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject", PersitedObject);
			registerClassAlias("com.rollerderbyproductions.jamtracker.model.ScoringModel", ScoringModel);
			getClassByAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject");
			getClassByAlias("com.rollerderbyproductions.jamtracker.model.ScoringModel");

			var stream:ByteArray = persistedObject.binaryData;
			var readScoringModel:ScoringModel = stream.readObject();
			
			try {
				// Validate the the object type is accurate
				if (persistedObject.objectType != PersitedObject.OBJECT_SCORINGMODEL) throw new Error("Invalid file type ["+persistedObject.objectType+"]");
				_LOG.debug("Loading ScoringModel version ["+persistedObject.objectVersion+"]");
				// Load the object based on the version that was loaded
				switch (persistedObject.objectVersion){
					case "3.0":
						// NO BREAK? - May want to let it run through the older loaders...
					case "2.0":
						targetObject.officialTimeoutClock	= readScoringModel.officialTimeoutClock;
						// NO BREAK? - May want to let it run through the older loaders...
					case "1.0":
					default:
						// The only think we load from the scoreboard model is the clock settings. The current score etc
						// is not reloaded when the application is closed/reopened.
						targetObject.gameClock				= readScoringModel.gameClock;
						targetObject.jamClock 				= readScoringModel.jamClock;
						targetObject.breakClock				= readScoringModel.breakClock;
						targetObject.timeoutClock			= readScoringModel.timeoutClock;
						targetObject.intermissionClock 		= readScoringModel.intermissionClock;
						break;
				}
			} catch (e:Error){
				ApplicationModel.errorMsg("The provided JamTracker Settings file is corrupt or invalid.", "Invalid File Type");
			}
			
		}
		
	}
}