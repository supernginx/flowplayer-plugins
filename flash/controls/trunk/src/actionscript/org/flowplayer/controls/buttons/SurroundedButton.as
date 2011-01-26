/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
 package org.flowplayer.controls.buttons {
    
	import org.flowplayer.ui.buttons.AbstractButton;
	import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.ColorTransform;
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.AnimationEngine;
	import org.flowplayer.ui.tooltips.ToolTip;
	import org.flowplayer.ui.tooltips.NullToolTip;
	import org.flowplayer.ui.tooltips.DefaultToolTip;
	import org.flowplayer.ui.buttons.ConfigurableWidget;
	
	import org.flowplayer.controls.SkinClasses;
	
	public class SurroundedButton extends SurroundedWidget {
      
     

		public function SurroundedButton(button:ConfigurableWidget, top:DisplayObject = null, right:DisplayObject = null, bottom:DisplayObject = null, left:DisplayObject = null) {
			super(	button, 	
					(top 	|| SkinClasses.getDisplayObject("fp.ButtonTopEdge")), 
					(right 	|| SkinClasses.getDisplayObject("fp.ButtonRightEdge")), 
					(bottom || SkinClasses.getDisplayObject("fp.ButtonBottomEdge")), 
					(left   || SkinClasses.getDisplayObject("fp.ButtonLeftEdge")));
		}
		
        override protected function onResize():void {

            // We scale width according to the current height! The aspect ratio of the face is always preserved.

            _widget.x = _left.width;
            _widget.y = _top.height;

			var h:Number = height - _top.height - _bottom.height;
			var w:Number = h / _widget.height * _widget.width;
			
			_widget.setSize(w, h);

            _left.x = 0;
            _left.y = _top.height;
            _left.height = height - _top.height - _bottom.height;

            _top.x = 0;
            _top.y = 0;
            _top.width = _widget.width + _left.width + _right.width;

            _right.x = _left.width + _widget.width;
            _right.y = _top.height;
            _right.height = height - _top.height - _bottom.height;

            _bottom.x = 0;
            _bottom.y = height - _bottom.height;
            _bottom.width = _widget.width + _left.width + _right.width;

            _height = _top.height + _widget.height + _bottom.height;
            _width = _left.width + _widget.width + _right.width; 
        }

    }
}
