package com.rollerderbyproductions.jamtracker.presentation.popup
{
	import com.rollerderbyproductions.jamtracker.domain.AppImage;
	import com.rollerderbyproductions.jamtracker.domain.PersitedObject;
	import com.rollerderbyproductions.jamtracker.domain.Player;
	import com.rollerderbyproductions.jamtracker.domain.Team;
	import com.rollerderbyproductions.jamtracker.events.PlayerEvent;
	import com.rollerderbyproductions.jamtracker.events.RosterEvent;
	import com.rollerderbyproductions.jamtracker.model.ApplicationModel;
	import com.rollerderbyproductions.jamtracker.model.AssetModel;
	import com.rollerderbyproductions.jamtracker.persistance.Repository;
	import com.rollerderbyproductions.jamtracker.persistance.TeamRepository;
	import com.rollerderbyproductions.jamtracker.presentation.AbstractPresentationModel;
	import com.rollerderbyproductions.jamtracker.presentation.input.SettingsConfigPresentationModel;
	import com.rollerderbyproductions.jamtracker.util.FileSystem;
	import com.rollerderbyproductions.jamtracker.util.ImageUtility;
	import com.rollerderbyproductions.jamtracker.views.popup.RosterEdit;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.events.CloseEvent;
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;
	import mx.utils.object_proxy;
	
	import spark.components.TitleWindow;
	
	public class RosterEditPresentationModel extends AbstractPresentationModel
	{
		
		public const MODE_EDIT:String = "MODE_EDIT";
		public const MODE_NEW:String  = "MODE_NEW";
		public const IMAGE_GOOD_MIN_HEIGHT:int = 300;
		public const IMAGE_EXCELLENT_MIN_HEIGHT:int = 500;
		
				
		[Bindable][Inject] public var controller:SettingsConfigPresentationModel;		
		[Bindable][Inject] public var applicationModel:ApplicationModel;
		
		[Bindable] public var associatedTeam:Team;		
		[Bindable] public var currentViewState:String;
		[Bindable] public var errorMessage:String;
		[Bindable] public var playerSelected:Player;
		[Bindable] public var playerSelectedHasImage:Boolean = false;
		[Bindable] public var playerEditing:Player;
		[Bindable] public var displayImageSizeWarning:Boolean = false;
		[Bindable] public var viewEnabled:Boolean = true;
		
		private var _view:TitleWindow = null;
		private var _fileReference:File = new File();
		private var _teamFileReference:File = new File();
		private var _image:AppImage = new AppImage();
		private var _associatedTeamSide:String = null;

		private static const _LOG:ILogger = Log.getLogger("RosterEditPresentationModel");

		// ----------------------------------------------------------------------------------------
		// Public Methods
		// ----------------------------------------------------------------------------------------
		/**
		 * Initialize the view
		 */
		public function init():void {
			// Reset the form and suspend all shortcuts 
			resetView();
			controller.suspendKeyboardShortcuts();
		}

		
		/**
		 * This creates the Edit Roster PopUp screen, and loads it onto the stage
		 * 
		 * @param RosterEvent 
		 * 
		 */
		[EventHandler("RosterEvent.EDIT_ROSTER")]
		public function showSettingsView(event:RosterEvent):void 
		{			
			_associatedTeamSide = event.teamSide;
			// The associated team to buld this roster for comes from the event. Make a copy
			// of the team to be edited.  Changes will ONLY be committed when the window is closed 
			associatedTeam = ObjectUtil.copy(event.team) as Team;
			// Create the popup for editing the roster, and center it.			
			_view = TitleWindow(PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, RosterEdit, true));
			PopUpManager.centerPopUp(_view);
			// Setting isPopUp to false prevents it from being moved.
			_view.isPopUp = false;
		}
		
		/**
		 * This method sets the move of the the view.
		 * 
		 * @param viewStateName - The name of the viewstate to display
		 */
		public function setViewMode(viewStateName:String):void {
			switch (viewStateName){
				case MODE_EDIT:
					currentViewState = MODE_EDIT;
					break;
				case MODE_NEW:
				default:
					currentViewState = MODE_NEW;
					break;
			}
		}
		
		public function dispatchUpdateLeadJammerInformation(): void{
			swizDispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.JAMMERS_RESET_VIEW));
		}
		
		/**
		 * Validates the required elements of a new player are present, and if
		 * this is an addition to the roster can check for a duplicate
		 * 
		 * @param [checkForDuplicates] - True:  [default] Checks for a duplicate entry
		 *                               False: Ignore duplications (usually for update)
		 * 
		 * @return True is the entry is valid, false if there is an error detected
		 */ 
		public function validateEditedPlayer(checkForDuplicates:Boolean = true):Boolean {
			// A jersy number is required
			if (playerEditing.number.length == 0) {
				errorMessage = "Please provide a Jersey Number";
				return false;
			}
			// If we are checking for duplicates, and there is one, then provide an error message			
			if (checkForDuplicates && duplicateRosterPlayer()){
				errorMessage = "A player with this Jersey Number and Derby Name already exists.";
				return false;
			}
			// getting here means that there were no validation errors detected
			errorMessage = null;
			return true;
		}

		
		// ----------------------------------------------------------------------------------------
		// Public Click Handler Methods
		// ----------------------------------------------------------------------------------------
		/**
		 * When the user clicks cancel
		 */
		public function cancelUserEditButton_clickHandler():void {
			// Reset the form
			resetView();
		}

		/**
		 * This clickhandler closes the window without saving any of the changes made
		 */		
		public function cancelWindow_clickHandler(addDialog:IFlexDisplayObject):void {
			Alert.show("Are you sure you want abandon any changes made to this team?", "Confirm Cancel", Alert.OK | Alert.CANCEL, null, confirmCancelWindowHandler, AssetModel.ICON_QUESTION32_CLASS, Alert.CANCEL, null);
		}
		
		/** 
		 * This is the close handler that cleans up the view and and closes the popup
		 * This dispatches an event to save the changes that were made in the popup
		 */
		public function closeWindow_clickHandler(addDialog:IFlexDisplayObject):void
		{
			// Update the active roster with the changes made
			updateActiveRoster();
			// dispatch and event to save the roster changes
			swizDispatcher.dispatchEvent(new RosterEvent(RosterEvent.SAVE_ROSTER_CHANGES, associatedTeam, _associatedTeamSide));
			closeWindow();

		}

		
		/**
		 * This method asks for confirmation before deleting a player
		 */
		public function deleteButton_clickHandler():void {
			Alert.show("Are you sure you want to delete player #"+playerEditing.number+" \""+playerEditing.derbyName+"\"?", "Confirm Delete", Alert.OK | Alert.CANCEL, null, confirmDeletePlayerHandler, AssetModel.ICON_QUESTION32_CLASS, Alert.CANCEL, null);
		}

		
		/**
		 * This will delete the image for the player being modified
		 */
		public function deleteImage_clickHandler():void {
			// Set the image to null to delete it
			playerEditing.playerImage = null;
			setImageFlag();
		}
		

		/**
		 * This will start the process of exporting the image for the selected player
		 */
		public function exportImage_clickHandler():void {			// open the file browser to the default location for team storage
			_fileReference = new File(applicationModel.exportsDir.nativePath+File.separator+playerEditing.playerImage.fileName);
			_fileReference.browseForSave("Save "+playerEditing.playerImage.fileName+"  image for "+playerEditing.derbyName+" as..");
			// Once the user as selected a file, call the onTeamFileSelected			
			_fileReference.addEventListener(Event.SELECT,onSaveImageFileSelected, false, 0, true);			
		}

		
		
		/**
		 * Launches the file browser allowing the user to select an image to upload
		 */
		public function imageUpload_ClickHandler():void
		{
			_LOG.debug("Image upload request for: " + playerEditing.derbyName);
			//Instantiate on loading
			_image = new AppImage();
			_fileReference = new File();
			_fileReference.browse([ImageUtility.SUPPORTED_IMAGE_FILTER]);
			_fileReference.addEventListener(Event.SELECT, onFileSelected, false, 0, true);
			_fileReference.addEventListener(Event.COMPLETE, onFileLoadComplete, false, 0 , true);  				
		}
		
		/**
		 * Launches the process for loading a team
		 */
		public function loadTeam_clickHandler():void {
			// open the file browser to the default location for team storage
			_teamFileReference = new File(applicationModel.teamsDir.nativePath);
			_teamFileReference.browse([TeamRepository.FILE_FILTER]);
			// Once the user as selected a file, call the onTeamFileSelected			
			_teamFileReference.addEventListener(Event.SELECT,onLoadTeamFileSelected, false, 0, true);
		}
		
		public function newTeam_clickHandler():void {
			associatedTeam = new Team();
			associatedTeam.shortName = _associatedTeamSide;
			// reset any selected lead jammer
			swizDispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.JAMMER_DESELECT, _associatedTeamSide));
		}
		
		/**
		 * Launches the process for saving a team 
		 */	
		public function saveTeam_clickHandler():void {
			// open the file browser to the default location for team storage
			_teamFileReference = new File(applicationModel.teamsDir.nativePath);
			_teamFileReference.browseForSave("Save "+associatedTeam.shortName+" team configuration as..");
			// Once the user as selected a file, call the onTeamFileSelected			
			_teamFileReference.addEventListener(Event.SELECT,onSaveTeamFileSelected, false, 0, true);			
		}
		
		
		/**
		 * Saves a newly added player to the edited roster
		 */
		public function saveAddButton_clickHandler():void {
			// If the player data entered is valid, then add them to the roster
			if (!validateEditedPlayer())
				Alert.show(errorMessage, "Validation Error", Alert.OK , null, null, AssetModel.ICON_ALERT32_CLASS, Alert.CANCEL, null);
			else {
				associatedTeam.teamRoster.addItem(playerEditing);
				// and reset the form
				resetView();
			}
		}
		
		
		/**
		 * Saves an updated player to the edited roster
		 */
		public function saveUpdate_clickHandler():void {
			// If the player data entered is valid, then replace them in the roster
			if (!validateEditedPlayer(false)) Alert.show(errorMessage) else {
				// Delete the player from the list
				deleteRosterPlayer();
				// Add the newly updated player to the list
				associatedTeam.teamRoster.addItem(playerEditing);
				// Reset the form
				resetView();
			}
		}

		public function setImageFlag():void {
			if (playerEditing.playerImage != null) playerSelectedHasImage=true else playerSelectedHasImage=false;
		}
				

		// ----------------------------------------------------------------------------------------
		// Private Methods
		// ----------------------------------------------------------------------------------------
		
		private function closeWindow():void {
			// Reset the view for the next time this is opened
			resetView();
			// Remove the popup, and resume keyboard shortcuts
			PopUpManager.removePopUp(_view);
			controller.resumeKeyboardShortcuts();
		}
		
		
		/**
		 * This method is called when the user answers the "Confirm Cancel Chanes" dialogue for canceling
		 * the open window.
		 * 
		 * @param event - mx.events.CloseEvent
		 */
		private function confirmCancelWindowHandler(event:CloseEvent):void{
			if(event.detail==Alert.OK) {
				_LOG.debug("Cancel Changes Confirm OK'd");
				closeWindow();
			} else {
				_LOG.debug("Cancel Changes Confirm Canceled");
			}
		}

		
		/**
		 * This method is called when the user answers the "Confirm Delete Player" dialogue for deleting
		 * the selected player. It analyses the CloseEvent to determin which action the user chose, 
		 * and acts accordingly
		 * 
		 * @param event - mx.events.CloseEvent
		 */
		private function confirmDeletePlayerHandler(event:CloseEvent):void{
			if(event.detail==Alert.OK) {
				_LOG.debug("Delete Player Confirm OK'd");
				if (! deleteRosterPlayer())
					Alert.show("This player could not be deleted", "Fatal Error", Alert.OK , null, null, AssetModel.ICON_ALERT32_CLASS, Alert.CANCEL, null);
				else 
					resetView();
			} else {
				_LOG.debug("Delete Player Confirm Canceled");
			}
		}
		
		
		/**
		 * This deleted the selected player from the roster
		 * 
		 * @return True on a successfull delete, otherwise false
		 */
		private function deleteRosterPlayer():Boolean {
			
			var index:int = 0;
			// Loop through the modified roster and look for the match to the selected player
			for each(var item:Player in associatedTeam.teamRoster) {    
				// If this is the seleted player, then remove it from the list
				if ((item.number == playerSelected.number) && (item.derbyName == playerSelected.derbyName)){
					associatedTeam.teamRoster.removeItemAt(index);
					return true;
				}
				index++;
			}
			return false;
		}
		
		/**
		 * Checks for a duplicate player on the roster.
		 * 
		 * @return True if a duplicate is found, otherwise false
		 */
		private function duplicateRosterPlayer():Boolean {
			// Loop through the modified roster and look for the match to the edited player
			for each(var item:Player in associatedTeam.teamRoster) {    
				// If a match is found, then return true
				if ((item.number == playerEditing.number) && (item.derbyName == playerEditing.derbyName)) return true;
			}
			return false;
		}
		
				
		/**
		 * Resets the form in the view
		 */
		private function resetView():void {
			// Clear the edited payer
			playerEditing = new Player();
			playerEditing.active = true;
			playerSelectedHasImage = false;
			// reset any error message, and switch the view to ADD NEW
			errorMessage = null;
			displayImageSizeWarning = false;
			setViewMode(MODE_NEW);
		}

		
		/**
		 * This method replaces the contents of the active roster, with the newly edited roster.
		 */
		private function updateActiveRoster():void {
			
			var index:int = 0;
			// Clear the active roster
			associatedTeam.activeTeamRoster = new ArrayCollection();
			// Copy each ACTIVE player in the newly updated team roster, to the active roster.
			for each(var item:Player in associatedTeam.teamRoster)
			{    
				if (item.active) associatedTeam.activeTeamRoster.addItem(item);
				index++;
			}
		}
		
		// ----------------------------------------------------------------------------------------
		// Team Persistance methods
		// ----------------------------------------------------------------------------------------		
		/** 
		 * After the team file to be loaded is selected, this method is used to actually kick off
		 * the loading process. 
		 */
		private function onLoadTeamFileSelected(event:Event):void
		{
			
			// Remove the event listener that fired this method
			_teamFileReference.removeEventListener(Event.SELECT, onLoadTeamFileSelected);
			
			// load the selected object using the teamRepository
			TeamRepository.loadPersistedObject(_teamFileReference.name, _teamFileReference.parent, associatedTeam);
			// reset any selected lead jammer
			swizDispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.JAMMER_DESELECT, _associatedTeamSide));
			// Update the active roster with the changes made
			updateActiveRoster();
			// Reset the view for the next time this is opened
			resetView();			
		}
		
		/**
		 * An event listener fires this method once the save file has been identified
		 */
		private function onSaveTeamFileSelected(event:Event):void {

			// Remove the event listener that fired this method
			_teamFileReference.removeEventListener(Event.SELECT,onSaveTeamFileSelected);

			//Split the returned File native path to retrieve file name
			var tmpArr:Array = File(event.target).nativePath.split(File.separator);
			//remove last array item and return its content
			var fileName:String = tmpArr.pop();
			
			//Check if the extension given by user is valid, if not the default on is put.
			//(for example if user put himself/herself an invalid file extension it is removed in favour of the default one)
			var conformedFileDef:String = FileSystem.conformFileExtension(fileName, ApplicationModel.FILEEXT_TEAM_STORAGE);
			tmpArr.push(conformedFileDef);
			
			//Create a new file object giving as input our new path with conformed file extension
			var conformedFile:File = new File("file:///" + tmpArr.join(File.separator));
			
			// Write the file
			TeamRepository.writePersistedObject(applicationModel.versionNumber, associatedTeam, conformedFile);			
		}
		
		// ----------------------------------------------------------------------------------------
		// Imaging methods
		// ----------------------------------------------------------------------------------------		
		/**
		 * This method enables a warning flag if the provided image data exceeds the 
		 * recommended size.
		 */
		public function determineImageWarning(imageData:ByteArray):void {
			var imageSizeKB:Number = ImageUtility.bytesToKB(imageData.bytesAvailable);
			// If the image exceeds the maximum bytes, then display ethe image size warning message
			if (imageSizeKB > ApplicationModel.PLAYER_IMAGE_MAX_KBSIZE) {
				displayImageSizeWarning = true;	
			} else displayImageSizeWarning=false;
		}
		
		/**
		 * This function is called by an event listener when the load completes
		 */
		public function onFileLoadComplete(event:Event):void{
			
			var loader:Loader = new Loader();
			_image.data = _fileReference.data;
			_image.fileName = _fileReference.name;
			
			// Determine if this image has earned a warning for being too large
			determineImageWarning(_image.data);
			// Add a listener event to fire after the image file is loaded
			// This addEventLister contains a function call so that data may be passed along
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,
				function(event:Event): void {
					var imageBitmap:Bitmap = event.currentTarget.loader.content as Bitmap;
					onFileStoreComplete(imageBitmap); 
				}, false, 0, true);				
			loader.loadBytes(_image.data);			
			
			// Remove the event listener that fired this event
			_fileReference.removeEventListener(Event.COMPLETE, onFileLoadComplete);
		}
		
		/**
		 * This function is called then the loader finished storing the image in the oject
		 */
		public function onFileStoreComplete(imageBitmap:Bitmap):void{
			_LOG.debug("Image Uploaded file stored for: " + playerEditing.derbyName);
			_image = ImageUtility.populateImageDimensions(imageBitmap, _image);
			_LOG.debug("Storing image for: " + playerEditing.derbyName);
			// Load the image object for the player being edited
			playerEditing.playerImage = _image;
			setImageFlag();			
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

		
		/**
		 * An event listener fires this method once the save file has been identified
		 */
		private function onSaveImageFileSelected(event:Event):void {
			
			var loader:Loader = new Loader();
			var targetFilePath:String = File(event.target).nativePath;
			// Remove the event listener that fired this method
			_fileReference.removeEventListener(Event.SELECT,onSaveImageFileSelected);
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,
				function(event:Event): void {
					var imageBitmap:Bitmap = event.currentTarget.loader.content as Bitmap;
					bitmapLoaded(imageBitmap, targetFilePath); 
				}, false, 0, true);
			
			// load the image into the loader.
			_LOG.debug("loading image for export: "+playerSelected.playerImage.fileName);
			loader.loadBytes(playerSelected.playerImage.data);
		}
		
		
		/**
		 * An event listener fires this method once the save file has been identified
		 */
		private function bitmapLoaded(imageBitmap:Bitmap, targetFilePath:String):void {
			
			var imageFileExt:String = playerSelected.playerImage.fileName.split(".").pop();
			var imageDataToWrite:ByteArray;

			try {
				switch (imageFileExt.toLowerCase()){
					case "jpg":
					case "jpeg":
						_LOG.debug("Encoding JPG for export");
						var jpgenc:JPEGEncoder = new JPEGEncoder(80);
						imageDataToWrite =  jpgenc.encode(imageBitmap.bitmapData);
						break;
					case "png":
						_LOG.debug("Encoding PNG image for export");
						var pngenc:PNGEncoder = new PNGEncoder();
						imageDataToWrite = pngenc.encode(imageBitmap.bitmapData);
						break;
					default:
						throw new Error("Export of unsupported file extension: "+ imageFileExt.toLowerCase());
				}		
				
				//Split the returned File native path to retrieve file name
				var tmpArr:Array = targetFilePath.split(File.separator);
				//remove last array item and return its content
				var fileName:String = tmpArr.pop();
				
				//Check if the extension given by user is valid, if not the default on is put.
				//(for example if user put himself/herself an invalid file extension it is removed in favour of the default one)
				var conformedFileDef:String = FileSystem.conformFileExtension(fileName, "."+imageFileExt);
				tmpArr.push(conformedFileDef);
				
				//Create a new file object giving as input our new path with conformed file extension
				var conformedFile:File = new File("file:///" + tmpArr.join(File.separator));
				
				ImageUtility.writeByteArrayToFilesystem(imageDataToWrite, conformedFile);
				
			}  catch (e:Error){
				_LOG.error(e.message);
				ApplicationModel.errorMsg("JamTracker is unable to export this image based on its file format. Sorry, JamTracker is only capable of exporting JPG and PNG images.", "Invalid File Type");
			}

		}
		
	}
}