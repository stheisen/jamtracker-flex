package com.rollerderbyproductions.jamtracker.persistance
{
	import com.rollerderbyproductions.jamtracker.domain.PersitedObject;
	import com.rollerderbyproductions.jamtracker.events.RosterEvent;
	import com.rollerderbyproductions.jamtracker.model.ApplicationModel;
	import com.rollerderbyproductions.jamtracker.model.SettingsModel;
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

	public class SettingsModelRepository extends Repository
	{
		public static const FILE_FILTER:FileFilter = new FileFilter("JamTracker Settings (*.jto)", "*.jto");
		
		private static const _LOG:ILogger = Log.getLogger("SettingsModelRepository");

		
		/**
		 * Builds the persisted object for the provided SettingsModel
		 *
		 * @param applicationVersionNumber - The version number of the jamTracker application
		 * @param scoreboardModelObj - the SettingsModel object to persist
		 */
		public static function buildPersistedObject(applicationVersionNumber:String, SettingsModelObj:SettingsModel):PersitedObject {
			
			// Register the classes to be serialized
			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject", PersitedObject);
			registerClassAlias("com.rollerderbyproductions.jamtracker.model.SettingsModel", SettingsModel);
			
			return createPersistedInstance(applicationVersionNumber, SettingsModel.OBJECT_VERSION, PersitedObject.OBJECT_SETTINGSMODEL, SettingsModelObj);
				
		}
		
		
		/**
		 * Writes the supplied SettingsModel object to the filesystem
		 * 
		 * @param applicationVersionNumber - The version number of the jamTracker application
		 * @param settingsModelObj - the SettingsModel object to persist
		 * @param targetFile - the file to write the SettingsModel object to
		 */
		public static function writePersistedObject(applicationVersionNumber:String, SettingsModelObj:SettingsModel, targetFile:File):void {			
			// Create and write the object to the filesystem
			writeObjectToFileSystem(buildPersistedObject(applicationVersionNumber, SettingsModelObj), targetFile);
		}
		

		/**
		 * This method loads the persisted object from the file system
		 * 
		 * @fileName - The name of the file to load
		 * @readDir - The directory that contains the file to load
		 * @targetObject - The object that contains the SettingsModel to be loaded. For some reason if
		 *                 this method returns a SettingsModel object, and assignes it to the object
		 *                 currently bound to the view, it does not get refreshed. This fixes this problem
		 */
		public static function loadPersistedObject(fileName:String, readDir:File, targetObject:SettingsModel):void {
			
			var readPersistedObject:PersitedObject = null;
			var fileStream:FileStream = new FileStream();
			var readFile:File = readDir.resolvePath(fileName);
			
			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject", PersitedObject);
			registerClassAlias("com.rollerderbyproductions.jamtracker.model.SettingsModel", SettingsModel);
			getClassByAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject");
			getClassByAlias("com.rollerderbyproductions.jamtracker.model.SettingsModel");
		    
			// Load the persisted SettingsModel object from the filesystem
			readPersistedObject = loadPersistedObjectFromFileSystem(fileName, readDir);
			
			// If the read object is not null. then load the SettingsModel
			if (readPersistedObject == null){
				ApplicationModel.errorMsg("JamTracker was unable to properly load the selected settings.", "Settings Loading Error");
			} else {
				loadSettingsModelObject(readPersistedObject, targetObject);
			}
			
		}
		
		
		/**
		 * This method takes a persistedObject and attempts to load it into a SettingsModel object
		 * 
		 * @persistedObject - The persisted object to load into a SettingsModel object
		 * @targetObject - The object that contains the SettingsModel to be loaded. For some reason if
		 *                 this method returns a SettingsModel object, and assignes it to the object
		 *                 currently bound to the view, it does not get refreshed. This fixes this problem
		 */
		public static function loadSettingsModelObject(persistedObject:PersitedObject, targetObject:SettingsModel):void {

			registerClassAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject", PersitedObject);
			registerClassAlias("com.rollerderbyproductions.jamtracker.model.SettingsModel", SettingsModel);
			getClassByAlias("com.rollerderbyproductions.jamtracker.domain.PersitedObject");
			getClassByAlias("com.rollerderbyproductions.jamtracker.model.SettingsModel");

			var stream:ByteArray = persistedObject.binaryData;
			var readSettingsModel:SettingsModel = stream.readObject();
			
			try {
				// Validate the the object type is accurate
				if (persistedObject.objectType != PersitedObject.OBJECT_SETTINGSMODEL) throw new Error("Invalid file type ["+persistedObject.objectType+"]");
				_LOG.debug("Loading settings model version ["+persistedObject.objectVersion+"]");
				// Load the object based on the version that was loaded
				switch (persistedObject.objectVersion){
					case "6.0":
						// NO BREAK? - May want to let it run through the older loaders...
					case "5.0":
						targetObject.disableRightClickPrimaryAction			= readSettingsModel.disableRightClickPrimaryAction;
						targetObject.displayOfficialTimeoutDuration			= readSettingsModel.displayOfficialTimeoutDuration;
						targetObject.activeDebugLog							= readSettingsModel.activeDebugLog;
					case "4.0":
						targetObject.customViewsAutoSwitch 				    = readSettingsModel.customViewsAutoSwitch;
					case "3.0":
						// NO BREAK? - May want to let it run through the older loaders...
						targetObject.breakClockAutostartOnJamExpire			= readSettingsModel.breakClockAutostartOnJamExpire;
						targetObject.curtainImage							= readSettingsModel.curtainImage;
						targetObject.jamClockAutostartOnBreakExpire			= readSettingsModel.jamClockAutostartOnBreakExpire;
						targetObject.resetJamCountAtNewPeriod				= readSettingsModel.resetJamCountAtNewPeriod;
					case "2.0":
						// NO BREAK? - May want to let it run through the older loaders...
						targetObject.resetTeamTimeoutCount              	= readSettingsModel.resetTeamTimeoutCount;
						targetObject.resetTimeoutsEachPeriod            	= readSettingsModel.resetTimeoutsEachPeriod;
						targetObject.synchBreakClockwithGameClock			= readSettingsModel.synchBreakClockwithGameClock;
					case "1.0":
					default:
						targetObject.breakClockAutostartOnJamStop       	= readSettingsModel.breakClockAutostartOnJamStop;
						targetObject.breakClockAutostartOnTimeoutExpire 	= readSettingsModel.breakClockAutostartOnTimeoutExpire;
						targetObject.checkForUpdates                    	= readSettingsModel.checkForUpdates;
						targetObject.disableKeyboardShortcuts           	= readSettingsModel.disableKeyboardShortcuts;
						targetObject.finalPeriodNumber                  	= readSettingsModel.finalPeriodNumber;
						targetObject.hideLeadJammerIndicatorAtStop      	= readSettingsModel.hideLeadJammerIndicatorAtStop;
						targetObject.resetSelectedJammersAtStop         	= readSettingsModel.resetSelectedJammersAtStop;
						break;
				}
			} catch (e:Error){
				ApplicationModel.errorMsg("The provided JamTracker Settings file is corrupt or invalid.", "Invalid File Type");
			}
			
		}
		
	}
}