package org.flowplayer.pseudostreaming {

import org.flowplayer.model.Clip;

public class H264SeekDataStore extends DefaultSeekDataStore {

    override protected function extractKeyFrameTimes(metaData:Object):Array {
        var times:Array = new Array();
        for (var j:Number = 0; j != metaData.seekpoints.length; ++j) {
          times[j] = Number(metaData.seekpoints[j]['time']);
//          log.debug("keyFrame[" + j + "] = " + _keyFrameTimes[j]);
        }
        return times;
    }

    override protected function queryParamValue(pos:Number):Number {
        return _keyFrameTimes[pos] as Number;
    }
}

}