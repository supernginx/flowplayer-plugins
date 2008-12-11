Version history:

3.0.2
-----
- improved scrubbing: Cannot click on unbuffered areas when random seeking is not enabled (streaming server not used).
  The scrubber now has hand cursor enabled on areas where seeking can be done.
- No longer hides the controlbar when mouse is over it (when autoHide is used)
- Fixed the controlbar disappearing and not appearing again when autoHide is used
- dispatches the LOAD event when initialized (needed for flowplayer 3.0.2 compatibility)

3.0.1
-----
- mute volume button shows the muted state correctly initially when it has been loaded

3.0.0
-----
- does not show the duration for live feeds
- pause button goes to play mode when closeBuffering() was called in the player

beta7
-----
- tweaking autoHide
- added hideDelay config option
- fixed scrubber to work with images that have a duration in the playlist

beta6
-----
- fix to prevent the buffer bar to grow out of bounds if supplying a bufferEnd value that is larger than clip's duration

beta5
-----
- compatibility with core beta6

beta4
-----
- play-button was not positioned at zero y position, fixed now

beta3
-----
- backward seeking by just clicking on the timeline did not work with the default http provider

beta2
-----
- fixed autohiding on HW scaled fullscreen
- made it easier to use the controls when autoHiding is enabled

beta1
-----
- First public beta release
