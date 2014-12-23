package com.rollerderbyproductions.jamtracker.util
{
	import com.rollerderbyproductions.jamtracker.model.ApplicationModel;
	
	import flash.errors.IOError;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.registerClassAlias;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	// http://www.switchonthecode.com/tutorials/adobe-air-and-flex-saving-serialized-objects-to-file
	public class FileSystem
	{
		
		private static const _LOG:ILogger = Log.getLogger("FileSystem");
		
		/**
		 * Attempts to create the output directory (if needed)
		 * 
		 * @param dir Fully qualified path to the output directory
		 */
		public static function createOutputDir(dir:File):Boolean {
			// Determine if the state dir exists, if not then try and create it
			if (! dir.exists){
				try {
					dir.createDirectory();
					_LOG.info("Created directory: " + dir.nativePath);
				} catch (error:IOError){
					ApplicationModel.fatalErrorMsg("Could not create directory: " + dir.nativePath);
					return false;
				} catch (e:Error){
					ApplicationModel.fatalErrorMsg(e.message, e.name);
					return false;
				}
			} else _LOG.debug("Directory Exists: " + dir.nativePath);
			return true;
		}
		
		/**
		 * This conforms a fileName to a supported file extension
		 * 
		 * @param fileName - The name of the file to conform
		 * @param requiredFileExt - the extension that the filename should contain.
		 */
		public static function conformFileExtension(fileName:String, requiredFileExt:String):String
		{
			_LOG.debug("Conforming filextsion ["+requiredFileExt+"] on file ["+fileName+"]");
			var fileExtension:String = fileName.split(".")[1];
			
			if (fileExtension == requiredFileExt){
				return fileName
				
			} else {
				return fileName.split(".")[0] + requiredFileExt;
			}
		}
		
		
	}
}