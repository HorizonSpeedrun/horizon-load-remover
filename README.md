# Horizon Load Remover

This repository serves the memory-based load removers for both Horizon Zero Dawn and Horizon Forbidden West on PC. It also provides a OBS-centric approach to video-based load removal for console speedruns.

The up-to-date rules for Horizon Zero Dawn for the loads that count can be found [here](https://www.speedrun.com/hzd/guides/6atmp).

## Autosplitter (PC)

For PC, use the autosplitter that is automatically suggested in the `Splits Editor` after having selected the game.

If necessary (e.g. CE Runs), the Autosplitter can manually be added to LiveSplit by adding a `Scriptable Auto Splitter` component in LiveSplit and downloading the corresponding script in the `autosplitter` subfolder:
* [hzd-autosplitter.asl](https://raw.githubusercontent.com/HorizonSpeedrun/horizon-load-remover/master/autosplitter/hzd-autosplitter.asl)
* [hfw-autosplitter.asl](https://raw.githubusercontent.com/HorizonSpeedrun/horizon-load-remover/master/autosplitter/hfw-autosplitter.asl)

At the moment, only Load Removal is implemented in the scripts.

## Video-based Load Remover (Console)

Based on previous work on the load remover by [Blegas78](https://github.com/blegas78/autoSplitters) and the [description in the SceneSwitcher wiki](https://github.com/WarmUpTill/SceneSwitcher/wiki/Activate-overlay-to-hide-parts-of-the-screen).

At its core, the new video-based load remover is using the Advanced Scene Switcher plugin in OBS to determine if a loadscreen is active and gives the pause / resume commands to the LiveSplit Server component via a Lua script.

Please see [the dedicated README for its setup](video-based-LR.md)

## License

This repository is provided under MIT license. See [LICENSE.md](/LICENSE.md)
