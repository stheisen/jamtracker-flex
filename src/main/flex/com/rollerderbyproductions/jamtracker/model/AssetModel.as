package com.rollerderbyproductions.jamtracker.model
{
	import spark.filters.ColorMatrixFilter;

	[RemoteClass]
	[Bindable]
	public class AssetModel
	{
	
		public static const matrix:Array = [0.3, 0.59, 0.11, 0, 0, 0.3, 0.59, 0.11, 0, 0, 0.3, 0.59, 0.11, 0, 0, 0, 0, 0, 1, 0];
		public static const GRAYSCALE_FILTER:ColorMatrixFilter = new ColorMatrixFilter(matrix);
		
		[Embed(source="/assets/icon/add_16.png",mimeType="image/png")]
		public static const ICON_ADD16_CLASS:Class;

		[Embed(source="/assets/icon/add_16.png",mimeType="image/png")]
		public static const ICON_ADDIMAGE16_CLASS:Class;

		[Embed(source="/assets/icon/error_32.png",mimeType="image/png")]
		public static const ICON_ERROR32_CLASS:Class;
		
		[Embed(source="/assets/icon/about16.png",mimeType="image/png")]
		public static const ICON_ABOUT16_CLASS:Class;

		[Embed(source="/assets/icon/aboutDisabled16.png",mimeType="image/png")]
		public static const ICON_ABOUTDISABLED16_CLASS:Class;

		[Embed(source="/assets/icon/important_32.png",mimeType="image/png")]
		public static const ICON_ALERT32_CLASS:Class;
		
		[Embed(source="/assets/icon/announce_16.png",mimeType="image/png")]
		public static const ICON_ANNOUNCE16_CLASS:Class;
		
		[Embed(source="/assets/icon/cancel_16.png",mimeType="image/png")]
		public static const ICON_CANCEL16_CLASS:Class;

		[Embed(source="/assets/icon/check_16.png",mimeType="image/png")]
		public static const ICON_CHECK16_CLASS:Class;
		
		[Embed(source="/assets/icon/curtainClosed_16.png",mimeType="image/png")]
		public static const ICON_CURTAINCLOSED16_CLASS:Class;

		[Embed(source="/assets/icon/curtainOpen_16.png",mimeType="image/png")]
		public static const ICON_CURTAINOPEN16_CLASS:Class;
		
		[Embed(source="/assets/icon/confirm_16.png",mimeType="image/png")]
		public static const ICON_CONFIRM16_CLASS:Class;
		
		[Embed(source="/assets/icon/corrections_16.png",mimeType="image/png")]
		public static const ICON_CORRECTIONS_CLASS:Class;

		[Embed(source="/assets/icon/correctionsDisabled_16.png",mimeType="image/png")]
		public static const ICON_CORRECTIONSDISABLED_CLASS:Class;

		[Embed(source="/assets/logo/paypalDonate.png",mimeType="image/png")]
		public static const LOGO_PAYPALDONATE_CLASS:Class;
		
		[Embed(source="/assets/icon/export_16.png",mimeType="image/png")]
		public static const ICON_EXPORT16_CLASS:Class;

		[Embed(source="/assets/icon/girl_16.png",mimeType="image/png")]
		public static const ICON_GIRL16_CLASS:Class;
		
		[Embed(source="/assets/icon/girlInactive_16.png",mimeType="image/png")]
		public static const ICON_GIRLINACTIVE16_CLASS:Class;

		[Embed(source="/assets/icon/image_inactive.png",mimeType="image/png")]
		public static const ICON_IMAGEINACTIVE_CLASS:Class;
		
		[Embed(source="/assets/icon/image_active.png",mimeType="image/png")]
		public static const ICON_IMAGEACTIVE_CLASS:Class;

		[Embed(source="/assets/icon/new_16.png",mimeType="image/png")]
		public static const ICON_NEW16_CLASS:Class;
		
		[Embed(source="/assets/icon/open_16.png",mimeType="image/png")]
		public static const ICON_OPEN16_CLASS:Class;
		
		[Embed(source="/assets/icon/picture_16.png",mimeType="image/png")]
		public static const ICON_PLAYERPHOTO_CLASS:Class;

		[Embed(source="/assets/icon/preview_16.png",mimeType="image/png")]
		public static const ICON_PREVIEW16_CLASS:Class;

		[Embed(source="/assets/icon/previewDisabled_16.png",mimeType="image/png")]
		public static const ICON_PREVIEWDISABLED16_CLASS:Class;
		
		[Embed(source="/assets/icon/remove_16.png",mimeType="image/png")]
		public static const ICON_REMOVE16_CLASS:Class;

		[Embed(source="/assets/icon/reset_16.png",mimeType="image/png")]
		public static const ICON_RESET16_CLASS:Class;
		
		[Embed(source="/assets/icon/restore_16.png",mimeType="image/png")]
		public static const ICON_RESTORE16_CLASS:Class;

		[Embed(source="/assets/icon/roster_16.png",mimeType="image/png")]
		public static const ICON_ROSTER16_CLASS:Class;
		
		[Embed(source="/assets/icon/question_32.png",mimeType="image/png")]
		public static const ICON_QUESTION32_CLASS:Class;

		[Embed(source="/assets/icon/save_16.png",mimeType="image/png")]
		public static const ICON_SAVE16_CLASS:Class;

		[Embed(source="/assets/icon/saveInactive_16.png",mimeType="image/png")]
		public static const ICON_SAVEINACTIVE16_CLASS:Class;

		[Embed(source="/assets/icon/scoring_16.png",mimeType="image/png")]
		public static const ICON_SCORING16_CLASS:Class;

		[Embed(source="/assets/icon/settings_16.png",mimeType="image/png")]
		public static const ICON_SETTINGS16_CLASS:Class;

		[Embed(source="/assets/icon/star_16.png",mimeType="image/png")]
		public static const ICON_STAR16_CLASS:Class;

		[Embed(source="/assets/icon/undo_16.png",mimeType="image/png")]
		public static const ICON_UNDO16_CLASS:Class;

		[Embed(source="/assets/icon/arrow_right.png",mimeType="image/png")]
		public static const ICON_ARROWRIGHT_CLASS:Class;
		
		[Embed(source="/assets/icon/arrow_left.png",mimeType="image/png")]
		public static const ICON_ARROWLEFT_CLASS:Class;

		[Embed(source="/assets/icon/arrow_up.png",mimeType="image/png")]
		public static const ICON_ARROWUP_CLASS:Class;
		
		[Embed(source="/assets/icon/arrow_down.png",mimeType="image/png")]
		public static const ICON_ARROWDOWN_CLASS:Class;
		
		[Embed(source="/assets/icon/usaFlag_16.png",mimeType="image/png")]
		public static const ICON_USAFLAG16_CLASS:Class;

		[Embed(source="/assets/icon/views_16.png",mimeType="image/png")]
		public static const ICON_VIEWS16_CLASS:Class;

		[Embed(source="/assets/icon/warning_16.png",mimeType="image/png")]
		public static const ICON_WARNING_CLASS:Class;
		                              
		[Embed(source="/assets/logo/jamtracker_logo_30.png",mimeType="image/png")]
		public static const LOGO_JAMTRACKERSMALL_CLASS:Class;		

		[Embed(source="/assets/logo/jamtracker_logo_70.png",mimeType="image/png")]
		public static const LOGO_JAMTRACKER_BOARDLABEL_CLASS:Class;		

		[Embed(source="/assets/logo/jamtracker_logo_350x128.png",mimeType="image/png")]
		public static const LOGO_JAMTRACKER_CLASS:Class;		
		
		[Embed(source="/assets/logo/defaultHomeLogo.png",mimeType="application/octet-stream")]
		public static const LOGO_DEFAULTHOME_CLASS:Class;		
		
		[Embed(source="/assets/logo/defaultVisitorLogo.png",mimeType="application/octet-stream")]
		public static const LOGO_DEFAULTVISITOR_CLASS:Class;		
				
		[Embed(source="/assets/background/defaultCurtain.png",mimeType="application/octet-stream")]
		public static const IMAGE_DEFAULTCURTAINIMAGE_CLASS:Class;		

		[Embed(source="/assets/background/defaultScoreboardBackground.png",mimeType="application/octet-stream")]
		public static const IMAGE_DEFAULTSCOREBOARDBACKGROUND_CLASS:Class;		

		[Embed(source="/assets/background/transparency.png",mimeType="application/octet-stream")]
		public static const IMAGE_TRANSPARANCYBACKGROUND_CLASS:Class;		
		
		[Embed(source="/assets/header/defaultScoreboardHeader.png",mimeType="application/octet-stream")]
		public static const IMAGE_DEFAULTSCOREBOARDOVERLAY_CLASS:Class;		
		
		[Embed(source="/assets/img/leadJammer.png",mimeType="application/octet-stream")]
		public static const IMAGE_DEFAULTLEADJAMMER_CLASS:Class;			
		
		[Embed(source="/assets/img/defaultPlayerImage.png",mimeType="application/octet-stream")]
		public static const IMAGE_DEFAULTPLAYERIMG_CLASS:Class;			

		// Constructor ----------------------------------------------------------------------------
		public function AssetModel(){
		}
	}
}