/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.shareembed.config
{
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.util.URLUtil;

    public class Config {
        private var _email:EmailConfig = new EmailConfig();
        private var _share:ShareConfig = new ShareConfig();
        private var _embed:EmbedConfig = new EmbedConfig;
        private var _canvas:Object;

        private var _baseURL:String = URLUtil.pageUrl;

        public function get baseURL():String {
            return _baseURL;
        }

        public function set baseURL(value:String):void {
            _baseURL = value;
        }

        public function get email():EmailConfig {
            return _email;
        }

        public function setEmail(value:Object):void {
            if (! value) {
                _email = null;
                return;
            }
            if (! _email) {
                _email = new EmailConfig();
            }
            if (value is Boolean) {
                return;
            }
            new PropertyBinder(_email).copyProperties(value);
        }

        public function get share():ShareConfig {
            return _share;
        }

        public function setShare(value:Object):void {
            if (! value) {
                _share = null;
                return;
            }
            if (! _share) {
                _share = new ShareConfig();
            }
            if (value is Boolean) {
                return;
            }
            new PropertyBinder(_share).copyProperties(value);
        }

        public function get embed():EmbedConfig {
            return _embed;
        }

        public function setEmbed(value:Object):void {
            if (! value) {
                _embed = null;
                return;
            }
            if (! _embed) {
                _embed = new EmbedConfig();
            }
            if (value is Boolean) {
                return;
            }
            new PropertyBinder(_embed).copyProperties(value);
        }

        public function get canvas():Object {
            if (! _canvas) {
                _canvas = {
                    backgroundGradient: 'medium',
                    border: 'none',
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    
                    body: {
                        fontSize: 14,
                        fontWeight: 'normal',
                        fontFamily: 'Arial',
                        left: 0,
                        bottom: 0,
                        textAlign: 'left',
                        color: '#ffffff'
                    },
                    '.title': {
                        fontSize: 16
                    },
                    '.label': {
                        fontSize: 12
                    },
                    '.input': {
                        fontSize: 12
                    },
                    '.small': {
                        fontSize: 8
                    },
                    '.error': {
                        color: '#ff3333',
                        fontSize: 10,
                        fontWeight: 'normal',
                        fontFamily: 'Arial'
                    },
                    '.success': {
                        color: '#000000',
                        fontSize: 10,
                        fontWeight: 'normal',
                        fontFamily: 'Arial'
                    },
                    '.embed': {
                        color: '#000000',
                        fontSize: 6,
                        fontWeight: 'normal',
                        fontFamily: 'Arial',
                        textAlign: 'left'
                    },
                    '.info': {
                        color: '#CCCCCC',
                        fontSize: 10
                    }
                };
            }
            return _canvas;
        }

        public function set canvas(value:Object):void {
            _canvas = value;
        }
    }
}



