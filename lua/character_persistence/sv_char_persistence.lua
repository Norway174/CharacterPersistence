CHARACTER_PERSISTENCE.MsgC("Character Persistence Loading.")

CHARACTER_PERSISTENCE = CHARACTER_PERSISTENCE or {}
CHARACTER_PERSISTENCE.Config = CHARACTER_PERSISTENCE.Config or {}
CHARACTER_PERSISTENCE.Modules = CHARACTER_PERSISTENCE.Modules or {}


function CHARACTER_PERSISTENCE.GetCharacter( ply, foldername, fileName )
    if not fileName then fileName = "default" end
    if not foldername then foldername = ply:SteamID64() end

    if not file.IsDir(CHARACTER_PERSISTENCE.Config.Directory..foldername, "DATA") then
        print("No character data found for '" .. foldername .. "'")
        return false
    end

    -- Load the character data
    return util.JSONToTable(file.Read(CHARACTER_PERSISTENCE.Config.Directory .. foldername .. "/" .. fileName .. ".json", "DATA"))
end


function CHARACTER_PERSISTENCE.SaveCharacter( ply, fileName )
    --print("Saving character data for " .. ply:Nick() .. "...")

    if not fileName then fileName = "default" end
    local foldername = ply:SteamID64()

    local CharTable = {} --CHARACTER_PERSISTENCE.GetCharacter( ply, foldername, fileName )
    if CharTable == false then CharTable = {} end


    for ModuleName, ModuleTable in SortedPairsByMemberValue(CHARACTER_PERSISTENCE.Modules, "Order" ) do
        
        CharTable[ModuleName] = CharTable[ModuleName] or {}

        local succ, err = pcall(ModuleTable.Save, ply, CharTable[ModuleName] or {})

        if not succ then
            print("Error saving character data: '" .. ModuleName .. "'\n" .. err)
            ply:SendLua( 'CHARACTER_PERSISTENCE.MsgC("Error saving character. See server console for details.")' )
            return false
        end

        CharTable[ModuleName] = err

    end


    -- Create the folder if it doesn't exist
    if not file.IsDir(CHARACTER_PERSISTENCE.Config.Directory..foldername, "DATA") then
        file.CreateDir(CHARACTER_PERSISTENCE.Config.Directory..foldername)
    end

    -- Save the character data
    file.Write(CHARACTER_PERSISTENCE.Config.Directory .. foldername .. "/" .. fileName .. ".json", util.TableToJSON(CharTable, true))


    return true

end


function CHARACTER_PERSISTENCE.LoadCharacter( ply, fileName )
    if not fileName then fileName = "default" end
    local foldername = ply:SteamID64()

    local CharTable = CHARACTER_PERSISTENCE.GetCharacter( ply, foldername, fileName )
    if not istable(CharTable) then return false end


    for ModuleName, ModuleTable in SortedPairsByMemberValue(CHARACTER_PERSISTENCE.Modules, "Order" ) do
        if not CharTable[ModuleName] then CharTable[ModuleName] = {} end

        local succ, err = pcall(ModuleTable.Load, ply, CharTable[ModuleName] or {})

        if not succ then
            print("Error saving character data: '" .. ModuleName .. "'\n" .. err)
            ply:SendLua( 'CHARACTER_PERSISTENCE.MsgC("Error saving character. See server console for details.")' )
            return false
        end

    end


    return true

end


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
hook.Add("PlayerDisconnected", "CHARACTER_PERSISTENCE.SVSAVE", function(ply)
    CHARACTER_PERSISTENCE.SaveCharacter( ply )
    CHARACTER_PERSISTENCE.MsgC("CHARACTHER PERSISTENCE SAVED FOR " .. ply:Nick() .. " ON DISCONNECT.")
end)

hook.Add("ShutDown", "CHARACTER_PERSISTENCE.SVSAVE", function()
    for _, ply in pairs(player.GetAll()) do
        if ply.CHARACTER_PERSISTENCE_CanSave then
            CHARACTER_PERSISTENCE.SaveCharacter( ply )
        end
    end
    CHARACTER_PERSISTENCE.MsgC("CHARACTHER PERSISTENCE SAVED FOR " .. #player.GetAll() .. " PLAYERS BEFORE SHUTDOWN.")
end)

local function SaveCharTimer()
    CHARACTER_PERSISTENCE.MsgC("CHARACTHER PERSISTENCE TIMER INITIALIZED.")
    timer.Create( "SaveCharTimer", 60 * 2, 0, function( )
        for _, ply in pairs(player.GetAll()) do
            if ply.CHARACTER_PERSISTENCE_CanSave then
                local saved = CHARACTER_PERSISTENCE.SaveCharacter( ply )
                if saved then
                    ply:SendLua( 'CHARACTER_PERSISTENCE.MsgC("Character saved to server.")' )
                end
            end
        end
        CHARACTER_PERSISTENCE.MsgC("CHARACTHER PERSISTENCE SAVED FOR " .. #player.GetAll() .. " PLAYERS.")
    end )
end
hook.Add( "Initialize", "CHARACTER_PERSISTENCE.TimerInit", SaveCharTimer )
// If timer exists, call the function again
if timer.Exists( "SaveCharTimer" ) then
    SaveCharTimer()
end
