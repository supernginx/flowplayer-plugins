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
    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.StyleableSprite;

    public class StyleableView extends StyleableSprite {
        private var _model:DisplayPluginModel;
        private var _player:Flowplayer;

        public function StyleableView(styleName:String, plugin:DisplayPluginModel, player:Flowplayer, style:Object) {
            super(styleName, player, player.createLoader());
            rootStyle = style;
            css(style);
            _player = player;
            _model = plugin;
        }

        protected function get model():DisplayPluginModel {
            return _model;
        }

        protected function get player():Flowplayer {
            return _player;
        }
    }

}