HALOARMORY.MsgC("Server CHARACTHER PERSISTENCE Loading.")

CHARACTER_PERSISTENCE = CHARACTER_PERSISTENCE or {}
CHARACTER_PERSISTENCE.Config = CHARACTER_PERSISTENCE.Config or {}
CHARACTER_PERSISTENCE.Modules = CHARACTER_PERSISTENCE.Modules or {}


function CHARACTER_PERSISTENCE:RegisterModule( name, order, SaveFnc, LoadFnc )

    if !name then
        HALOARMORY.MsgC("ERROR: No module name specified.")
        return
    end

    if !order then
        order = 50
    end

    if !SaveFnc and !isfunction(SaveFnc) then
        HALOARMORY.MsgC("ERROR: No save function specified for module " .. name)
        return
    end

    if !LoadFnc and !isfunction(LoadFnc) then
        HALOARMORY.MsgC("ERROR: No load function specified for module " .. name)
        return
    end


    CHARACTER_PERSISTENCE.Modules[name] = {
        Save = SaveFnc,
        Load = LoadFnc,
        Order = order
    }

end


function CHARACTER_PERSISTENCE:LoadModules()

    local files, folders = file.Find( "./modules/*", "LUA" )

    for k, v in pairs( files ) do
        local path = "haloarmory/character_persistence/modules/" .. v
        include( path )
    end


end