package com.rollerderbyproductions.jamtracker.util
{
	public class FlexHelper
	{

		static public function getElemenyByName(group:Object, name:String):int {
			
			for (var i:int = 0; i < group.numElements; i++)
			{
				var stringName:String = group.getElementAt(i) + "";
				if (stringName.indexOf(".") > 0)
				{
					stringName = stringName.substr(stringName.lastIndexOf(".")+1, stringName.length);
				}
				if (stringName == name) return i;
			}
			
			return -1;
		}
		
	}
}