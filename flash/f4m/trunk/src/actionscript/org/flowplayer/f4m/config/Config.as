/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi <electroteque@gmail.com>, Anssi Piirainen <api@iki.fi> Flowplayer Oy
 * Copyright (c) 2009, 2010 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.f4m.config {

    import org.flowplayer.util.PropertyBinder;

    public class Config {

        private var _bitratesConfig:BitratesConfig = new BitratesConfig();

        public function set bitrates(config:Object):void {
            new PropertyBinder(_bitratesConfig).copyProperties(config);
        }

        public function get bitratesConfig():BitratesConfig {
            return _bitratesConfig;
        }

        
    }
}
