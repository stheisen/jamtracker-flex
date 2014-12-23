package com.rollerderbyproductions.jamtracker.persistance
{
	import com.rollerderbyproductions.jamtracker.domain.PersitedObject;
	import com.rollerderbyproductions.jamtracker.model.ApplicationModel;
	import com.rollerderbyproductions.jamtracker.util.FileSystem;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class Repository
	{
		
		private static const _LOG:ILogger = Log.getLogger("Repository");

		/**
		 * Build the common persistance object
		 * 
		 * @param appVersionNumber - The curretn application version number
		 * @param objectVersionNumber - The version of the object to persist
		 * @param objectType - The type of object to be saved (i.e. PersitedObject.OBJECT_TEAM)
		 * @param objectToPersist - The object itself to persist
		 * 
		 * @return The PersistedObject
		 */
		public static function createPersistedInstance(appVersionNumber:String, objectVersionNumber:String, objectType:String, objectToPersist:Object):PersitedObject {
			
			var persistedObject:PersitedObject = new PersitedObject();
			var stream:ByteArray = new ByteArray();
			
			stream.writeObject(objectToPersist);
			stream.position = 0;
			
			persistedObject.objectType         = objectType;
			persistedObject.objectVersion      = objectVersionNumber;
			persistedObject.applicationVersion = appVersionNumber;
			persistedObject.createDate         = new Date();
			persistedObject.binaryData         = stream;	
			
			return persistedObject;
			
		}
		
		
		/**
		 * Reads a persisted object from the fileSystem
		 * 
		 * @param fileName - The name of the file to read
		 * @param readDir - The directory in which the file to be read exist
		 * 
		 * @return the persisted object from the filesystem
		 */
		public static function loadPersistedObjectFromFileSystem(fileName:String, readDir:File):PersitedObject {
			
			var readPersistedObject:PersitedObject = null;
			var fileStream:FileStream = new FileStream();
			var readFile:File = readDir.resolvePath(fileName);
			
			try {
				if (readFile.exists){
					_LOG.debug("Attempt to load object from: " + readFile.nativePath);
					fileStream.open(readFile, FileMode.READ);
					fileStream.position = 0;
					readPersistedObject = fileStream.readObject();
					fileStream.close();
					_LOG.debug("Loaded ["+readPersistedObject.objectType+"] Object version ["+readPersistedObject.objectVersion+"] was created by JamTracker version: [" + readPersistedObject.applicationVersion + "] on ["+readPersistedObject.createDate+"]");
				} else {
					_LOG.debug("Object File Not Found ["+readFile.nativePath+"]");
				}
				
			} catch (e:Error){
				_LOG.debug("Object Load Error: "+e.message);
			}
			
			return readPersistedObject;
			
		}

		
		
		/**
		 * Write a persisted object to the file system
		 * 
		 * @param persistedObject - The persisted object to write
		 * @param targetFile - The file object to write the persisted object to
		 */
		public static function writeObjectToFileSystem (persistedObject:PersitedObject, targetFile:File):void {
			
			var fileStream:FileStream = new FileStream();
			
			if (FileSystem.createOutputDir(targetFile.parent)){
				try {
					// Write out the object
					_LOG.debug("Attempt to write ["+persistedObject.objectType+"] object to: " + targetFile.nativePath);
					fileStream.open(targetFile, FileMode.WRITE);
					fileStream.writeObject(persistedObject);
					fileStream.close();
				} catch (e:Error){
					_LOG.debug("Object Persistance Error: "+e.message);
					ApplicationModel.fatalErrorMsg("Error Saving Team: "+e.message, "Persistance Error");
				}
			}
			
		}
					
	}
}