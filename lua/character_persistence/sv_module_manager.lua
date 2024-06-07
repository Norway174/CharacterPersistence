CHARACTER_PERSISTENCE.MsgC("Module Manager Loading.")

CHARACTER_PERSISTENCE = CHARACTER_PERSISTENCE or {}
CHARACTER_PERSISTENCE.Config = CHARACTER_PERSISTENCE.Config or {}
CHARACTER_PERSISTENCE.Modules = CHARACTER_PERSISTENCE.Modules or {}



function CHARACTER_PERSISTENCE:RegisterModule( name, order, SaveFnc, LoadFnc, NewCharFnc )

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

    if !NewCharFnc or !isfunction(NewCharFnc) then
        NewCharFnc = function() end
    end


    CHARACTER_PERSISTENCE.Modules[name] = {
        Save = SaveFnc,
        Load = LoadFnc,
        NewChar = NewCharFnc,
        Order = order
    }

end


function CHARACTER_PERSISTENCE:SetupModules()
    local files, folders = file.Find( "character_persistence/modules/*", "LUA" )

    CHARACTER_PERSISTENCE.Modules = {}

    for k, v in pairs( files ) do
        local path = "character_persistence/modules/" .. v
        include( path )
    end
end

CHARACTER_PERSISTENCE:SetupModules()