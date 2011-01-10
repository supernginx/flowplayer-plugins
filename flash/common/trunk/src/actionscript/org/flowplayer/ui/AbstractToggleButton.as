/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2009 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.ui {
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.events.MouseEvent;
    
    import org.flowplayer.ui.assets.Button;
    import org.flowplayer.view.AnimationEngine;

    public class AbstractToggleButton extends AbstractButton {
        
		protected var _upStateFace:DisplayObjectContainer;
		protected var _downStateFace:DisplayObjectContainer;
		private var _config:ButtonConfig;
		private var _toggle:Boolean;


        public function AbstractToggleButton(config:ButtonConfig, animationEngine:AnimationEngine) {
			
			_downStateFace = createDownStateFace();
			_upStateFace = createUpStateFace();
			_config = config;
			
			addChild(_upStateFace);
			
			_face = _upStateFace;
			
			super(config, animationEngine);
			
        }
        
        override protected function onResize():void {
            log.debug("onResize() " + width + " x " + height);
            
            _face.width = width;
            _face.height = height;

        }
		
		override protected function get faceWidth():Number {	
			return _face.width;
		}
		
		override protected function get faceHeight():Number {
			return _face.height;
		}
		
		override protected function onMouseOut(event:MouseEvent = null):void {
			resetDispColor(_face.getChildByName(HIGHLIGHT_INSTANCE_NAME));
            showMouseOutState(_face);
		}
		
		override protected function onMouseOver(event:MouseEvent):void {
			transformDispColor(_face.getChildByName(HIGHLIGHT_INSTANCE_NAME));
            showMouseOverState(_face);
		}

		override protected function onMouseDown(event:MouseEvent):void {
			
			if (toggle) {
				toggle = false;
			} else {
				toggle = true;
			}
			
			var overClip:DisplayObject = _face.getChildByName(HIGHLIGHT_INSTANCE_NAME);
            if ( overClip && overClip is MovieClip )
                MovieClip(overClip).gotoAndPlay("down");
		}
		
		public function get toggle():Boolean {
			return _toggle;
		}
		
		public function set toggle(down:Boolean):void {
			if (toggle == down) return;
			removeChild(down ? _upStateFace : _downStateFace);
			_face = down ? _downStateFace : _upStateFace;
			addChild(_face);
			
			_toggle = down;
			log.error(String(_toggle));
		}
		
		
		protected function createUpStateFace():DisplayObjectContainer {
		 	return null;
		 }
		
		protected function createDownStateFace():DisplayObjectContainer {
		 	return null;
		}

		override protected function createFace():DisplayObjectContainer {
		 	return _upStateFace;
		}
		
		protected function transformToggleDispColor(disp:DisplayObject):void {
			log.debug("toggle on colors", _config.toggleOnColorRGBA);
			transformColor(disp, _config.toggleOnColorRGBA[0], _config.toggleOnColorRGBA[1], _config.toggleOnColorRGBA[2], _config.toggleOnColorRGBA[3]);
		}
		
		private function transformColor(disp:DisplayObject, redOffset:Number, greenOffset:Number, blueOffset:Number, alphaOffset:Number):void {
			log.debug("transformColor, alphaOffset " + alphaOffset);
			if (! disp) return;
			//ColorTransform(redMultiplier:Number = 1,greenMultiplier:Number = 1,blueMultiplier:Number = 1,alphaMultiplier:Number = 1,redOffset:Number = 0,greenOffset:Number = 0,blueOffset:Number = 0,alphaOffset:Number = 0):*;
			var transform:ColorTransform = new ColorTransform( 0, 0, 0, alphaOffset, redOffset, greenOffset, blueOffset);
			disp.transform.colorTransform = transform;
		}
		

    }
}