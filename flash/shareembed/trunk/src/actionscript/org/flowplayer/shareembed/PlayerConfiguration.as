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
package org.flowplayer.shareembed {
    import com.adobe.serialization.json.JSON;

    import flash.display.Stage;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.util.URLUtil;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.StyleableSprite;

    public class PlayerConfiguration {
        private var _player:Flowplayer;
        private var _stage:Stage;
        private var _viralPluginConfiguredName:String;
        private var _config:Object;
        private var _height:Number;
        private var _width:Number;
        private var _controls:StyleableSprite;
        private var _controlsOriginalOptions:Object;
        private var _controlsModel:DisplayPluginModel;
        private var _controlsOptions:Object;

        public function PlayerConfiguration(player:Flowplayer, viralPluginConfiguredName:String, stage:Stage, config:Object) {
            _player = player;
            _viralPluginConfiguredName = viralPluginConfiguredName;
            _stage = stage;
            _config = config;
            initializeConfig();
            lookupControls();
        }

        private function createOptions():void {
            if (! _controlsOptions) {
                _controlsOptions = {};
            }
        }

        public function set backgroundColor(color:Number) {
            createOptions();
            _controlsOptions.backgroundColor = color;
            _controls.css(_controlsOptions);
        }

        public function get backgroundColor():Number {
            if (! _controlsOptions) return NaN;
            return _controlsOptions.backgroundColor;
        }

        public function set buttonColor(color:Number) {
            createOptions();
            _controlsOptions.buttonColor = color;
            _controls.css(_controlsOptions);
        }

        public function get buttonColor():Number {
            if (! _controlsOptions) return NaN;
            return _controlsOptions.buttonColor;
        }

        public function resetControls():Number {
            _controls.css(_controlsOriginalOptions);
        }

        private function lookupControls():void {
            var controlsModel:DisplayPluginModel = _player.pluginRegistry.getPlugin("controls") as DisplayPluginModel;
            if (! controlsModel) return;
            _controlsModel = controlsModel;
            _controls = controlsModel.getDisplayObject() as StyleableSprite;
            _controlsOriginalOptions = {};
            var props:Object = _controls.css();
            _controlsOriginalOptions = { backgroundColor: props.backgroundColor, buttonColor: props.buttonColor };
        }

        private function initializeConfig():void {
            //loop through the plugins and replace the plugin urls with absolute full domain urls
            for (var plugin:String in _config.plugins) {
                if (_config.plugins[plugin].url) {
                    var url:String = URLUtil.isCompleteURLWithProtocol(_config.plugins[plugin].url)
                            ? _config.plugins[plugin].url
                            : _config.plugins[plugin].url.substring(_config.plugins[plugin].url.lastIndexOf("/") + 1, _config.plugins[plugin].url.length);

                    _config.plugins[plugin].url = URLUtil.completeURL(_config.baseURL, url);
                }
            }


            _config.plugins[_viralPluginConfiguredName].emailScriptURL = null;
            _config.plugins[_viralPluginConfiguredName].emailScriptTokenURL = null;
            _config.plugins[_viralPluginConfiguredName].emailScriptToken = null;
            _config.playerId = null;
        }

        public function getEmbedCode():String {
            if (_controlsOptions) {
                new PropertyBinder(_config.plugins["controls"]).copyProperties(_controlsOptions);
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

        private function get width():Number {
            if (_width > 0) return _width;
            return _stage.width;
        }

        private function get height():Number {
            if (_height > 0) return _height;
            return _stage.height;
        }

        public function get controls():StyleableSprite {
            return _controls;
        }

        public function set height(value:Number):void {
            _height = value;
        }

        public function set width(value:Number):void {
            _width = value;
        }
    }
}