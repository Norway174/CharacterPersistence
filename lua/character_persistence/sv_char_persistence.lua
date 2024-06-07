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
            local auto_Load = ply:GetInfo( "char_persistence_autoload" )
            if auto_Load ~= "" then
                // Check if auto_Load is a valid slot name
                if CHARACTER_PERSISTENCE.Config.CharacterSlots[auto_Load] then
                    CHARACTER_PERSISTENCE.LoadCharacter( ply, auto_Load )
                    CHARACTER_PERSISTENCE.MsgC("CHARACTHER PERSISTENCE LOADED FOR " .. ply:Nick() .. ".")
                    ply:SendLua( 'CHARACTER_PERSISTENCE.MsgC("Character loaded from the server.")' )
                else
                    CHARACTER_PERSISTENCE.MsgC("CHARACTHER PERSISTENCE NOT FOUND FOR " .. ply:Nick() .. ". INVALID SLOT NAME.")
                    ply:ConCommand("char_persistence_open")
                end
            else
                ply:ConCommand("char_persistence_open")
            end
        end)

    end
end)


// SAVING
local function SaveAllCharacters()
    local SavedForNum = 0
    local FailedSave = {}

    for _, ply in pairs(player.GetAll()) do
        local fileName = ply:GetNWString("char_persistence", "")
        if fileName == "" then
            table.insert(FailedSave, ply:Nick())
            continue
        end

        local saved = CHARACTER_PERSISTENCE.SaveCharacter( ply )
        if saved then
            ply:SendLua( 'CHARACTER_PERSISTENCE.MsgC("Character saved to server.")' )
            SavedForNum = SavedForNum + 1
        end
        
    end

    CHARACTER_PERSISTENCE.MsgC("CHARACTHER PERSISTENCE SAVED FOR " .. SavedForNum .. " PLAYER(S).")
    if #FailedSave > 0 then
        CHARACTER_PERSISTENCE.MsgC("CHARACTHER PERSISTENCE NOT FOUND FOR " .. table.concat(FailedSave, ", ") .. ".")
    end
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
