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
package org.flowplayer.shareembed.config {

    public class ShareConfig {
        private var _title:String;
        private var _body:String = "";
        private var _category:String = "";
        private var _popupOnClick:Boolean = true;

        private var _icons:Object = {
            facebook: [440,620],
            myspace: [650,1024],
            twitter: [650,1024],
            bebo: [436,626],
            orkut: [650,1024],
            digg: [650,1024],
            stumbleupon: [650,1024],
            livespaces: [650,1024]
        };

        public function get title():String {
            return _title;
        }

        public function set title(value:String):void {
            _title = value;
        }

        public function get icons():Object {
            return _icons;
        }

        public function set icons(value:Object):void {
            _icons = value;
        }

        public function get body():String {
            return _body;
        }

        public function set body(value:String):void {
            _body = value;
        }

        public function get category():String {
            return _category;
        }

        public function set category(value:String):void {
            _category = value;
        }

        public function get popupOnClick():Boolean {
            return _popupOnClick;
        }

        public function set popupOnClick(value:Boolean):void {
            _popupOnClick = value;
        }
    }

}