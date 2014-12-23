package com.rollerderbyproductions.jamtracker.presentation.input
{
	
	import com.rollerderbyproductions.jamtracker.domain.AppImage;
	import com.rollerderbyproductions.jamtracker.domain.ViewCollection;
	import com.rollerderbyproductions.jamtracker.domain.ViewElement;
	import com.rollerderbyproductions.jamtracker.events.CustomizedViewEvent;
	import com.rollerderbyproductions.jamtracker.model.ApplicationModel;
	import com.rollerderbyproductions.jamtracker.model.SettingsModel;
	import com.rollerderbyproductions.jamtracker.model.ViewsModel;
	import com.rollerderbyproductions.jamtracker.presentation.AbstractPresentationModel;
	import com.rollerderbyproductions.jamtracker.util.ImageUtility;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.HSlider;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import spark.events.IndexChangeEvent;
	
	public class CustomizedViewPresentationModel extends AbstractPresentationModel
	{
		
		[Bindable][Inject] public var settingsModel:SettingsModel;
		[Bindable][Inject] public var viewsModel:ViewsModel;
		
		[Bindable] public var backgroundImageUploadText:String = "UPDATE IMAGE";
		[Bindable] public var foregroundImageUploadText:String = "UPDATE IMAGE";
		[Bindable] public var displayImageCurtainSizeWarning:Boolean = false;		
		[Bindable] public var displayPregameForgroundImageSizeWarning:Boolean = false;		
		[Bindable] public var displayPregameBackgroundImageSizeWarning:Boolean = false;
		[Bindable] public var dropdownlistArrayCollection:ArrayCollection = new ArrayCollection();
		[Bindable] public var viewCollection:ViewCollection;
		[Bindable] public var selectedViewElement:ViewElement = new ViewElement();
		[Bindable] public var viewType:String = "";
		
		[Bindable] public var control_horizontalAvail:Boolean = true; 
		[Bindable] public var control_verticalAvail:Boolean = true; 
		[Bindable] public var control_scaleAvail:Boolean = true; 
		[Bindable] public var control_transparancyAvail:Boolean = true; 
		[Bindable] public var control_visibleAvail:Boolean = true; 
		[Bindable] public var control_colorAvail:Boolean = true; 
		
		public const IMAGE_CURTAIN:String = "IMAGE_CURTAIN";
		public const IMAGE_PREGAME_BACKGROUND:String = "IMAGE_PREGAME_BACKGROUND";
		public const IMAGE_PREGAME_FOREGROUND:String = "IMAGE_PREGAME_FOREGROUND";		
		
		public const ELEMENT_ID_HOMELOGO:String = "homeLogo";
		public const ELEMENT_ID_VISITORLOGO:String = "visitorLogo";
		public const ELEMENT_ID_BACKGROUNDCOLOR:String = "backgroundColor";
		public const ELEMENT_ID_BACKGROUNDIMAGE:String = "backgroundImage";
		public const ELEMENT_ID_FORGROUNDIMAGE:String = "forgroundImage";
		public const ELEMENT_ID_HOMESCORE:String = "homeScore";
		public const ELEMENT_ID_VISITORSCORE:String = "visitorScore";
		public const ELEMENT_ID_GAMECLOCK:String = "gameClock";
		public const ELEMENT_ID_LABEL1:String = "label1";
		public const ELEMENT_ID_LABEL2:String = "label2";
		public const ELEMENT_ID_LABEL3:String = "label3";
		public const ELEMENT_ID_LABEL4:String = "label4";

		private static const _LOG:ILogger = Log.getLogger("CustomizedViewPresentationModel");
		
		private var _image:AppImage = new AppImage();
		private var _fileReference:FileReference = new FileReference();
		private var _viewType:String;
		
		
		
		// Public Methods -------------------------------------------------------------------------
		/**
		 * This function is called after all the SWIZ injections are completed (as called by the view)
		 */
		public function setViewCollection(viewType:String):void {
			_viewType = viewType;
			setBeanInstanceViewCollection();
		}
				
		public function setBeanInstanceViewCollection():void {
			
			_LOG.debug("Set Instance viewCollection ["+_viewType+"]");
			
			switch (_viewType){
				case ViewsModel.PREGAME_VIEW:
					viewCollection = viewsModel.preGame;
					break;
				case ViewsModel.INTERMISSION_VIEW:
					viewCollection = viewsModel.intermission;
					break;
				case ViewsModel.POSTGAME_VIEW:
					viewCollection = viewsModel.postGame;
					break;
				case ViewsModel.CURTAIN_VIEW:
					viewCollection = viewsModel.curtain;
					break;
			}
		}
		
		
		public function buildDropdownListData():void {
			// just some data for the DropDownList
			dropdownlistArrayCollection.addItem({name: "Background Color",data: ELEMENT_ID_BACKGROUNDCOLOR});
			dropdownlistArrayCollection.addItem({name: "Background Image",data: ELEMENT_ID_BACKGROUNDIMAGE});
			dropdownlistArrayCollection.addItem({name: "Forground Image", data: ELEMENT_ID_FORGROUNDIMAGE});
			dropdownlistArrayCollection.addItem({name: "Game Clock", 		data: ELEMENT_ID_GAMECLOCK});
			dropdownlistArrayCollection.addItem({name: "Home Logo", 		data: ELEMENT_ID_HOMELOGO});
			dropdownlistArrayCollection.addItem({name: "Home Score", 		data: ELEMENT_ID_HOMESCORE});
			dropdownlistArrayCollection.addItem({name: "Visitor Logo", 	data: ELEMENT_ID_VISITORLOGO});
			dropdownlistArrayCollection.addItem({name: "Visitor Score", 	data: ELEMENT_ID_VISITORSCORE});
			dropdownlistArrayCollection.addItem({name: "Label 1", 			data: ELEMENT_ID_LABEL1});
			dropdownlistArrayCollection.addItem({name: "Label 2", 			data: ELEMENT_ID_LABEL2});
			dropdownlistArrayCollection.addItem({name: "Label 3", 			data: ELEMENT_ID_LABEL3});
			dropdownlistArrayCollection.addItem({name: "Label 4", 			data: ELEMENT_ID_LABEL4});
		}
		
		
		public function setSelectedDropDownItem(elementId:String):void{		
						
			control_horizontalAvail = true; 
			control_verticalAvail = true; 
			control_scaleAvail = true; 
			control_transparancyAvail = true; 			
			control_visibleAvail = true; 
			control_colorAvail = true;
			
			switch (elementId){
				case ELEMENT_ID_HOMELOGO:
					control_colorAvail = false;
					break;
				case ELEMENT_ID_VISITORLOGO:
					control_colorAvail = false;
					break;
				case ELEMENT_ID_HOMESCORE:
					control_colorAvail = false;
					break;
				case ELEMENT_ID_VISITORSCORE:
					control_colorAvail = false;
					break;
				case ELEMENT_ID_BACKGROUNDCOLOR:
					control_horizontalAvail = false; 
					control_verticalAvail = false; 
					control_scaleAvail = false; 
					control_visibleAvail = false;
					break;
				case ELEMENT_ID_BACKGROUNDIMAGE:
					control_horizontalAvail = false; 
					control_verticalAvail = false; 
					control_scaleAvail = false;
					control_colorAvail = false;
					break;
				case ELEMENT_ID_FORGROUNDIMAGE:
					control_colorAvail = false;
					break;
				case ELEMENT_ID_GAMECLOCK:
					break;
				case ELEMENT_ID_LABEL1:
					break;
				case ELEMENT_ID_LABEL2:
					break;
				case ELEMENT_ID_LABEL3:
					break;
				case ELEMENT_ID_LABEL4:
					break;
			}
			
			swizDispatcher.dispatchEvent(new CustomizedViewEvent(CustomizedViewEvent.SET_SELECTED_ELEMENT,elementId));
		}
		
		public function elementSelect_changeHandler(event:Event):void
		{
			// TODO Auto-generated method stub
			var elementData:String = event.target.selectedItem.data;
			
			switch (elementData){
				case ELEMENT_ID_HOMELOGO:
					selectedViewElement = viewCollection.homeLogo;
					break;
				case ELEMENT_ID_VISITORLOGO:
					selectedViewElement = viewCollection.visitorLogo;
					break;
				case ELEMENT_ID_HOMESCORE:
					selectedViewElement = viewCollection.homeScore;
					break;
				case ELEMENT_ID_VISITORSCORE:
					selectedViewElement = viewCollection.visitorScore;
					break;
				case ELEMENT_ID_BACKGROUNDCOLOR:
					selectedViewElement = viewCollection.backgroundColor;
					break;
				case ELEMENT_ID_BACKGROUNDIMAGE:
					selectedViewElement = viewCollection.backgroundImage;
					break;
				case ELEMENT_ID_FORGROUNDIMAGE:
					selectedViewElement = viewCollection.forgroundImage;
					break;
				case ELEMENT_ID_GAMECLOCK:
					selectedViewElement = viewCollection.gameClock;
					break;
				case ELEMENT_ID_LABEL1:
					selectedViewElement = viewCollection.label1;
					break;
				case ELEMENT_ID_LABEL2:
					selectedViewElement = viewCollection.label2;
					break;
				case ELEMENT_ID_LABEL3:
					selectedViewElement = viewCollection.label3;
					break;
				case ELEMENT_ID_LABEL4:
					selectedViewElement = viewCollection.label4;
					break;
			}
			setSelectedDropDownItem(elementData);
			
		}
		

		
		/**
		 * Launches the file browser allowing the user to select a background image to uplaod
		 */
		public function viewImageUpload(imageType:String):void
		{
			//Instantiate on loading
			_fileReference = new FileReference();
			_fileReference.browse([ImageUtility.SUPPORTED_IMAGE_FILTER]);
			_fileReference.addEventListener(Event.SELECT,onFileSelected, false, 0, true);
			if (imageType == IMAGE_PREGAME_FOREGROUND) {
				_LOG.debug("Pregame foreground image upload request");
				setSelectedDropDownItem(ELEMENT_ID_FORGROUNDIMAGE);
				_fileReference.addEventListener(Event.COMPLETE, onFileComplete_pregameForground, false, 0, true);				
			} else if (imageType == IMAGE_PREGAME_BACKGROUND) {
				_LOG.debug("Pregame backgroung image upload request");
				setSelectedDropDownItem(ELEMENT_ID_BACKGROUNDIMAGE);
				_fileReference.addEventListener(Event.COMPLETE, onFileComplete_pregameBackground, false, 0, true);				
			} 
		}
		
		
		public function changeElementAlpha(event:Event, element:ViewElement):void
		{
			var currentSlider:HSlider = HSlider(event.currentTarget);
			element.alpha = currentSlider.value;
		}
		
		
		public function changeScale(event:Event, element:ViewElement):void {
			var currentSlider:HSlider = HSlider(event.currentTarget);
			element.scale = currentSlider.value;			
		}

		
		public function changeHorizontalPosition(event:Event, element:ViewElement):void {
			var currentSlider:HSlider = HSlider(event.currentTarget);
			element.x = currentSlider.value;			
		}
		

		public function changeVerticalPosition(event:Event, element:ViewElement):void {
			var currentSlider:HSlider = HSlider(event.currentTarget);
			element.y = currentSlider.value;			
		}
		
		
		
		// ----------------------------------------------------------------------------------------
		// Imaging methods
		// ----------------------------------------------------------------------------------------		
		
		/**
		 * This event handler determines the quality of the provided home team logo
		 */
		public function buildCurtainImageProperties (event:Event) : void {
			// Convert the image that fired this event into a Bitmat so its properties can be analysed
			var imageBitmap:Bitmap = event.currentTarget.loader.content as Bitmap;		
			settingsModel.curtainImage = ImageUtility.populateImageDimensions(imageBitmap, settingsModel.curtainImage);
		} 
		
		/**
		 * This event handler determines the quality of the provided home team logo
		 */
		public function buildPregameBackgroundImageProperties (event:Event) : void {
			// Convert the image that fired this event into a Bitmat so its properties can be analysed
			var imageBitmap:Bitmap = event.currentTarget.loader.content as Bitmap;		
			viewCollection.backgroundImage.appImage = ImageUtility.populateImageDimensions(imageBitmap, viewCollection.backgroundImage.appImage);
		} 
		
		
		/**
		 * This event handler determines the quality of the provided home team logo
		 */
		public function buildPregameForgroundImageProperties (event:Event) : void {
			// Convert the image that fired this event into a Bitmat so its properties can be analysed
			var imageBitmap:Bitmap = event.currentTarget.loader.content as Bitmap;		
			viewCollection.forgroundImage.appImage = ImageUtility.populateImageDimensions(imageBitmap, viewCollection.forgroundImage.appImage);
		} 
		
		
		/**
		 * This method enables a warning flag if the provided image data exceeds the 
		 * recommended size.
		 */
		public function determineImageWarning(imageType:String, imageData:ByteArray):void {
			
			var imageSizeKB:Number = ImageUtility.bytesToKB(imageData.bytesAvailable);
			
			switch (imageType){
				case IMAGE_CURTAIN:
					if (imageSizeKB > ApplicationModel.CURTAIN_IMAGE_MAX_KBSIZE) 
						displayImageCurtainSizeWarning = true 
					else displayImageCurtainSizeWarning = false;	
					break;
				case IMAGE_PREGAME_BACKGROUND:
					if (imageSizeKB > ApplicationModel.PREGAME_IMAGE_MAX_KBSIZE) 
						displayPregameBackgroundImageSizeWarning = true 
					else displayPregameBackgroundImageSizeWarning = false;
					break;
				case IMAGE_PREGAME_FOREGROUND:
					if (imageSizeKB > ApplicationModel.PREGAME_IMAGE_MAX_KBSIZE) 
						displayPregameForgroundImageSizeWarning = true 
					else displayPregameForgroundImageSizeWarning = false;
					break;
			}
			
		}
		
		
		/** 
		 * Begin the load if the selected file 
		 */
		private function onFileSelected(event:Event):void
		{
			_fileReference.load();
			// Remove the event listener that fired this method
			_fileReference.removeEventListener(Event.SELECT, onFileSelected);
			
		}
		
		
		/*
		* This event handler fires after the scoreboard curtain image file has been loaded
		*/
		private function onFileComplete_curtain(event:Event):void
		{ 				
			var loader:Loader = new Loader();
			settingsModel.curtainImage.data = _fileReference.data;
			settingsModel.curtainImage.fileName = _fileReference.name;
			
			// Determine if this image has earned a warning for being too large
			determineImageWarning(IMAGE_CURTAIN, settingsModel.curtainImage.data);
			
			// Add a listener event to fire after the image file is laoded
			_fileReference.removeEventListener(Event.COMPLETE,onFileComplete_curtain);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, buildCurtainImageProperties, false, 0, true);
			loader.loadBytes(settingsModel.curtainImage.data);
		} // onFileComplete_curtain
		
		
		/*
		* This event handler fires after the scoreboard pregame background image file has been loaded
		*/
		private function onFileComplete_pregameBackground(event:Event):void
		{ 				
			var loader:Loader = new Loader();
			viewCollection.backgroundImage.appImage.data = _fileReference.data;
			viewCollection.backgroundImage.appImage.fileName = _fileReference.name;
			
			// Determine if this image has earned a warning for being too large
			determineImageWarning(IMAGE_PREGAME_FOREGROUND, viewCollection.backgroundImage.appImage.data);
			
			// Add a listener event to fire after the image file is laoded
			_fileReference.removeEventListener(Event.COMPLETE,onFileComplete_pregameBackground);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, buildPregameBackgroundImageProperties, false, 0, true);
			loader.loadBytes(viewCollection.backgroundImage.appImage.data);
		} // onFileComplete_pregameForground
		
		
		/*
		* This event handler fires after the scoreboard pregame forground image file has been loaded
		*/
		private function onFileComplete_pregameForground(event:Event):void
		{ 				
			var loader:Loader = new Loader();
			viewCollection.forgroundImage.appImage.data = _fileReference.data;
			viewCollection.forgroundImage.appImage.fileName = _fileReference.name;
			
			// Determine if this image has earned a warning for being too large
			determineImageWarning(IMAGE_PREGAME_FOREGROUND, viewCollection.forgroundImage.appImage.data);
			
			// Add a listener event to fire after the image file is laoded
			_fileReference.removeEventListener(Event.COMPLETE,onFileComplete_pregameForground);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, buildPregameForgroundImageProperties, false, 0, true);
			loader.loadBytes(viewCollection.forgroundImage.appImage.data);
		} // onFileComplete_pregameForground
		
		
	}
	
}