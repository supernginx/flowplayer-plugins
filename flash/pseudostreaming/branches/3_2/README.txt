Version history:

3.2.0
-----
- changes related to bandwidth detection compatibility

3.1.3
-----
- compatible with the new ConnectionProvider and URLResolver API

3.1.3
-----
- fixed to work with bwcheck, so that random seeking works when bitrate is switched in the middle of a clip
- fixed issue when autoPlay is false, autoBuffering is true and video without metadatas
- fixed PlayOverlayButton state

3.1.2
-----
- fixed out-of-sync scrubbing: http://flowplayer.org/forum/8/17706

3.1.1
-----
- random seeking did not work when looping through the same video for the 2nd time
- the time indicator stayed at value 00:00
- random seeking after stop did not work

3.1.0
-----
- integrated h.264 streaming support, contributed by Arjen Wagenaar, CodeShop B.V.

3.0.3
-----
- now uses the queryString also in the initial request, the start param has value zero in it

3.0.2
-----
- compatible with flowplayer 3.0.3 provider API

3.0.1
-----
- dispatches the LOAD event when initialized (needed for flowplayer 3.0.2 compatibility)

3.0.0
-----
- 3.0.0-final release

beta3
----
- Fixed the typo in the configuration variable queryString
- compatible with core RC4

beta1
-----
- First public beta release
