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
package org.flowplayer.viralvideos.config {
    import org.flowplayer.ui.ButtonConfig;
    import org.flowplayer.util.PropertyBinder;

    public class ShareConfig {
        private var _title:String = "Click on an icon to share this video";
        private var _description:String = "A cool video";
        private var _body:String = "";
        private var _category:String = "";
        private var _popupOnClick:Boolean = true;

        private var _facebook:Boolean = true;
        private var _twitter:Boolean = true;
        private var _myspace:Boolean = true;
        private var _livespaces:Boolean = true;
        private var _digg:Boolean = true;
        private var _orkut:Boolean = true;
        private var _stubmbleupon:Boolean = true;
        private var _bebo:Boolean = true;
        private var _icons:ButtonConfig;

        private var _popupDimensions:Object = {
            facebook: [440,620],
            myspace: [650,1024],
            twitter: [650,1024],
            bebo: [436,626],
            orkut: [650,1024],
            digg: [650,1024],
            stumbleupon: [650,1024],
            livespaces: [650,1024]
        };

        public function get icons():ButtonConfig {
            if (! _icons) {
                _icons = new ButtonConfig();
                _icons.setColor("rgba(20,20,20,0.5)");
                _icons.setOverColor("rgba(0,0,0,1)");
            }
            return _icons;
        }

        public function setIcons(config:Object):void {
            new PropertyBinder(icons).copyProperties(config);
        }

        public function get title():String {
            return _title;
        }

        public function set title(value:String):void {
            _title = value;
        }

        public function get popupDimensions():Object {
            return _popupDimensions;
        }

        public function set popupDimensions(value:Object):void {
            _popupDimensions = value;
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

        public function get facebook():Boolean {
            return _facebook;
        }

        public function set facebook(value:Boolean):void {
            _facebook = value;
        }

        public function get twitter():Boolean {
            return _twitter;
        }

        public function set twitter(value:Boolean):void {
            _twitter = value;
        }

        public function get myspace():Boolean {
            return _myspace;
        }

        public function set myspace(value:Boolean):void {
            _myspace = value;
        }

        public function get livespaces():Boolean {
            return _livespaces;
        }

        public function set livespaces(value:Boolean):void {
            _livespaces = value;
        }

        public function get digg():Boolean {
            return _digg;
        }

        public function set digg(value:Boolean):void {
            _digg = value;
        }

        public function get orkut():Boolean {
            return _orkut;
        }

        public function set orkut(value:Boolean):void {
            _orkut = value;
        }

        public function get stubmbleupon():Boolean {
            return _stubmbleupon;
        }

        public function set stubmbleupon(value:Boolean):void {
            _stubmbleupon = value;
        }

        public function get bebo():Boolean {
            return _bebo;
        }

        public function set bebo(value:Boolean):void {
            _bebo = value;
        }

        public function get description():String {
            return _description;
        }

        public function set description(value:String):void {
            _description = value;
        }
    }

}