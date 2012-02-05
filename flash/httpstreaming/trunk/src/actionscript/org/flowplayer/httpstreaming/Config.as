/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi <electroteque@gmail.com>, Anssi Piirainen <api@iki.fi> Flowplayer Oy
 * Copyright (c) 2009, 2010 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.httpstreaming {

    public class Config {
        
        private var _dvrBufferTime:int = 4;
        private var _liveBufferTime:int = 2;
        private var _dvrSnapToLiveClockOffset:int = 4;
        private var _startLivePosition:Boolean = true;

        
        public function set dvrBufferTime(value:int):void
        {
            _dvrBufferTime = value;
        }

        public function get dvrBufferTime():int
        {
            return _dvrBufferTime;
        }

        public function set liveBufferTime(value:int):void
        {
            _liveBufferTime = value;
        }

        public function get liveBufferTime():int
        {
            return _liveBufferTime;
        }

        public function set dvrSnapToLiveClockOffset(value:int):void
        {
            _dvrSnapToLiveClockOffset = value;
        }

        public function get dvrSnapToLiveClockOffset():int
        {
            return _dvrSnapToLiveClockOffset;
        }

        public function set startLivePosition(value:Boolean):void
        {
            _startLivePosition = value;
        }

        public function get startLivePosition():Boolean
        {
            return _startLivePosition;
        }
        
    }
}
