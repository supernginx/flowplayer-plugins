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

    public class PlayerEmbed {
        private var log:Log = new Log(this);
        private var _player:Flowplayer;
        private var _stage:Stage;
        private var _viralPluginConfiguredName:String;
        private var _config:Object;
        private var _height:int;
        private var _width:int;
        private var _controls:StyleableSprite;
        private var _controlsOriginalOptions:Object;
        private var _controlsModel:DisplayPluginModel;
        private var _controlsOptions:Object;
        private var _autoHide:Boolean;

        public function PlayerEmbed(player:Flowplayer, viralPluginConfiguredName:String, stage:Stage, configString:String) {
            _player = player;
            _viralPluginConfiguredName = viralPluginConfiguredName;
            _stage = stage;
            _config = JSON.decode(configString);
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
            log.debug("initializeConfig() " + _config);
            _config.plugins[_viralPluginConfiguredName].emailScriptURL = null;
            _config.plugins[_viralPluginConfiguredName].emailScriptTokenURL = null;
            _config.plugins[_viralPluginConfiguredName].emailScriptToken = null;
            _config.playerId = null;
        }

        public function getEmbedCode():String {
            log.debug("getEmbedCode() ", _controlsOptions);
            if (_controlsOptions) {
                if (! _config.plugins["controls"]) {
                    _config.plugins["controls"] = _controlsOptions;
                } else {
                    for (var prop:String in _controlsOptions) {
                        _config.plugins["controls"][prop] = _controlsOptions[prop];
                    }
                }
            }

            var playerSwf:String = URLUtil.completeURL(URLUtil.pageUrl, _player.config.playerSwfName);
            var configStr:String = JSON.encode(_config);

            var code:String =
                    '<object id="' + _player.id + '" width="' + width + '" height="' + height + '" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"> ' + "\n" +
                    '	<param value="true" name="allowfullscreen"/>' + "\n" +
                    '	<param value="always" name="allowscriptaccess"/>' + "\n" +
                    '	<param value="high" name="quality"/>' + "\n" +
                    '	<param value="true" name="cachebusting"/>' + "\n" +
                    '	<param value="#000000" name="bgcolor"/>' + "\n" +
                    '	<param name="movie" value="' + playerSwf + '" />' + "\n" +
                    '	<param value="config=' + configStr + '" name="flashvars"/>' + "\n" +
                    '	<embed src="' + playerSwf + '" type="application/x-shockwave-flash" width="' + width + '" height="' + height + '" allowfullscreen="true" allowscriptaccess="always" cachebusting="true" flashvars="config=' + configStr + '" bgcolor="#000000" quality="true"/>' + "\n" +
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