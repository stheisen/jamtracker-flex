package com.rollerderbyproductions.jamtracker.persistance
{
	import com.rollerderbyproductions.jamtracker.domain.PersitedObject;
	import com.rollerderbyproductions.jamtracker.domain.Player;
	import com.rollerderbyproductions.jamtracker.domain.Team;
	import com.rollerderbyproductions.jamtracker.events.RosterEvent;
	import com.rollerderbyproductions.jamtracker.model.ApplicationModel;
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

	public class TeamRepository extends Repository
	{
		public static const FILE_FILTER:FileFilter = new FileFilter("JamTracker Teams (*.jtt)", "*.jtt");
		private static const _LOG:ILogger = Log.getLogger("TeamRepository");

		
		
		/**
		 * Builds the persisted object for the provided scoreboardModelObj
		 *
		 * @param applicationVersionNumber - The version number of the jamTracker application
		 * @param teamObj - the Team object to persist
		 */
		public static function buildPersistedObject(applicationVersionNumber:String, teamObj:Team):PersitedObject {
			
			// Register the classes to be serialized
			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject", PersitedObject);
			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.Team", Team);
			
			return createPersistedInstance(applicationVersionNumber, Team.OBJECT_VERSION, PersitedObject.OBJECT_TEAM, teamObj);
				
		}

		
		/**
		 * Writes the supplied team object to the filesystem
		 * 
		 * @param applicationVersionNumber - The version number of the jamTracker application
		 * @param teamObj - the object file to persist
		 * @param targetFile - the file to write the team object to
		 */
		public static function writePersistedObject(applicationVersionNumber:String, teamObj:Team, targetFile:File):void {
			// Create and write the object to the filesystem
			writeObjectToFileSystem(buildPersistedObject(applicationVersionNumber, teamObj), targetFile);
		}
		

		/**
		 * This method loads the persisted object from the file system
		 * 
		 * @fileName - The name of the file to load
		 * @readDir - The directory that contains the file to load
		 * @targetObject - The object that contains the teamObject to be loaded. For some reason if
		 *                 this method returns a team object, and assignes it to the object
		 *                 currently bound to the view, it does not get refreshed. This fixes this problem
		 */
		public static function loadPersistedObject(fileName:String, readDir:File, targetObject:Team):void {
			
			var readPersistedObject:PersitedObject = null;
			var fileStream:FileStream = new FileStream();
			var readFile:File = readDir.resolvePath(fileName);
			
			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject", PersitedObject);
			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.Team", Team);
			getClassByAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject");
			getClassByAlias("com.rollerderbyproductions.jamtracker.domain.Team");
		    
			// Load the persisted team object from the filesystem
			readPersistedObject = loadPersistedObjectFromFileSystem(fileName, readDir);
			
			// If the read object is not null. then load the teamObject
			if (readPersistedObject == null){
				ApplicationModel.errorMsg("JamTracker was unable to properly load the selected team.", "Team Loading Error");
			} else {
				loadTeamObject(readPersistedObject, targetObject);
			}
			
		}
		
		
		/**
		 * This method takes a persistedObject and attempts to load it into a Team object
		 * 
		 * @persistedObject - The persisted object to load into a team object
		 * @targetObject - The object that contains the teamObject to be loaded. For some reason if
		 *                 this method returns a team object, and assignes it to the object
		 *                 currently bound to the view, it does not get refreshed. This fixes this problem
		 */
		public static function loadTeamObject(persistedObject:PersitedObject, targetObject:Team):void {

			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject", PersitedObject);
			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.Team", Team);
			getClassByAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject");
			getClassByAlias("com.rollerderbyproductions.jamtracker.domain.Team");

			var stream:ByteArray = persistedObject.binaryData;
			var readTeam:Team = stream.readObject();
			
			try {
				// Validate the the object type is accurate
				if (persistedObject.objectType != PersitedObject.OBJECT_TEAM) throw new Error("Invalid file type ["+persistedObject.objectType+"]");
				_LOG.debug("Loading Team Object version ["+persistedObject.objectVersion+"]");
				// Load the object based on the version that was loaded
				switch (persistedObject.objectVersion){
					case "2.0":
						// NO BREAK? - May want to let it run through the older loaders...
					case "1.0":
					default:
						targetObject.shortName                 = readTeam.shortName;
						targetObject.logoImage                 = readTeam.logoImage;
						targetObject.displayImageSizeWarning   = readTeam.displayImageSizeWarning;
						targetObject.scoreBoardNameFontColor   = readTeam.scoreBoardNameFontColor;
						targetObject.controllerBackgroundColor = readTeam.controllerBackgroundColor;
						targetObject.controllerBackgroundAlpha = readTeam.controllerBackgroundAlpha;
						targetObject.teamRoster                = readTeam.teamRoster;
						targetObject.activeTeamRoster          = readTeam.activeTeamRoster;					
						break;
				}
			} catch (e:Error){
				_LOG.error(e.message);
				ApplicationModel.errorMsg("The provided JamTracker Team file is corrupt or invalid.", "Invalid File Type");
			}
			
		}
		
	}
}