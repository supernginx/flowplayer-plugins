Version history:

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
