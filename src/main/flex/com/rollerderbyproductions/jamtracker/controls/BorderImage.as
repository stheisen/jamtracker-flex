package com.rollerderbyproductions.jamtracker.controls
{
	import mx.controls.Image;
	
	[Style(name="borderColor", type="uint", format="Color", inherit="no")]
	[Style(name="borderThickness", type="Number", format="Length",inherit="no")]
	[Style(name="borderAlpha", type="Number", format="Length", inherit="no")] 
	[Style(name="borderRounded", type="Number", format="Length", inherit="no")] 
	public class BorderImage extends Image
	{
		public function BorderImage()
		{
			super();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			
			super.updateDisplayList(w,h);
			
			if (!isNaN(contentWidth)){
			
				// adjust the position 
				// calculation based on initial position
				var contentX:Number = (w - contentWidth) * getHorizontalAlignValue();
				var contentY:Number = (h - contentHeight) * getVerticalAlignValue()
				
				// clear graphics
				// we want only one rectangle
				graphics.clear();
				// set line style with with 0 and alpha 0
				graphics.lineStyle(getStyle('borderThickness'),getStyle('borderColor'),getStyle('borderAlpha'),false);

				// NO FILL (Commented Out)
				//graphics.beginFill(getStyle('borderColor'), getStyle('borderAlpha'));
				
				if (contentHeight > 1){
					graphics.drawRoundRect(-getStyle('borderThickness') + contentX +2,
						                   -getStyle('borderThickness') + contentY +3,
						                   (contentWidth+getStyle('borderThickness')*2)-5,
						                   (contentHeight+getStyle('borderThickness')*2)-6, 
										   getStyle('borderRounded'));
				}
				 
				// NO FILL
				//graphics.endFill();
			} else {
				graphics.clear();
			}
		}
		
		protected function getHorizontalAlignValue():Number
		{
			var horizontalAlign:String = getStyle("horizontalAlign");
			
			if (horizontalAlign == "left")
				return 0;
			else if (horizontalAlign == "right")
				return 1;
			
			// default = center
			return 0.5;
		}
		
		protected function getVerticalAlignValue():Number
		{
			var verticalAlign:String = getStyle("verticalAlign");
			
			if (verticalAlign == "top")
				return 0;
			else if (verticalAlign == "bottom")
				return 1;
			
			// default = middle
			return 0.5;
		}
	
	}
}