Version history:

3.2.9
-----
Fixes:
- #488 does not work with playlist based splash image (regression)
- #502 use new widget enabling api method to update the controls widget enable configs also.

3.2.8
-----

- Migrated HD button code from bwcheck to bitrateselect plugin
- Migrated stream selection and switching code to common classes
- Transition events are now handled in the rtmp plugin and new clip events added.
- set hd getter to external method to provide feedback of the hd state ie $f().getPlugin('bitrateselect').getHd()
- #355 fixes for hd button asset to provide toggle colour state correctly.
- to enable the HD/SD splash screen, have 2 bitrate items and mark one of them with a 'hd' property
- #367 new httpstreaming logic switches automatically on startup, need to check for existence of the manual switch manager.
- don't initialize the menu if the bitrates list has not been resolved / generated on load.
- #388 specify splash labels here as they are not specific to display properties so don't get set.
- set lowercase to embedded fonts on the hd button asset.
- #452 make sure the first bitrate item has a url configured when initialising the menu or else it will be generated while resolving.
- #488 regression with #r1764 filter onStart events to only work with bitrateselect configured clips. Problem when autobuffering with playlst splash images.
