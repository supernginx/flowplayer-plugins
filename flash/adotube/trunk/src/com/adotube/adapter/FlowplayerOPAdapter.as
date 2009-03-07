/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2009 AdoTube
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
	 package com.adotube.adapter {
 	import flash.system.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.display.*;
	import flash.utils.*;
 		
	import org.flowplayer.model.*;
	import org.flowplayer.util.Arrange;
	import org.flowplayer.view.*;

	public class FlowplayerOPAdapter extends StyleableSprite implements Plugin {

		static private var Config_AS3OverstreamPlatformAdapterURL = 'adotube_AS3OverstreamPlatformAdapterURL';
		static private var Config_overstreamPlatformURL = 'adotube_overstreamPlatformURL';
		static private var Config_omlSource= 'adotube_omlSource';
		
		private var model:PluginModel;
		private var pluginLoader:Loader;
		private var AS3OverstreamPlatformAdapterURL:String;
		private var overstreamPlatformURL:String;
		private var omlSource:String;
		public var plugin:MovieClip;
		public var player:Flowplayer;
		
		var opWrapper:OPWrapper;
		
		public function FlowplayerOPAdapter() {}
		
		
		protected function loadAdotubePlugin():void {
			var config:Object = model.config;
			if (config[Config_AS3OverstreamPlatformAdapterURL]){
				AS3OverstreamPlatformAdapterURL = config[Config_AS3OverstreamPlatformAdapterURL];
			} else {
				AS3OverstreamPlatformAdapterURL = 'http://chibis.adotube.com/adapters/AS3OverstreamPlatformAdapter.swf';
			}
			if (config[Config_overstreamPlatformURL]){
				overstreamPlatformURL = config[Config_overstreamPlatformURL];
			} else {
				overstreamPlatformURL = 'http://chibis.adotube.com/overstreamPlatform/OverstreamPlatform.swf';
			}
			if (config[Config_omlSource]){
				omlSource = config[Config_omlSource];
			} else {
				trace("[Warning] No placements will be displayed in the Adotube placement until provided with a valid omlSource. support@adotube.com ");
			}
			
			Security.allowDomain("*");
			var fullPluginURL:String = AS3OverstreamPlatformAdapterURL+
												'?overstreamPlatformURL='+escape(overstreamPlatformURL)+
												'&omlSource='+escape(omlSource);
			var req:URLRequest = new URLRequest(fullPluginURL);
			pluginLoader = new Loader();
			addChild(pluginLoader);
			pluginLoader.contentLoaderInfo.addEventListener(Event.INIT, onPluginLoaded);
			pluginLoader.load(req);									
		}


		function onPluginLoaded(e:Event):void {
			var config:Object = model.config;
			var _Adotube_Publisher_Dynamic_Vars:String;
			var _OR_Publisher_Post_Vars:String;
			var pdvPrefix:String = "pdv_";
			var pudPrefix:String = "pud_";
			plugin = MovieClip(pluginLoader.content);
			
			//create the Publisher Dynamic Vars Object and send it to the plugin
			//////
			_Adotube_Publisher_Dynamic_Vars = '<PostVariables>';
			_OR_Publisher_Post_Vars = '<PostVariables>';
			for (var i in config) {
				if (String(i).substr(0,pdvPrefix.length)==pdvPrefix) {
					_Adotube_Publisher_Dynamic_Vars += '<PostVariable name="'+String(i).substr(pdvPrefix.length)+'" value="'+config[i]+'" />';
				} else if (String(i).substr(0,pudPrefix.length)==pudPrefix) {
					_OR_Publisher_Post_Vars +='<PostVariable name="'+String(i).substr(pudPrefix.length)+'" value="'+config[i]+'" />';
				}
			}
			_Adotube_Publisher_Dynamic_Vars += '</PostVariables>';
			_OR_Publisher_Post_Vars += '</PostVariables>';
			if (_Adotube_Publisher_Dynamic_Vars) {
				plugin.initVars._Adotube_Publisher_Dynamic_Vars	=_Adotube_Publisher_Dynamic_Vars;
			}
			if (_OR_Publisher_Post_Vars) {
				plugin.initVars._OR_Publisher_Post_Vars = _OR_Publisher_Post_Vars;
			}
			
			///initialize the plugin
			initOnPlayerAndPlugin();
		}

		/*
		 * We must have both "player" and "plugin" in order to proceed with initialization. Plugin is available after it loads,
		 * player is available after it finishes initializing. These two events occur asynchronously, when each one is loaded
		 * this method is called and we check if we are ready to initialize. 
		 */
		function initOnPlayerAndPlugin():void {
			if (player && plugin) {
				trace("Both player and plugin loaded, proceeding with plugin initialization.");

				opWrapper = new OPWrapper(player, model, plugin);
				// Add the opWrapper to this Flowplayer plugin. This class will be added
				// to the display hierarchy after model.dispatchOnLoad() is called 
				this.addChild(opWrapper);
				onResize();
				// dispatch onLoad so that the player knows this plugin is initialized
				// Note: After this is called, this class is addChilded, to the Panel display object,
				// and its parent changes from Loader to Panel
				model.dispatchOnLoad();	
			}
		}

		/**
		 * Arranges the child display objects. Called by superclass when the size of this sprite changes. 
		 */
		override protected function onResize():void {
			if (width && height) {
				super.onResize();
				var controls_plugin:Object = DisplayPluginModel(player.pluginRegistry.getPlugin("controls"));
        	    var controls_height:Number = controls_plugin ? (controls_plugin.heightPx) : (0);
				if (opWrapper) {
					opWrapper.onResize(width, height-Number(controls_height));
				} else {
					trace("[INFO] onResize called before opWrapper is available.");	
				}
			}
		}
		
	    /* 
	        This should return the default configuration to be used for this plugin. 
	        Where it is placed and what are it's dimensions if they are not  
	        explicitly specified by the user. 
	    */ 
		public function getDefaultConfig():Object {
			return { top: 0, left: 0, width: '100%', height: '100%', backgroundColor: '#FFFFFF', opacity: 1, borderRadius: 0, backgroundGradient: 'high' };
		}
		 
	    /* 
	        This is invoked when the plugin is loaded. PluginModel gives you access  
	        to display properties and other configuration. You will also use it to  
	        dispatch events to outside world. 
	    */ 		
    	public function onConfig(model:PluginModel):void {
			this.model = model;
			// start loading the Adotube Overstream Platform
			loadAdotubePlugin();
		}
		
	    /* 
	        This is invoked when all plugins have been loaded and the player  
	        initialization is complete. Flowplayer API is supplied as the argument. 
	    */
		public function onLoad(player:Flowplayer):void {
			this.player = player;
			// initilizing the plugin
			initOnPlayerAndPlugin();
		}		
	}
}
