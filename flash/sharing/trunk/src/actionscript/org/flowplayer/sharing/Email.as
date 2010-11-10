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
package org.flowplayer.sharing {
    import flash.net.URLRequest;

    import flash.net.navigateToURL;

    import org.flowplayer.util.URLUtil;
    import org.flowplayer.view.Flowplayer;

    public class Email extends AbstractCommand {

        private var _subject:String = "Video you might be interested in";
        private var _message:String = "";
        private var _template:String = "{0} \n\n Video Link: <a href=\"{1}\">{2}</a>";


        public function Email(player:Flowplayer) {
            super(player);
        }

        override protected function process():void {
            var request:URLRequest = new URLRequest(formatString("mailto:{0}?subject={1}&body={2}", "", escape(_subject), escape(formatString(_template, _message, getPageUrl(), getPageUrl()))));            
            navigateToURL(request, "_self");
        }

        private function getPageUrl():String {
        	return player.currentClip.getCustomProperty("pageUrl")
        	? String(player.currentClip.getCustomProperty("pageUrl"))
        	: URLUtil.pageUrl;
        }

        private function formatString(original:String, ...args):String {
            var replaceRegex:RegExp = /\{([0-9]+)\}/g;
            return original.replace(replaceRegex, function():String {
                if (args == null)
                {
                    return arguments[0];
                }
                else
                {
                    var resultIndex:uint = uint(between(arguments[0], '{', '}'));
                    return (resultIndex < args.length) ? args[resultIndex] : arguments[0];
                }
            });
        }

        private function between(p_string:String, p_start:String, p_end:String):String {
            var str:String = '';
            if (p_string == null) { return str; }
            var startIdx:int = p_string.indexOf(p_start);
            if (startIdx != -1) {
                startIdx += p_start.length; // RM: should we support multiple chars? (or ++startIdx);
                var endIdx:int = p_string.indexOf(p_end, startIdx);
                if (endIdx != -1) { str = p_string.substr(startIdx, endIdx-startIdx); }
            }
            return str;
        }

        public function set subject(value:String):void {
            _subject = value;
        }

        public function set message(value:String):void {
            _message = value;
        }

        public function set template(value:String):void {
            _template = value;
        }
    }
}