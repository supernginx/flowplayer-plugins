/* * This file is part of Flowplayer, http://flowplayer.org * *Copyright (c) 2008, 2009 Flowplayer Oy * * Released under the MIT License: * http://www.opensource.org/licenses/mit-license.php */package org.flowplayer.controls.button {	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import org.flowplayer.controls.Config;
	import org.flowplayer.controls.flash.FullScreenOffButton;
	import org.flowplayer.controls.flash.FullScreenOnButton;	
	/**	 * @author api	 */	public class ToggleFullScreenButton extends AbstractToggleButton {		public function ToggleFullScreenButton(config:Config) {			super(config);		}						protected override function createUpStateFace():DisplayObjectContainer {			return new FullScreenOnButton();		}				protected override function createDownStateFace():DisplayObjectContainer {			return new FullScreenOffButton();		}				override protected function onMouseOver(event:MouseEvent):void {			super.onMouseOver(event);			MovieClip(_upStateFace).play();		}				override protected function onMouseOut(event:MouseEvent = null):void {			super.onMouseOut(event);			MovieClip(_upStateFace).gotoAndStop(1);		}		override protected function onClicked(event:MouseEvent):void {			super.onClicked(event);			onMouseOut();		}	}}