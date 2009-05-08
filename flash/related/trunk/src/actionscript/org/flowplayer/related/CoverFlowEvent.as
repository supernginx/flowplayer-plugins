/**************************************
title: CoverFlow knockoff
author: John Dyer (johndyer.name)
license: MIT
*************************************/

package org.flowplayer.related 
{	
    import flash.events.*;

	
	public class CoverFlowEvent extends Event {
		
		public static var ITEM_FOCUS:String = "itemFocus";
		public static var ITEM_CLICK:String = "itemClick";		

		public var itemIndex:Number = -1;
		
		function CoverFlowEvent(type:String, itemIndex:Number)  {
			super(type);
			this.itemIndex = itemIndex;
		}
	}
	
}