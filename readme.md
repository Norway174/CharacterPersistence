# Welcome to Character Persistence!

Character Persistence is quite a simple, yet powerful, Character Persistence addon for Garry's Mod!

It works straight out of the box, no config required. But every aspect can be customized and configured if desired.

And it also serves as a very simple framework for other developers to add in their own saving & loading modules for players.

It was initially created for HaloRP, as a part of my HaloArmory addon. But it has since grown in both scope and flexibility since then. And grown into it's own standalone project.

And it should be more then capeable of handling any other games you want to throw at it. Keep in mind, it's mainly designed around Sandbox and DarkRP styles of gamemodes.

But with the right modules in place, I don't see why it shouldn't work for practically any gamemode you'd like to. Provided it doesn't already add it's own Character Persistence already, of course!

## Config
Grab the standalone Config addon to configure Character Persistence to suit your needs!

This is the reccommended method of configuring Character Persistence, so you don't have to re-do all your custom changes each update.

You can download the Config from here: [CharacterPersistence-Config](https://github.com/Norway174/CharacterPersistence-Config)

## Modules
Character Persitence uses a custom made module system. Which can be tailored for whatever needs you may have.

Currently, two modules are included by default:
* [Sandbox](https://wiki.facepunch.com/gmod/gamemodes/Sandbox)
* [DarkRP](https://github.com/FPtje/DarkRP)

The DarkRP Module comes with additional support for these addons as well, but are not required:
* [HaloArmory](https://steamcommunity.com/sharedfiles/filedetails/?id=3287212606)
* [MRS - Advanced Rank System](https://www.gmodstore.com/market/view/rankup-advanced-rank-system)

More modules might also get added from requests. But it's also real easy to add your own as well!

## For Developers
If you want to add your own module, doing so is very easy!

Simply copy the example modules from this repo, which can be found here: [lua/character_persistence/modules/example.lua](https://github.com/Norway174/CharacterPersistence/blob/main/lua/character_persistence/modules/example.lua)

I would suggest putting your own file, in the same folder path, in your own addon, as such: `<addonname>/lua/character_persistence/modules/<your_module_name>.lua`

But really, you could put the file anywhere. As long as it gets loaded sometime **AFTER** Character Persistence has loaded. Putting it in the modules folder, would automatically load it once it's ready. However, it could be before your own mod is ready.

You can also just call the function directly, without the file. Check the wiki for more details. *(Note: Wiki is not ready yet!)*

`CHARACTER_PERSISTENCE:RegisterModule( ModuleName, Order, SaveFunction, LoadFunction, NewCharFunction)`

* `ModuleName` = This is the name of your module. Has to be unique, otherwise, it could overwrite other modules.
* `Order` = This is the ordering number. Lower numbers go first.
* `SaveFunction` = This is the function that gets called on save. You must return a table with your save data. This function is also given a table with the existing data if there is any. It's up to you how you wanna use that.
* `LoadFunction` = This function is called when a character is being loaded. IE. Selected from the menu, or spawned in for the first time with Auto-Load. This function is given a table with the data. This is the same data you supplied it with the save function.
* `NewCharFunction` = Optional helper function. This is only ever called when the player creates a new character. It's meant to reset everything to a blank default state. As if the player had spawned on the server for the very first time. This function is sent a table from the CharacterCreator with the players options, currently these are:  
 ● `nick`  
 ● `job`  
 ● `model`  
 ● `skin`  
 ● `bodygroups`


## Discord
I have set up a development Discord server here: https://discord.gg/aBapcEjaDa  
Feel free to join if you need help, or want to chat!


## Support
You can support me on Ko-Fi, if you like the addon.
Support is not required or necessary. But it's greatly appreciated!

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/J3J010ELH2)
