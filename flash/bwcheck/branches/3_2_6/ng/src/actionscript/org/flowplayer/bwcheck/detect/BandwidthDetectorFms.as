/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>, Anssi Piirainen Flowplayer Oy
 * Copyright (c) 2008-2011 Flowplayer Oy *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.bwcheck.detect {
    import org.flowplayer.bwcheck.detect.AbstractDetectionStrategy;

    /**
     * @author danielr
     */
    public class BandwidthDetectorFms extends AbstractDetectionStrategy {

        private var _host:String;

        public function set host(host:String):void {
            _host = host;
        }

        public function onBWCheck(... rest):Number {
            dispatchStatus(rest);
            return 0;
        }

        public function onBWDone(... rest):void {
            if (rest[0] != undefined) {
                log.debug("onBWDone() " + rest[0]);
                var obj:Object = new Object();
                obj.kbitDown = rest[0];
                obj.latency = rest[3];
                dispatchComplete(obj);
            }
        }

        override public function connect(host:String = null):void {
            connection.connect(host, true);
        }

        override public function detect():void {
            log.debug("detect() calling service " + _service);
            connection.client = this;
            connection.call(_service, null);
        }

        public function close(... rest):void {
            log.debug("close()");
        }
    }
}