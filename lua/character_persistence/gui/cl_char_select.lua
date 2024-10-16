CHARACTER_PERSISTENCE.MsgC("Character Select GUI Loading.")

CHARACTER_PERSISTENCE = CHARACTER_PERSISTENCE or {}
CHARACTER_PERSISTENCE.Config = CHARACTER_PERSISTENCE.Config or {}


CHARACTER_PERSISTENCE.WindowFrame = CHARACTER_PERSISTENCE.WindowFrame or {}
CHARACTER_PERSISTENCE.WindowFrameBackground = CHARACTER_PERSISTENCE.WindowFrameBackground or {}


local serverIP = game.GetIPAddress()
serverIP = string.gsub(serverIP, ":", "_") // convert all colons to underscores

local char_persistence_autoload = CreateClientConVar("char_persistence_autoload_" .. serverIP, "", true, true)
local char_persistence_autoload_server = CreateClientConVar("char_persistence_autoload", char_persistence_autoload:GetString(), false, true)

char_persistence_autoload_server:Revert()

local selected_char = nil

local CharactersCache = {}

local GUI_Theme = {
    BackgroundImage = {
        "https://msdesign.blob.core.windows.net/wallpapers/Microsoft_Nostalgic_Windows_Wallpaper_4k.jpg",
        //"https://aboutmurals.ca/wp-content/uploads/2021/08/Fall-Wallpaper-in-a-Nature-Themed-Room-from-About-Murals.jpg",
        //"https://images3.alphacoders.com/133/1332803.png",
        //"gui/noicon.png",
    },
    BackgroundBlur = true,
    BackgroundColor = Color(0, 0, 0, 255 * .95),
    ButtonCorners = Color(255, 255, 255),
    TextColor = Color(255, 255, 255),
    TitleColor = Color(255, 255, 255),
    DefaultZoom = 25, // 100 for full body view, 35 for shoulder view, 25 for head view. Min: 15, Max: 1000
}

//GUI_Theme.BackgroundColor = Color(0, 0, 0, 255 * .8)

-- Initialize the camera distance and angles
local camDistance = CHARACTER_PERSISTENCE.Config.GUI_Theme.DefaultZoom or GUI_Theme.DefaultZoom or 100
local pitch = 0
local yaw = 0
local centerOffsetZ = 0

-- Reset the view to the initial state
local function CharacterModel_ResetView()
    camDistance = CHARACTER_PERSISTENCE.Config.GUI_Theme.DefaultZoom or GUI_Theme.DefaultZoom or 100
    pitch = 0
    yaw = 0
    centerOffsetZ = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------


local function MakeNewCharacter(ParentFrame, CharSlot)

    if !IsValid(ParentFrame) then return end
    ParentFrame:Clear()

    selected_char = CharSlot

    // Display the character name as a header
    local CharacterName = vgui.Create("DPanel", ParentFrame)
    CharacterName:Dock(TOP)
    CharacterName:SetTall(45)

    local prettyName = CHARACTER_PERSISTENCE.Config.CharacterSlots[CharSlot].PrintName

    CharacterName.Paint = function(self, w, h)
        draw.SimpleText(prettyName, "CharCreatorMedium", w * .5, 5, GUI_Theme.TitleColor, TEXT_ALIGN_CENTER)

        --draw.RoundedBox(2, 0, 0, w, h, Color(15, 15, 15, 255 * .8))
    end



    local NewCharacterContainer = vgui.Create("DPanel", ParentFrame)
    NewCharacterContainer:Dock(FILL)

    local wid = ParentFrame:GetWide() * .3
    local hei = ParentFrame:GetTall() * .4

    --NewCharacterContainer:DockPadding(wid, hei, wid, hei)

    NewCharacterContainer:InvalidateLayout(true)

    NewCharacterContainer.Paint = function(self, w, h)
        --draw.RoundedBox(0, 0, 0, w, h, Color(219, 107, 107, 255 * .8))
    end


    // Create a button in the center of the screen
    local NewCharacterButton = vgui.Create("DButton", NewCharacterContainer)
    //NewCharacterButton:Dock(FILL)
    NewCharacterButton:SetSize(400, 120)
    NewCharacterButton:SetText("")
    NewCharacterButton:Center()
    NewCharacterButton:SetPos(wid, hei)

    local icon_Size = 45

    NewCharacterButton.Paint = function(self, w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color(15, 15, 15, 255 * .8))
        if self:IsHovered() then
            draw.RoundedBox(2, 0, 0, w, h, Color(37, 37, 37, 255 * .8))
        end
        CHARACTER_PERSISTENCE.GUI.DrawFrame(0, 0, w, h, 10, Color(0, 0, 0, 0), GUI_Theme.ButtonCorners)

        surface.SetDrawColor( Color(233, 233, 233) )
        surface.SetMaterial( CHARACTER_PERSISTENCE.Config.Materials["person_add"] )
        surface.DrawTexturedRect((w * .5) - (icon_Size * .5) - 165 + 20, (h * .5) - (icon_Size * .5), icon_Size, icon_Size)

        draw.SimpleText("CREATE NEW", "CharCreatorLarge", w * .5 + 20, h * .5, GUI_Theme.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    NewCharacterButton.DoClick = function(self, button)
        surface.PlaySound("ui/buttonclick.wav")
        CHARACTER_PERSISTENCE.NewCharacter( CharSlot )
    end


    
    local oLayout = CHARACTER_PERSISTENCE.WindowFrame.PerformLayout
    CHARACTER_PERSISTENCE.WindowFrame.PerformLayout = function(self, w, h)
        oLayout(self, w, h)

        if IsValid(ParentFrame) then
            wid = NewCharacterContainer:GetWide() * .3
            hei = NewCharacterContainer:GetTall() * .4
        
            if IsValid(NewCharacterButton) then
                --NewCharacterContainer:DockPadding(wid, hei, wid, hei)
                NewCharacterButton:SetPos(wid, hei)
            end
        end

    end

end

//---------------------------------------------------------------------------------------------------------------------------------------------


local function MakeCharacterDetails(ParentFrame, CharTable, CharSlot)

    if !IsValid(ParentFrame) then return end

    //PrintTable(CharTable)

    ParentFrame:Clear()

    local NameText = CHARACTER_PERSISTENCE.GUI.FormatCharName(CharTable)
    local JobText = CHARACTER_PERSISTENCE.GUI.FormatJobName(CharTable)

    selected_char = CharSlot

    local CharacterDetails = vgui.Create("DPanel", ParentFrame)
    CharacterDetails:Dock(FILL)
    CharacterDetails:SetSize(ParentFrame:GetWide(), ParentFrame:GetTall())

    CharacterDetails.Paint = function(self, w, h)
        --draw.RoundedBox(0, 0, 0, w, h, Color(219, 107, 107, 255 * .8))
        
    end

    // Display the character name as a header
    local CharacterName = vgui.Create("DPanel", CharacterDetails)
    CharacterName:Dock(TOP)
    CharacterName:SetTall(45)

    CharacterName.Paint = function(self, w, h)
        draw.SimpleText(NameText, "CharCreatorMedium", w * .5, 5, GUI_Theme.TitleColor, TEXT_ALIGN_CENTER)

        --draw.RoundedBox(2, 0, 0, w, h, Color(15, 15, 15, 255 * .8))
    end



    -- Display the character model
    local CharacterModel = vgui.Create("DModelPanel", CharacterDetails)
    CharacterModel:Dock(FILL)
    CharacterModel:SetSize(CharacterDetails:GetWide(), CharacterDetails:GetTall())
    CharacterModel:DockMargin(5, 0, 0, 5)

    CharacterModel:SetFOV(30)
    CharacterModel:SetDirectionalLight(BOX_RIGHT, Color(255, 189, 135))
    CharacterModel:SetDirectionalLight(BOX_LEFT, Color(125, 182, 252))
    CharacterModel:SetAmbientLight(Vector(-64, -64, -64))
    CharacterModel:SetAnimated(true)
    CharacterModel:SetCursor("arrow")
    CharacterModel.Angles = Angle(0, 0, 0)

    // Set the model - required
    local Player_model = "models/player/kleiner.mdl"
    if istable(CharTable) and istable(CharTable.Sandbox) and isstring(CharTable.Sandbox.model) then
        Player_model = CharTable.Sandbox.model
    end
    CharacterModel:SetModel(Player_model)

    // Set the skin - optional
    if istable(CharTable) and istable(CharTable.Sandbox) and isnumber(CharTable.Sandbox.skin) then
        CharacterModel.Entity:SetSkin(CharTable.Sandbox.skin)
    end

    // Set the bodygroups - optional
    if istable(CharTable) and istable(CharTable.Sandbox) and istable(CharTable.Sandbox.bodygroups) then
        local bodygroups = CharTable.Sandbox.bodygroups
        local ent = CharacterModel.Entity

        for k, v in pairs(bodygroups) do
            local bodygroupNum = ent:FindBodygroupByName(k)
            if bodygroupNum ~= -1 then
                ent:SetBodygroup(bodygroupNum, v)
            end
        end
    end

    -- Calculate the center of the model
    local mins, maxs = CharacterModel.Entity:GetModelBounds()
    local center = (mins + maxs) / 2

    CharacterModel:SetLookAt(center)

    -- Track the last right-click time for double-click detection
    local lastRightClickTime = 0
    local doubleClickThreshold = 0.2 -- seconds

    -- Hold to rotate
    function CharacterModel:DragMousePress()
        -- Get left click
        if input.IsMouseDown(MOUSE_LEFT) then
            self.PressX, self.PressY = input.GetCursorPos()
            self.LeftPressed = true
        end
        if input.IsMouseDown(MOUSE_RIGHT) then
            self.PressX, self.PressY = input.GetCursorPos()
            self.RightPressed = true

            -- Check for double-click
            local currentTime = CurTime()
            if currentTime - lastRightClickTime < doubleClickThreshold then
                -- Double-click detected, reset the view
                CharacterModel_ResetView()
            end
            lastRightClickTime = currentTime
        end
    end

    function CharacterModel:DragMouseRelease()
        self.LeftPressed = false
        self.RightPressed = false
    end

    function CharacterModel:OnMouseWheeled(delta)
        camDistance = math.Clamp(camDistance - delta * 5, 50, 1000)
    end

    local ZoomTransitionMin, ZoomTransitionMax = 30, 90

    -- Calculate the allowable Z offset range based on model bounds
    local minZOffset = mins.z - center.z
    local maxZOffset = maxs.z - center.z

    function CharacterModel:LayoutEntity(ent)
        if (self.bAnimated) then self:RunAnimation() end

        if (self.LeftPressed) then
            local mx, my = input.GetCursorPos()
            -- Update the yaw and pitch angles based on mouse movement
            yaw = yaw + ((self.PressX or mx) - mx) * 0.8 -- Invert left-right control and increase sensitivity
            pitch = math.Clamp(pitch - ((self.PressY or my) - my) * 0.8, -89, 89) -- Normal up-down control and increase sensitivity
            self.PressX, self.PressY = mx, my
        end

        if (self.RightPressed) then
            local mx, my = input.GetCursorPos()
            -- Update the centerOffsetZ based on mouse movement up and down
            centerOffsetZ = centerOffsetZ - ((self.PressY or my) - my) * 0.1 -- Adjust 0.1 to change sensitivity
            self.PressX, self.PressY = mx, my
        end

        -- Limit the center offset
        centerOffsetZ = math.Clamp(centerOffsetZ, minZOffset, maxZOffset)

        -- Calculate the camera position using spherical coordinates
        local radiansPitch = math.rad(pitch)
        local radiansYaw = math.rad(yaw)

        -- Determine the head position
        local headPos = CharacterModel.Entity:GetBonePosition(CharacterModel.Entity:LookupBone("ValveBiped.Bip01_Head1") or 0)

        -- Interpolate between the head position and the center based on camDistance
        local selectedCenter
        if centerOffsetZ == 0 then
                if camDistance <= ZoomTransitionMin then
                selectedCenter = headPos
            elseif camDistance >= ZoomTransitionMax then
                selectedCenter = center
            else
                local t = (camDistance - ZoomTransitionMin) / (ZoomTransitionMax - ZoomTransitionMin)
                selectedCenter = LerpVector(t, headPos, center)
            end
        else
            selectedCenter = center
        end


        -- Apply the offset to the selectedCenter
        selectedCenter = selectedCenter + Vector(0, 0, centerOffsetZ)

        -- Calculate the final camera position
        local x = camDistance * math.cos(radiansPitch) * math.cos(radiansYaw)
        local y = camDistance * math.cos(radiansPitch) * math.sin(radiansYaw)
        local z = camDistance * math.sin(radiansPitch)

        CharacterModel:SetCamPos(selectedCenter + Vector(x, y, z))
        CharacterModel:SetLookAt(selectedCenter)

        CharacterModel.Entity:SetEyeTarget(selectedCenter + Vector(x, y, z))
    end






    // Right side panel with the character info
    local CharacterInfo = vgui.Create("DPanel", CharacterDetails)
    CharacterInfo:Dock(RIGHT)
    CharacterInfo:SetSize(ParentFrame:GetWide() * .5, ParentFrame:GetTall())

    CharacterInfo.Paint = function(self, w, h)
        //draw.RoundedBox(2, 0, 0, w, h, Color(15, 15, 15, 255 * .8))
    end

    ParentFrame.OnSizeChanged = function(self, w, h)
        if IsValid(CharacterModel) then
            CharacterModel:SetSize(w * .5, h)
        end
    end

    // CHARACTER DETAILS
    local CharacterListDetails = vgui.Create("DListLayout", CharacterInfo)
    CharacterListDetails:Dock(FILL)

    CharacterListDetails:DockMargin(15, 0, 0, 0)


    // Get the character name
    local CharacterDetailName = vgui.Create("DLabel", CharacterListDetails)
    CharacterDetailName:Dock(TOP)
    CharacterDetailName:SetText("Name")
    CharacterDetailName:SetColor(CHARACTER_PERSISTENCE.GUI.AdditiveColor(GUI_Theme.TextColor,Color(77,77,77, 50), true))

    CharacterDetailName.Paint = function(self, w, h)
        draw.SimpleText(NameText, "ChatFont", w * .12, h * .5, GUI_Theme.TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    // Get the job
    local CharacterDetailJob = vgui.Create("DLabel", CharacterListDetails)
    CharacterDetailJob:Dock(TOP)
    CharacterDetailJob:SetText("Job")
    CharacterDetailJob:SetColor(CHARACTER_PERSISTENCE.GUI.AdditiveColor(GUI_Theme.TextColor,Color(77,77,77, 50), true))

    CharacterDetailJob.Paint = function(self, w, h)
        draw.SimpleText(JobText, "ChatFont", w * .12, h * .5, GUI_Theme.TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end


    // Get the rank
    if MRS then
        local group = MRS.GetNWdata(LocalPlayer(), "Group")
        local rank = MRS.GetNWdata(LocalPlayer(), "Rank")
        
        if not MRS.Ranks[group] or not MRS.Ranks[group].ranks[rank] then
        // Do nothing.
        else
            local CharacterDetailRank = vgui.Create("DLabel", CharacterListDetails)
            CharacterDetailRank:Dock(TOP)
            CharacterDetailRank:SetText("Rank")
            CharacterDetailRank:SetColor(CHARACTER_PERSISTENCE.GUI.AdditiveColor(GUI_Theme.TextColor,Color(77,77,77, 50), true))

            local rank_info = MRS.Ranks[group].ranks[rank]

            CharacterDetailRank.Paint = function(self, w, h)
                draw.SimpleText(rank_info.name, "ChatFont", w * .12, h * .5, GUI_Theme.TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end

    end

    // Add DarkRP Money
    if DarkRP and CharTable.DarkRP.money then
        local CharacterDetailMoney = vgui.Create("DLabel", CharacterListDetails)
        CharacterDetailMoney:Dock(TOP)
        CharacterDetailMoney:SetText("Money")
        CharacterDetailMoney:SetColor(CHARACTER_PERSISTENCE.GUI.AdditiveColor(GUI_Theme.TextColor,Color(77,77,77, 50), true))

        CharacterDetailMoney.Paint = function(self, w, h)
            draw.SimpleText(DarkRP.formatMoney(CharTable.DarkRP.money), "ChatFont", w * .12, h * .5, GUI_Theme.TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end

    // Add a spacer
    local CharacterDetailSpacer = vgui.Create("DLabel", CharacterListDetails)
    CharacterDetailSpacer:Dock(TOP)
    CharacterDetailSpacer:SetText("")

    // Add HP and Armor
    if CharTable.Sandbox.health and CharTable.Sandbox.armor then
        // Add Container for HP and Armor
        local CharacterDetailHPArmorContainer = vgui.Create("DPanel", CharacterListDetails)
        CharacterDetailHPArmorContainer:Dock(TOP)

        CharacterDetailHPArmorContainer.Paint = function(self, w, h)
            --draw.RoundedBox(2, 0, 0, w, h, Color(15, 15, 15, 255 * .8))
        end


        // Add health
        local CharacterDetailHealth = vgui.Create("DLabel", CharacterDetailHPArmorContainer)
        CharacterDetailHealth:Dock(LEFT)
        CharacterDetailHealth:SetText("Health")
        CharacterDetailHealth:SetColor(CHARACTER_PERSISTENCE.GUI.AdditiveColor(GUI_Theme.TextColor,Color(77,77,77, 50), true))
        CharacterDetailHealth:SetWide(135)

        CharacterDetailHealth.Paint = function(self, w, h)
            draw.SimpleText(CharTable.Sandbox.health .. " / " .. CharTable.Sandbox.max_health, "ChatFont", 45, h * .5, GUI_Theme.TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        // Add armor
        local CharacterDetailArmor = vgui.Create("DLabel", CharacterDetailHPArmorContainer)
        CharacterDetailArmor:Dock(FILL)
        CharacterDetailArmor:SetText("Armor")
        CharacterDetailArmor:SetColor(CHARACTER_PERSISTENCE.GUI.AdditiveColor(GUI_Theme.TextColor,Color(77,77,77, 50), true))
        --CharacterDetailArmor:SetWide(250)

        CharacterDetailArmor.Paint = function(self, w, h)
            draw.SimpleText(CharTable.Sandbox.armor .. " / " .. CharTable.Sandbox.max_armor, "ChatFont", 45, h * .5, GUI_Theme.TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end


    // Draw a button container in CharacterInfo
    local CharacterButtonContainer = vgui.Create("DPanel", CharacterInfo)
    CharacterButtonContainer:Dock(BOTTOM)
    CharacterButtonContainer:SetSize(CharacterInfo:GetWide(), CharacterInfo:GetTall() * .36)

    CharacterButtonContainer.Paint = function(self, w, h)
        --draw.RoundedBox(2, 0, 0, w, h, Color(15, 15, 15, 255 * .8))
    end

    CharacterButtonContainer:DockPadding(10, 10, 10, 10)

    // Draw a "PLAY" button on the bottom.
    local PlayButton = vgui.Create("DButton", CharacterButtonContainer)
    PlayButton:Dock(FILL)
    --PlayButton:SetSize(CharacterButtonContainer:GetWide(), CharacterButtonContainer:GetTall())
    PlayButton:SetText("")
    --PlayButton:SetTextColor(Color(255, 255, 255))
    --PlayButton:SetFont("ChatFont")
    --PlayButton:SetContentAlignment(5)

    PlayButton.DoClick = function(self, button)
        surface.PlaySound("ui/buttonclick.wav")
        
        RunConsoleCommand("char_persistence_load", CharSlot)

        CHARACTER_PERSISTENCE.WindowFrame:Close()
    end

    PlayButton.Paint = function(self, w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color(15, 15, 15, 255 * .8))
        if self:IsHovered() then
            draw.RoundedBox(2, 0, 0, w, h, Color(37, 37, 37, 255 * .8))
        end
        CHARACTER_PERSISTENCE.GUI.DrawFrame(0, 0, w, h, 10, Color(0, 0, 0, 0), GUI_Theme.ButtonCorners)


        draw.SimpleText("PLAY", "CharCreatorLarge", w * .5, h * .5, GUI_Theme.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end


    


    // Create a delete button
    local DeleteButtonContainer = vgui.Create("DPanel", CharacterButtonContainer)
    DeleteButtonContainer:Dock(TOP)
    DeleteButtonContainer:SetHeight(40)

    DeleteButtonContainer.Paint = function(self, w, h)
    end


    local DeleteButton = vgui.Create("DButton", DeleteButtonContainer)
    DeleteButton:Dock(RIGHT)
    DeleteButton:SetWidth(40)
    DeleteButton:SetText("")

    DeleteButton.Paint = function(self, w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color(15, 15, 15, 255 * .8))
        if self:IsHovered() then
            draw.RoundedBox(2, 0, 0, w, h, Color(73, 0, 0, 255 * .8))
        end
        CHARACTER_PERSISTENCE.GUI.DrawFrame(0, 0, w, h, 10, Color(0, 0, 0, 0), GUI_Theme.ButtonCorners)

        --draw.SimpleText("DELETE", "CharCreatorMedium", w * .5, h * .5, GUI_Theme.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        // Draw an icon
        //surface.SetDrawColor(GUI_Theme.TextColor)
        surface.SetDrawColor( Color(233, 233, 233) )
        surface.SetMaterial( CHARACTER_PERSISTENCE.Config.Materials["delete"] )
        surface.DrawTexturedRect(w * .5 - 10, w * .5 - 10, 20, 20)

    end

    DeleteButton.DoClick = function(self, _button)
        surface.PlaySound("ui/buttonclick.wav")
        -- RunConsoleCommand("char_persistance_delete", CharSlot)

        -- MakeNewCharacter(ParentFrame, CharSlot)

        -- // CharactersCache[k].Status ~= false
        -- CharactersCache[CharSlot].Status = false

        -- CHARACTER_PERSISTENCE.MsgC("Attempting to delete ", Color(98,194,223), CharSlot, Color(255,255,255), "...")

        // Create a confirmation dialog container
        local ConfirmDeleteContainer = vgui.Create("DFrame", CharacterDetails)
        ConfirmDeleteContainer:SetSize( ScrW(), ScrH() )
        ConfirmDeleteContainer:SetPos( 0, 0 )
        ConfirmDeleteContainer:SetTitle( "" )
        ConfirmDeleteContainer:SetVisible( true )
        ConfirmDeleteContainer:SetDraggable( false )
        ConfirmDeleteContainer:ShowCloseButton( false )
        ConfirmDeleteContainer:MakePopup()

        function ConfirmDeleteContainer:OnMousePressed()
            --ConfirmDeleteContainer:Close()
        end

        ConfirmDeleteContainer.Paint = function(self2, w, h)
        end

        // Create a confirmation dialog
        local ConfirmDeleteGUI = vgui.Create("DFrame", ConfirmDeleteContainer)
        ConfirmDeleteGUI:SetSize(400, 250)
        ConfirmDeleteGUI:Center()
        ConfirmDeleteGUI:SetTitle("")
        --ConfirmDeleteGUI:SetDraggable(false)
        ConfirmDeleteGUI:ShowCloseButton(false) // Debug only, change to false later

        ConfirmDeleteGUI.Paint = function(self2, w, h)
            if GUI_Theme.BackgroundBlur then
                CHARACTER_PERSISTENCE.GUI.RenderBlur(self2, 1, 3, 250)
            end
            -- Draws a rounded box with the color faded_black stored above.
            draw.RoundedBox(2, 0, 0, w, h, GUI_Theme.BackgroundColor)
    
            -- Draw a header bar
            draw.RoundedBox(0, 0, 0, w, 30, Color(0, 0, 0, 255 * 1))
    
            -- Draws text in the color white.
            draw.SimpleText("Delete Character", "CharCreatorMedium", w * .5, 30 * .5, GUI_Theme.TitleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        function ConfirmDeleteGUI:Init()
            self.startTime = SysTime()
        end

        function ConfirmDeleteGUI:OnClose()
            ConfirmDeleteContainer:Close()
        end

        local ConfirmDeleteText = vgui.Create("DLabel", ConfirmDeleteGUI)
        ConfirmDeleteText:Dock(TOP)
        ConfirmDeleteText:SetText("Are you sure you want to delete this character?\nThis action is irreversible.\n\nType the character name to confirm:")
        ConfirmDeleteText:SetContentAlignment(5)
        ConfirmDeleteText:SetColor(GUI_Theme.TextColor)
        ConfirmDeleteText:SetTall(60)

        local ConfirmDeleteTextInputContainer = vgui.Create("DPanel", ConfirmDeleteGUI)
        ConfirmDeleteTextInputContainer:Dock(FILL)
        ConfirmDeleteTextInputContainer:DockMargin(25, 10, 25, 10)

        ConfirmDeleteTextInputContainer.Paint = function(self2, w, h)
            --draw.RoundedBox(2, 0, 0, w, h, Color(15, 15, 15, 255 * .8))
        end


        local ConfirmTextInput = vgui.Create("DTextEntry", ConfirmDeleteTextInputContainer)
        ConfirmTextInput:Dock(TOP)
        ConfirmTextInput:SetPlaceholderText( NameText )
        ConfirmTextInput:SetTextColor(GUI_Theme.TextColor)
        ConfirmTextInput:SetTall(40)

        ConfirmTextInput.Paint = function(self2, w, h)
            draw.RoundedBox(2, 0, 0, w, h, Color(15, 15, 15, 255 * .8))
            if self2:IsHovered() then
                draw.RoundedBox(2, 0, 0, w, h, Color(37, 37, 37, 255 * .8))
            end
            CHARACTER_PERSISTENCE.GUI.DrawFrame(0, 0, w, h, 10, Color(0, 0, 0, 0), GUI_Theme.ButtonCorners)

            if ( self2.GetPlaceholderText && self2.GetPlaceholderColor && self2:GetPlaceholderText() && self2:GetPlaceholderText():Trim() != "" && self2:GetPlaceholderColor() && ( !self2:GetText() || self2:GetText() == "" ) ) then
                local oldText = self2:GetText()
                self2:SetText( self2:GetPlaceholderText() )
                self2:DrawTextEntryText( self2:GetPlaceholderColor(), Color(0,0,0), Color(255,255,255) )
                self2:SetText( oldText )
                return
    
            end

            self2:DrawTextEntryText(GUI_Theme.TextColor, Color(89, 151, 167), GUI_Theme.TextColor)
        end


        local ConfirmDeleteButtonContainer = vgui.Create("DPanel", ConfirmDeleteGUI)
        ConfirmDeleteButtonContainer:Dock(BOTTOM)
        ConfirmDeleteButtonContainer:SetHeight(40)

        ConfirmDeleteButtonContainer.Paint = function(self2, w, h)
        end


        local ConfirmDeleteButton = vgui.Create("DButton", ConfirmDeleteButtonContainer)
        ConfirmDeleteButton:Dock(RIGHT)
        ConfirmDeleteButton:SetWidth(150)
        ConfirmDeleteButton:SetText("")

        ConfirmDeleteButton.Paint = function(self2, w, h)


            draw.RoundedBox(2, 0, 0, w, h, Color(15, 15, 15, 255 * .8))
            
            local confirmText = ConfirmTextInput:GetText()
            if confirmText ~= NameText then
                draw.RoundedBox(2, 0, 0, w, h, Color(95, 95, 95, 161))
            elseif self2:IsHovered() then
                draw.RoundedBox(2, 0, 0, w, h, Color(73, 0, 0, 255 * .8))
            end


            CHARACTER_PERSISTENCE.GUI.DrawFrame(0, 0, w, h, 10, Color(0, 0, 0, 0), GUI_Theme.ButtonCorners)

            draw.SimpleText("DELETE", "CharCreatorMedium", w * .5, h * .5, GUI_Theme.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end


        local CancelDeleteButton = vgui.Create("DButton", ConfirmDeleteButtonContainer)
        CancelDeleteButton:Dock(LEFT)
        CancelDeleteButton:SetWidth(150)
        CancelDeleteButton:SetText("")

        CancelDeleteButton.Paint = function(self2, w, h)
            draw.RoundedBox(2, 0, 0, w, h, Color(15, 15, 15, 255 * .8))
            if self2:IsHovered() then
                draw.RoundedBox(2, 0, 0, w, h, Color(37, 37, 37, 255 * .8))
            end
            CHARACTER_PERSISTENCE.GUI.DrawFrame(0, 0, w, h, 10, Color(0, 0, 0, 0), GUI_Theme.ButtonCorners)

            draw.SimpleText("CANCEL", "CharCreatorMedium", w * .5, h * .5, GUI_Theme.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        ConfirmDeleteButton.DoClick = function(self2, button)
            local confirmText = ConfirmTextInput:GetText()
            if confirmText == NameText then
                surface.PlaySound("ui/buttonclick.wav")

                RunConsoleCommand("char_persistance_delete", CharSlot)

                MakeNewCharacter(ParentFrame, CharSlot)
                // CharactersCache[k].Status ~= false
                CharactersCache[CharSlot].Status = false

                if char_persistence_autoload:GetString() == CharSlot  then
                    char_persistence_autoload:SetString("")
                    char_persistence_autoload_server:SetString("")
                    CHARACTER_PERSISTENCE.MsgC("Auto-Load set to none.")
                end

                CHARACTER_PERSISTENCE.MsgC("Attempting to delete ", Color(98,194,223), CharSlot, Color(255,255,255), "...")
                ConfirmDeleteContainer:Close()
            else
                --CHARACTER_PERSISTENCE.MsgC("Character name does not match. Please try again.")
            end
        end

        CancelDeleteButton.DoClick = function(self2, button)
            surface.PlaySound("ui/buttonclick.wav")
            ConfirmDeleteContainer:Close()
        end


    end




    // Draw a "Set Auto-Load" button on the bottom.
    local AutoLoadButton = vgui.Create("DButton", CharacterButtonContainer)
    AutoLoadButton:Dock(TOP)
    --PlayButton:SetSize(CharacterButtonContainer:GetWide(), CharacterButtonContainer:GetTall())
    AutoLoadButton:SetHeight(40)
    AutoLoadButton:SetText("")
    --AutoLoadButton:SetTextColor(GUI_Theme.TextColor)
    --AutoLoadButton:SetFont("ChatFont")
    --AutoLoadButton:SetContentAlignment(5)

    AutoLoadButton:DockMargin(0, 15, 0, 15)

    //local AutoLoad = false

    AutoLoadButton.DoClick = function(self, button)
        surface.PlaySound("ui/buttonclick.wav")
        // Create a ClientConVar to store the AutoLoad slot name, to indicate which slot to AutoLoad.
        if char_persistence_autoload:GetString() == CharSlot  then
            char_persistence_autoload:SetString("")
            char_persistence_autoload_server:SetString("")
            CHARACTER_PERSISTENCE.MsgC("Auto-Load set to none.")
        else
            char_persistence_autoload:SetString( CharSlot )
            char_persistence_autoload_server:SetString( CharSlot )
            CHARACTER_PERSISTENCE.MsgC("Auto-Load set to ", Color(98,194,223), CharSlot, Color(255,255,255), ".")
        end

        --print( char_persistence_autoload:GetString() )
        
    end



    AutoLoadButton.Paint = function(self, w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color(15, 15, 15, 255 * .8))
        if self:IsHovered() then
            draw.RoundedBox(2, 0, 0, w, h, Color(37, 37, 37, 255 * .8))
        end
        CHARACTER_PERSISTENCE.GUI.DrawFrame(0, 0, w, h, 10, Color(0, 0, 0, 0), GUI_Theme.ButtonCorners)


        -- local AutoLoad_text = "[ ]"
        -- if char_persistence_autoload:GetString() == CharSlot then
        --     AutoLoad_text = "[x]"
        -- end

        surface.SetMaterial( CHARACTER_PERSISTENCE.Config.Materials["check_box_outline"] )
        if char_persistence_autoload:GetString() == CharSlot then
            surface.SetMaterial( CHARACTER_PERSISTENCE.Config.Materials["check_box"] )
        end

        surface.SetDrawColor( Color(233, 233, 233) )
        surface.DrawTexturedRect(w * .5 - 10 - 80, h * .5 - 10, 20, 20)

        draw.SimpleText("Toggle Auto-Load", "CharCreatorMedium", w * .5, h * .5, GUI_Theme.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    

end

//----------------------------

function CHARACTER_PERSISTENCE.OpenSelector()


    local WindowFrame = CHARACTER_PERSISTENCE.WindowFrame

    if IsValid(WindowFrame) then
        WindowFrame:Remove()
    end

    // Check if CHARACTER_PERSISTENCE.Config.GUI_Theme is a table
    // If it is, merge the tables.
    if istable(CHARACTER_PERSISTENCE.Config.GUI_Theme) then
        table.Merge(GUI_Theme, CHARACTER_PERSISTENCE.Config.GUI_Theme, true)
    end


    RunConsoleCommand("char_persistence_save")


    WindowFrame = vgui.Create("DFrame")
    WindowFrame:SetSize(ScrW() * .7, ScrH() * .7)
    WindowFrame:Center()
    WindowFrame:SetTitle("")
    WindowFrame:SetDraggable(true)
    WindowFrame:ShowCloseButton(false)
    WindowFrame:SetSizable( true )
    //WindowFrame:SetScreenLock(true)

    WindowFrame:SetMinWidth( 350 )
    WindowFrame:SetMinHeight( 200 )

    WindowFrame:MakePopup()

    if GUI_Theme.BackgroundImage and GUI_Theme.BackgroundImage ~= "" then
        if IsValid(WindowFrameBackground) then
            WindowFrameBackground:Remove()
        end

        local Backgrounds = GUI_Theme.BackgroundImage
        if not istable(Backgrounds) then
            Backgrounds = {Backgrounds}
        end

        // Check if the background table is empty, if it is abort.
        if table.Count(Backgrounds) == 0 then
            return // No background for us.
        end

        // Randomly select a background image
        Backgrounds = Backgrounds[math.random(1, #Backgrounds)]

        if not isstring(Backgrounds) then
            Backgrounds = "gui/noicon.png"
        end
        
        // Create a panel that sits behind the window frame and covers the whole screen and displays the background image.
        local BackgroundPanel = vgui.Create("DFrame")
        BackgroundPanel:SetSize(ScrW(), ScrH())
        BackgroundPanel:Center()
        BackgroundPanel:SetTitle("")
        BackgroundPanel:SetDraggable(false)
        BackgroundPanel:ShowCloseButton(false)
        BackgroundPanel:SetSizable( false )
        BackgroundPanel:SetScreenLock(true)
        BackgroundPanel:SetVisible(true)

        BackgroundPanel.CustomMaterial = Material(Backgrounds, "smooth noclamp")

        if string.StartWith(Backgrounds, "http") then
            //CHARACTER_PERSISTENCE.Config.BaseDir = "char_persistence"
            //CHARACTER_PERSISTENCE.Config.CharactersDir = "characters"
            //CHARACTER_PERSISTENCE.Config.CacheDir = "cache"

            local BaseDir = CHARACTER_PERSISTENCE.Config.BaseDir
            local CacheDir = BaseDir .. "/" .. CHARACTER_PERSISTENCE.Config.CacheDir

            local crc = util.CRC(Backgrounds)

            // Check if the image 
            local fileName = "/"..crc..".png"
            // Check if the url ends with .jpg
            if string.EndsWith(Backgrounds, ".jpg") then
                fileName = "/"..crc..".jpg"
            end
            local backgroundPath = CacheDir .. fileName

            if not file.Exists(CacheDir, "DATA") then
                file.CreateDir(CacheDir)
            end

            if file.Exists(backgroundPath, "DATA") then
                BackgroundPanel.CustomMaterial = Material("data/"..backgroundPath, "smooth noclamp")
            else 
                BackgroundPanel.CustomMaterial = Material("gui/noicon.png", "smooth noclamp")
            end



            http.Fetch(Backgrounds, function(body, len, headers, code)
                if code == 200 then
                    file.Write(backgroundPath, body)
                    if IsValid(BackgroundPanel) then
                        BackgroundPanel.CustomMaterial = Material("data/"..backgroundPath, "smooth noclamp")
                    end
                end
            end)


        end


        BackgroundPanel.Paint = function(self, w, h)
            if self.CustomMaterial and not self.CustomMaterial:IsError() then
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial( self.CustomMaterial )
                surface.DrawTexturedRect(0, 0, w, h)
            end
        end

        WindowFrameBackground = BackgroundPanel
    end


    WindowFrame.Paint = function(self, w, h)
        if GUI_Theme.BackgroundBlur then
            CHARACTER_PERSISTENCE.GUI.RenderBlur(self, 1, 3, 250)
        end
        -- Draws a rounded box with the color faded_black stored above.
        draw.RoundedBox(2, 0, 0, w, h, GUI_Theme.BackgroundColor)

        -- Draw a header bar
        draw.RoundedBox(0, 0, 0, w, 30, Color(0, 0, 0, 255 * 1))

        -- Draws text in the color white.
        draw.SimpleText("Character Selector", "CharCreatorMedium", w * .5, 30 * .5, GUI_Theme.TitleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    WindowFrame.OnClose = function( self )
        if IsValid(WindowFrameBackground) then
            WindowFrameBackground:Remove()
        end
    end


    CHARACTER_PERSISTENCE.WindowFrame = WindowFrame


    // Create an exit button
    local ExitButton = vgui.Create("DButton", WindowFrame)
    ExitButton:SetSize( 30, 30 )
    ExitButton:SetPos( WindowFrame:GetWide() - 30, 0 )
    ExitButton:SetText("")

    ExitButton.Paint = function(self, w, h)
        draw.RoundedBox( 0, 0, 0, w, h, Color(97,0,0) )
        if self:IsHovered() then
            draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0,45) )
        end
        draw.SimpleText( "✕", "CharCreatorMedium", w/2, h/2, GUI_Theme.TitleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    ExitButton.DoClick = function()
        WindowFrame:Close()
    end

    local oLayout = WindowFrame.PerformLayout
    CHARACTER_PERSISTENCE.WindowFrame.PerformLayout = function(self, w, h)
        oLayout(self, w, h)
        ExitButton:SetPos( self:GetWide() - 30, 0 )
    end



    // Add a centered label that says "Loading..."
    local LoadingLabel = vgui.Create("DLabel", WindowFrame)
    LoadingLabel:SetText("Loading...")
    LoadingLabel:SetSize(WindowFrame:GetWide(), WindowFrame:GetTall())
    LoadingLabel:Center()
    LoadingLabel:SetFont("ChatFont")
    LoadingLabel:SetTextColor(GUI_Theme.TextColor)
    LoadingLabel:SetContentAlignment(5)

    // Make the number of dots after "Loading..." animate
    LoadingLabel.Think = function(self)
        if math.fmod(CurTime(), 1) < .5 then
            self:SetText("Loading.  ")
        elseif math.fmod(CurTime(), 1) < .75 then
            self:SetText("Loading.. ")
        else
            self:SetText("Loading...")
        end
    end

    CHARACTER_PERSISTENCE.SendRequest("GetAllCharacters", nil, function(CharactersCacheTmp)
        if not IsValid(WindowFrame) then return end

        LoadingLabel:Remove()

        CharactersCache = CharactersCacheTmp


        // Create two docked containers, one on the left with a width of 200 and the other on the right with a width of the rest of the window.
        // The left is for the character list and the right is for the character details.
        local CharacterListWidth = .3

        local CharacterList = vgui.Create("DPanel", WindowFrame)
        CharacterList:Dock(LEFT)
        CharacterList:SetSize(WindowFrame:GetWide() * CharacterListWidth, WindowFrame:GetTall())
        CharacterList:DockMargin(5, 10, 5, 5)

        CharacterList.Paint = function(self, w, h)
            draw.RoundedBox(2, 0, 0, w, h, Color(15, 15, 15, 255 * .8))
        end

        local CharacterDetails = vgui.Create("DPanel", WindowFrame)
        CharacterDetails:Dock(FILL)
        //CharacterDetails:SetSize(WindowFrame:GetWide() - 200, WindowFrame:GetTall())
        CharacterDetails:DockMargin(5, 10, 5, 5)

        CharacterDetails.Paint = function(self, w, h)
            draw.RoundedBox(2, 0, 0, w, h, Color(15, 15, 15, 255 * .8))
        end


        
        // Create a title bar for the character list.
        local CharacterListTitle = vgui.Create("DPanel", CharacterList)
        CharacterListTitle:Dock(TOP)
        CharacterListTitle:SetText("")
        --CharacterListTitle:SetFont("CharCreatorMedium")
        --CharacterListTitle:SetTextColor(GUI_Theme.TitleColor)
        --CharacterListTitle:SetContentAlignment(5)
        CharacterListTitle:SetSize(CharacterList:GetWide(), 32)

        
        CharacterListTitle.Paint = function(self, w, h)
            draw.SimpleText("Your Characters", "CharCreatorMedium", w * .5, 5, GUI_Theme.TitleColor, TEXT_ALIGN_CENTER)
        end

        // Create a scroll panel for the character list.
        local CharacterListScroll = vgui.Create("DScrollPanel", CharacterList)
        CharacterListScroll:Dock(FILL)

        local sbar = CharacterListScroll:GetVBar()
        function sbar:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
        end
        function sbar.btnUp:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(34, 34, 34))
        end
        function sbar.btnDown:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(34, 34, 34))
        end
        function sbar.btnGrip:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(44, 44, 44))
        end

        sbar:SetHideButtons(false)

        local firstRun = false

        // Create a list of characters.
        for k, v in SortedPairsByMemberValue(CHARACTER_PERSISTENCE.Config.CharacterSlots, "Order") do

            --print(k, v)
            --PrintTable(v)

            local CanSee = false
            if isbool(v.CanSee) then
                CanSee = v.CanSee
            elseif isfunction(v.CanSee) then
                // Try catch the function
                    local success, return_msg = pcall(v.CanSee, LocalPlayer())
                    if success then
                        CanSee = return_msg
                    end
            end

            if !CanSee then continue end

            local CanUse = false
            if isbool(v.CanUse) then
                CanUse = v.CanUse
            elseif isfunction(v.CanUse) then
                // Try catch the function
                    local success, return_msg = pcall(v.CanUse, LocalPlayer())
                    if success then
                        CanUse = return_msg
                    end
            end

            //local CharactersCache[k] = CharactersCache[k]

            local CharacterContainer = vgui.Create("DButton", CharacterListScroll)
            CharacterContainer:SetText( "" )
            CharacterContainer:Dock(TOP)
            CharacterContainer:SetSize(CharacterList:GetWide(), 100)
            CharacterContainer:DockMargin(5, 0, 5, 5)

            if !CanUse then
                CharacterContainer:SetEnabled(false)
            end

            CharacterContainer.DoClick = function(self, button)
                surface.PlaySound("ui/buttonclick.wav")
                --print("Clicked", k, #CharTable, CharTable)
                if istable(CharactersCache[k]) and CharactersCache[k].Status ~= false then
                    MakeCharacterDetails(CharacterDetails, CharactersCache[k], k)
                elseif istable(CharactersCache[k]) and CharactersCache[k].Status == false then
                    MakeNewCharacter(CharacterDetails, k)
                end
            end

            -- if !firstRun then
            --     timer.Simple(0.1, function()
            --         local selectedChar = LocalPlayer():GetNWString("char_persistence", "")
            --         print( selectedChar )

            --         if istable(CharTable) and CharTable.Status ~= false then
            --             MakeCharacterDetails(CharacterDetails, CharTable, k)
            --         elseif istable(CharTable) and CharTable.Status == false then
            --             MakeNewCharacter(CharacterDetails, k)
            --         end
            --     end)
            --     firstRun = true
            -- end

            local NameText = CHARACTER_PERSISTENCE.GUI.FormatCharName(CharactersCache[k])
            local JobText = CHARACTER_PERSISTENCE.GUI.FormatJobName(CharactersCache[k])

            CharacterContainer.Paint = function(self, w, h)
                draw.RoundedBox(2, 0, 0, w, h, Color(0, 0, 0))

                -- if k == LocalPlayer():GetNWString("char_persistence", "") then
                --     draw.RoundedBox(2, 0, 0, w, h, Color(18, 30, 37, 255 * .8))
                -- end

                if self:IsHovered() then
                    draw.RoundedBox(2, 0, 0, w, h, Color(61, 61, 61, 145))
                end

                if k == selected_char then
                    draw.RoundedBox(2, 0, 0, w, h, Color(37, 37, 37, 145))
                end

                CHARACTER_PERSISTENCE.GUI.DrawFrame(0, 0, w, h, 10, Color(0, 0, 0), GUI_Theme.ButtonCorners)

                if !CanUse then
                    draw.RoundedBox(2, 0, 0, w, h, Color(37, 37, 37, 255 * .8))

                    draw.SimpleText(v.PrintName, "ChatFont", 5, 5, CHARACTER_PERSISTENCE.GUI.AdditiveColor(GUI_Theme.TextColor,Color(77,77,77, 50), true))

                    draw.SimpleText(v.CanUseDeniedText, "ChatFont", w * .5, h * .5, CHARACTER_PERSISTENCE.GUI.AdditiveColor(GUI_Theme.TextColor,Color(77,77,77, 50), true), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                elseif CharactersCache[k].Status ~= false then

                    // Display the character name
                    draw.SimpleText(NameText, "ChatFont", 5, 5, GUI_Theme.TextColor)

                    // Display the job name
                    draw.SimpleText(JobText, "ChatFont", 5, 5 + 20, CHARACTER_PERSISTENCE.GUI.AdditiveColor(GUI_Theme.TextColor,Color(77,77,77, 50), true))

                else
                    draw.SimpleText(v.PrintName, "ChatFont", 5, 5, GUI_Theme.TextColor)

                    draw.SimpleText("Not Found", "ChatFont", w * .5, h * .5, CHARACTER_PERSISTENCE.GUI.AdditiveColor(GUI_Theme.TextColor,Color(77,77,77, 50), true), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
        
        end

        // Select either the loaded character, or the first character in the list.
        timer.Simple(0.1, function()
            local selectedChar = LocalPlayer():GetNWString("char_persistence", "")
            --print( selectedChar )

            if selectedChar ~= "" then
                local CharTable = CharactersCache[selectedChar]
                if istable(CharTable) and CharTable.Status ~= false then
                    MakeCharacterDetails(CharacterDetails, CharTable, selectedChar)
                elseif istable(CharTable) and CharTable.Status == false then
                    MakeNewCharacter(CharacterDetails, selectedChar)
                end
            end
        end)




    end)

end


// ConCommand
concommand.Add("char_persistence_open", CHARACTER_PERSISTENCE.OpenSelector)

if IsValid(CHARACTER_PERSISTENCE.WindowFrame) then
    CHARACTER_PERSISTENCE.OpenSelector()
end


// Add a menu button to the C menu
list.Set( "DesktopWindows", "CHARACTER SELECTOR", {
    title = "Character",
    icon = "haloarmory-charpersistence/gui/buttonpersonmultiple.png",
    init = function( icon, window )
        CHARACTER_PERSISTENCE.OpenSelector()
    end,
})