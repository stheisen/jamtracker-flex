package com.rollerderbyproductions.jamtracker.model
{
	import com.rollerderbyproductions.jamtracker.domain.AppImage;
	import com.rollerderbyproductions.jamtracker.domain.JammerDisplay;
	import com.rollerderbyproductions.jamtracker.domain.ViewCollection;
	
	import flash.utils.ByteArray;
	
	import mx.core.ByteArrayAsset;

	[RemoteClass]
	[Bindable]
	public class ViewsModel
	{
		// **************************************************************************************
		// NOTE :: In order to support persistance do NOT remove any of the properties on this
		//         object. In the case that any are added, be sure to add them to the persistance
		//         classes
		// **************************************************************************************

		// This is the version number of this object
		public static var OBJECT_VERSION:String = "1.0"; // Reflect this change in TeamRepository
		
		public static var MAIN_VIEW:String = "MAIN_VIEW";
		public static var CURTAIN_VIEW:String = "CURTAIN_VIEW";
		public static var PREGAME_VIEW:String = "PREGAME_VIEW";
		public static var POSTGAME_VIEW:String = "POSTGAME_VIEW";
		public static var INTERMISSION_VIEW:String = "INTERMISSION_VIEW";

		
		// NOTE: Any time any of these properties are updated you MUST change the OBJECT_VERSION number, and load the
		//       object accordingly in the TeamRepository 
		
		// Version 1.0 //////////////////////////////////////////////////////////////////////////////
		
		public var curtain:ViewCollection;
		public var preGame:ViewCollection;
		public var postGame:ViewCollection;
		public var intermission:ViewCollection;
		
		// Version 2.0 //////////////////////////////////////////////////////////////////////////////

		
		// Constructors ---------------------------------------------------------------------------
		/* NOTE: An empty constructor is required to export/import this object to/from filesystem */
		public function ViewsModel(){}

		
		/**
		 * Simply initializes the View Model, and set all the views to their default values
		 */
		public function init():void
		{
			initCurtainView();
			initPreGameView();
			initPostGameView();
			initIntermissionView();
		}	
		
		/**
		 * Initializes the viewModel for the curtain
		 */
		public function initCurtainView():void {
			
			curtain = new ViewCollection()
			curtain.backgroundImage.appImage = new AppImage();
			curtain.backgroundImage.appImage.data = new AssetModel.IMAGE_DEFAULTCURTAINIMAGE_CLASS() as ByteArrayAsset;
			curtain.forgroundImage.appImage = new AppImage();
			curtain.visitorLogo.visible = false;
			curtain.visitorScore.visible = false;
			curtain.homeScore.visible = false;
			curtain.homeLogo.visible = false;
			curtain.gameClock.visible = false;
			curtain.label1.color=0xFFFFFF;
			curtain.label2.color=0xFFFFFF;
			curtain.label3.color=0xFFFFFF;
			curtain.label4.color=0xFFFFFF;
		}
			
		/**
		 * Initializes the viewModel for the preGame view
		 */
		public function initPreGameView():void {
			
			preGame = new ViewCollection();
			preGame.backgroundImage.appImage = new AppImage();
			preGame.backgroundImage.appImage.data = new AssetModel.IMAGE_DEFAULTSCOREBOARDBACKGROUND_CLASS() as ByteArrayAsset;
			preGame.forgroundImage.appImage = new AppImage();
			preGame.homeLogo.x = 0;
			preGame.homeLogo.y = 87;
			preGame.visitorLogo.x = 494;
			preGame.visitorLogo.y = 109;
			preGame.gameClock.x = 258;
			preGame.gameClock.y = 532;
			preGame.gameClock.scale = 1.4;
			preGame.visitorScore.visible = false;
			preGame.homeScore.visible = false;
			preGame.label1.color=0xFFFFFF;
			preGame.label2.color=0xFFFFFF;
			preGame.label3.color=0xFFFFFF;
			preGame.label4.color=0xFFFFFF;
			
		}
			
			
		/**
		 * Initializes the viewModel for the postGame view
		 */
		public function initPostGameView():void {
			
			postGame = new ViewCollection();
			postGame.backgroundImage.appImage = new AppImage();
			postGame.backgroundImage.appImage.data = new AssetModel.IMAGE_DEFAULTSCOREBOARDBACKGROUND_CLASS() as ByteArrayAsset;
			postGame.forgroundImage.appImage = new AppImage();
			postGame.homeLogo.x = 0;
			postGame.homeLogo.y = 87;
			postGame.visitorLogo.x = 494;
			postGame.visitorLogo.y = 109;
			postGame.homeScore.visible = true;
			postGame.homeScore.x=150;
			postGame.homeScore.y=577;
			postGame.gameClock.visible = false;
			postGame.gameClock.x = 328;
			postGame.gameClock.y = 552;
			postGame.visitorScore.visible = true;
			postGame.visitorScore.x=655;
			postGame.visitorScore.y=577;
			postGame.label1.visible=true;
			postGame.label1.text="GAME OVER"
			postGame.label1.color=0xFFFFFF;
			postGame.label1.scale=2;
			postGame.label1.x = 330;
			postGame.label1.y = 20;			
			postGame.label2.color=0xFFFFFF;
			postGame.label3.color=0xFFFFFF;
			postGame.label4.color=0xFFFFFF;

		}
		
		/**
		 * Initializes the viewModel for the intermissionView view
		 */
		public function initIntermissionView():void {			

			
			intermission = new ViewCollection();
			intermission.backgroundImage.appImage = new AppImage();
			intermission.backgroundImage.appImage.data = new AssetModel.IMAGE_DEFAULTSCOREBOARDBACKGROUND_CLASS() as ByteArrayAsset;
			intermission.forgroundImage.appImage = new AppImage();
			intermission.homeLogo.x = 0;
			intermission.homeLogo.y = 87;
			intermission.visitorLogo.x = 494;
			intermission.visitorLogo.y = 109;
			intermission.homeScore.visible = true;
			intermission.homeScore.x=50;
			intermission.homeScore.y=577;
			intermission.gameClock.x = 328;
			intermission.gameClock.y = 552;
			intermission.visitorScore.visible = true;
			intermission.visitorScore.x=750;
			intermission.visitorScore.y=577;
			intermission.label1.visible=true;
			intermission.label1.text="HALFTIME"
			intermission.label1.color=0xFFFFFF;
			intermission.label1.scale=2;
			intermission.label1.x = 330;
			intermission.label1.y = 20;		
			intermission.label2.color=0xFFFFFF;
			intermission.label3.color=0xFFFFFF;
			intermission.label4.color=0xFFFFFF;


		}
		
	}
}