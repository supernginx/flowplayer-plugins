/**
 * Created by IntelliJ IDEA.
 * User: danielr
 * Date: 21/03/11
 * Time: 11:04 PM
 * To change this template use File | Settings | File Templates.
 */
package org.flowplayer.f4m.config {

    public class BitratesConfig {

        private var _labels:Object;
        private var _hd:Number;
        private var _normal:Number;
        private var _default:Number;

        public function BitratesConfig() {

        }

        public function set labels(labels:Object):void {
            _labels = labels;
        }

        public function get labels():Object {
            return _labels;
        }

        public function set hd(hd:Number):void {
            _hd = hd;
        }

        public function get hd():Number {
            return _hd;
        }

        public function set normal(normal:Number):void {
            _normal = normal;
        }

        public function get normal():Number {
            return _normal;
        }

        public function set defaultItem(defaultItem:Number):void {
            _default = defaultItem;
        }

        public function get defaultItem():Number {
            return _default;
        }
    }

}
