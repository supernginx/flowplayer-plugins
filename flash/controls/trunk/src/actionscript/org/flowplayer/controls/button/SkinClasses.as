package org.flowplayer.controls.button {
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
import flash.system.ApplicationDomain;
import flash.utils.getDefinitionByName;
    import org.flowplayer.util.Log;
    import fp.*;


    /**
     * Holds references to classes contained in the buttons.swc lib.
     * These are needed here because the classes are instantiated dynamically and without these
     * the compiler will not include thse classes into the controls.swf
     */
    public class SkinClasses {
        private static var log:Log = new Log("org.flowplayer.controls.button::SkinClasses");
        private static var _skinClasses:ApplicationDomain;

		CONFIG::hasSlowMotion {
			private var slowMotionFwd:fp.SlowMotionFwdButton;
			private var slowMotionBwd:fp.SlowMotionBwdButton;
			private var slowMotionFFwd:fp.SlowMotionFFwdButton;
			private var slowMotionFBwd:fp.SlowMotionFBwdButton;
		}

        CONFIG::skin {
            private var foo:fp.FullScreenOnButton;
            private var bar:fp.FullScreenOffButton;
            private var next:fp.NextButton;
            private var prev:fp.PrevButton;
            private var dr:fp.Dragger;
            private var pause:fp.PauseButton;
            private var play:fp.PlayButton;
            private var stop:fp.StopButton;
            private var vol:fp.MuteButton;
            private var volOff:fp.UnMuteButton;
            private var scrubberLeft:fp.ScrubberLeftEdge;
            private var scrubberRight:fp.ScrubberRightEdge;
            private var scrubberTop:fp.ScrubberTopEdge;
            private var scrubberBottom:fp.ScrubberBottomEdge;
            private var buttonLeft:fp.ButtonLeftEdge;
            private var buttomRight:fp.ButtonRightEdge;
            private var buttomTop:fp.ButtonTopEdge;
            private var buttonBottom:fp.ButtonBottomEdge;
            private var timeLeft:fp.TimeLeftEdge;
            private var timeRight:fp.TimeRightEdge;
            private var timeTop:fp.TimeTopEdge;
            private var timeBottom:fp.TimeBottomEdge;
            private var volumeLeft:fp.VolumeLeftEdge;
            private var volumeRight:fp.VolumeRightEdge;
            private var volumeTop:fp.VolumeTopEdge;
            private var volumeBottom:fp.VolumeBottomEdge;
            private var defaults:SkinDefaults;
        }

        public static function getDisplayObject(name:String):DisplayObject {
            var clazz:Class = getClass(name);
            return new clazz() as DisplayObject;
        }

        public static function getClass(name:String):Class {
            log.debug("creating skin class " + name + (_skinClasses ? "from skin swf" : ""));
            if (_skinClasses) {
                return _skinClasses.getDefinition(name) as Class;
            }
            return getDefinitionByName(name) as Class;
        }

        public static function get defaults():Object {
            try {
                var clazz:Class = getClass("SkinDefaults");
                return clazz["values"];
            } catch (e:Error) {
            }
            return null;
        }

		public static function get margins():Array {
            try {
                var clazz:Class = getClass("SkinDefaults");
                return clazz["margins"];
            } catch (e:Error) {
            }
            return [0,0,0,0];
        }

        public static function getSpaceAfterWidget(widget:DisplayObject, lastOnRight:Boolean):Number {
            try {
                var clazz:Class = getClass("SkinDefaults");
                return clazz["getSpaceAfterWidget"](widget, lastOnRight);
            } catch (e:Error) {
            }
            return 0;
        }

        public static function getScrubberRightEdgeWidth(nextWidgetToRight:DisplayObject):Number {
            try {
                var clazz:Class = getClass("SkinDefaults");
                return clazz["getScrubberRightEdgeWidth"](nextWidgetToRight);
            } catch (e:Error) {
            }
            return 0;
        }

		public static function getVolumeSliderWidth():Number {
            try {
                var clazz:Class = getClass("SkinDefaults");
                return clazz["getVolumeSliderWidth"]();
            } catch (e:Error) {
            }
            return 40;
        }

        public static function set skinClasses(val:ApplicationDomain):void {
            log.debug("received skin classes " + val);
            _skinClasses = val;
        }

        public static function getScrubberLeftEdge():DisplayObject {
            return getDisplayObject("fp.ScrubberLeftEdge");
        }

        public static function getScrubberRightEdge():DisplayObject {
            return getDisplayObject("fp.ScrubberRightEdge");
        }

        public static function getScrubberTopEdge():DisplayObject {
            return getDisplayObject("fp.ScrubberTopEdge");
        }

        public static function getScrubberBottomEdge():DisplayObject {
            return getDisplayObject("fp.ScrubberBottomEdge");
        }

        public static function getFullScreenOnButton():DisplayObject {
            return getDisplayObject("fp.FullScreenOnButton");
        }

        public static function getFullScreenOffButton():DisplayObject {
            return getDisplayObject("fp.FullScreenOffButton");
        }

        public static function getPlayButton():DisplayObject {
            return getDisplayObject("fp.PlayButton");
        }

        public static function getPauseButton():DisplayObject {
            return getDisplayObject("fp.PauseButton");
        }

        public static function getMuteButton():DisplayObject {
            return getDisplayObject("fp.MuteButton");
        }

        public static function getUnmuteButton():DisplayObject {
            return getDisplayObject("fp.UnMuteButton");
        }

        public static function getNextButton():DisplayObjectContainer {
            return DisplayObjectContainer(getDisplayObject("fp.NextButton"));
        }

        public static function getPrevButton():DisplayObjectContainer {
            return DisplayObjectContainer(getDisplayObject("fp.PrevButton"));
        }

		public static function getSlowMotionFwdButton():DisplayObjectContainer {
			CONFIG::hasSlowMotion {
            	return DisplayObjectContainer(getDisplayObject("fp.SlowMotionFwdButton"));
			}
			
			return null;
        }

        public static function getSlowMotionBwdButton():DisplayObjectContainer {
			CONFIG::hasSlowMotion {
            	return DisplayObjectContainer(getDisplayObject("fp.SlowMotionBwdButton"));
			}
			
			return null;
        }

		public static function getSlowMotionFFwdButton():DisplayObjectContainer {
			CONFIG::hasSlowMotion {
            	return DisplayObjectContainer(getDisplayObject("fp.SlowMotionFFwdButton"));
			}
			
			return null;
        }

        public static function getSlowMotionFBwdButton():DisplayObjectContainer {
			CONFIG::hasSlowMotion {
            	return DisplayObjectContainer(getDisplayObject("fp.SlowMotionFBwdButton"));
			}
			
			return null;
        }

        public static function getStopButton():DisplayObjectContainer {
            return DisplayObjectContainer(getDisplayObject("fp.StopButton"));
        }

        public static function getButtonLeft():DisplayObject {
            return getDisplayObject("fp.ButtonLeftEdge");
        }

        public static function getButtonRight():DisplayObject {
            return getDisplayObject("fp.ButtonRightEdge");
        }

        public static function getButtonTop():DisplayObject {
            return getDisplayObject("fp.ButtonTopEdge");
        }

        public static function getButtonBottom():DisplayObject {
            return getDisplayObject("fp.ButtonBottomEdge");
        }

        public static function getTimeLeft():DisplayObject {
            return getDisplayObject("fp.TimeLeftEdge");
        }

        public static function getTimeRight():DisplayObject {
            return getDisplayObject("fp.TimeRightEdge");
        }

        public static function getTimeTop():DisplayObject {
            return getDisplayObject("fp.TimeTopEdge");
        }

        public static function getTimeBottom():DisplayObject {
            return getDisplayObject("fp.TimeBottomEdge");
        }

        public static function getVolumeLeft():DisplayObject {
            return getDisplayObject("fp.VolumeLeftEdge");
        }

        public static function getVolumeRight():DisplayObject {
            return getDisplayObject("fp.VolumeRightEdge");
        }

        public static function getVolumeTop():DisplayObject {
            return getDisplayObject("fp.VolumeTopEdge");
        }

        public static function getVolumeBottom():DisplayObject {
            return getDisplayObject("fp.VolumeBottomEdge");
        }

        public static function getDragger():DisplayObjectContainer {
            return getDisplayObject("fp.Dragger") as DisplayObjectContainer;
        }
    }
}