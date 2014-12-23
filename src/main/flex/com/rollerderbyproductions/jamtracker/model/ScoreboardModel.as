package com.rollerderbyproductions.jamtracker.model
{
	import com.rollerderbyproductions.jamtracker.domain.AppImage;
	import com.rollerderbyproductions.jamtracker.domain.JammerDisplay;
	
	import flash.utils.ByteArray;

	[RemoteClass]
	[Bindable]
	public class ScoreboardModel
	{
		// **************************************************************************************
		// NOTE :: In order to support persistance do NOT remove any of the properties on this
		//         object. In the case that any are added, be sure to add them to the persistance
		//         classes
		// **************************************************************************************

		// This is the version number of this object
		public static var OBJECT_VERSION:String = "4.0"; // Reflect this change in TeamRepository
		
		
		// NOTE: Any time any of these properties are updated you MUST change the OBJECT_VERSION number, and load the
		//       object accordingly in the TeamRepository 
		
		// Version 1.0 //////////////////////////////////////////////////////////////////////////////
		public var backgroundAlpha:Number = 1;
		public var backgroundColor:uint = 0x000000;
		public var backgroundImage:AppImage;
		public var backgroundImageAlpha:Number = 1;
		public var backgroundImageVisible:Boolean = true;
		public var backgroundMaintainAspect:Boolean = false;
		public var containerBorderAlpha:Number = 1;
		public var containerBorderColor:uint = 0xffffff;
		public var defaultJammerImage:AppImage;
		public var displayJammerImage:Boolean = true;
		public var displayJammerName:Boolean = true;
		public var fontAlpha:Number = 1;
		public var fontColor:uint = 0xffffff;
		public var glowEnabled:Boolean = true;
		public var jammerHome:JammerDisplay = new JammerDisplay();
		public var jammerImageBorderColor:uint = 0xABABAB;
		public var jammerImageLeadBorderColor:uint = 0xFFFF00;
		public var jammerNameFontSize:Number = 25;
		public var jammerVisitor:JammerDisplay = new JammerDisplay();
		public var LED_BackColor:uint = 0x212121;
		public var LED_ForeColor:uint = 0xffff00;
		public var LED_GlowAlpha:Number = .6;
		public var LED_GlowColor:uint = 0xFF9922;
		public var LeadJammer_Color:uint = 0xffff00;		
		public var LeadJammer_Alpha:Number = 1;
		public var leadJammerIndicatorImage:AppImage;
		public var overlayImage:AppImage;
		public var overlayImageAlpha:Number = 1;
		public var overlayImageVisible:Boolean = true;
		public var scoreboardScale:Number = 1;
		public var scoreboardX:Number = 0;
		public var scoreboardY:Number = 116;
		public var timeoutFontColor:uint = 0xcc9900;
		public var timeoutFontAlpha:Number = 1;
		public var useDefaultJammerImage:Boolean = true;
		
		// Version 2.0 //////////////////////////////////////////////////////////////////////////////

		// The height of the jammer image as set by the slider on the configuration panel
		public var setJammerImageHeight:Number = 200;
		// This is the currently displayed jammer image height
		public var currentJammerImageHeight:Number = 200;
		// This is the currently displayed team logo height
		public var currentTeamLogoHeight:Number = 190;
		// This flag sets the visibility of the jammer image and jammer indicator area
		public var hideJammerImageArea:Boolean = false;
		
		// Version 3.0 //////////////////////////////////////////////////////////////////////////////
		public var clockTitlefontColor:uint = 0xffffff;
		public var clockTitleFontAlpha:Number = 1;
		
		// Version 4.0 (v0.5.0) /////////////////////////////////////////////////////////////////////
		
		public var homeDefaultJammerImage:AppImage;
		public var visitorDefaultJammerImage:AppImage;
		public var autoMinimizeJammerInfo:Boolean = false;

		// Version 5.0 //////////////////////////////////////////////////////////////////////////////

		// Constructors ---------------------------------------------------------------------------
		/* NOTE: An empty constructor is required to export/import this object to/from filesystem */
		public function ScoreboardModel(){}

		
		public function init():void {
			// Version 1.0 //////////////////////////////////////////////////////////////////////////////
			backgroundAlpha = 1;
			backgroundColor = 0x000000;
			backgroundImage;
			backgroundImageAlpha = 1;
			backgroundImageVisible = true;
			backgroundMaintainAspect = false;
			containerBorderAlpha = 1;
			containerBorderColor = 0xffffff;
			defaultJammerImage;
			displayJammerImage = true;
			displayJammerName = true;
			fontAlpha = 1;
			fontColor = 0xffffff;
			glowEnabled = true;
			jammerHome = new JammerDisplay();
			jammerImageBorderColor = 0xABABAB;
			jammerImageLeadBorderColor = 0xFFFF00;
			jammerNameFontSize = 25;
			jammerVisitor = new JammerDisplay();
			LED_BackColor = 0x212121;
			LED_ForeColor = 0xffff00;
			LED_GlowAlpha = .6;
			LED_GlowColor = 0xFF9922;
			LeadJammer_Color = 0xffff00;		
			LeadJammer_Alpha = 1;
			leadJammerIndicatorImage;
			overlayImage;
			overlayImageAlpha = 1;
			overlayImageVisible = true;
			scoreboardScale = 1;
			scoreboardX = 0;
			scoreboardY = 116;
			timeoutFontColor = 0xcc9900;
			timeoutFontAlpha = 1;
			useDefaultJammerImage = true;
			
			// Version 2.0 //////////////////////////////////////////////////////////////////////////////
			setJammerImageHeight = 200;
			currentJammerImageHeight = 200;
			currentTeamLogoHeight = 190;
			hideJammerImageArea = false;
			
			// Version 3.0 //////////////////////////////////////////////////////////////////////////////
			clockTitlefontColor = 0xffffff;
			clockTitleFontAlpha = 1;

			// Version 3.0 //////////////////////////////////////////////////////////////////////////////
			homeDefaultJammerImage;
			visitorDefaultJammerImage;
			autoMinimizeJammerInfo = false;
		}
		
	}
}