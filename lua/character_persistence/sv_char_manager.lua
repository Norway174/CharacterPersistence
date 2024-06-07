CHARACTER_PERSISTENCE.MsgC("Character Manager Loading.")

CHARACTER_PERSISTENCE = CHARACTER_PERSISTENCE or {}
CHARACTER_PERSISTENCE.Config = CHARACTER_PERSISTENCE.Config or {}
CHARACTER_PERSISTENCE.Modules = CHARACTER_PERSISTENCE.Modules or {}


//CHARACTER_PERSISTENCE.Config.BaseDir = "char_persistence"
//CHARACTER_PERSISTENCE.Config.CharactersDir = "characters"
//CHARACTER_PERSISTENCE.Config.CacheDir = "cache"


//==========================================================
//==================== UTILITY HELPER ======================
//==========================================================

function CHARACTER_PERSISTENCE.CharacterLocation( ply, fileName )
    if not fileName then fileName = ply:GetNWString("char_persistence", "") end

    if not CHARACTER_PERSISTENCE.Config.CharacterSlots[fileName] then
        ErrorNoHalt("Invalid character slot name.", tostring(ply), tostring(fileName))
        return "", "", ""
    end

    // Ply can either be a player or a string. If it's a string, it's the foldername.
    // If it's a player, it's the player's SteamID64.
    local foldername = ""
    
    if type(ply) == "string" then
        foldername = ply
    elseif IsValid(ply) and ply.SteamID64 then
        foldername = ply:SteamID64()
    else
        ErrorNoHalt("Invalid player or foldername.", tostring(ply), tostring(fileName))
        return "", "", ""
    end

    local baseDir = CHARACTER_PERSISTENCE.Config.BaseDir
    local charDir = baseDir .. "/" .. CHARACTER_PERSISTENCE.Config.CharactersDir


    local file_folder = charDir .. "/" .. foldername
    local file_name = "/" .. fileName .. ".json"

    return file_folder, file_name, foldername
end


//==========================================================
//======================== GETTING =========================
//==========================================================

// Get a single character for a player
function CHARACTER_PERSISTENCE.GetCharacter( ply, fileName )
    local file_folder, file_path, foldername = CHARACTER_PERSISTENCE.CharacterLocation( ply, fileName )


    if (not file.IsDir(file_folder, "DATA")) or (not file.Exists(file_folder .. file_path, "DATA")) then
        local player_name = {Color(255,255,255), " (", Color(197,13,0), "Unknown", Color(255,255,255), ")"}
        if IsValid(ply) and ply.Nick then
            player_name = {Color(255,255,255), " (", Color(197,112,0), ply:Nick(), Color(255,255,255), ")"}
        end

        local folderTrace = {
            Color(37,198,209), foldername, Color(255,255,255), "/", Color(37,209,89), fileName, unpack(player_name)
        }

        return false, {"No character data found for: ", unpack(folderTrace)}
    end

    -- Load the character data
    return util.JSONToTable(file.Read(file_folder..file_path, "DATA"))
end

// Get all characters for a player
function CHARACTER_PERSISTENCE.GetAllCharacters( ply )

    // Get each character for the player from the CHARACTER_PERSISTENCE.Config.CharacterSlots table

    local characters = {}

    for slotName, slotTable in pairs( CHARACTER_PERSISTENCE.Config.CharacterSlots ) do

        characters[slotName] = CHARACTER_PERSISTENCE.GetCharacter( ply, slotName ) or { 
            ["Status"] = false,
            ["Message"] = "No Character Data"
        }
        
    end

    // TODO: Implement this
    return characters

end



//==========================================================
//======================== SAVING ==========================
//==========================================================
function CHARACTER_PERSISTENCE.SaveCharacter( ply, fileName )
    --print("Saving character data for " .. ply:Nick() .. "...")

    // Get the old character data
    local CharTable = CHARACTER_PERSISTENCE.GetCharacter( ply, fileName )
    if CharTable == false then CharTable = {} end

    // Request the new character data to save
    for ModuleName, ModuleTable in SortedPairsByMemberValue(CHARACTER_PERSISTENCE.Modules, "Order" ) do
        
        CharTable[ModuleName] = CharTable[ModuleName] or {}

        local succ, responseData = pcall(ModuleTable.Save, ply, CharTable[ModuleName])

        if not succ then
            ErrorNoHaltWithStack( responseData )
            ply:SendLua( 'CHARACTER_PERSISTENCE.MsgC("Error saving character. See server console for details.")' )
            return false, {"Error saving character data: ", Color(14, 113, 126), ModuleName, Color(255, 255, 255), responseData}
        end

        CharTable[ModuleName] = responseData

    end

    // Get the details of where to save the character data
    local file_folder, file_path, foldername = CHARACTER_PERSISTENCE.CharacterLocation( ply, fileName )

    -- Create the folder if it doesn't exist
    if not file.IsDir(file_folder, "DATA") then
        file.CreateDir(file_folder)
    end

    -- Save the character data
    file.Write(file_folder..file_path, util.TableToJSON(CharTable, true))


    return true

end


//==========================================================
//======================== LOADING =========================
//==========================================================
function CHARACTER_PERSISTENCE.LoadCharacter( ply, fileName )

    local CharTable, CharErr = CHARACTER_PERSISTENCE.GetCharacter( ply, fileName )
    if not istable(CharTable) then return false, CharErr end


    for ModuleName, ModuleTable in SortedPairsByMemberValue(CHARACTER_PERSISTENCE.Modules, "Order" ) do
        if not CharTable[ModuleName] then CharTable[ModuleName] = {} end

        local succ, err = pcall(ModuleTable.Load, ply, CharTable[ModuleName] or {})

        if not succ then
            ErrorNoHaltWithStack( err )
            return false, {"Error loading character data: ", Color(14, 113, 126), ModuleName, Color(255, 255, 255), err}
        end
        

    end

    ply:SetNWString("char_persistence", fileName)

    return true

end

//==========================================================
//===================== NEW CHARACTER ======================
//==========================================================
function CHARACTER_PERSISTENCE.NewCharacter( ply, slotName, PlyName, PlyTeam, PlyModel, PlySkin, PlyBodygroups )

    // Check if the SlotName is valid
    if not CHARACTER_PERSISTENCE.Config.CharacterSlots[slotName] then
        ErrorNoHalt("Invalid character slot name.", tostring(ply), tostring(slotName))
        return false, {"Invalid character slot name."}
    end

    // Check if CanUse is not a function. If it's not, make it a function.
    if type(CHARACTER_PERSISTENCE.Config.CharacterSlots[slotName].CanUse) ~= "function" then
        local canUse = CHARACTER_PERSISTENCE.Config.CharacterSlots[slotName].CanUse
        CHARACTER_PERSISTENCE.Config.CharacterSlots[slotName].CanUse = function(_ply)
            return canUse
        end
    end

    // Check if ply CanUse the slot
    if not CHARACTER_PERSISTENCE.Config.CharacterSlots[slotName].CanUse(ply) then
        ErrorNoHalt("Player cannot use this character slot.", tostring(ply), tostring(slotName))
        return false, {"Player cannot use this character slot."}
    end

    // Check if the player has a character in this slot
    local CharTable = CHARACTER_PERSISTENCE.GetCharacter( ply, slotName )
    if CharTable then
        ErrorNoHalt("Player already has a character in this slot.", tostring(ply), tostring(slotName))
        return false, {"Player already has a character in this slot."}
    end

    // Create the character data
    CharTable = {}

    CharTable["nick"] = PlyName
    CharTable["job"] = PlyTeam
    CharTable["model"] = PlyModel
    CharTable["skin"] = PlySkin
    CharTable["bodygroups"] = PlyBodygroups



    for ModuleName, ModuleTable in SortedPairsByMemberValue(CHARACTER_PERSISTENCE.Modules, "Order" ) do
        local succ, err = pcall(ModuleTable.NewChar, ply, CharTable)

        if not succ then
            ErrorNoHaltWithStack( err )
        end
    end

    ply:SetNWString("char_persistence", slotName)

    CHARACTER_PERSISTENCE.SaveCharacter( ply, slotName )

    return true

end

//==========================================================
//====================== DELETE CHAR =======================
//==========================================================
function CHARACTER_PERSISTENCE.DeleteCharacter( ply, fileName )

    local file_folder, file_path, foldername = CHARACTER_PERSISTENCE.CharacterLocation( ply, fileName )

    if (not file.IsDir(file_folder, "DATA")) or (not file.Exists(file_folder .. file_path, "DATA")) then
        return false, {"No character data found."}
    end

    file.Delete(file_folder .. file_path)

    if ply:GetNWString("char_persistence", "") == fileName then
        ply:SetNWString("char_persistence", "")
    end

    return true

end

//==========================================================
//====================== CONCOMMANDS =======================
//==========================================================

concommand.Add("char_persistence_load", function(ply, cmd, args)

    args = table.concat(args, " ")

    local fileName = args or ply:GetNWString("char_persistence", "")
    if !CHARACTER_PERSISTENCE.Config.CharacterSlots[fileName] then
        ply:SendLua( 'CHARACTER_PERSISTENCE.MsgC("No character to load.")' )
        return
    end

    local success, err_msg = CHARACTER_PERSISTENCE.LoadCharacter( ply, fileName )

    if success then
        ply:SendLua( 'CHARACTER_PERSISTENCE.MsgC("Character loaded from the server.")' )
    else
        CHARACTER_PERSISTENCE.MsgC("Error loading character: ", unpack(err_msg))
        ply:SendLua( 'CHARACTER_PERSISTENCE.MsgC("Error loading character. See server console for details.")' )
    end

end)


concommand.Add("char_persistence_save", function(ply, cmd, args)

    args = table.concat(args, " ")
    if args == "" then args = nil end

    local fileName = args or ply:GetNWString("char_persistence", "")
    if fileName == "" then
        ply:SendLua( 'CHARACTER_PERSISTENCE.MsgC("No character to save.")' )
        return
    end

    if !CHARACTER_PERSISTENCE.Config.CharacterSlots[fileName] then
        ply:SendLua( 'CHARACTER_PERSISTENCE.MsgC("Invalid character slot name.")' )
        return
    end

    local success, err_msg = CHARACTER_PERSISTENCE.SaveCharacter( ply, fileName )

    if success then
        ply:SendLua( 'CHARACTER_PERSISTENCE.MsgC("Character saved to server.")' )
    else
        CHARACTER_PERSISTENCE.MsgC("Error saving character: ", unpack(err_msg))
        ply:SendLua( 'CHARACTER_PERSISTENCE.MsgC("Error saving character. See server console for details.")' )
    end

end)


concommand.Add("char_persistance_delete", function(ply, cmd, args)

    // Check if the character slot is valid
    local fileName = table.concat(args, " ")
    if !CHARACTER_PERSISTENCE.Config.CharacterSlots[fileName] then
        ply:SendLua( 'CHARACTER_PERSISTENCE.MsgC("No character to delete.")' )
        return
    end

    local success, err_msg = CHARACTER_PERSISTENCE.DeleteCharacter( ply, fileName )

    if success then
        ply:SendLua( 'CHARACTER_PERSISTENCE.MsgC("Character deleted.")' )
    else
        CHARACTER_PERSISTENCE.MsgC("Error deleting character: ", unpack(err_msg))
        ply:SendLua( 'CHARACTER_PERSISTENCE.MsgC("Error deleting character. See server console for details.")' )
    end

end)
