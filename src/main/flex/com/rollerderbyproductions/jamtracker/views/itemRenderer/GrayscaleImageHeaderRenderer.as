package com.rollerderbyproductions.jamtracker.views.itemRenderer
{
	import com.rollerderbyproductions.jamtracker.model.AssetModel;
	
	import flash.display.DisplayObject;
	
	import mx.controls.Image;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import spark.filters.ColorMatrixFilter;
	
	public class GrayscaleImageHeaderRenderer extends UIComponent implements IListItemRenderer
	{
		
		private var _starImage:Class = AssetModel.ICON_STAR16_CLASS;
		private var _cameraImage:Class = AssetModel.ICON_PLAYERPHOTO_CLASS;

		private var _image:Image;
		private var _data:Object;
		
		public function GrayscaleImageHeaderRenderer()
		{
			super();
			_image = new Image();
			_image.source = _starImage;
			this.addChild(_image);
		}

		public function get data():Object 
		{
			return _data;
		}
		
		public function set data(value:Object):void
		{
			var headerText:String = (value as DataGridColumn).headerText;
			switch (headerText) {
				case "ActiveJammer": 
					_image.source = _starImage;
					_image.toolTip = "Active Jammer";
					break;
				case "PlayerImage":  
					_image.source = _cameraImage;
					_image.toolTip = "Players with an Image";
					break;
				default: 
					_image.source = _starImage;
					break;
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			_image.filters = [AssetModel.GRAYSCALE_FILTER];
			_image.setActualSize(12,12);
			_image.move((unscaledWidth - 12) / 2, (unscaledHeight - 12) / 2);
		}
		
	}
}