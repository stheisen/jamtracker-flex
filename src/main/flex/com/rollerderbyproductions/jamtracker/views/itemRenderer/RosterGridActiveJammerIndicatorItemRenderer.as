package com.rollerderbyproductions.jamtracker.views.itemRenderer
{
	import com.rollerderbyproductions.jamtracker.model.AssetModel;
	
	import mx.controls.Image;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	public class RosterGridActiveJammerIndicatorItemRenderer extends UIComponent implements IListItemRenderer
	{
		
		private var _imageSource:Class = AssetModel.ICON_STAR16_CLASS;
		private var _image:Image;
		private var _data:Object;
		
		public function RosterGridActiveJammerIndicatorItemRenderer()
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
				if (data.currentJammer){
					_image.source = _imageSource;
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