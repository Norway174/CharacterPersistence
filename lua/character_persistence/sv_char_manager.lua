CHARACTER_PERSISTENCE.MsgC("Character Manager Loading.")

CHARACTER_PERSISTENCE = CHARACTER_PERSISTENCE or {}
CHARACTER_PERSISTENCE.Config = CHARACTER_PERSISTENCE.Config or {}
CHARACTER_PERSISTENCE.Modules = CHARACTER_PERSISTENCE.Modules or {}


//==========================================================
//==================== UTILITY HELPER ======================
//==========================================================

function CHARACTER_PERSISTENCE.CharacterLocation( ply, fileName )
    if not fileName then fileName = "default" end

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


    local file_folder = CHARACTER_PERSISTENCE.Config.Directory .. "/" .. foldername
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


    return true

end

