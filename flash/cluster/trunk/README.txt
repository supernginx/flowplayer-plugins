Version history:

3.2.3
-----
- fixed to work when there is a RTMP plugin in player config, and it does not contain any configuration. durationFunc
  lookup was failing in this case.  

3.2.2
-----
Fixes: was throwing an async NetConnection error with the onMetadata event

3.2.1
-----
- now uses the durationFunc of the RTMP plugin

3.2.0
-----
- fix for clustering RTMP servers 

3.1.1
-----
- compatible with 3.1.3 URL resolver API

3.1.0
-----
- first public release
