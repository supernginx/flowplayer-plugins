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
    import flash.display.Sprite;

    import org.flowplayer.view.AbstractSprite;

    public class MenuItemFace extends AbstractSprite {
        private var _bg:Sprite;

        public function MenuItemFace() {
            createChildren();
        }

        private function createChildren():void {
            _bg = new Sprite();
            _bg.name = "mOver";
            redrawFill();
            addChild(_bg);
        }

        private function redrawFill():void {
            _bg.graphics.clear();
            _bg.graphics.beginFill(0, 1);
            _bg.graphics.drawRoundRect(0, 0, width, height, 0, 0);
            _bg.graphics.endFill();
        }

        override protected function onResize():void {
            redrawFill();
        }
    }
}