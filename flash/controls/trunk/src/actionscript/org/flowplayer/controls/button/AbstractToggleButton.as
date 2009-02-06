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
			_upStateFace = createUpStateFace();
			_downStateFace = createDownStateFace(); 
			addChild(_upStateFace);
			super(config, animationEngine);
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
		}		protected function arrange():void {
		}

		protected function createUpStateFace():DisplayObjectContainer {
			log.error("createUpStateFace not overridden");
			return null;
		}
		
		protected function createDownStateFace():DisplayObjectContainer {
			log.error("createDownStateFace not overridden");
			return null;
		}
		
		protected override function createFace():DisplayObjectContainer {
			return null;
		}
		
	}
}
