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
    import org.flowplayer.viralvideos.PlayerEmbed;

    public class EmbedConfig {
        public static const DEFAULT:int = -1;
        public static const OVERRIDE_FALSE:int = 0;
        public static const OVERRIDE_TRUE:int = 1;

        private var _playerEmbed:PlayerEmbed;
        private var _autoPlay:int = DEFAULT;
        private var _autoBuffering:int = DEFAULT;
        private var _linkUrl:String = null;
        private var _configUrl:String = null;
        private var _fallbackUrls:Array = new Array();
        private var _fallbackPoster:String = null;
        private var _anchorText:String = null;
        private var _shareCurrentPlaylistItem:Boolean;

        public function get shareCurrentPlaylistItem():Boolean {
            return _shareCurrentPlaylistItem;
        }

        public function set shareCurrentPlaylistItem(value:Boolean):void {
            _shareCurrentPlaylistItem = value;
        }

        public function set playerEmbed(playerEmbed:PlayerEmbed):void {
            _playerEmbed = playerEmbed;
        }

        public function get playerEmbed():PlayerEmbed {
            return _playerEmbed;
        }

        public function get autoPlay():Boolean {
            return _autoPlay == OVERRIDE_TRUE;
        }

        public function get isAutoPlayOverriden():Boolean {
            return _autoPlay != DEFAULT;
        }

        public function set autoPlay(value:Boolean):void {
            _autoPlay = value ? OVERRIDE_TRUE : OVERRIDE_FALSE;
        }

        public function get autoBuffering():Boolean {
            return _autoBuffering == OVERRIDE_TRUE;
        }

        public function get isAutoBufferingOverriden():Boolean {
            return _autoBuffering != DEFAULT;
        }

        public function set autoBuffering(value:Boolean):void {
            _autoBuffering = value ? OVERRIDE_TRUE : OVERRIDE_FALSE;
        }

        public function get linkUrl():String {
            return _linkUrl;
        }

        public function set linkUrl(value:String):void {
            _linkUrl = value;
        }

        public function get configUrl():String {
            return _configUrl;
        }

        public function set configUrl(value:String):void {
            _configUrl = value;
        }

        public function get fallbackUrls():Array {
            return _fallbackUrls;
        }

        public function set fallbackUrls(value:Array):void {
            _fallbackUrls = value;
        }

        public function get anchorText():String {
            return _anchorText;
        }

        public function set anchorText(value:String):void {
            _anchorText = value;
        }

        public function get fallbackPoster():String {
            return _fallbackPoster;
        }

        public function set fallbackPoster(value:String):void {
            _fallbackPoster = value;
        }

    }
}