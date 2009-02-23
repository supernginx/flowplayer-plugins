/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 *Copyright (c) 2008, 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.controls.button {
	import org.flowplayer.view.AnimationEngine;	
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	
	import org.flowplayer.controls.Config;	
	/**
	 * @author api
	 */
	public class AbstractToggleButton extends AbstractButton {

		protected var _upStateFace:DisplayObjectContainer;
		protected var _downStateFace:DisplayObjectContainer;

		public function AbstractToggleButton(config:Config, animationEngine:AnimationEngine) {
            super(config, animationEngine);
            _downStateFace = createDownStateFace();
			_upStateFace = createUpStateFace();
			addChild(_upStateFace);
			clickListenerEnabled = true;
			arrange();
		}
		
		protected override function onMouseOut(event:MouseEvent = null):void {
			resetDispColor(_upStateFace.getChildByName(BACK_INSTANCE_NAME));
			resetDispColor(_downStateFace.getChildByName(BACK_INSTANCE_NAME));
			hideTooltip();
		}

		protected override function onMouseOver(event:MouseEvent):void {
			transformDispColor(_upStateFace.getChildByName(BACK_INSTANCE_NAME));
			transformDispColor(_downStateFace.getChildByName(BACK_INSTANCE_NAME));
			showTooltip();
		}
		
		public function get isDown():Boolean {
			return getChildByName(_downStateFace.name) != null;
		}

		public function set down(down:Boolean):void {
			if (isDown == down) return;
			removeChild(down ? _upStateFace : _downStateFace);
			addChild(down ? _downStateFace : _upStateFace);
			arrange();
		}

		protected function arrange():void {
		}

		private function createUpStateFace():DisplayObjectContainer {
            var className:String = getUpStateFaceClassName();
            log.debug("creating skin from " + className);
            var Face:Class = getClass(className);
			return new Face();
		}

		private function createDownStateFace():DisplayObjectContainer {
            var Face:Class = getClass(getDownStateFaceClassName());
			return new Face();
		}

        protected function getUpStateFaceClassName():String {
            throw new Error("getUpStateFaceClassName must be overridden in a subclass");
            return null;
        }

        protected function getDownStateFaceClassName():String {
            throw new Error("getDownStateFaceClassName must be overridden in a subclass");
            return null;
        }
		
        override protected function createFace():DisplayObjectContainer {
            return null;
        }

	}
}
