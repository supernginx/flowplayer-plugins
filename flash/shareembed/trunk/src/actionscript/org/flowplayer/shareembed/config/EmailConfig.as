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

    public class EmailConfig {
        private var _script:String;
        private var _tokenUrl:String;
        private var _token:String;
        private var _subject:String = "Video you might be interested in";
        private var _template:String = "{0} \n\n Video Link: <a href=\"{1}\">{2}</a>";
        private var _required:Array = ["name","email","to","message","subject"];
        private var _title:String = "Email this video";

        public function get script():String {
            return _script;
        }

        public function set script(value:String):void {
            _script = value;
        }

        public function get tokenUrl():String {
            return _tokenUrl;
        }

        public function set tokenUrl(value:String):void {
            _tokenUrl = value;
        }

        public function get token():String {
            return _token;
        }

        public function set token(value:String):void {
            _token = value;
        }

        public function get subject():String {
            return _subject;
        }

        public function set subject(value:String):void {
            _subject = value;
        }

        public function get template():String {
            return _template;
        }

        public function set template(value:String):void {
            _template = value;
        }

        public function get required():Array {
            return _required;
        }

        public function set required(value:Array):void {
            _required = value;
        }

        public function get title():String {
            return _title;
        }

        public function set title(value:String):void {
            _title = value;
        }
    }

}