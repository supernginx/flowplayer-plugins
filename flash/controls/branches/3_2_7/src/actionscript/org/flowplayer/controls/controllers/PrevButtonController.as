/* * Author: Thomas Dubois, <thomas _at_ flowplayer org> * This file is part of Flowplayer, http://flowplayer.org * * Copyright (c) 2011 Flowplayer Ltd * * Released under the MIT License: * http://www.opensource.org/licenses/mit-license.php */package org.flowplayer.controls.controllers {	import org.flowplayer.controls.Controlbar;	import org.flowplayer.controls.SkinClasses;		import org.flowplayer.ui.controllers.AbstractButtonController;	import org.flowplayer.ui.buttons.ButtonEvent;	import org.flowplayer.view.Flowplayer;	import flash.display.DisplayObjectContainer;		public class PrevButtonController extends AbstractButtonController {				public function PrevButtonController() {			super();		}				override public function get name():String {			return "previous";		}				override public function get groupName():String {			return "playlist";		}				override public function get defaults():Object {			return {				tooltipEnabled: false,				tooltipLabel: "Previous",				visible: false,				enabled: true			};		}				override protected function get faceClass():Class {			return SkinClasses.getClass("fp.PrevButton");		}				override protected function onButtonClicked(event:ButtonEvent):void {			_player.previous();		}	}}