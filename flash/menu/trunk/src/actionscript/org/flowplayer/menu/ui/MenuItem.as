/*    
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2010 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.menu.ui {
    import flash.display.BlendMode;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFieldType;
    import flash.text.TextFormatAlign;

    import fp.TickMark;

    import org.flowplayer.controller.ResourceLoader;

    import org.flowplayer.menu.*;
    import org.flowplayer.ui.buttons.AbstractButton;
    import org.flowplayer.util.Arrange;
    import org.flowplayer.util.GraphicsUtil;
    import org.flowplayer.util.TextUtil;
    import org.flowplayer.view.AnimationEngine;

    public class MenuItem extends AbstractButton {
        private var _text:TextField;
        private var _tickMark:DisplayObject;
        private var _roundedTop:Boolean;
        private var _roundedBottom:Boolean;
        private var _mask:Sprite;
        private var _loader:ResourceLoader;
        private var _image:DisplayObject;

        public function MenuItem(loader:ResourceLoader, config:ItemConfig, animationEngine:AnimationEngine, roundedTop:Boolean = false) {
            _loader = loader;
            _roundedTop = roundedTop;
            super(config, animationEngine);
        }

        public function set roundBottom(enable:Boolean):void {
            _roundedBottom = enable;
            redrawMask();
        }

        override protected function onClicked(event:MouseEvent):void {
            if (! itemConfig.toggle) return;
            if (_tickMark.parent) {
                removeChild(_tickMark);
            } else {
                addChild(_tickMark);
            }
        }

        public function set selected(selected:Boolean):void {
//            if (! _tickMark) return;
            if (selected && ! _tickMark.parent) {
                addChild(_tickMark);
            } else if (_tickMark.parent) {
                removeChild(_tickMark);
            }
        }

        public function get selected():Boolean {
            return _tickMark.parent != null;
        }

        override protected function createFace():DisplayObjectContainer {
            return new MenuItemFace();
        }

        override protected function childrenCreated():void {
            if (itemConfig.toggle) {
                _tickMark = new TickMark();
                if (itemConfig.selected) {
                    addChild(_tickMark);
                }
            }
            _text = addChild(TextUtil.createTextField(false, null, 12, true)) as TextField;
            _text.selectable = false;
            _text.type = TextFieldType.DYNAMIC;
            _text.textColor = config.fontColor;
            _text.blendMode = BlendMode.LAYER;
            _text.autoSize = TextFieldAutoSize.CENTER;
            _text.wordWrap = true;
            _text.multiline = true;
            _text.antiAliasType = AntiAliasType.ADVANCED;
            _text.condenseWhite = true;
            _text.defaultTextFormat.bold = false;

            _text.htmlText = itemConfig.label;
            addChild(_text);

            if (config.imageUrl) {
                loadImage();
            }
        }

        private function loadImage():void {
            _loader.addBinaryResourceUrl(config.imageUrl);
            _loader.load(null, function(loader:ResourceLoader):void {
                log.debug("image loaded from " + config.imageUrl);
                _image = addChild(loader.getContent() as DisplayObject) as DisplayObject;
                onResize();
            });
        }

        private function addMask():void {
            log.debug("addMask()");
            _mask = addChild(new Sprite()) as Sprite;
            _mask.blendMode = BlendMode.ERASE;
        }

        override protected function onResize():void {
            log.debug("onResize() " + width + " x " + height);
            face.width = width;
            face.height = height;
            _text.width = _text.textWidth + 10;
            _text.height = _text.textHeight + 6;

            if (_image) {
                _image.x = 10;
                _image.y = 5;
                _image.height = height - 10;
                _image.scaleX = _image.scaleY;
            }

            if (itemConfig.toggle) {
                _tickMark.height = 12;
                _tickMark.scaleX = _tickMark.scaleY;
                Arrange.center(_tickMark, 0, height);
                _tickMark.y = _tickMark.y - 2; // adjust it a bit
                _tickMark.x = _image ? (_image.x + _image.width) : 10;
                _text.x = _tickMark.x + _tickMark.width + 7;
                Arrange.center(_text, 0, height);
            } else {

                _text.x = _image ? (_image.x + _image.width + 10) : 10;
                Arrange.center(_text,  0, height);
//                Arrange.center(_text, _image ? (width - _image.x - _image.width) : width, height);
            }

            redrawMask();
        }

        private function redrawMask():void {
            if (maskNeeded && ! _mask) {
                addMask();
            }
            if (! maskNeeded) {
                if (_mask) {
                    log.debug("removing mask");
                    removeChild(_mask);
                    mask = _mask = null;
                }
                return;
            }

            var graf:Graphics = _mask.graphics;
            graf.clear();
            graf.beginFill(0, 1);

            if (_roundedTop) {
                // top left corner
                graf.moveTo(0, 0);
                graf.lineTo(5, 0);
                graf.curveTo(0, 0, 0, 5);
                graf.lineTo(0, 0);

                // top right corner
                graf.moveTo(width - 5, 0);
                graf.lineTo(width, 0);
                graf.lineTo(width, 5);
                graf.curveTo(width, 0, width - 5, 0);
            }
            if (_roundedBottom) {
                // bottom left
                graf.moveTo(0, height-5);
                graf.lineTo(0, height);
                graf.lineTo(5, height);
                graf.curveTo(0, height, 0, height-5);

                // bottom right
                graf.moveTo(width-5, height);
                graf.lineTo(width, height);
                graf.lineTo(width, height-5);
                graf.curveTo(width, height, width-5, height);
            }
            graf.endFill();
        }

        private function get maskNeeded():Boolean {
            return _roundedTop || _roundedBottom;
        }

        override protected function doEnable(enabled:Boolean):void {
            _text.textColor = enabled ? config.fontColor: config.disabledColor;
            _text.alpha = enabled ? config.fontAlpha : config.disabledAlpha;
            if (_tickMark) {
                GraphicsUtil.transformColor(_tickMark, enabled ? config.fontColorRGBA : config.disabledRGBA);
            }
        }

        override protected function get disabledDisplayObject():DisplayObject {
            return null;
        }

        private function get itemConfig():ItemConfig {return _config as ItemConfig;}

    }
}