package com.rollerderbyproductions.jamtracker.views.itemRenderer
{
	import com.rollerderbyproductions.jamtracker.model.ApplicationModel;
	import com.rollerderbyproductions.jamtracker.model.AssetModel;
	import com.rollerderbyproductions.jamtracker.util.ImageUtility;
	
	import mx.controls.Image;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	public class RosterGridImageIndicatorItemRenderer extends UIComponent implements IListItemRenderer
	{
		
		private var _imageSource:Class = AssetModel.ICON_CHECK16_CLASS;
		private var _warningImage:Class = AssetModel.ICON_WARNING_CLASS;
		private var _image:Image;
		private var _data:Object;
		
		public function RosterGridImageIndicatorItemRenderer()
		{
			super();
			this.mouseChildren = true;
			_image = new Image();
			_image.source = _imageSource;
			_image.buttonMode = true;
			this.addChild(_image);
		}

		[Bindable("dataChange")]
		[Inspectable(environment="none")]
		public function get data():Object 
		{
			return _data;
		}
		
		public function set data(value:Object):void
		{
			_data = value;
			invalidateProperties();
			dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
		}
		
		/**
		 * This will display the delete image only if the data is set to NOT be read-only.
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (data){
				// If readonly is false, show the user the delete image
				if ((data.playerImage != null)){
					var imageSizeKB:Number = ImageUtility.bytesToKB(data.playerImage.data.bytesAvailable);
					
					if (imageSizeKB > ApplicationModel.PLAYER_IMAGE_MAX_KBSIZE)	{
						_image.source = _warningImage;
						_image.toolTip = ApplicationModel.MESSAGE_PLAYER_IMAGE_EXCEED_MAX_SIZE;	
					} else { 
						_image.source = _imageSource;
						_image.toolTip = "";
					}
					
				} else {
					_image.source = null;
				}
			}
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			_image.setActualSize(16,16);
			_image.move((unscaledWidth - 16) / 2, (unscaledHeight - 16) / 2);
		}

		
	}
}