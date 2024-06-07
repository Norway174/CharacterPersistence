CHARACTER_PERSISTENCE.MsgC("Character Persistence Materials Loading.")

CHARACTER_PERSISTENCE = CHARACTER_PERSISTENCE or {}
CHARACTER_PERSISTENCE.Config = CHARACTER_PERSISTENCE.Config or {}

local materials_path = "materials/haloarmory-charpersistence/gui/"
local material_icons, _dir = file.Find(materials_path .. "*.png", "GAME")

CHARACTER_PERSISTENCE.Config.Materials = {}

if SERVER then
    for k, v in pairs(material_icons) do
        resource.AddSingleFile(materials_path .. v)

        local name = string.StripExtension( string.GetFileFromFilename( v ) )
        CHARACTER_PERSISTENCE.Config.Materials[name] = "haloarmory-charpersistence/gui/" .. v
    end
end

if CLIENT then
    for k, v in pairs(material_icons) do
        local name = string.StripExtension( string.GetFileFromFilename( v ) )
        CHARACTER_PERSISTENCE.Config.Materials[name] = Material("haloarmory-charpersistence/gui/" .. v)
    end
end