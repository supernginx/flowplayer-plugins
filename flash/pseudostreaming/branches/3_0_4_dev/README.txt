Version history:

3.1.1
-----
Fixes:
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
