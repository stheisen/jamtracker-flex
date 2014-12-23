package com.rollerderbyproductions.jamtracker.presentation.input
{
	import com.rollerderbyproductions.jamtracker.domain.Team;
	import com.rollerderbyproductions.jamtracker.events.PlayerEvent;
	import com.rollerderbyproductions.jamtracker.events.ScoreboardEvent;
	import com.rollerderbyproductions.jamtracker.model.ApplicationModel;
	import com.rollerderbyproductions.jamtracker.model.ScoreboardModel;
	import com.rollerderbyproductions.jamtracker.model.ScoringModel;
	import com.rollerderbyproductions.jamtracker.model.SettingsModel;
	import com.rollerderbyproductions.jamtracker.presentation.AbstractPresentationModel;
	import com.rollerderbyproductions.jamtracker.presentation.MainPresentationModel;
	import com.rollerderbyproductions.jamtracker.util.FileSystem;
	import com.rollerderbyproductions.jamtracker.util.ImageUtility;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.PerspectiveProjection;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.profiler.showRedrawRegions;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.controls.HSlider;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.core.ByteArrayAsset;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class ScoreboardConfigPresentationModel extends AbstractPresentationModel
	{

		public const IMAGE_BACKGROUND:String = "IMAGE_BACKGROUND";
		public const IMAGE_OVERLAY:String = "IMAGE_OVERLAY";
		public const IMAGE_LEAD_JAMMER_INDICATOR:String = "IMAGE_LEAD_JAMMER_INDICATOR";
		public const IMAGE_HOME_DEFAULT_JAMMER_IMG:String = "IMAGE_HOME_DEFAULT_JAMMER_IMG";
		public const IMAGE_VISITOR_DEFAULT_JAMMER_IMG:String = "IMAGE_VISITOR_DEFAULT_JAMMER_IMG";
		
		[Bindable][Inject] public var settingsModel:SettingsModel;
		[Bindable][Inject] public var scoring:ScoringModel;
		[Bindable][Inject] public var scoreboard:ScoreboardModel;
		
		[Bindable] public var headerImageUploadText:String = "UPDATE IMAGE";
		[Bindable] public var headerImageQualityIndicator:ByteArray;		
		[Bindable] public var headerImageHeight:int;		
		[Bindable] public var backgroundImageUploadText:String = "UPDATE IMAGE";
		[Bindable] public var backgroundImageQualityIndicator:ByteArray;		
		[Bindable] public var backgroundImageHeight:int;		
		[Bindable] public var displayLeadIndicatorImageSizeWarning:Boolean = false;
		[Bindable] public var displayHomeDefaultImageSizeWarning:Boolean = false;
		[Bindable] public var displayVisitorDefaultImageSizeWarning:Boolean = false;
		[Bindable] public var displayBackgroundImageSizeWarning:Boolean = false;
		[Bindable] public var displayOverlayImageSizeWarning:Boolean = false;

		[Bindable] public var defaultJammerImageUploadText:String = "UPDATE IMAGE";		
		[Bindable] public var leadJammerIndicatorImageUploadText:String = "UPDATE IMAGE";

		
		private var _fileReference:FileReference = new FileReference();
		private var _imageTypes:FileFilter = new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg; *.jpeg; *.gif; *.png");
		private var _allFileTypes:FileFilter = new FileFilter("All Files (*.*)", "*.*")
		private var _configFileTypes:FileFilter = new FileFilter("DerbySkore Files (*.dby)", "*.dby")
		private var _localFile:File = new File();
		
		private static const _LOG:ILogger = Log.getLogger("ScoreboardConfigPresentationModel");

		
		// General Functions ----------------------------------------------------------------------
		/**
		 * The init function is called by the view, at creation complete
		 */
		public function init():void {
			// Determine the image warning levels for the images associated with this view
			if (scoreboard.backgroundImage != null) determineImageWarning(IMAGE_BACKGROUND, scoreboard.backgroundImage.data);
			if (scoreboard.overlayImage != null) determineImageWarning(IMAGE_OVERLAY, scoreboard.overlayImage.data);
			if (scoreboard.homeDefaultJammerImage != null) determineImageWarning(IMAGE_VISITOR_DEFAULT_JAMMER_IMG, scoreboard.homeDefaultJammerImage.data);
			if (scoreboard.visitorDefaultJammerImage != null) determineImageWarning(IMAGE_VISITOR_DEFAULT_JAMMER_IMG, scoreboard.visitorDefaultJammerImage.data);
			if (scoreboard.leadJammerIndicatorImage != null) determineImageWarning(IMAGE_LEAD_JAMMER_INDICATOR, scoreboard.leadJammerIndicatorImage.data);

		}
		
		/**
		 * This function will use the image height to determine its quality
		 */
		private function determineImageQualityIndicator(imageHeight:int, goodMinHeight:int, excellentMinHeight:int):ByteArray
		{
			var determinedQualityIndicator:ByteArray;
			// Judge the image quality based on the height of the images against the set thresholds
			if (imageHeight < goodMinHeight){ 
				//determinedQualityIndicator = new _IconFlagRed() as ByteArrayAsset;
			}
			else if ((imageHeight >= goodMinHeight) && (imageHeight < excellentMinHeight)){ 
				//determinedQualityIndicator = new _IconFlagYellow() as ByteArrayAsset; 
			}
			
			return determinedQualityIndicator;
		} // determineImageQuality
		
		[PreDestroy]
		public function preDestroy():void {
			_LOG.debug("PREDESTROY");
		}
		
		// Click Handlers -------------------------------------------------------------------------
		
		public function changeBackgroundColorIntensity(event:Event):void
		{
			var currentSlider:HSlider = HSlider(event.currentTarget);
			scoreboard.backgroundAlpha = currentSlider.value;
		}

		public function changeBackgroundImageTransparancy(event:Event):void
		{
			var currentSlider:HSlider = HSlider(event.currentTarget);
			scoreboard.backgroundImageAlpha = currentSlider.value;
		}
		
		public function changeContainerBorderColorIntensity(event:Event):void
		{
			var currentSlider:HSlider = HSlider(event.currentTarget);
			scoreboard.containerBorderAlpha = currentSlider.value;
		}

		public function changeFontColorIntensity(event:Event):void
		{
			var currentSlider:HSlider = HSlider(event.currentTarget);
			scoreboard.fontAlpha = currentSlider.value;
		}

		public function changeHeaderImageTransparancy(event:Event):void
		{
			var currentSlider:HSlider = HSlider(event.currentTarget);
			scoreboard.overlayImageAlpha = currentSlider.value;
		}

		public function changeJammerImageHeight(event:Event):void
		{
			var currentSlider:HSlider = HSlider(event.currentTarget);
			
			scoreboard.setJammerImageHeight = currentSlider.value;
			if (scoreboard.currentJammerImageHeight > 0){
			  scoreboard.currentJammerImageHeight = currentSlider.value;
			  scoreboard.currentTeamLogoHeight = ApplicationModel.HEIGHT_OF_IMAGE_AND_LOGO - scoreboard.currentJammerImageHeight;
			} 

			if (scoreboard.currentJammerImageHeight == 0){
				scoreboard.hideJammerImageArea = true;
			}
		}

		
		public function changeScoreboardHorizontal(event:Event):void
		{
			var currentSlider:HSlider = HSlider(event.currentTarget);
			scoreboard.scoreboardX = currentSlider.value;
		}

		public function changeScoreboardVertical(event:Event):void
		{
			var currentSlider:HSlider = HSlider(event.currentTarget);
			scoreboard.scoreboardY = currentSlider.value;
		}

		public function changeScoreboardScale(event:Event):void
		{
			var currentSlider:HSlider = HSlider(event.currentTarget);
			scoreboard.scoreboardScale = currentSlider.value;
		}

		public function changeTimeoutColorIntensity(event:Event):void
		{
			var currentSlider:HSlider = HSlider(event.currentTarget);
			scoreboard.timeoutFontAlpha = currentSlider.value;
		}
		
		public function changeClockTitleFontColorIntensity(event:Event):void
		{
			var currentSlider:HSlider = HSlider(event.currentTarget);
			scoreboard.clockTitleFontAlpha = currentSlider.value;
		}

		public function changeLeadJammerColorIntensity(event:Event):void
		{
			var currentSlider:HSlider = HSlider(event.currentTarget);
			scoreboard.LeadJammer_Alpha = currentSlider.value;
		}
		
		public function glowEffectClickHandler(event:Event):void{
			if (event.target.selected){
				swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.GLOW_EFFECT_ON));
			} else {
				swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.GLOW_EFFECT_OFF));
			}			
		}

		public function glowEffectColorChangeHandler(event:Event):void{
			swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.GLOW_EFFECT_ON));
		}

		
		public function toggleBackgroundImage(event:Event):void{
			if (event.target.selected){
				scoreboard.backgroundImageVisible = true;
			} else {
				scoreboard.backgroundImageVisible = false;				
			}
		}
		
		public function toggleHeaderImage(event:Event):void{
			if (event.target.selected){
				scoreboard.overlayImageVisible = true;
			} else {
				scoreboard.overlayImageVisible = false;				
			}
		}

		/**
		 * Launches the file browser allowing the user to select a background image to uplaod
		 */
		public function scoreboardImageUpload(imageType:String):void
		{
			//Instantiate on loading
			_fileReference = new FileReference();
			_fileReference.browse([_imageTypes]);
			_fileReference.addEventListener(Event.SELECT,onFileSelect, false, 0, true);
			if (imageType == IMAGE_BACKGROUND){
				_fileReference.addEventListener(Event.COMPLETE,onFileComplete_background, false, 0, true);
			} else if (imageType == IMAGE_HOME_DEFAULT_JAMMER_IMG) {
				_fileReference.addEventListener(Event.COMPLETE,onFileComplete_homeDefaultJammerImg, false, 0, true);				
			} else if (imageType == IMAGE_VISITOR_DEFAULT_JAMMER_IMG) {
				_fileReference.addEventListener(Event.COMPLETE,onFileComplete_visitorDefaultJammerImg, false, 0, true);				
			} else if (imageType == IMAGE_LEAD_JAMMER_INDICATOR) {
				_fileReference.addEventListener(Event.COMPLETE,onFileComplete_leadJammerIndicator, false, 0, true);				
			} else if (imageType == IMAGE_OVERLAY) {
				_fileReference.addEventListener(Event.COMPLETE,onFileComplete_overlay, false, 0, true);				
			}
		}


		public function toggleLEDGlow() : void{
			if (scoreboard.glowEnabled){  scoreboard.glowEnabled = false; } else { scoreboard.glowEnabled = true; }
			
		}
		
		// Event Handlers -------------------------------------------------------------------------
		

		public function updateLeadJammerIndicators(event:MouseEvent): void{
			swizDispatcher.dispatchEvent(new ScoreboardEvent(ScoreboardEvent.UPDATE_LEAD_JAMMER));
		}
		
		public function updateLeadJammerInformation(event:Event): void{
			swizDispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.JAMMERS_RESET_VIEW));
		}
		
		// ----------------------------------------------------------------------------------------
		// Imaging methods
		// ----------------------------------------------------------------------------------------	
		
		/**
		 * This event handler determines the quality of the provided home team logo
		 */
		public function determineBackgroundImageProperties (event:Event) : void {
			// Convert the image that fired this event into a Bitmat so its properties can be analysed
			var imageBitmap:Bitmap = event.currentTarget.loader.content as Bitmap;			
			scoreboard.backgroundImage = ImageUtility.populateImageDimensions(imageBitmap, scoreboard.backgroundImage);
		} 
		
		/**
		 * This event handler determines the quality of the provided home team logo
		 */
		public function determineHomeDefaultJammerImageProperties (event:Event) : void {
			// Convert the image that fired this event into a Bitmat so its properties can be analysed
			var imageBitmap:Bitmap = event.currentTarget.loader.content as Bitmap;			
			scoreboard.homeDefaultJammerImage = ImageUtility.populateImageDimensions(imageBitmap, scoreboard.homeDefaultJammerImage);
		} 
		

		/**
		 * This event handler determines the quality of the provided visitor team logo
		 */
		public function determineVisitorDefaultJammerImageProperties (event:Event) : void {
			// Convert the image that fired this event into a Bitmat so its properties can be analysed
			var imageBitmap:Bitmap = event.currentTarget.loader.content as Bitmap;			
			scoreboard.visitorDefaultJammerImage = ImageUtility.populateImageDimensions(imageBitmap, scoreboard.visitorDefaultJammerImage);
		} 

		
		/**
		 * This event handler determines the quality of the provided home team logo
		 */
		public function determineLeadJammerIndicatorImageProperties (event:Event) : void {
			// Convert the image that fired this event into a Bitmat so its properties can be analysed
			var imageBitmap:Bitmap = event.currentTarget.loader.content as Bitmap;		
			scoreboard.leadJammerIndicatorImage = ImageUtility.populateImageDimensions(imageBitmap, scoreboard.leadJammerIndicatorImage);
		} 

		
		/**
		 * This event handler determines the quality of the provided home team logo
		 */
		public function determineOverlayImageProperties (event:Event) : void {
			// Convert the image that fired this event into a Bitmat so its properties can be analysed
			var imageBitmap:Bitmap = event.currentTarget.loader.content as Bitmap;			
			scoreboard.overlayImage = ImageUtility.populateImageDimensions(imageBitmap, scoreboard.overlayImage);
		} 

		/**
		 * This method enables a warning flag if the provided image data exceeds the 
		 * recommended size.
		 */
		public function determineImageWarning(imageType:String, imageData:ByteArray):void {
			
			var imageSizeKB:Number = ImageUtility.bytesToKB(imageData.bytesAvailable);

			switch (imageType){
				case IMAGE_HOME_DEFAULT_JAMMER_IMG:
					if (imageSizeKB > ApplicationModel.DEFAULTJAMMERIMAGE_IMAGE_MAX_KBSIZE) 
							  displayHomeDefaultImageSizeWarning = true 
						else displayHomeDefaultImageSizeWarning = false;	
					break;
				case IMAGE_VISITOR_DEFAULT_JAMMER_IMG:
					if (imageSizeKB > ApplicationModel.DEFAULTJAMMERIMAGE_IMAGE_MAX_KBSIZE) 
						displayVisitorDefaultImageSizeWarning = true 
					else displayVisitorDefaultImageSizeWarning = false;	
					break;
				case IMAGE_LEAD_JAMMER_INDICATOR:
					if (imageSizeKB > ApplicationModel.LEADINDICATOR_IMAGE_MAX_KBSIZE) 
						displayLeadIndicatorImageSizeWarning = true 
					else displayLeadIndicatorImageSizeWarning = false;
					break;
				case IMAGE_BACKGROUND:
					if (imageSizeKB > ApplicationModel.BACKGROUND_IMAGE_MAX_KBSIZE) 
						displayBackgroundImageSizeWarning = true 
					else displayBackgroundImageSizeWarning = false;
					break;
				case IMAGE_OVERLAY:
					if (imageSizeKB > ApplicationModel.OVERLAY_IMAGE_MAX_KBSIZE) 
						displayOverlayImageSizeWarning = true 
					else displayOverlayImageSizeWarning = false;
					break;
			}

		}
		
		/**
		 * This event handler fires after the scoreboard background image file has been loaded
		 */
		private function onFileComplete_background(event:Event):void
		{ 				
			var loader:Loader = new Loader();
			scoreboard.backgroundImage.data = _fileReference.data;
			scoreboard.backgroundImage.fileName = _fileReference.name;
			// Determine if this image has earned a warning for being too large
			determineImageWarning(IMAGE_BACKGROUND, scoreboard.backgroundImage.data);
			
			// Add a listener event to fire after the image file is laoded
			_fileReference.removeEventListener(Event.COMPLETE,onFileComplete_background);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, determineBackgroundImageProperties, false, 0, true);
			loader.loadBytes(scoreboard.backgroundImage.data);
		} // onFileComplete_background
		
		/**
		 * This event handler fires after the scoreboard header image file has been loaded
		 */
		private function onFileComplete_overlay(event:Event):void
		{ 				
			var loader:Loader = new Loader();
			scoreboard.overlayImage.data = _fileReference.data;
			scoreboard.overlayImage.fileName = _fileReference.name;

			// Determine if this image has earned a warning for being too large
			determineImageWarning(IMAGE_OVERLAY, scoreboard.overlayImage.data);
			
			// Add a listener event to fire after the image file is laoded
			_fileReference.removeEventListener(Event.COMPLETE,onFileComplete_overlay);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, determineOverlayImageProperties, false, 0, true);
			loader.loadBytes(scoreboard.overlayImage.data);
		} // onFileComplete_header
		
		/**
		 * This event handler fires after the scoreboard header image file has been loaded
		 */
		private function onFileComplete_homeDefaultJammerImg(event:Event):void
		{ 				
			var loader:Loader = new Loader();
			scoreboard.homeDefaultJammerImage.data = _fileReference.data;
			scoreboard.homeDefaultJammerImage.fileName = _fileReference.name;
			
			// Determine if this image has earned a warning for being too large
			determineImageWarning(IMAGE_HOME_DEFAULT_JAMMER_IMG, scoreboard.homeDefaultJammerImage.data);
			
			// Add a listener event to fire after the image file is laoded
			_fileReference.removeEventListener(Event.COMPLETE,onFileComplete_background);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, determineHomeDefaultJammerImageProperties, false, 0, true);
			loader.loadBytes(scoreboard.homeDefaultJammerImage.data);
		} // onFileComplete_leadJammerIndicator
		
		
		/**
		 * This event handler fires after the scoreboard header image file has been loaded
		 */
		private function onFileComplete_visitorDefaultJammerImg(event:Event):void
		{ 				
			var loader:Loader = new Loader();
			scoreboard.visitorDefaultJammerImage.data = _fileReference.data;
			scoreboard.visitorDefaultJammerImage.fileName = _fileReference.name;
			
			// Determine if this image has earned a warning for being too large
			determineImageWarning(IMAGE_VISITOR_DEFAULT_JAMMER_IMG, scoreboard.visitorDefaultJammerImage.data);
			
			// Add a listener event to fire after the image file is laoded
			_fileReference.removeEventListener(Event.COMPLETE,onFileComplete_background);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, determineVisitorDefaultJammerImageProperties, false, 0, true);
			loader.loadBytes(scoreboard.visitorDefaultJammerImage.data);
		} // onFileComplete_leadJammerIndicator

		
		/**
		 * This event handler fires after the scoreboard header image file has been loaded
		 */
		private function onFileComplete_leadJammerIndicator(event:Event):void
		{ 				
			var loader:Loader = new Loader();
			scoreboard.leadJammerIndicatorImage.data = _fileReference.data;
			scoreboard.leadJammerIndicatorImage.fileName = _fileReference.name;
			
			// Determine if this image has earned a warning for being too large
			determineImageWarning(IMAGE_LEAD_JAMMER_INDICATOR, scoreboard.leadJammerIndicatorImage.data);
			
			// Add a listener event to fire after the image file is laoded
			_fileReference.removeEventListener(Event.COMPLETE,onFileComplete_leadJammerIndicator);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, determineLeadJammerIndicatorImageProperties, false, 0, true);
			loader.loadBytes(scoreboard.leadJammerIndicatorImage.data);
		} // onFileComplete_leadJammerIndicator

		
		/**
		 * This event handler loads the image into the fileReference
		 * After this, look for the onFileComplete handler will execute.
		 */
		private function onFileSelect(event:Event):void
		{
			_fileReference.load();
		} // onFileSelect
		


	}
}