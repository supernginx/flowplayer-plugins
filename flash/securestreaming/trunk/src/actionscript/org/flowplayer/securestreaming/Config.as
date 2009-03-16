/*
 *    Copyright 2009 Flowplayer Oy
 *
 *    author: Anssi Piirainen, api@iki.fi, Flowplayer Oy
 *
 *    This file is part of FlowPlayer.
 *
 *    FlowPlayer is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    FlowPlayer is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with FlowPlayer.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.flowplayer.securestreaming {

    public class Config {
        private var _timestamp:String;
        private var _timestampUrl:String;
        private var _token:String;

        public function get timestampUrl():String {
            return _timestampUrl;
        }

        public function set timestampUrl(val:String):void {
            _timestampUrl = val;
        }

        public function toString():String {
            return "[Config] timestampUrl = '" + _timestampUrl + "'";
        }

        public function get token():String {
            return _token;
        }

        public function set token(val:String):void {
            _token = val;
        }

        public function get timestamp():String {
            return _timestamp;
        }

        public function set timestamp(val:String):void {
            _timestamp = val;
        }
    }
}