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
package org.flowplayer.analytics {

    public class Events {
        private var _start:String = "Start";
        private var _stop:String = "Stop";
        private var _finish:String = "Stop";
        private var _unload:String = "Stop";

        private var _pause:String = "Pause";
        private var _resume:String = "Resume";
        private var _seek:String = "Seek";
        private var _mute:String = "Mute";
        private var _unmute:String = "Unmute";
        private var _fullscreen:String = "Full Screen";
        private var _fullscreenExit:String = "Full Screen Exit";

        private var _all:Boolean = false;

        public function get start():String {
            return _start;
        }

        public function set start(value:String):void {
            _start = value;
        }

        public function get stop():String {
            return _stop;
        }

        public function set stop(value:String):void {
            _stop = value;
        }

        public function get finish():String {
            return _finish;
        }

        public function set finish(value:String):void {
            _finish = value;
        }

        public function get pause():String {
            return _pause;
        }

        public function get trackPause():Boolean {
            return _all && _pause as Boolean;
        }

        public function set pause(value:String):void {
            _pause = value;
        }

        public function get resume():String {
            return _resume;
        }

        public function get trackResume():Boolean {
            return _all && _resume as Boolean;
        }

        public function set resume(value:String):void {
            _resume = value;
        }

        public function get seek():String {
            return _seek;
        }

        public function get trackSeek():Boolean {
            return _all && _seek as Boolean;
        }

        public function set seek(value:String):void {
            _seek = value;
        }

        public function get mute():String {
            return _mute;
        }

        public function get trackMute():Boolean {
            return _all && _mute as Boolean;
        }

        public function set mute(value:String):void {
            _mute = value;
        }

        public function get unmute():String {
            return _unmute;
        }

        public function get trackUnmute():Boolean {
            return _all && _unmute as Boolean;
        }

        public function set unmute(value:String):void {
            _unmute = value;
        }

        public function get fullscreen():String {
            return _fullscreen;
        }

        public function get trackFullscreen():Boolean {
            return _all && _fullscreen as Boolean;
        }

        public function set fullscreen(value:String):void {
            _fullscreen = value;
        }

        public function get fullscreenExit():String {
            return _fullscreenExit;
        }

        public function get trackFullscreenExit():Boolean {
            return _all && _fullscreenExit as Boolean;
        }

        public function set fullscreenExit(value:String):void {
            _fullscreenExit = value;
        }

        public function get all():Boolean {
            return _all;
        }

        public function set all(value:Boolean):void {
            _all = value;
        }

        public function get unload():String {
            return _unload;
        }

        public function set unload(value:String):void {
            _unload = value;
        }
    }

}