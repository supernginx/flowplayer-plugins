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
	
	import org.flowplayer.util.Arrange;
	
	public class SurroundedWidget extends ConfigurableWidget {
      
        protected var _top:DisplayObject;
        protected var _bottom:DisplayObject;
        protected var _left:DisplayObject;
        protected var _right:DisplayObject;
		protected var _widget:ConfigurableWidget;
		protected var _config:Object;

		public function SurroundedWidget(widget:ConfigurableWidget, top:DisplayObject, right:DisplayObject, bottom:DisplayObject, left:DisplayObject) {	
            _left 	= DisplayObjectContainer(addFaceIfNotNull(left));
            _right 	= DisplayObjectContainer(addFaceIfNotNull(right));
            _top 	= DisplayObjectContainer(addFaceIfNotNull(top));
            _bottom = DisplayObjectContainer(addFaceIfNotNull(bottom));
			_widget = addFaceIfNotNull(widget) as ConfigurableWidget;
		}
		
		public function get widget():ConfigurableWidget {
			return _widget;
		}
		
		public function setRightEdgeWidth(width:Number):void {
            log.debug("setRightEdgeWidth() " + width);
            _right.width = width;
        }
		
		override public function configure(config:Object):void {
			_config = config;
			_widget.configure(config);
			onResize();
		}
      
        override public function set enabled(value:Boolean):void {
			_widget.enabled = value;
		}

		override public function get enabled():Boolean {
			return _widget.enabled;
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean  = false, priority:int  = 0, useWeakReference:Boolean  = false):void {
			_widget.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean  = false):void {
			_widget.removeEventListener(type, listener, useCapture);
		}
		
		override public function get name():String {
			return _widget.name;
		}

		protected function addFaceIfNotNull(child:DisplayObject):DisplayObject {
            if (! child) return child;
            return addChild(child);
        }
     
        override protected function onResize():void {
			_left.height = _height - _top.height - _bottom.height;
            _left.x = 0;
            _left.y = _top.height;

            _right.height = _height - _top.height - _bottom.height;
            _right.x = _width - _right.width;
            _right.y = _top.height;


            _widget.x = _left.width;
            _widget.setSize(_width - _left.width - _right.width, (height-_bottom.height) * widgetHeightRatio);
            Arrange.center(_widget, 0, height);

            _bottom.y = _height - _bottom.height;
            _bottom.width = _width;

            _top.y = 0;
            _top.width = _width;
        }

		public override function get width():Number {
			return _left.width + _widget.width + _right.width;
		}

		protected function get widgetHeightRatio():Number {
			return _config['heightRatio'] || 1;
		}
    }
}
