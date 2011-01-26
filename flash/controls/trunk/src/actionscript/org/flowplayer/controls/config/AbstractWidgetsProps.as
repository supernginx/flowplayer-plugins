/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */


package org.flowplayer.controls.config {
	import org.flowplayer.util.ObjectConverter;	
	import org.flowplayer.util.Log;	
	
	import org.flowplayer.controls.Controlbar;
	import org.flowplayer.controls.controllers.AbstractWidgetController;
	import org.flowplayer.controls.controllers.AbstractButtonController;

	// This is really a consultation class
	// no setters here
	public dynamic class AbstractWidgetsProps {

		protected var _props:Object;
		protected var log:Log = new Log(this);
		
		public function AbstractWidgetsProps(styleProps:Object) {
			_props = styleProps || {};
		}
	
		protected function addWidgetsDefaults(propName:String, checkDownState:Boolean = false):void {
			log.error("Adding defaults for " + propName);
			var registeredControllers:Array = Controlbar.registeredControllers;
			for ( var i:int = 0; i < registeredControllers.length; i++ ) {
				var controllerClass:Class = registeredControllers[i];
				if ( controllerClass['DEFAULTS'] && controllerClass['DEFAULTS'][propName] != undefined) {
					addProperty(controllerClass['NAME'], controllerClass['DEFAULTS'][propName])
				}
				
				if ( checkDownState ) {
					if ( controllerClass['DOWN_DEFAULTS'] && controllerClass['DOWN_DEFAULTS'][propName] != undefined) {
						addProperty(controllerClass['DOWN_NAME'], controllerClass['DOWN_DEFAULTS'][propName])
					}
				}
			}
		}

		protected function addProperty(name:String, defaultValue:*):void {
			// take value from config or default
			log.error("adding "+ name + " = " + _props[name] + " || "+ defaultValue);
			
			this[name] = _props[name] == undefined ? defaultValue : _props[name];
		}


		// handy function for visibility and enabled
		protected function handleAll():void {
			
			if ( _props['all'] != undefined ) {
				var registeredControllers:Array = Controlbar.registeredControllers;
				for ( var i:int = 0; i < registeredControllers.length; i++ ) {
					if ( _props[registeredControllers[i]['NAME']] == undefined )
						_props[registeredControllers[i]['NAME']] = _props['all'];
				}
			}
			
			if ( _props['playlist'] != undefined ) {
				_props['next'] = _props['previous'] = _props['playlist'];
			}
		}		
	}
}
