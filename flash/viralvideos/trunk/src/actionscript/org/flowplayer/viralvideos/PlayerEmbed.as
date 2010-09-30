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

    import flash.external.ExternalInterface;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.URLUtil;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.StyleableSprite;
    import org.flowplayer.viralvideos.config.Config;
    import org.flowplayer.viralvideos.config.EmbedConfig;

    import flash.utils.ByteArray;

    import org.flowplayer.viralvideos.config.ShareConfig;

    public class PlayerEmbed {
        private var log:Log = new Log(this);
        private var _player:Flowplayer;
        private var _stage:Stage;
        private var _viralPluginConfiguredName:String;
        private var _playerConfig:Object;
        private var _height:int;
        private var _width:int;
        private var _controls:StyleableSprite;
        private var _controlsOriginalOptions:Object;
        private var _controlsModel:DisplayPluginModel;
        private var _controlsOptions:Object;
        private var _autoHide:Boolean;
        private var _viralConfig:Config;

        public function PlayerEmbed(player:Flowplayer, viralPluginConfiguredName:String, stage:Stage, viralConfig:Config) {
            _player = player;
            _viralPluginConfiguredName = viralPluginConfiguredName;
            _stage = stage;
            _viralConfig = viralConfig;
            initializeConfig(stage);
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
            log.debug("lookupControls() ");
            var controlsModel:DisplayPluginModel = _player.pluginRegistry.getPlugin("controls") as DisplayPluginModel;
            if (! controlsModel) return;
            log.debug("lookupControls() " + controlsModel + ", disp " + controlsModel.getDisplayObject());
            _controlsModel = controlsModel;
            _controls = controlsModel.getDisplayObject() as StyleableSprite;
            _controlsOriginalOptions = {};
            var props:Object = _controls.css();
            _controlsOriginalOptions = { backgroundColor: props.backgroundColor, buttonColor: props.buttonColor, buttonOverColor: props.buttonOverColor };
            _autoHide = controls["getAutoHide"]()["state"] == "always";
        }

        private function initializeConfig(stage:Stage):void {
            var configObj:* = stage.loaderInfo.parameters["config"];

            if (configObj && String(configObj).indexOf("{") > 0 && ! configObj.hasOwnProperty("url")) {
                // a regular configuration object
                _playerConfig = JSON.decode(configObj);

            } else {
                // had an external config file configured using 'url', use the loaded config object
                //_playerConfig = _player.config.configObject;
                _playerConfig = _player.config.configObject;
            }

            log.debug("initializeConfig() ", _playerConfig);
        }

        private function fixPluginsURL(config:Object):void {
            for (var pluginName:String in config.plugins) {
                var pluginModel:Object = _player.pluginRegistry.getPlugin(pluginName);
                var plugin:Object = pluginModel.pluginObject;
                if (! pluginModel.isBuiltIn && plugin.hasOwnProperty("loaderInfo")) {
                    var pluginUrl:String = plugin ? plugin.loaderInfo.url : "";
                    if (pluginUrl) {
                        config.plugins[pluginName]["url"] = pluginUrl;
                    }
                } else if (pluginModel.isBuiltIn) {
                    delete config.plugins[pluginName]["url"];
                }
            }
        }

        private function fixShareUrl(updatedConfig:Object):void {
            log.debug("fixShareUrl(), viral enabled? " + Boolean(_viralConfig.share));
            if (! _viralConfig.share) return;

            var viralConfig:Object = updatedConfig.plugins[_viralPluginConfiguredName];
            if (! viralConfig.hasOwnProperty("share")) {
                viralConfig.share = {};
            }
            if (! viralConfig.share.shareUrl) {
                viralConfig.share.shareUrl = URLUtil.pageUrl;
            }
        }

        private function updateConfig(_playerConfig:Object):Object {
            _playerConfig.plugins[_viralPluginConfiguredName].emailScriptURL = null;
            _playerConfig.plugins[_viralPluginConfiguredName].emailScriptTokenURL = null;
            _playerConfig.plugins[_viralPluginConfiguredName].emailScriptToken = null;
            _playerConfig.playerId = null;

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

            fixPluginsURL(updatedConfig);
            fixShareUrl(updatedConfig);

            var clip:Object = updatedConfig.clip || {};
            clip.autoPlay = _viralConfig.embed.isAutoPlayOverriden ? _viralConfig.embed.autoPlay : clip.autoPlay;
            clip.autoBuffering = _viralConfig.embed.isAutoBufferingOverriden ? _viralConfig.embed.autoBuffering : clip.autoBuffering;
            clip.linkUrl = _viralConfig.embed.linkUrl ? _viralConfig.embed.linkUrl : clip.linkUrl;
            updatedConfig.clip = clip;

            var playlist:Array = updatedConfig.playlist || [];
            if (playlist.length == 0)
                playlist.push(clip);

            if (_viralConfig.shareCurrentPlaylistItem) {
                playlist.splice(_player.currentClip.index - 1, 1);
                playlist.unshift(_player.currentClip);
            }

            if (_viralConfig.embed.isAutoPlayOverriden)
                playlist[0].autoPlay = _viralConfig.embed.autoPlay;

            if (_viralConfig.embed.isAutoBufferingOverriden)
                playlist[0].autoBuffering = _viralConfig.embed.autoBuffering;

            updatedConfig.playlist = playlist;

            return updatedConfig;
        }

        public function getEmbedCode(escaped:Boolean = false):String {
            var configStr:String = _viralConfig.embed.configUrl;
            if (! configStr) {
                var conf:Object = updateConfig(_playerConfig);
                configStr = escaped ? escape(JSON.encode(conf)) : JSON.encode(conf);
            }

            var code:String =
                    '<object id="' + _player.id + '" width="' + width + '" height="' + height + '" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"> ' + "\n" +
                            '    <param value="true" name="allowfullscreen"/>' + "\n" +
                            '    <param value="always" name="allowscriptaccess"/>' + "\n" +
                            '    <param value="high" name="quality"/>' + "\n" +
                            '    <param value="true" name="cachebusting"/>' + "\n" +
                            '    <param value="#000000" name="bgcolor"/>' + "\n" +
                            '    <param name="movie" value="' + _player.config.playerSwfUrl + '" />' + "\n" +
                            '    <param value="config=' + configStr + '" name="flashvars"/>' + "\n" +
                            '    <embed src="' + _player.config.playerSwfUrl + '" type="application/x-shockwave-flash" width="' + width + '" height="' + height + '" allowfullscreen="true" allowscriptaccess="always" cachebusting="true" flashvars="config=' + configStr + '" bgcolor="#000000" quality="true">' + "\n";

            if (_viralConfig.embed.fallbackUrls.length > 0) {
                code += '     <video controls width="' + width + '" height="' + height + '"';
                if (_viralConfig.embed.fallbackPoster != null) {
                    code += ' poster="' + _viralConfig.embed.fallbackPoster + '" ';
                }
                code += '>' + "\n";
                for (var i:uint = 0; i < _viralConfig.embed.fallbackUrls.length; i++) {
                    code += '<source src="' + _viralConfig.embed.fallbackUrls[i] + '" />';
                }
            }

            code += '      <a href="' + _viralConfig.embed.linkUrl + '" target="_blank">' + _viralConfig.embed.anchorText + '</a>' + "\n";

            if (_viralConfig.embed.fallbackUrls.length > 0) {
                code += '     </video>' + "\n";
            }

            code += '    </embed>' + "\n" +
                    '</object>';
            return code;
        }

        public function get width():int {
            if (_width > 0) return _width;
            return _stage.stageWidth;
        }

        public function get height():int {
            if (_height > 0) return _height;
            return _stage.stageHeight;
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