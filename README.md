# Gladdy - Macumba / XiCoN Edit

### [v1.0-Release Download Here](https://github.com/XiconQoo/XiconPlateBuffs/releases/download/v1.6.4-Beta/XiconPlateBuffs_v1.6.4-Beta.zip)

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
- added black borders to all frames
- basically all elements are arrangable LEFT or RIGHT
  - trinket and classicon separately attachable LEFT or RIGHT
  - DR LEFT or RIGHT
  - castbar LEFT or RIGHT
  - cooldowns TOP or DOWN  and LEFT or RIGHT
- trinket / classicon width/height now rectangular
- everything aligns to each other depending on config
  - eg: if castbar and DR on same side, they arrange each other
- in general-tab the padding, scaling and margin works for all movable things
- castbar height/width is again configurable
- increase max for healthbar-height to 100px
- classicon/trinket scale with healthbar
- replaced the classicons with their PNG icons for better frameborder
- trinket icon is clickable again (to trigger a cooldown on that target)
- added a config for background color of castbar/healthbar/powerbar
- added TrinketTracker again (added Endless-realms (Sunstrider/Tournament) to the exclusion list)
