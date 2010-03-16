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
package org.flowplayer.shareembed.icons {
    import flash.display.DisplayObjectContainer;
    import flash.text.TextField;

    import org.flowplayer.ui.AbstractButton;
    import org.flowplayer.ui.ButtonConfig;
    import org.flowplayer.util.Arrange;
    import org.flowplayer.util.TextUtil;
    import org.flowplayer.view.AnimationEngine;

    public class AbstractIcon extends AbstractButton {
        private var _labelText:String;
        private var _label:TextField;

        public function AbstractIcon(config:ButtonConfig, animationEngine:AnimationEngine, label:String) {
            _labelText = label;
            super(config, animationEngine);
        }

        override protected function onResize():void {
            face.width = width;
            face.height = width;

            _label.y = face.height;
            _label.width = _label.textWidth + 5;
            log.debug("label arranged to Y pos " + _label.y);
            Arrange.center(_label, width);
        }

        override protected final function createFace():DisplayObjectContainer {
            var icon:DisplayObjectContainer = createIcon();
            addChild(icon);
            createLabel(icon, _labelText);
            return icon;
        }

        protected function createIcon():DisplayObjectContainer {
            return null;
        }

        private function createLabel(icon:DisplayObjectContainer, label:String):void {
            _label = TextUtil.createTextField(false);
            _label.text = label;
            _label.height = 20;
            addChild(_label);

            _label.y = icon.height;
        }
//
//        public function get contentWidth():Number {
//            return face.width;
//        }
//
//        public function get contentHeight():Number {
//            return face.height;
//        }
    }
}