/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.controls.controllers {
    
	import org.flowplayer.view.Flowplayer;
	import org.flowplayer.view.AbstractSprite;
	import org.flowplayer.model.Clip;
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.model.Status;
	
	import org.flowplayer.ui.buttons.ConfigurableWidget;
	
	import flash.utils.*;
	import flash.events.TimerEvent;

	import org.flowplayer.util.PropertyBinder;
	import org.flowplayer.util.Log;
	
	import flash.display.DisplayObjectContainer;
	

	public class AbstractWidgetController {

		protected var _config:Object;
		protected var _player:Flowplayer;
		protected var _controlbar:DisplayObjectContainer;
	
		protected var _widget:ConfigurableWidget;
	
		protected var log:Log = new Log(this);
		
		public function AbstractWidgetController(config:Object, player:Flowplayer, controlbar:DisplayObjectContainer) {
			_config		= config;
			_player 	= player;
			_controlbar = controlbar;
			
			addPlayerListeners();
			
			createWidget();
			initWidget();
			
			configure(config);
		}
		
		
		
		public function get view():ConfigurableWidget {
			return _widget;
		}
		
		public function configure(config:Object):void {
			_config = config;
			view.configure(_config);
		}
		
		public function get config():Object {
			return _config;
		}

		public function get name():String {
			return Object(this).constructor['NAME'];
		}


		// this is what you should override 
		
		protected function createWidget():void {			
			throw new Error("You need to override createWidget");
		}
				
		// helper methods
		
		public static function isKindOfClass(controller:Class, requestedType:Class):Boolean {
			// if controller is the good type
			if ( controller == requestedType )
				return true;

			// else we need to look in super classes
			var requestedTypeName:String = getQualifiedClassName(requestedType);

			var description:XML = describeType(controller);
			var superClasses:XMLList = description..extendsClass.@type;
			for ( var i:int = 0; i < superClasses.length(); i++ ) {
				if ( superClasses[i] == requestedTypeName )
					return true;
			}

			return false;
		}
/*
		protected function mergeConfiguration(config:Object, defaults:Object):Object {
		log.error("Merging configuration using ", defaults);
			for ( var i:String in defaults ) {
				var setterName:String = 'set' + i.substr(0, 1).toUpperCase() + i.substr(1);
				log.error("using setter name "+ setterName);
				try {	config[setterName](config[i] === undefined ? defaults[i] : config[i]); }
				catch(e:Error) { log.error("Got error while setting defaults using "+ setterName); }
			}
		
			log.error("Merging config ",config)
		
		
			return config;
		}
*/
		protected function initWidget():void {
			_widget.visible = false;
			_widget.name    = name;
		}
		
		protected function addPlayerListeners():void {
            _player.playlist.onConnect(onPlayStarted);
            _player.playlist.onBeforeBegin(onPlayStarted);
            _player.playlist.onBegin(onPlayStarted);
            _player.playlist.onMetaData(onPlayStarted);
            _player.playlist.onStart(onPlayStarted); // bug #120

            _player.playlist.onPause(onPlayPaused);
            _player.playlist.onResume(onPlayResumed);

            _player.playlist.onStop(onPlayStopped);
            _player.playlist.onBufferStop(onPlayStopped);
            _player.playlist.onFinish(onPlayStopped);
        }
				
		// This is some handy functions you can override to handle your buttons' state.
		
        protected function onPlayStarted(event:ClipEvent):void {

        }

        protected function onPlayPaused(event:ClipEvent):void {
           
        }
        
        protected function onPlayResumed(event:ClipEvent):void {
           
        }

		protected function onPlayStopped(event:ClipEvent):void {

        }

		
		
	}
}

