--[[
  _____             _    _____  _____  
 |  __ \           | |  |  __ \|  __ \ 
 | |  | | __ _ _ __| | _| |__) | |__) |
 | |  | |/ _` | '__| |/ /  _  /|  ___/ 
 | |__| | (_| | |  |   <| | \ \| |     
 |_____/ \__,_|_|  |_|\_\_|  \_\_|     
                                       
                                       
]]
local ModuleName = "DarkRP"

CHARACTER_PERSISTENCE.MsgC(Color( 207, 146, 33), "-> "..ModuleName.." Module Loading.")


CHARACTER_PERSISTENCE:RegisterModule( ModuleName, 50,
function( ply, DataToSave )
    // Save the player's Data
    // Make sure you return 'data' to save it.

    if not DarkRP then return end

    // Default Stats
    DataToSave["nick"] = ply:Nick()
    DataToSave["job"] = team.GetName( ply:Team() )
    DataToSave["money"] = ply:getDarkRPVar("money") 

    // Extra DarkRP Stats
    DataToSave["license"] = ply:getDarkRPVar("HasGunlicense")
    DataToSave["wanted"] = ply:getDarkRPVar("wanted")
    DataToSave["wantedreason"] = ply:getDarkRPVar("wantedReason")

    // HALOARMORY Shield Support
    DataToSave["shield"] = ply:getJobTable().spartan_shield

    // MRS Support
    if MRS and ply.MRSOGName then
        DataToSave["nick"] = ply:MRSOGName()
    end

    return DataToSave
end,
function( ply, DataToLoad, GlobalData )
    // Load the player's Data

    if not DarkRP then return end
    
    // Default Stats
    if DataToLoad["nick"] then ply:setRPName( DataToLoad["nick"] ) end
    if DataToLoad["money"] then ply:setDarkRPVar("money", DataToLoad["money"]) end

    // Very complicated hack to set the job. But it works.
    // Basically this: https://github.com/FPtje/DarkRP/blob/52f01d366cdff7adbf48dbe4836ce47694a6320d/gamemode/modules/jobs/sv_jobs.lua#L5
    // But without all the extra overhead functionality. And skips a lot of checks, and other function calls.
    for key, value in pairs(RPExtraTeams) do
        if value.name == DataToLoad["job"] then
            local TEAM = RPExtraTeams[key]
            if TEAM then
                ply:updateJob(TEAM.name)
                ply:setSelfDarkRPVar("salary", TEAM.salary)
                ply:SetTeam(key)
                player_manager.SetPlayerClass(ply, TEAM.playerClass or "player_darkrp")
                ply:applyPlayerClassVars(false)
                ply.LastJob = CurTime()

                if isfunction(TEAM.PlayerSpawn) then
                     TEAM.PlayerSpawn(ply)
                end
            end
            break // Break the loop when job has been found and set.
        end
    end

    // Extra DarkRP Stats
    if DataToLoad["license"] then ply:setDarkRPVar("HasGunlicense", DataToLoad["license"]) end
    if DataToLoad["wanted"] then ply:setDarkRPVar("wanted", DataToLoad["wanted"]) end
    if DataToLoad["wantedreason"] then ply:setDarkRPVar("wantedReason", DataToLoad["wantedreason"]) end


    // HALOARMORY Shield Support
    if DataToLoad["shield"] then
        local shield_func = hook.GetTable()["PlayerLoadout"]["DRCShield_ply"] // Get the shield hook manually.
        if isfunction(shield_func) then shield_func(ply) end
    end

end )