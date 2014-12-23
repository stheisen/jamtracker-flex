package com.rollerderbyproductions.jamtracker.util
{
	import com.rollerderbyproductions.jamtracker.domain.AppImage;
	import com.rollerderbyproductions.jamtracker.model.ApplicationModel;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.sampler.NewObjectSample;
	import flash.utils.ByteArray;
	
	import mx.controls.Image;
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.HeaderEvent;

	public class ImageUtility
	{
		public static const SUPPORTED_IMAGE_FILTER:FileFilter = new FileFilter("Images (*.jpg, *.jpeg, *.png)", "*.jpg; *.jpeg; *.png");
		
		public static const QUALITY_POOR:String = "QUALITY_POOR";
		public static const QUALITY_GOOD:String = "QUALITY_GOOD";
		public static const QUALITY_EXCELLENT:String = "QUALITY_EXCELLENT";
		
		private static const _LOG:ILogger = Log.getLogger("ImageUtility");
		
		/**
		 * Determines and stores the image height and width, and retuns the updated AppImage object
		 */
		public static function populateImageDimensions(imageBitmap:Bitmap, imageObject:AppImage):AppImage {

			// Convert the image that fired this event into a Bitmap so its properties can be analysed
			_LOG.debug("populateImageDimensions");
			imageObject.imageHeight = imageBitmap.height;
			imageObject.imageWidth = imageBitmap.width;			
			_LOG.debug("populateImageDimensions height ["+imageBitmap.height+"] width ["+imageBitmap.width+"]");

			return(imageObject);
		}
		/*
		
		public static function determineImageQualitySingleDimension(imageDimension:int, goodMinDimension:int, excellentMinDimension:int):String {

			var qualityString:String = null;

			_LOG.debug("determineImageQualitySingleDimension imageDimension ["+imageDimension+"] goodMinDimension ["+goodMinDimension+"] excellentMinDimension ["+excellentMinDimension+"]");
			// Judge the image quality based on the height of the images against the set thresholds
			if (imageDimension < goodMinDimension){ 
				qualityString = QUALITY_POOR;
			}
			else if ((imageDimension >= goodMinDimension) && (imageDimension < excellentMinDimension)){ 
				qualityString = QUALITY_GOOD;
			} else {
				qualityString = QUALITY_EXCELLENT;
			}
			_LOG.debug("determineImageQualitySingleDimension image determined to be of ["+qualityString+"]");
			return qualityString;
		}
		*/
		
		/**
		 * This method is used to convery bytes to kilobytes
		 * 
		 * @param size - The size to convert in bytes. 
		 */
		public static function bytesToKB(size:Number):Number {
			return int(size * .0009765625);
		}
		
		
		public static function writeByteArrayToFilesystem(imageData:ByteArray, targetFile:File):void {
			
			var fileStream:FileStream = new FileStream();
			
			if (FileSystem.createOutputDir(targetFile.parent)){
				try {
					// Write out the object
					_LOG.debug("Attempt to write Image to: " + targetFile.nativePath);
					fileStream.open(targetFile, FileMode.WRITE);
					fileStream.writeBytes(imageData);
					fileStream.close();
				} catch (e:Error){
					_LOG.debug("Image Persistance Error: "+e.message);
					ApplicationModel.fatalErrorMsg("Error Saving Image: "+e.message, "Export Error");
				}
			}
			
		}

		
	}
}