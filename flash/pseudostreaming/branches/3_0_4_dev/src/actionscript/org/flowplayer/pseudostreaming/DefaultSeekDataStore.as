package org.flowplayer.pseudostreaming {

import org.flowplayer.util.Log;
import org.flowplayer.model.ClipEventType;
import org.flowplayer.model.Clip;

public class DefaultSeekDataStore {
    protected var log:Log = new Log(this);
    protected var _keyFrameTimes:Array;
    protected var _keyFrameFilePositions:Array;
    private var _prevSeekTime:Number;

    private function init(clip:Clip, metaData:Object):void {
        if (! metaData) return;
        log.debug("will extract keyframe metadata");
        try {
            _keyFrameTimes = extractKeyFrameTimes(metaData);
            _keyFrameFilePositions = extractKeyFrameFilePositions(metaData);
        } catch (e:Error) {
            log.error("error getting keyframes " + e.message);
            clip.dispatch(ClipEventType.ERROR, e.message);
        }
        log.info("_keyFrameTimes array lenth is " + (_keyFrameTimes ? _keyFrameTimes.length+"" : "null array"));
        log.info("_keyFrameFilePositions array lenth is " + (_keyFrameFilePositions ? _keyFrameFilePositions.length+"" : "null array"));
    }

    public static function create(clip:Clip, metaData:Object):DefaultSeekDataStore {
        var log:Log = new Log("org.flowplayer.pseudostreaming::DefaultKeyFrameStore");
        log.debug("extracting keyframe times and filepositions");
        var store:DefaultSeekDataStore = metaData.seekpoints ? new H264SeekDataStore() : new FLVSeekDataStore();
        store.init(clip, metaData);
        return store;
    }

    protected function extractKeyFrameFilePositions(metadata:Object):Array {
        return null;
    }

    protected function extractKeyFrameTimes(metadata:Object):Array {
        return null;
    }

    internal function allowRandomSeek():Boolean {
        return _keyFrameTimes != null && _keyFrameTimes.length > 0;        
    }

    internal function get dataAvailable():Boolean {
        return _keyFrameTimes != null;
    }


    public function getQueryStringStartValue(seekPosition: Number, rangeBegin:Number = 0, rangeEnd:Number = undefined):Number {
        if (!rangeEnd) {
            rangeEnd = _keyFrameTimes.length - 1;
        }
        if (rangeBegin == rangeEnd) return queryParamValue(rangeBegin);

        var rangeMid:Number = Math.floor((rangeEnd + rangeBegin)/2);
        if (_keyFrameTimes[rangeMid] >= seekPosition)
            return getQueryStringStartValue(seekPosition, rangeBegin, rangeMid);
        else
            return getQueryStringStartValue(seekPosition, rangeMid+1, rangeEnd);
    }

    protected function queryParamValue(pos:Number):Number {
        return _keyFrameFilePositions[pos];
    }

    public function get prevSeekTime():Number {
        return _prevSeekTime;
    }
    
    public function set prevSeekTime(val:Number):void {
        _prevSeekTime = val;
    }
}

}