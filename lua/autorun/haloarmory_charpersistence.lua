CHARACTER_PERSISTENCE = CHARACTER_PERSISTENCE or {}
CHARACTER_PERSISTENCE.Config = CHARACTER_PERSISTENCE.Config or {}

local loadFolders = {
    "character_persistence",
}

local ignoreFiles = {}

function CHARACTER_PERSISTENCE.MsgC( ... )
    local args = {...}

    local message_table = {}

    if SERVER then
        table.insert(message_table, Color(52, 160, 211))
        table.insert(message_table, "[SV:CHAR_PERS] ")
    end
    if CLIENT then
        table.insert(message_table, Color(52, 211, 78))
        table.insert(message_table, "[CL:CHAR_PERS] ")
    end

    table.insert(message_table, Color(255, 255, 255))
    table.Add(message_table, args)
    table.insert(message_table, Color(198, 52, 211))
    table.insert(message_table, " ["..os.date('%Y-%m-%d %H:%M:%S').."]\n")

    MsgC(unpack(message_table))
end


function CHARACTER_PERSISTENCE.LoadAllFile(fileDir)
    local files, dirs = file.Find(fileDir .. "*", "LUA")
    
    for _, subFilePath in ipairs(files) do
        if (string.match(subFilePath, ".lua", -4) and not ignoreFiles[subFilePath]) then
            
            local fileRealm = string.sub(subFilePath, 1, 2)

            if SERVER and (fileRealm == "cl" or fileRealm == "sh") then
                CHARACTER_PERSISTENCE.MsgC("Adding CSLuaFile File " .. fileDir .. subFilePath)
                AddCSLuaFile(fileDir .. subFilePath)
            end

            if CLIENT and (fileRealm == "cl" or fileRealm == "sh") then
                CHARACTER_PERSISTENCE.MsgC("Including File " .. fileDir .. subFilePath)
                include(fileDir .. subFilePath)
            elseif SERVER and (fileRealm == "sv" or fileRealm == "sh") then
                CHARACTER_PERSISTENCE.MsgC("Including File " .. fileDir .. subFilePath)
                include(fileDir .. subFilePath)
            end

        end
    end
end


function CHARACTER_PERSISTENCE.LoadAllFiles()
    if not istable( loadFolders ) then return end

    for _, f in pairs( loadFolders ) do
        f = f .. "/"
        CHARACTER_PERSISTENCE.MsgC("Loading folder: " .. f)
        CHARACTER_PERSISTENCE.LoadAllFile(f)
        CHARACTER_PERSISTENCE.MsgC("Successfully loaded folder: " .. f)
    end

end


function CHARACTER_PERSISTENCE.LoadConfig()
    
    -- if CLIENT then
    --     CHARACTER_PERSISTENCE.MsgC("Config file not loaded. (Client)")
    --     return
    -- end

    CHARACTER_PERSISTENCE.Config.SelectableJobs = {}

    local configFile = "charpersistence_config.lua"
    local defaultConfigFile = "charpersistence_config.README.lua"

    if file.Exists(configFile, "LUA") then
        AddCSLuaFile(configFile)
        include(configFile)
        CHARACTER_PERSISTENCE.MsgC("Config file loaded.")
    elseif file.Exists(defaultConfigFile, "LUA") then
        CHARACTER_PERSISTENCE.MsgC("Config file not found. Using default config.")
        AddCSLuaFile(defaultConfigFile)
        include(defaultConfigFile)
    else
        CHARACTER_PERSISTENCE.MsgC("Config file not found. Something is wrong?")
    end

end


CHARACTER_PERSISTENCE.MsgC("---- CHARACTER PERSISTENCE LOADING ----")
CHARACTER_PERSISTENCE.LoadConfig()
CHARACTER_PERSISTENCE.LoadAllFiles()
CHARACTER_PERSISTENCE.MsgC("---- CHARACTER PERSISTENCE END ----")