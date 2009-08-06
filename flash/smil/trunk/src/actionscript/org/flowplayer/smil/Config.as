/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, Flowplayer Oy
 * Copyright (c) 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.smil {
    public class Config {
        private var _proxyType:String = "best";
        private var _netConnectionUrl:String;

        public function get proxyType():String {
            return _proxyType;
        }

        public function set proxyType(value:String):void {
            _proxyType = value;
        }

        public function get netConnectionUrl():String {
            return _netConnectionUrl;
        }

        public function set netConnectionUrl(value:String):void {
            _netConnectionUrl = value;
        }
    }
}