/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.captions.parsers
{
    import org.flowplayer.model.Cuepoint;
    import org.flowplayer.util.Log;
    import org.flowplayer.config.ConfigParser;
    import org.flowplayer.flow_internal;
    import org.flowplayer.view.FlowStyleSheet;
	
	use namespace flow_internal;
	
    public class JSONParser extends AbstractCaptionParser
    {

        protected var log:Log = new Log(this);
        private var _arr:Array = new Array();
        private var cueRow:int = 0;
        private var _external:Boolean;

        /**
         * Creates a new JSONParser.
         *
         * @param externalCaptions captions are "external" captions coming from a separate file
         */
        public function JSONParser(externalCaptions:Boolean) {
            _external = externalCaptions;
        }

        // { text: 'captionText', time: 10, duration: 3 }

        private function parseRows(item:*, index:int, array:Array):void
        {

            var time:int = Number(item.time);
            var cue:Object = Cuepoint.createDynamic(time, "embedded"); // creates a dynamic
            var parameters:Object = new Object();
            var name:String = (item.name ? item.name : "cue" + cueRow);

            // convert to milliseconds
            cue.time = time * 1000;
            cue.type = "event";
            cue.name = "caption"+time;
            if (_external) {
                cue.captionType = "external";
            }

            parameters.style = styles.rootStyleName;
            parameters.begin = cue.time;
            parameters.duration = item.duration * 1000;
            parameters.text = item.text;

            cue.parameters = parameters;
            _arr.push(cue);
            cueRow++;
        }

        override protected function parseCaptions(data:Object):Array {
        	
        	if (data is String) data = ConfigParser.parse(String(data));
            (data as Array).forEach(parseRows);
            return _arr;
        }
    }
}