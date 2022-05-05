# Aladdin Practice Hack (SNES)
 This hack is intended to help speedrunners practice the game in the most convenient ways possible. The practice menu, HUD display, controller shortcuts, and savestates are forked from Super Metroid's practice hack found at [github.com/tewtal/sm_practice_hack](https://github.com/tewtal/sm_practice_hack). Modifications were made to fit Aladdin.


## How to get it:
 Check the \releases\ directory for pre-made IPS patch files. Further instructions are available in the `README.md` file there.


## How to build/apply changes:

### Building IPS patches:
 Building patches requires Python 3.0+ installed, but does not require a ROM to produce the IPS patches.

1. Download and install Python 3+ from https://python.org. Windows users will need to set the PATH environmental variable to point to their Python installation folder.
2. Run `build_ips.bat` to create IPS patch files.
3. Locate the patch files in the \build\ folder.

### Building patched ROM:

1. Rename your unheadered SM rom to `Aladdin.sfc` and place it in the \build\ folder.
2. Run `build_rom.bat` to generate a patched practice rom in \build\ named `Aladdin_Practice_1.X.sfc`.


## Features included:

- Ability to save and reload instantly during gameplay (on supported platforms)
- Level timer and lag frames displayed on the HUD and updates on music changes
- Customizable controller shortcuts
- Equipment menu to set values such as hearts, apples, and the cape.
- Level select menu lets you load any level, restart the current level, or skip to the next level.
- HUD display modes to show RAM or other calculated values on the HUD during gameplay
- RAM watch and memory editor tools
- Skip stage clear and story time cutscenes
- Options to save, preserve, or cycle the RNG when loading savestates
- Option to disable game music (SFX only)
- Customize the equipment you start the game with
- Infinite apples, hearts, lives, and/or credits
- Invulnerability to all enemies
- Access to the game's own options within the practice menu
- Sample any music or sound effects in the menu
- Customize the sound effects used by the practice menu

## Special thanks:

- [Metroid Construction Discord](https://discord.com/invite/xDwaaqa). P.JBoy in particular for helping with SPC sync.
