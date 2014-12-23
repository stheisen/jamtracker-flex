package com.rollerderbyproductions.jamtracker.persistance
{
	import com.rollerderbyproductions.jamtracker.domain.PersitedObject;
	import com.rollerderbyproductions.jamtracker.events.RosterEvent;
	import com.rollerderbyproductions.jamtracker.model.ApplicationModel;
	import com.rollerderbyproductions.jamtracker.model.ClosingStateModel;
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

	public class ClosingStateModelRepository extends Repository
	{
		private static const _LOG:ILogger = Log.getLogger("ClosingStateModelRepository");

		/**
		 * Builds the persisted object for the provided ClosingStateModel
		 *
		 * @param applicationVersionNumber - The version number of the jamTracker application
		 * @param closingStateModelObj - the ClosingStateModel object to persist
		 */
		public static function buildPersistedObject(applicationVersionNumber:String, closingStateModelObj:ClosingStateModel):PersitedObject {
			
			// Register the classes to be serialized
			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject", PersitedObject);
			registerClassAlias("com.rollerderbyproductions.jamtracker.model.ClosingStateModel", ClosingStateModel);
			
			return createPersistedInstance(applicationVersionNumber, ClosingStateModel.OBJECT_VERSION, PersitedObject.OBJECT_CLOSINGSTATE, closingStateModelObj);
				
		}

		
		/**
		 * Writes the supplied ClosingStateModel object to the filesystem
		 * 
		 * @param applicationVersionNumber - The version number of the jamTracker application
		 * @param closingStateModelObj - the ClosingStateModel object file to persist
		 * @param targetFile - the file to write the ClosingStateModel object to
		 */
		public static function writePersistedObject(applicationVersionNumber:String, closingStateModelObj:ClosingStateModel, targetFile:File):void {
			// Create and write the object to the filesystem
			writeObjectToFileSystem(buildPersistedObject(applicationVersionNumber, closingStateModelObj), targetFile);
		}
		

		/**
		 * This method loads the persisted object from the file system
		 * 
		 * @fileName - The name of the file to load
		 * @readDir - The directory that contains the file to load
		 * @targetObject - The object that contains the ClosingStateModel to be loaded. For some reason if
		 *                 this method returns a ClosingStateModel object, and assignes it to the object
		 *                 currently bound to the view, it does not get refreshed. This fixes this problem
		 * 
		 * @return - A string containing the application version which stored this state
		 */
		public static function loadPersistedObject(fileName:String, readDir:File, targetObject:ClosingStateModel):String {
			
			var readPersistedObject:PersitedObject = null;
			var fileStream:FileStream = new FileStream();
			var readFile:File = readDir.resolvePath(fileName);
			var lastAppVersion:String;
			
			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject", PersitedObject);
			registerClassAlias("com.rollerderbyproductions.jamtracker.model.ClosingStateModel", ClosingStateModel);
			getClassByAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject");
			getClassByAlias("com.rollerderbyproductions.jamtracker.model.ClosingStateModel");
		    
			if (readFile.exists) {			
				// Load the persisted ClosingStateModel object from the filesystem
				readPersistedObject = loadPersistedObjectFromFileSystem(fileName, readDir);
				
				// If the read object is not null. then load the ClosingStateModel
				if (readPersistedObject == null){
					ApplicationModel.errorMsg("JamTracker was unable to properly load previous application state. It will try and recover from this problem the next time it is opened.", "Application Error");
				} else {
					lastAppVersion= loadClosingStateModel(readPersistedObject, targetObject);
				}
			} else {
				_LOG.debug("No previous closing state file located ["+readFile.nativePath+"]");
			}
			return lastAppVersion;
		}
		
		
		/**
		 * This method takes a persistedObject and attempts to load it into a ClosingStateModel
		 * 
		 * @persistedObject - The persisted object to load into a ClosingStateModel object
		 * @targetObject - The object that contains the ClosingStateModel to be loaded. For some reason if
		 *                 this method returns a ClosingStateModel object, and assignes it to the object
		 *                 currently bound to the view, it does not get refreshed. This fixes this problem
		 * 
		 * @return - A string containing the application version which stored this state
		 */
		public static function loadClosingStateModel(persistedObject:PersitedObject, targetObject:ClosingStateModel):String {
			
			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject", PersitedObject);
			registerClassAlias("com.rollerderbyproductions.jamtracker.model.ClosingStateModel", ClosingStateModel);
			getClassByAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject");
			getClassByAlias("com.rollerderbyproductions.jamtracker.model.ClosingStateModel");

			var stream:ByteArray = persistedObject.binaryData;
			var readClosingStateModel:ClosingStateModel = stream.readObject();
			
			try {
				// Validate the the object type is accurate
				if (persistedObject.objectType != PersitedObject.OBJECT_CLOSINGSTATE) throw new Error("Invalid file type ["+persistedObject.objectType+"]");
				_LOG.debug("Loading ClosingStateModel version ["+persistedObject.objectVersion+"]");
				// Load the object based on the version that was loaded
				switch (persistedObject.objectVersion){
					case "4.0":
						// NO BREAK? - May want to let it run through the older loaders...
					case "3.0":
						targetObject.customViewsPersistedObject    = readClosingStateModel.customViewsPersistedObject;
					case "2.0":
						targetObject.scoringModelPersistedObject   = readClosingStateModel.scoringModelPersistedObject;
					case "1.0":
					default:
						targetObject.scoreboardModelPersitedObject = readClosingStateModel.scoreboardModelPersitedObject;
						targetObject.settingsModelPersitedObject   = readClosingStateModel.settingsModelPersitedObject;
						targetObject.homeTeamPersitedObject        = readClosingStateModel.homeTeamPersitedObject;
						targetObject.visitorTeamPersitedObject     = readClosingStateModel.visitorTeamPersitedObject;
						break;
				}
			} catch (e:Error){
				_LOG.error(e.message);
				ApplicationModel.errorMsg("JamTracker was unable to propery load previous application state. It will try and recover from this problem the next time it is opened.", "Invalid File Type");

			}
			return persistedObject.applicationVersion;
			
		}
		
	}
}