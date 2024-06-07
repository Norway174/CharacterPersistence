CHARACTER_PERSISTENCE.MsgC("Character GUI Utils Loading.")

CHARACTER_PERSISTENCE = CHARACTER_PERSISTENCE or {}
CHARACTER_PERSISTENCE.Config = CHARACTER_PERSISTENCE.Config or {}

CHARACTER_PERSISTENCE.GUI = CHARACTER_PERSISTENCE.GUI or {}


---------------------------------------------------------------------------------------------------------------------------------------------

surface.CreateFont( "CharCreatorLarge", {
    font = "Arial", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 45,
    weight = 500,
} )


surface.CreateFont( "CharCreatorMedium", {
    font = "Tahoma", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 20,
    weight = 500,
} )

---------------------------------------------------------------------------------------------------------------------------------------------

local blur = Material("pp/blurscreen")

function CHARACTER_PERSISTENCE.GUI.RenderBlur(panel, inn, density, alpha)
    local x, y = panel:LocalToScreen(0, 0)
    surface.SetDrawColor(255, 255, 255, alpha)
    surface.SetMaterial(blur)

    for i = 1, 3 do
        blur:SetFloat("$blur", (i / inn) * density)
        blur:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------

function CHARACTER_PERSISTENCE.GUI.FormatCharName(CharTable)
    local NameText = LocalPlayer():Nick()
    if DarkRP and istable(CharTable) and istable(CharTable.DarkRP) and isstring(CharTable.DarkRP.nick) then
        NameText = CharTable.DarkRP.nick
    end
    return NameText
end

function CHARACTER_PERSISTENCE.GUI.FormatJobName(CharTable)
    local NameText = LocalPlayer():Team()
    if DarkRP and istable(CharTable) and istable(CharTable.DarkRP) and isstring(CharTable.DarkRP.job) then
        NameText = CharTable.DarkRP.job
    end
    return NameText
end


function CHARACTER_PERSISTENCE.GUI.DrawFrame(x, y, w, h, lw, color, otcolor)
    surface.SetDrawColor(color)
    surface.DrawOutlinedRect(x, y, w, h)
    surface.SetDrawColor(otcolor)

    if lw then
        surface.DrawLine(x, y, x + lw, y)
        surface.DrawLine(w + x - 1, y, w + x - lw - 1, y)
        surface.DrawLine(x, y + h - 1, x + lw, y + h - 1)
        surface.DrawLine(w + x - 1, y + h - 1, w + x - lw - 1, y + h - 1)
        surface.DrawLine(x, y, x, y + lw)
        surface.DrawLine(w + x - 1, y, w + x - 1, y + lw)
        surface.DrawLine(x, y, x, y + lw)
        surface.DrawLine(w + x - 1, y + h - 1, w + x - 1, y + h - lw - 1)
        surface.DrawLine(x, y + h - 1, x, y + h - lw - 1)
    end
end

function CHARACTER_PERSISTENCE.GUI.AdditiveColor(color1, color2, subtract)
    if subtract then
        return Color(color1.r - color2.r, color1.g - color2.g, color1.b - color2.b, color1.a - color2.a)
    else
        return Color(color1.r + color2.r, color1.g + color2.g, color1.b + color2.b, color1.a + color2.a)
    end
    //return Vector(color1:ToVector() - color2:ToVector()):ToColor()
end