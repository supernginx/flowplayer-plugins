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
    import flash.external.ExternalInterface;

    import flash.net.URLRequest;

    import flash.net.navigateToURL;

    import org.flowplayer.model.PluginEventType;
    import org.flowplayer.view.Flowplayer;

    public class AbstractShareCommand extends AbstractCommand {
        private var _description:String = "A cool video";
        private var _popupOnClick:Boolean = true;

        public function AbstractShareCommand(player:Flowplayer) {
            super(player);
        }

        override protected function process():void {
            var url:String = formatString(serviceUrl, encodeURIComponent(_description), pageUrl);
            launchURL(url, popupDimensions);
        }

        protected function get popupDimensions():Array {
            throw new Error("this method needs to be overridden in subclasses");
            return null;
        }

        protected function get serviceUrl():String {
            throw new Error("this method needs to be overridden in subclasses");
            return null;
        }

        protected function launchURL(url:String, popUpDimensions:Array):void {
            url = escape(url);

            var request:URLRequest;
            //if we are using a popup window, launch javascript with window.open
            if (_popupOnClick)
            {
                var jscommand:String = "window.open('" + url + "','PopUpWindow','height=" + popUpDimensions[0] + ",width=" + popUpDimensions[1] + ",toolbar=yes,scrollbars=yes');";
                request = new URLRequest("javascript:" + jscommand + " void(0);");
                navigateToURL(request, "_self");
            } else {
                //request a blank page
                request = new URLRequest(url);
                navigateToURL(request, "_blank");
            }
        }

        public function set description(value:String):void {
            _description = value;
        }

        public function set popupOnClick(value:Boolean):void {
            _popupOnClick = value;
        }

        [Value]
        public function get description():String
        {
            return _description;
        }

        [Value]
        public function get popupOnClick():Boolean
        {
            return _popupOnClick;
        }
    }
}