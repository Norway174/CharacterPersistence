//
// The configuration file for Character Persistence
//

//
// THANK YOU for using Character Persistence!
// If you have any questions, suggestions, or need help, please contact me on the Discord.
//
// Please read these instructions carefully.
//
// This is the config file, you can either leave everything default. And it will work out of the box.
// however, if you'd like to change any of he settings, DO NOT change them in this file.
//
// Instead, make a copy of this file, and rename it to "charpersistence_config.lua" (Remove the README part)
// Then you can change the settings in that file. If that file exists, it will be loaded instead of this one.
// This way, you can update the addon without losing your settings. And check this README file for updates.
// 
// It's also suggest you move the config file to either another addon you create yourself, like so: "myaddon/lua/charpersistence_config.lua"
// I have already created such a helper addon for you here: https://github.com/Norway174/CharacterPersistence-Config
// Just download, put it into your Addons folder, and edit the Config included in that file as you wish.
// If you are editing that file, then you can ignore this notice. But remember to check this README file for updates.
//


//
// Here you can define the various character slots available to the players
// Leave the table definition empty. And add the slots following the example.
//
CHARACTER_PERSISTENCE.Config.CharacterSlots = {} // <- Do not remove this line. Add the character slots below.

//
// The table key is the slot name. This is used for the filename. Lowercase and non-special characters only.
// If you change the name, you will also have to change the filenames of the characters.
// Or those characters will become unavailable.
// "CanSee" and "CanUse" accepts both a boolean and a function.
// "CanSee" is used to determine if the player can see the character slot.
// If the player can't see the character slot, they can't use it.
// So both must be true for the player to be able to use the character slot.
//
CHARACTER_PERSISTENCE.Config.CharacterSlots["character1"] = { // <- This is the key name. It has to be unique.
    PrintName = "Character 1", // <- This is print name displayed to the player.
    CanSee = true, // <- This is a boolean. If true, the player can see the character slot.
    CanUse = true, // <- This is a boolean. Has to return true for the player to be able to use the character slot.
    CanUseDeniedText = "", // <- This is a string. If the player can't use the character slot, this text will be displayed.
    Order = 1, // <- This is a number. The order of the character slots.
}

CHARACTER_PERSISTENCE.Config.CharacterSlots["character2"] = {
    PrintName = "Character 2",
    CanSee = function(ply)
        return true
    end,
    CanUse = function(ply)
        return true
    end,
    CanUseDeniedText = "",
    Order = 2,
}

CHARACTER_PERSISTENCE.Config.CharacterSlots["character3"] = {
    PrintName = "Character 3",
    CanSee = true,
    CanUse = true,
    CanUseDeniedText = "",
    Order = 3,
}

-- CHARACTER_PERSISTENCE.Config.CharacterSlots["vip_character"] = {
--     PrintName = "VIP Character",
--     CanSee = true,
--     CanUse = function(ply)
--         // Add custom function here to check if the player is a VIP.
--         // Returning nothing is the same as returning false.
--     end,
--     CanUseDeniedText = "Requires a VIP rank",
--     Order = 50,
-- }

CHARACTER_PERSISTENCE.Config.CharacterSlots["admin_character"] = {
    PrintName = "Admin Character",
    CanSee = function(ply)
        return ply:IsAdmin() // Only admins can see this character slot.
    end,
    CanUse = function(ply)
        return ply:IsAdmin() // While CanSee is only used clientside. CanUse is shared, and used for validiation.
    end,
    CanUseDeniedText = "You are not an admin",
    Order = 99,
}


//
// The default DarkRP job is included in the character selection.
// These settings are only active for DarkRP.
//
CHARACTER_PERSISTENCE.Config.IncludeDefaultDarkRPJob = true

//
// Here you can define other jobs that the player can select.
// Use this format: ["TEAMNAME"] = true,
//
CHARACTER_PERSISTENCE.Config.SelectableJobs = {
    --["TEAM_POLICE"] = true,
    --["TEAM_CHIEF"] = true,
    --["TEAM_MAYOR"] = true,
}

//
// Enforce the first and last name for the character. And no numbers.
//
CHARACTER_PERSISTENCE.Config.EnforceFirstAndLastName = true


//
// This is the Client-side configuration for the GUI.
// Not everything uses these values yet. But it will be implemented in the future.
//
CHARACTER_PERSISTENCE.Config.GUI_Theme = {
    BackgroundImage = { // If you add multiple options here, it will pick one at random.
        "https://msdesign.blob.core.windows.net/wallpapers/Microsoft_Nostalgic_Windows_Wallpaper_4k.jpg", // <- Will automatically download the image and cache it.
        //"gui/noicon.png", // <- Can also use materials and textures.
    },
    BackgroundBlur = true,
    BackgroundColor = Color(0, 0, 0, 255 * .95),
    ButtonCorners = Color(255, 255, 255),
    TextColor = Color(255, 255, 255),
    TitleColor = Color(255, 255, 255),
    DefaultZoom = 25, // 100 for full body view, 35 for shoulder view, 25 for head view. Min: 15, Max: 1000
}


//
///////////////////////////////////////////////////////////////////////////////
// DO NOT CHANGE ANYTHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU'RE DOING. //
///////////////////////////////////////////////////////////////////////////////
//
// The base directory for the character persistence files
// This is located in the data directory
//
CHARACTER_PERSISTENCE.Config.BaseDir = "char_persistence"
//
// The directory for the character files
// This is located in the base directory
//
CHARACTER_PERSISTENCE.Config.CharactersDir = "characters"
//
// The directory for the cache files
// This is located in the base directory
//
CHARACTER_PERSISTENCE.Config.CacheDir = "cache"
//
///////////////////////////////////////////////////////////////////////////////