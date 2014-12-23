package com.rollerderbyproductions.jamtracker.persistance
{
	import com.rollerderbyproductions.jamtracker.domain.PersitedObject;
	import com.rollerderbyproductions.jamtracker.events.RosterEvent;
	import com.rollerderbyproductions.jamtracker.model.ApplicationModel;
	import com.rollerderbyproductions.jamtracker.model.ViewsModel;
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

	public class ViewsModelRepository extends Repository
	{
		private static const _LOG:ILogger = Log.getLogger("ViewsModelRepository");

		/**
		 * Builds the persisted object for the provided ViewsModel Obj
		 *
		 * @param applicationVersionNumber - The version number of the jamTracker application
		 * @param viewsModelObj - the ViewsModel object to persist
		 */
		public static function buildPersistedObject(applicationVersionNumber:String, viewsModelObj:ViewsModel):PersitedObject {

			// Register the classes to be serialized
			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject", PersitedObject);
			registerClassAlias("com.rollerderbyproductions.jamtracker.model.ViewsModel", ViewsModel);

			return createPersistedInstance(applicationVersionNumber, ViewsModel.OBJECT_VERSION, PersitedObject.OBJECT_VIEWSMODEL, viewsModelObj);
			
		}
		
		
		/**
		 * Writes the supplied ViewsModel object to the filesystem
		 * 
		 * @param applicationVersionNumber - The version number of the jamTracker application
		 * @param viewsModelObj - the ViewsModel object to persist
		 * @param targetFile - the file to write the ViewsModel object to
		 */
		public static function writePersistedObject(applicationVersionNumber:String, viewsModelObj:ViewsModel, targetFile:File):void {
			// Create and write the object to the filesystem
			writeObjectToFileSystem(buildPersistedObject(applicationVersionNumber, viewsModelObj), targetFile);
		}
		

		/**
		 * This method loads the persisted object from the file system
		 * 
		 * @fileName - The name of the file to load
		 * @readDir - The directory that contains the file to load
		 * @targetObject - The object that contains the ViewsModel to be loaded. For some reason if
		 *                 this method returns a ViewsModel object, and assignes it to the object
		 *                 currently bound to the view, it does not get refreshed. This fixes this problem
		 */
		public static function loadPersistedObject(fileName:String, readDir:File, targetObject:ViewsModel):void {
			
			var readPersistedObject:PersitedObject = null;
			var fileStream:FileStream = new FileStream();
			var readFile:File = readDir.resolvePath(fileName);
			
			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject", PersitedObject);
			registerClassAlias("com.rollerderbyproductions.jamtracker.model.ViewsModel", ViewsModel);
			getClassByAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject");
			getClassByAlias("com.rollerderbyproductions.jamtracker.model.ViewsModel");
		    
			// Load the persisted ScoreboardModel object from the filesystem
			readPersistedObject = loadPersistedObjectFromFileSystem(fileName, readDir);
			
			// If the read object is not null. then load the ScoreboardModel
			if (readPersistedObject == null){
				ApplicationModel.errorMsg("JamTracker was unable to properly load the selected custom view settings.", "Custom View Loading Error");
			} else {
				loadViewsModelObject(readPersistedObject, targetObject);
			}
			
		}
		
		
		/**
		 * This method takes a persistedObject and attempts to load it into a ViewsModel object
		 * 
		 * @persistedObject - The persisted object to load into a ViewsModel object
		 * @targetObject - The object that contains the ViewsModel to be loaded. For some reason if
		 *                 this method returns a ViewsModel object, and assignes it to the object
		 *                 currently bound to the view, it does not get refreshed. This fixes this problem
		 */
		public static function loadViewsModelObject(persistedObject:PersitedObject, targetObject:ViewsModel):void {

			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject", PersitedObject);
			registerClassAlias("com.rollerderbyproductions.jamtracker.model.ViewsModel", ViewsModel);
			getClassByAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject");
			getClassByAlias("com.rollerderbyproductions.jamtracker.model.ViewsModel");

			var stream:ByteArray = persistedObject.binaryData;
			var readViewsModel:ViewsModel = stream.readObject();
			
			try {
				// Validate the the object type is accurate
				if (persistedObject.objectType != PersitedObject.OBJECT_VIEWSMODEL) throw new Error("Invalid file type ["+persistedObject.objectType+"]");
				_LOG.debug("Loading ViewsModel version ["+persistedObject.objectVersion+"]");
				// Load the object based on the version that was loaded
				switch (persistedObject.objectVersion){
					case "2.0":
						// NO BREAK? - May want to let it run through the older loaders...
					case "1.0":
					default:
						targetObject.curtain       = readViewsModel.curtain;
						targetObject.intermission  = readViewsModel.intermission;
						targetObject.preGame       = readViewsModel.preGame;
						targetObject.postGame      = readViewsModel.postGame;
						break;
				}
				
			} catch (e:Error){
				ApplicationModel.errorMsg("The provided JamTracker custom views settings file is corrupt or invalid.", "Invalid File Type");
			}
			
		}
		
	}
}