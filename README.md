# Gladdy - Macumba / XiCoN Edit

### [v1.0-Release Download Here](https://github.com/XiconQoo/Gladdy/releases/download/v1.0-Release/Gladdy-MX-Edit-v1.0-Release.zip)

### Recommended addons to use with Gladdy

#### - [BuffLib by Schaka](https://github.com/Schaka/BuffLib/releases/download/v1.1.1/BuffLib.zip)

#### Join the [TBC addons 2.4.3 Discord](https://discord.gg/5qVu56M) by Macumba

Gladdy - the most powerful arena addon for WoW 2.4.3

Based on https://github.com/Schaka/gladdy

Forked from https://github.com/SunstriderEmu/GladdyEndless with following changes
```
- Removed TrinketTracker module that guessed when PvP trinket was used. Now using a server message to reliably show trinket usage.
- Updates the "seconds until game starts" if the start time changes (a ready button has been clicked and the game starts earlier).
- Added a version check (upon receiving a message from the server)
```

## Screenshot

![Screenshot](../readme-media/sample.png)

### Changes

v1.0-Release
- `/gladdy test` now activates **everything** for maximum configurability
- added black borders to all frames
- added cooldown numbers to all elements (no need to use OmniCC or similar)
- **ALL ELEMENTS** are arrangeable LEFT or RIGHT independently
  - trinket LEFT or RIGHT
  - class icon LEFT or RIGHT
  - DR frames LEFT or RIGHT
  - cast bar and icon LEFT or RIGHT
  - cooldowns TOP or DOWN and LEFT or RIGHT
- everything aligns to each other responsively depending on config (eg if cast bar and DR are on same side, they will arrange each other)
- padding, scaling and margin responsive
- cast bar and icon height/width is configurable
- trinket and class icon are now rectangular
- trinket and class icon scale with health + power bar height
- replaced the class icons with their PNG icons for better frame border
- trinket icon is clickable again (to trigger a cooldown on that target)
- increase max height for health bar to 100px
- added TrinketTracker again (added Endless-realms (Sunstrider/Tournament) to the exclusion list)
- configurable highlight border size
- background color of health-/power-/cast bar configurable