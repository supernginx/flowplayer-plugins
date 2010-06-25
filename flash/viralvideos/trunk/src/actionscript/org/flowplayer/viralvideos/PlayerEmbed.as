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
package org.flowplayer.viralvideos {
    import com.adobe.serialization.json.JSON;

    import flash.display.Stage;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.URLUtil;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.StyleableSprite;
	import org.flowplayer.viralvideos.config.EmbedConfig;
	
	import flash.utils.ByteArray;

    public class PlayerEmbed {
        private var log:Log = new Log(this);
        private var _player:Flowplayer;
        private var _stage:Stage;
        private var _viralPluginConfiguredName:String;
		private var _config:EmbedConfig;
        private var _playerConfig:Object;
        private var _height:int;
        private var _width:int;
        private var _controls:StyleableSprite;
        private var _controlsOriginalOptions:Object;
        private var _controlsModel:DisplayPluginModel;
        private var _controlsOptions:Object;
        private var _autoHide:Boolean;

        public function PlayerEmbed(player:Flowplayer, viralPluginConfiguredName:String, stage:Stage, config:EmbedConfig) {
            _player = player;
            _viralPluginConfiguredName = viralPluginConfiguredName;
            _stage = stage;
            _playerConfig = JSON.decode(stage.loaderInfo.parameters["config"]);
			_config = config;
			
            initializeConfig();
            lookupControls();
        }

        private function createOptions():void {
            if (! _controlsOptions) {
                _controlsOptions = {};
            }
        }

        public function set backgroundColor(color:String):void {
            log.debug("set backgroundColor " + color);
            createOptions();
            _controlsOptions.backgroundColor = color;
            _controls.css(_controlsOptions);
        }

        public function get backgroundColor():String {
            if (! _controlsOptions) return null;
            return _controlsOptions.backgroundColor;
        }

        public function set buttonColor(color:String):void {
            log.debug("set buttonColor " + color);
            createOptions();
            _controlsOptions.buttonColor = color;
            _controlsOptions.buttonOverColor = color;
            _controls.css(_controlsOptions);
        }

        public function get buttonColor():String {
            if (! _controlsOptions) return null;
            return _controlsOptions.buttonColor;
        }

        public function applyControlsOptions(value:Boolean = true):void {
            _controls.css(value ? _controlsOptions : _controlsOriginalOptions);
            if (_autoHide) {
                _controls["setAutoHide"](! value);
            }
        }

        private function lookupControls():void {
            var controlsModel:DisplayPluginModel = _player.pluginRegistry.getPlugin("controls") as DisplayPluginModel;
            if (! controlsModel) return;
            _controlsModel = controlsModel;
            _controls = controlsModel.getDisplayObject() as StyleableSprite;
            _controlsOriginalOptions = {};
            var props:Object = _controls.css();
            _controlsOriginalOptions = { backgroundColor: props.backgroundColor, buttonColor: props.buttonColor, buttonOverColor: props.buttonOverColor };
            _autoHide = controls["getAutoHide"]()["state"] == "always";
        }

        private function initializeConfig():void {
            log.debug("initializeConfig() " + _playerConfig);
            _playerConfig.plugins[_viralPluginConfiguredName].emailScriptURL = null;
            _playerConfig.plugins[_viralPluginConfiguredName].emailScriptTokenURL = null;
            _playerConfig.plugins[_viralPluginConfiguredName].emailScriptToken = null;
            _playerConfig.playerId = null;
        }
		
		private function fixPluginsURL(config:Object):Object {			
			for ( var pluginName:String in config.plugins ) {
				var plugin:Object = _player.pluginRegistry.getPlugin(pluginName).pluginObject;
                if (plugin.hasOwnProperty("loaderInfo")) {
                    var pluginUrl:String = plugin ? plugin.loaderInfo.url : "";
                    if ( pluginUrl ) {
                        config.plugins[pluginName]["url"] = pluginUrl;
                    }
                }
			}
			
			return config;
		}
		
		private function updateConfig(_playerConfig:Object):Object {
			var copier:ByteArray = new ByteArray();
			copier.writeObject(_playerConfig);
			copier.position = 0;
			var updatedConfig:Object = (copier.readObject());
			
			
			if (_controlsOptions) {
                if (! updatedConfig.plugins["controls"]) {
                    updatedConfig.plugins["controls"] = _controlsOptions;
                } else {
                    for (var prop:String in _controlsOptions) {
                        updatedConfig.plugins["controls"][prop] = _controlsOptions[prop];
                    }
                }
            }
			
			updatedConfig = fixPluginsURL(updatedConfig);
						
			var clip:Object = updatedConfig.clip || {};
			clip.autoPlay = _config.isAutoPlayOverriden ? _config.autoPlay : clip.autoPlay;
			clip.autoBuffering = _config.isAutoBufferingOverriden ? _config.autoBuffering : clip.autoBuffering;
			clip.linkUrl = _config.linkUrl ? _config.linkUrl : clip.linkUrl;
			updatedConfig.clip = clip;
			
			var playlist:Array = updatedConfig.playlist || [];
			if ( playlist.length == 0 )
				playlist.push(clip);
				
			if ( _config.isAutoPlayOverriden )
				playlist[0].autoPlay = _config.autoPlay;
				
			if ( _config.isAutoBufferingOverriden )
				playlist[0].autoBuffering = _config.autoBuffering;
				
			if ( _config.prerollUrl )
				playlist.splice(0, 0, {url: _config.prerollUrl});
			
			if ( _config.postrollUrl )
				playlist.push({url: _config.postrollUrl });
				
			updatedConfig.playlist = playlist;
						
			return updatedConfig;
		}
		
        public function getEmbedCode():String {
            var configStr:String = _config.configUrl;
			if ( ! configStr ) {
				var conf:Object = updateConfig(_playerConfig);
             	configStr = escape(JSON.encode(conf));
			}
			
            var code:String =
                    '<object id="' + _player.id + '" width="' + width + '" height="' + height + '" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"> ' + "\n" +
                    '	<param value="true" name="allowfullscreen"/>' + "\n" +
                    '	<param value="always" name="allowscriptaccess"/>' + "\n" +
                    '	<param value="high" name="quality"/>' + "\n" +
                    '	<param value="true" name="cachebusting"/>' + "\n" +
                    '	<param value="#000000" name="bgcolor"/>' + "\n" +
                    '	<param name="movie" value="' + _player.config.playerSwfUrl + '" />' + "\n" +
                    '	<param value="config=' + configStr + '" name="flashvars"/>' + "\n" +
                    '	<embed src="' + _player.config.playerSwfUrl + '" type="application/x-shockwave-flash" width="' + width + '" height="' + height + '" allowfullscreen="true" allowscriptaccess="always" cachebusting="true" flashvars="config=' + configStr + '" bgcolor="#000000" quality="true"/>' + "\n" +
                    '</object>';


            return code;
        }

        public function get width():int {
            if (_width > 0) return _width;
            return _stage.width;
        }

        public function get height():int {
            if (_height > 0) return _height;
            return _stage.height;
        }

        public function get controls():StyleableSprite {
            return _controls;
        }

        public function set height(value:int):void {
            log.debug("set height " + value);
            _height = value;
        }

        public function set width(value:int):void {
            log.debug("set width " + value);
            _width = value;
        }
    }
}