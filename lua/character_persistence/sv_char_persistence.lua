CHARACTER_PERSISTENCE.MsgC("Character Persistence Loading.")

CHARACTER_PERSISTENCE = CHARACTER_PERSISTENCE or {}
CHARACTER_PERSISTENCE.Config = CHARACTER_PERSISTENCE.Config or {}


// LOADING
// Load on player spawn
local load_queue = {}

hook.Add("PlayerInitialSpawn", "CHARACTER_PERSISTENCE.SVLOAD", function(ply)
    load_queue[ply] = true
end)

hook.Add("SetupMove", "CHARACTER_PERSISTENCE.SVLOAD", function(ply, _, cmd)
    if load_queue[ply] and not cmd:IsForced() then
        load_queue[ply] = nil

        // Check if the player has a character saved
        timer.Simple(0.4, function()
            if CHARACTER_PERSISTENCE.LoadCharacter( ply ) then
                CHARACTER_PERSISTENCE.MsgC("CHARACTHER PERSISTENCE LOADED FOR " .. ply:Nick() .. ".")
                ply:SendLua( 'CHARACTER_PERSISTENCE.MsgC("Character loaded from the server.")' )
            else
                // If not, open the character creator
                -- if EnableCharacterCreator:GetBool() then
                --     CHARACTER_PERSISTENCE.OpenCreator( ply )
                --     CHARACTER_PERSISTENCE.MsgC("CHARACTHER PERSISTENCE NOT FOUND FOR " .. ply:Nick() .. ". OPENED CREATOR.")
                -- else 
                --     CHARACTER_PERSISTENCE.MsgC("CHARACTHER PERSISTENCE NOT FOUND FOR " .. ply:Nick() .. ". CREATOR DISABLED.")
                -- end
            end
            ply.CHARACTER_PERSISTENCE_CanSave = true
        end)

    end
end)


// SAVING
local function SaveAllCharacters()
    for _, ply in pairs(player.GetAll()) do
        if ply.CHARACTER_PERSISTENCE_CanSave then
            local saved = CHARACTER_PERSISTENCE.SaveCharacter( ply )
            if saved then
                ply:SendLua( 'CHARACTER_PERSISTENCE.MsgC("Character saved to server.")' )
            end
        end
    end
    CHARACTER_PERSISTENCE.MsgC("CHARACTHER PERSISTENCE SAVED FOR " .. #player.GetAll() .. " PLAYER(S).")
end


hook.Add("PlayerDisconnected", "CHARACTER_PERSISTENCE.SVSAVE", function(ply)
    CHARACTER_PERSISTENCE.SaveCharacter( ply )
    CHARACTER_PERSISTENCE.MsgC("CHARACTHER PERSISTENCE SAVED FOR " .. ply:Nick() .. " ON DISCONNECT.")
end)

hook.Add("ShutDown", "CHARACTER_PERSISTENCE.SVSAVE", function()
    SaveAllCharacters()
end)

local function SaveCharTimer()
    CHARACTER_PERSISTENCE.MsgC(Color(120,222,240), "CHARACTHER PERSISTENCE TIMER INITIALIZED.")
    timer.Create( "SaveCharTimer", 60 * 2, 0, function( )
        SaveAllCharacters()
    end )
end
hook.Add( "Initialize", "CHARACTER_PERSISTENCE.TimerInit", SaveCharTimer )

// If timer exists, call the function again
if timer.Exists( "SaveCharTimer" ) then
    SaveCharTimer()
end
