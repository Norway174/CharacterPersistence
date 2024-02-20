--[[
   _____                 _ _               
  / ____|               | | |              
 | (___   __ _ _ __   __| | |__   _____  __
  \___ \ / _` | '_ \ / _` | '_ \ / _ \ \/ /
  ____) | (_| | | | | (_| | |_) | (_) >  < 
 |_____/ \__,_|_| |_|\__,_|_.__/ \___/_/\_\
                                           
                                           
]]
local ModuleName = "Sandbox"

CHARACTER_PERSISTENCE.MsgC(Color( 207, 146, 33), "-> "..ModuleName.." Module Loading.")


CHARACTER_PERSISTENCE:RegisterModule( ModuleName, 100,
function( ply, DataToSave )
    // Save the player's Data
    // Make sure you return 'data' to save it.

    // Default Stats
    DataToSave["health"] = ply:Alive() && ply:Health() or ply:GetMaxHealth()
    DataToSave["max_health"] = ply:GetMaxHealth()
    DataToSave["armor"] = ply:Alive() && ply:Armor() or ply:GetMaxArmor()
    DataToSave["max_armor"] = ply:GetMaxArmor()

    // Model
    DataToSave["model"] = ply:GetModel()
    DataToSave["model_scale"] = ply:GetModelScale()
    DataToSave["skin"] = ply:GetSkin()
    
    DataToSave["bodygroups"] = {}
    for i = 0, ply:GetNumBodyGroups() - 1 do
        DataToSave["bodygroups"][ply:GetBodygroupName(i)] = ply:GetBodygroup(i)
    end

    // Weapons
    DataToSave["weapons"] = {}
    for k, v in pairs(ply:GetWeapons()) do
        table.insert(DataToSave["weapons"], v:GetClass())
    end
    DataToSave["ammo"] = ply:GetAmmo()

    // Position
    if ply:Alive() && (ply:GetMoveType() == MOVETYPE_WALK) then
        DataToSave["pos"] = ply:GetPos()
        DataToSave["ang"] = ply:EyeAngles()
    end
    DataToSave["last_map"] = game.GetMap() // This is used to check if the player is on the same map when they load their character

    // Speed
    DataToSave["speed"] = DataToSave["speed"] or {}
    DataToSave["speed"]["max_speed"] = ply:GetMaxSpeed()
    DataToSave["speed"]["walk_speed"] = ply:GetWalkSpeed()
    DataToSave["speed"]["slow_walk_speed"] = ply:GetSlowWalkSpeed()
    DataToSave["speed"]["run_speed"] = ply:GetRunSpeed()
    DataToSave["speed"]["jump_power"] = ply:GetJumpPower()
    DataToSave["speed"]["crouch_walk_speed"] = ply:GetCrouchedWalkSpeed()
    DataToSave["speed"]["ladder_climb_speed"] = ply:GetLadderClimbSpeed()


    // Misc
    DataToSave["misc_info"] = ply:GetPlayerInfo()

    return DataToSave
end,
function( ply, DataToLoad, GlobalData )
    // Load the player's Data

    // Default Stats
    if DataToLoad["health"] then ply:SetHealth( DataToLoad["health"] ) end
    if DataToLoad["max_health"] then ply:SetMaxHealth( DataToLoad["max_health"] ) end
    if DataToLoad["armor"] then ply:SetArmor( DataToLoad["armor"] ) end
    if DataToLoad["max_armor"] then ply:SetMaxArmor( DataToLoad["max_armor"] ) end

    // Model
    if DataToLoad["model"] then ply:SetModel( DataToLoad["model"] ) end
    if DataToLoad["model_scale"] then ply:SetModelScale( DataToLoad["model_scale"] ) end
    if DataToLoad["skin"] then ply:SetSkin( DataToLoad["skin"] ) end

    if DataToLoad["bodygroups"] then
        for k, v in pairs(DataToLoad["bodygroups"]) do
            ply:SetBodygroup( ply:FindBodygroupByName(k), v )
        end
    end

    ply:SetupHands()

    // Weapons
    if DataToLoad["weapons"] then
        ply:StripWeapons()
        for k, v in pairs(DataToLoad["weapons"]) do
            ply:Give(v)
        end
    end

    if DataToLoad["ammo"] then
        ply:StripAmmo()
        for k, v in pairs(DataToLoad["ammo"]) do
            ply:SetAmmo(v, k)
        end
    end

    // Position
    if DataToLoad["last_map"] == game.GetMap() && DataToLoad["pos"] && DataToLoad["ang"] then
        ply:SetPos( DataToLoad["pos"] )
        ply:SetEyeAngles( DataToLoad["ang"] )
    end

    // Speed
    if DataToLoad["speed"] then
        if DataToLoad["speed"]["max_speed"] then ply:SetMaxSpeed( DataToLoad["speed"]["max_speed"] ) end
        if DataToLoad["speed"]["walk_speed"] then ply:SetWalkSpeed( DataToLoad["speed"]["walk_speed"] ) end
        if DataToLoad["speed"]["slow_walk_speed"] then ply:SetSlowWalkSpeed( DataToLoad["speed"]["slow_walk_speed"] ) end
        if DataToLoad["speed"]["run_speed"] then ply:SetRunSpeed( DataToLoad["speed"]["run_speed"] ) end
        if DataToLoad["speed"]["jump_power"] then ply:SetJumpPower( DataToLoad["speed"]["jump_power"] ) end
        if DataToLoad["speed"]["crouch_walk_speed"] then ply:SetCrouchedWalkSpeed( DataToLoad["speed"]["crouch_walk_speed"] ) end
        if DataToLoad["speed"]["ladder_climb_speed"] then ply:SetLadderClimbSpeed( DataToLoad["speed"]["ladder_climb_speed"] ) end
    end
end )