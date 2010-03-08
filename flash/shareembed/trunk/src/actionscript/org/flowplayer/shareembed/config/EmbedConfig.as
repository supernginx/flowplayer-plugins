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
    public class EmbedConfig {
        private var _title:String = "Copy and paste the code below to your web page.";
        
        public function get title():String {
            return _title;
        }

        public function set title(value:String):void {
            _title = value;
        }
    }
}