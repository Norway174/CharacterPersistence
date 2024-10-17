CHARACTER_PERSISTENCE.MsgC("Character Creator GUI Loading.")

CHARACTER_PERSISTENCE = CHARACTER_PERSISTENCE or {}
CHARACTER_PERSISTENCE.Config = CHARACTER_PERSISTENCE.Config or {}
CHARACTER_PERSISTENCE.Config.GUI_Theme = CHARACTER_PERSISTENCE.Config.GUI_Theme or {}

CHARACTER_PERSISTENCE.NewCharWindowFrame = CHARACTER_PERSISTENCE.NewCharWindowFrame or {}
CHARACTER_PERSISTENCE.ModelSelectorWindowFrame = CHARACTER_PERSISTENCE.ModelSelectorWindowFrame or {}


local GUI_Theme = {
	BackgroundBlur = true,
	BackgroundColor = Color(0, 0, 0, 255 * .95),
	ButtonCorners = Color(255, 255, 255),
	TextColor = Color(255, 255, 255),
	TitleColor = Color(255, 255, 255),
	TitleText = "Character Selector",
	DefaultZoom = 25, // 100 for full body view, 35 for shoulder view, 25 for head view. Min: 15, Max: 1000
}

//GUI_Theme.BackgroundColor = Color(0, 0, 0, 255 * .8)


-- Initialize the camera distance and angles
local camDistance = CHARACTER_PERSISTENCE.Config.GUI_Theme.DefaultZoom or GUI_Theme.DefaultZoom or 25
local pitch = 0
local yaw = 0
local centerOffsetZ = 0

-- Reset the view to the initial state
local function CharacterModel_ResetView()
    camDistance = CHARACTER_PERSISTENCE.Config.GUI_Theme.DefaultZoom or GUI_Theme.DefaultZoom or 25
    pitch = 0
    yaw = 0
    centerOffsetZ = 0
end


local function VerifyName(name)
    if !CHARACTER_PERSISTENCE.Config.EnforceFirstAndLastName then
        return true
    end

    local nameParts = string.Explode(" ", name)

    if #nameParts < 2 or string.len(nameParts[1]) < 3 or string.len(nameParts[2]) < 3 then
        return false, "Please enter a valid first and last name."
    elseif string.find(name, "%d") then
        return false, "Name cannot contain numbers."
    end

    return true
end




CHARACTER_PERSISTENCE.CharacterSlot = CHARACTER_PERSISTENCE.CharacterSlot or nil
function CHARACTER_PERSISTENCE.NewCharacter( CharSlot )

    if IsValid( CHARACTER_PERSISTENCE.NewCharWindowFrame ) then
        CHARACTER_PERSISTENCE.NewCharWindowFrame:Remove()
    end

    if IsValid(CHARACTER_PERSISTENCE.WindowFrame) then
        CHARACTER_PERSISTENCE.WindowFrame:Hide()
    else 
        CHARACTER_PERSISTENCE.OpenSelector()
        CHARACTER_PERSISTENCE.WindowFrame:Hide()
    end

    if IsValid( CHARACTER_PERSISTENCE.ModelSelectorWindowFrame ) then
        CHARACTER_PERSISTENCE.ModelSelectorWindowFrame:Remove()
    end

    // Check if CHARACTER_PERSISTENCE.Config.GUI_Theme is a table
    // If it is, merge the tables.
    if istable(CHARACTER_PERSISTENCE.Config.GUI_Theme) then
        table.Merge(GUI_Theme, CHARACTER_PERSISTENCE.Config.GUI_Theme, true)
    end

    CHARACTER_PERSISTENCE.CharacterSlot = CharSlot

    WindowFrame = vgui.Create("DFrame")
    WindowFrame:SetSize( CHARACTER_PERSISTENCE.WindowFrame:GetSize() )
    WindowFrame:SetPos( CHARACTER_PERSISTENCE.WindowFrame:GetPos() )
    //WindowFrame:Center()
    WindowFrame:SetTitle("")
    WindowFrame:SetDraggable(true)
    WindowFrame:ShowCloseButton(false)
    WindowFrame:SetSizable( true )
    //WindowFrame:SetScreenLock(true)

    WindowFrame:SetMinWidth( 350 )
    WindowFrame:SetMinHeight( 200 )

    WindowFrame:MakePopup()

    WindowFrame.Paint = function(self, w, h)
        if GUI_Theme.BackgroundBlur then
            CHARACTER_PERSISTENCE.GUI.RenderBlur(self, 1, 3, 250)
        end
        -- Draws a rounded box with the color faded_black stored above.
        draw.RoundedBox(2, 0, 0, w, h, GUI_Theme.BackgroundColor)

        -- Draw a header bar
        draw.RoundedBox(0, 0, 0, w, 30, Color(0, 0, 0, 255 * 1))

        -- Draws text in the color white.
        draw.SimpleText("Character Creator", "CharCreatorMedium", w * .5, 30 * .5, GUI_Theme.TitleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    WindowFrame.OnClose = function()
        CHARACTER_PERSISTENCE.WindowFrame:Show()
    end

    CHARACTER_PERSISTENCE.NewCharWindowFrame = WindowFrame


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
    CHARACTER_PERSISTENCE.NewCharWindowFrame.PerformLayout = function(self, w, h)
        oLayout(self, w, h)
        ExitButton:SetPos( self:GetWide() - 30, 0 )
    end


    if DarkRP and CHARACTER_PERSISTENCE.Config.IncludeDefaultDarkRPJob then
        CHARACTER_PERSISTENCE.Config.SelectableJobs[GAMEMODE.DefaultTeam] = true
        --table.insert(CHARACTER_PERSISTENCE.Config.SelectableJobs, 1, GAMEMODE.DefaultTeam or DarkRP.DefaultTeam)
    end


    local ModelContainerLeft = vgui.Create("DPanel", WindowFrame)
    ModelContainerLeft:Dock(FILL)
    --ModelContainerLeft:SetWide( (WindowFrame:GetWide() * .4) - 13 )
    ModelContainerLeft:DockMargin( 0, 0, 0, 0 )

    ModelContainerLeft.Paint = function(self, w, h)
        --draw.RoundedBox( 0, 0, 0, w, h, Color(109,40,40,162) )
    end


    local CharacterDetailsContainerRight = vgui.Create("DPanel", WindowFrame)
    CharacterDetailsContainerRight:Dock(RIGHT)
    CharacterDetailsContainerRight:SetWide( WindowFrame:GetWide() * .55 )
    CharacterDetailsContainerRight:DockMargin( 0, 0, 0, 0 )

    CharacterDetailsContainerRight.Paint = function(self, w, h)
        --draw.RoundedBox( 0, 0, 0, w, h, Color(43,180,116) )
    end



    -- Display the character model
    local CharacterModel = vgui.Create("DModelPanel", ModelContainerLeft)
    CharacterModel:Dock(FILL)
    --CharacterModel:SetSize(ModelContainerLeft:GetWide(), ModelContainerLeft:GetTall())
    CharacterModel:DockMargin(0, 0, 0, 0)

    CharacterModel:SetFOV(30)
    CharacterModel:SetDirectionalLight(BOX_RIGHT, Color(255, 189, 135))
    CharacterModel:SetDirectionalLight(BOX_LEFT, Color(125, 182, 252))
    CharacterModel:SetAmbientLight(Vector(-64, -64, -64))
    CharacterModel:SetAnimated(true)
    CharacterModel:SetCursor("arrow")
    CharacterModel.Angles = Angle(0, 0, 0)

    -- // Set the model - required
    local Player_model = "models/player/kleiner.mdl"
    -- if istable(CharTable) and istable(CharTable.Sandbox) and isstring(CharTable.Sandbox.model) then
    --     Player_model = CharTable.Sandbox.model
    -- end
    Player_model = LocalPlayer():GetModel()
    CharacterModel:SetModel(Player_model)

    -- // Set the skin - optional
    -- if istable(CharTable) and istable(CharTable.Sandbox) and isnumber(CharTable.Sandbox.skin) then
    --     CharacterModel.Entity:SetSkin(CharTable.Sandbox.skin)
    -- end
    CharacterModel.Entity:SetSkin(LocalPlayer():GetSkin() or 0)


    -- // Set the bodygroups - optional
    -- if istable(CharTable) and istable(CharTable.Sandbox) and istable(CharTable.Sandbox.bodygroups) then
    --     local bodygroups = CharTable.Sandbox.bodygroups
    --     local ent = CharacterModel.Entity

    --     for k, v in pairs(bodygroups) do
    --         local bodygroupNum = ent:FindBodygroupByName(k)
    --         if bodygroupNum ~= -1 then
    --             ent:SetBodygroup(bodygroupNum, v)
    --         end
    --     end
    -- end
    for k, v in pairs(LocalPlayer():GetBodyGroups()) do
        CharacterModel.Entity:SetBodygroup(v.id, LocalPlayer():GetBodygroup(v.id))
    end


    -- Calculate the center of the model
    local mins, maxs = CharacterModel.Entity:GetModelBounds()
    local center = (mins + maxs) / 2 - Vector(0, 0, -6)

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
        camDistance = math.Clamp(camDistance - delta * 5, 25, 1000)
    end

    local ZoomTransitionMin, ZoomTransitionMax = 30, 90

    -- Calculate the allowable Z offset range based on model bounds
    local minZOffset = mins.z - center.z
    local maxZOffset = maxs.z - center.z

    if CharacterModel.Entity:GetModel() == "models/error.mdl" then
        camDistance = 200
    end

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
        local headPos = CharacterModel.Entity:GetBonePosition(CharacterModel.Entity:LookupBone("ValveBiped.Bip01_Head1") or 0) + Vector(0, 0, 2)

        if CharacterModel.Entity:GetModel() == "models/error.mdl" then
            headPos = center
        end

        -- Interpolate between the head position and the center based on camDistance
        local selectedCenter = headPos
        if centerOffsetZ == 0 then
            if camDistance <= ZoomTransitionMin then
                selectedCenter = headPos
            elseif camDistance >= ZoomTransitionMax then
            --print(camDistance)
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


    // Display a character name box, let's start with a container. So we can also add a label.
    local CharacterNameContainer = vgui.Create("DPanel", CharacterDetailsContainerRight)
    CharacterNameContainer:Dock(TOP)
    CharacterNameContainer:SetTall( 60 )
    CharacterNameContainer:DockMargin( 0, 15, 0, 0 )

    CharacterNameContainer.BorderColor = Color(0,0,0,255)
    CharacterNameContainer.ErrorText = ""

    CharacterNameContainer.Paint = function(self, w, h)
        --draw.RoundedBox( 0, 0, 0, w, h, Color(204,204,204,129) )

        draw.SimpleText("Character Name", "CharCreatorMedium", 0, 0, GUI_Theme.TitleColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        if self.ErrorText != "" then
            draw.SimpleText(self.ErrorText, "DebugFixed", w-30, 30, self.BorderColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        end

        draw.RoundedBox( 0, 0, 30, w - 25, h-30, Color(0,0,0,255) )

        CHARACTER_PERSISTENCE.GUI.DrawFrame(0, 30, w - 25, h-30, 8, self.BorderColor, GUI_Theme.ButtonCorners)
    end

    local CharacterNameEntry = vgui.Create("DTextEntry", CharacterNameContainer)
    CharacterNameEntry:Dock(BOTTOM)
    CharacterNameEntry:SetTall( 30 )
    CharacterNameEntry:DockMargin( 10, 0, 25, 0 )
    --CharacterNameEntry:DockPadding( 5, 5, 5, 5 )
    CharacterNameEntry:SetText("")
    CharacterNameEntry:SetPlaceholderText("John Smith")
    CharacterNameEntry:SetUpdateOnType(true)

    CharacterNameEntry.Paint = function(self, w, h)
        --draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0,255) )

        --CHARACTER_PERSISTENCE.GUI.DrawFrame(0, 0, w, h, 10, Color(0, 0, 0), GUI_Theme.ButtonCorners)

        if ( self.GetPlaceholderText && self.GetPlaceholderColor && self:GetPlaceholderText() && self:GetPlaceholderText():Trim() != "" && self:GetPlaceholderColor() && ( !self:GetText() || self:GetText() == "" ) ) then
            local oldText = self:GetText()
            self:SetText( self:GetPlaceholderText() )
            self:DrawTextEntryText( self:GetPlaceholderColor(), Color(0,0,0), Color(255,255,255) )
            self:SetText( oldText )

            CharacterNameContainer.BorderColor = Color(0,0,0,255)
            CharacterNameContainer.ErrorText = ""

            return

        end

        self:DrawTextEntryText( GUI_Theme.TextColor, Color(146,171,207,187), Color(255,255,255) )
    end

    CharacterNameEntry.OnChange = function(self)
        local valid, errorText = VerifyName(self:GetText())
        if !valid then
            CharacterNameContainer.BorderColor = Color(255,0,0,255)
            CharacterNameContainer.ErrorText = errorText
        else
            CharacterNameContainer.BorderColor = Color(0,0,0,255)
            CharacterNameContainer.ErrorText = ""
        end

    end


    // Display a job selection dropdown box, let's start with a container. So we can also add a label.
    local CharacterJobContainer = vgui.Create("DPanel", CharacterDetailsContainerRight)
    CharacterJobContainer:Dock(TOP)
    CharacterJobContainer:SetTall( 60 )
    CharacterJobContainer:DockMargin( 0, 15, 0, 0 )

    CharacterJobContainer.BorderColor = Color(0,0,0,255)
    CharacterJobContainer.ErrorText = ""
    CharacterJobContainer.Hovered = false

    CharacterJobContainer.Paint = function(self, w, h)
        --draw.RoundedBox( 0, 0, 0, w, h, Color(204,204,204,129) )

        draw.SimpleText("Profession", "CharCreatorMedium", 0, 0, GUI_Theme.TitleColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        if self.ErrorText != "" then
            draw.SimpleText(self.ErrorText, "DebugFixed", w-30, 30, self.BorderColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        end

        draw.RoundedBox( 0, 0, 30, w - 25, h-30, Color(0,0,0,255) )

        if self.Hovered then
            draw.RoundedBox( 0, 0, 30, w - 25, h-30, Color(255,255,255,5) )
        end

        CHARACTER_PERSISTENCE.GUI.DrawFrame(0, 30, w - 25, h-30, 8, self.BorderColor, GUI_Theme.ButtonCorners)
    end

    local CharacterJobDropdown = vgui.Create("DComboBox", CharacterJobContainer)
    CharacterJobDropdown:Dock(BOTTOM)
    CharacterJobDropdown:SetTall( 30 )
    CharacterJobDropdown:DockMargin( 10, 0, 25, 0 )
    --CharacterJobDropdown:DockPadding( 5, 5, 5, 5 )
    CharacterJobDropdown:SetValue("Select a job")
    CharacterJobDropdown:SetColor( GUI_Theme.TextColor )

    CharacterJobDropdown.JobModels = {}

    CharacterJobDropdown.Paint = function(self, w, h)
        --draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0,255) )
        --CHARACTER_PERSISTENCE.GUI.DrawFrame(0, 0, w, h, 10, Color(0, 0, 0), GUI_Theme.ButtonCorners)
        --self:DrawTextEntryText( GUI_Theme.TextColor, Color(255,255,255), Color(255,255,255) )
        if self:IsHovered() then
            self:GetParent().Hovered = true
        else
            self:GetParent().Hovered = false
        end
    end

    for k, v in pairs(CHARACTER_PERSISTENCE.Config.SelectableJobs) do
        if isstring(k) then
            k = _G[k] or nil
        end
        local JobDetails = RPExtraTeams[k]

        print("Job:", k, v, JobDetails)

        if !JobDetails then continue end

        --PrintTable(JobDetails)

        local JobName = JobDetails.name or "Unknown Job"
        local JobCat = JobDetails.category or "Unknown Category"


        CharacterJobDropdown:AddChoice(JobName .. " [".. JobCat .. "]", k)
    end


    // Draw a button to open the model selector.
    local ModelSelectorButtonContainer = vgui.Create("DPanel", CharacterDetailsContainerRight)
    ModelSelectorButtonContainer:Dock(TOP)
    ModelSelectorButtonContainer:SetTall( 60 )
    ModelSelectorButtonContainer:DockMargin( 0, 15, 0, 0 )

    ModelSelectorButtonContainer.Paint = function(self, w, h)
        --draw.RoundedBox( 0, 0, 0, w, h, Color(204,204,204,129) )
        draw.SimpleText("Playermodel", "CharCreatorMedium", 0, 0, GUI_Theme.TitleColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.RoundedBox( 0, 0, 30, w - 25, h-30, Color(0,0,0,255) )
        CHARACTER_PERSISTENCE.GUI.DrawFrame(0, 30, w - 25, h-30, 8, Color(0,0,0,255), GUI_Theme.ButtonCorners)
    end

    local ModelSelectorButton = vgui.Create("DButton", ModelSelectorButtonContainer)
    ModelSelectorButton:Dock(BOTTOM)
    ModelSelectorButton:SetTall( 30 )
    ModelSelectorButton:DockMargin( 0, 0, 25, 0 )
    ModelSelectorButton:SetText("Open Model Selector")
    ModelSelectorButton:SetColor( GUI_Theme.TextColor )

    ModelSelectorButton.Paint = function(self, w, h)
        --draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0,255) )
        if self:IsHovered() then
            draw.RoundedBox( 0, 0, 0, w, h, Color(255,255,255,5) )
        end
        --CHARACTER_PERSISTENCE.GUI.DrawFrame(0, 0, w, h, 10, Color(0, 0, 0), GUI_Theme.ButtonCorners)
        self:DrawTextEntryText( GUI_Theme.TextColor, Color(255,255,255), Color(255,255,255) )
    end


    // Model options
    local ModelOptionsCategoryContainer = vgui.Create("DPanel", CharacterDetailsContainerRight)
    ModelOptionsCategoryContainer:Dock(FILL)
    ModelOptionsCategoryContainer:DockMargin( 0, 10, 0, 0 )
    --ModelOptionsCategoryContainer:SetTall( 60 )

    // Set a max height. It should not overlap the bottom docked elements.

    ModelOptionsCategoryContainer.Paint = function(self, w, h)
        --draw.RoundedBox( 0, 0, 0, w, h, Color(204,204,204,129) )
    end


    // Create a collapsible category for the model options
    local ModelOptionsCategory = vgui.Create("DCollapsibleCategory", ModelOptionsCategoryContainer)
    ModelOptionsCategory:Dock(FILL)
    ModelOptionsCategory:SetHeaderHeight( 30 )
    ModelOptionsCategory:DockMargin( 0, 0, 25, 0 )
    ModelOptionsCategory:SetLabel("")
    ModelOptionsCategory:SetExpanded(false)

    ModelOptionsCategory.Paint = function(self, w, h)
        --draw.RoundedBox( 0, 0, 0, w, h, Color(204,204,204,129) )
        draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0,255) )

        if self.Header:IsHovered() then
            draw.RoundedBox( 0, 0, 0, w, 30, Color(255,255,255,5) )
        end

        CHARACTER_PERSISTENCE.GUI.DrawFrame(0, 0, w, h, 10, Color(0, 0, 0, 0), GUI_Theme.ButtonCorners)

        draw.SimpleText("Model Options", "DermaDefault", w * .5, 30 * .5, GUI_Theme.TitleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    // Create a scrollbar container for the model options
    local ModelOptionsContainer = vgui.Create("DScrollPanel", ModelOptionsCategory )
    ModelOptionsContainer:Dock(FILL)
    ModelOptionsContainer:DockMargin( 0, 0, 0, 0 )
    --ModelOptionsContainer:SetTall( 100 )

    ModelOptionsContainer.Paint = function(self, w, h)
        --draw.RoundedBox( 0, 0, 0, w, h, Color(204,204,204,129) )
    end



    local function SetBodygroupSliders()

        ModelOptionsContainer:Clear()

        // Create a slider for the skin
        local SkinSlider = vgui.Create("DNumSlider", ModelOptionsContainer)
        SkinSlider:Dock(TOP)
        SkinSlider:SetTall( 30 )
        SkinSlider:DockMargin( 10, 0, 25, 0 )
        SkinSlider:SetText("Skin")
        SkinSlider:SetMin(0)
        SkinSlider:SetMax( CharacterModel.Entity:SkinCount() - 1 or 0 )
        SkinSlider:SetDecimals(0)
        SkinSlider:SetValue( CharacterModel.Entity:GetSkin() or 0 )

        SkinSlider.OnValueChanged = function(self, value)
            CharacterModel.Entity:SetSkin(value)
        end

        // Create a slider for each bodygroup
        local rowNum = 1
        for k, v in pairs(CharacterModel.Entity:GetBodyGroups()) do

            if v.num <= 1 then continue end

            --print(v.name, v.num)

            local BodygroupSlider = vgui.Create("DNumSlider", ModelOptionsContainer)
            BodygroupSlider:Dock(TOP)
            BodygroupSlider:SetTall( 30 )
            BodygroupSlider:DockMargin( 10, 0, 25, 0 )
            BodygroupSlider:SetText(v.name)
            BodygroupSlider:SetMin(0)
            BodygroupSlider:SetMax( v.num - 1 )
            BodygroupSlider:SetDecimals(0)
            BodygroupSlider:SetValue( CharacterModel.Entity:GetBodygroup(v.id) or 0 )


            BodygroupSlider.OnValueChanged = function(self, value)
                CharacterModel.Entity:SetBodygroup(v.id, value)
            end

            BodygroupSlider.RowNum = rowNum
            BodygroupSlider.Paint = function(self, w, h)
                if self.RowNum % 2 == 0 then
                    --draw.RoundedBox( 0, 0, 0, w, h, Color(24,24,24) )
                else
                    draw.RoundedBox( 0, 0, 0, w, h, Color(24,24,24) )
                end
            end
            rowNum = rowNum + 1

        end


    end

    --SetBodygroupSliders()



    // Do click buttons

    ModelSelectorButton.DoClick = function()
        if IsValid( CHARACTER_PERSISTENCE.ModelSelectorWindowFrame ) then
            CHARACTER_PERSISTENCE.ModelSelectorWindowFrame:Remove()
        end
        
        // Create a new window frame
        CHARACTER_PERSISTENCE.ModelSelectorWindowFrame = vgui.Create("DFrame")
        local ModelSelectorFrame = CHARACTER_PERSISTENCE.ModelSelectorWindowFrame
        ModelSelectorFrame:SetSize( 800, 600 )
        ModelSelectorFrame:Center()
        ModelSelectorFrame:SetTitle("")
        ModelSelectorFrame:SetDraggable(true)
        ModelSelectorFrame:ShowCloseButton(false)
        ModelSelectorFrame:SetSizable( true )
        
        ModelSelectorFrame:MakePopup()

        ModelSelectorFrame.Paint = function(self, w, h)
            if GUI_Theme.BackgroundBlur then
                CHARACTER_PERSISTENCE.GUI.RenderBlur(self, 1, 3, 250)
            end
            -- Draws a rounded box with the color faded_black stored above.
            draw.RoundedBox(2, 0, 0, w, h, GUI_Theme.BackgroundColor)

            -- Draw a header bar
            draw.RoundedBox(0, 0, 0, w, 30, Color(0, 0, 0, 255 * 1))

            -- Draws text in the color white.
            draw.SimpleText("Model Selector", "CharCreatorMedium", w * .5, 30 * .5, GUI_Theme.TitleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end


        // Create an exit button
        local ExitButtonModelSel = vgui.Create("DButton", ModelSelectorFrame)
        ExitButtonModelSel:SetSize( 30, 30 )
        ExitButtonModelSel:SetPos( ModelSelectorFrame:GetWide() - 30, 0 )
        ExitButtonModelSel:SetText("")

        ExitButtonModelSel.Paint = function(self, w, h)
            draw.RoundedBox( 0, 0, 0, w, h, Color(97,0,0) )
            if self:IsHovered() then
                draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0,45) )
            end
            draw.SimpleText( "✕", "CharCreatorMedium", w/2, h/2, GUI_Theme.TitleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end

        ExitButtonModelSel.DoClick = function()
            ModelSelectorFrame:Close()
        end

        local oLayoutModelSel = ModelSelectorFrame.PerformLayout
        ModelSelectorFrame.PerformLayout = function(self, w, h)
            oLayoutModelSel(self, w, h)
            ExitButtonModelSel:SetPos( self:GetWide() - 30, 0 )
        end


        // Get a list of all playermodels.
        local PlayerModels = {}

        if istable(CharacterJobDropdown.JobModels) then
            for k, v in pairs(CharacterJobDropdown.JobModels) do
                table.insert(PlayerModels, v)
            end
        end

        // Create a list of playermodels
        local ModelList = vgui.Create("DTileLayout", ModelSelectorFrame)
        ModelList:Dock(FILL)
        ModelList:DockMargin( 0, 1, 0, 0 )
        ModelList:SetSpaceX( 5 )
        ModelList:SetSpaceY( 5 )
        ModelList:SetBaseSize( 32 )

        for k, v in pairs(PlayerModels) do
            local ModelButton = ModelList:Add("SpawnIcon")
            ModelButton:SetSize( 100, 100 )
            ModelButton:SetModel(v)
            ModelButton:SetCursor("hand")
            ModelButton:SetTooltip(v)

            --ModelButton.Paint = function(self, w, h)
            --    draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0,255) )
            --end

            ModelButton.DoClick = function()
                Player_model = v
                CharacterModel:SetModel(v)

                // Copy the skin and bodygroups from the player to the model
                if LocalPlayer():GetModel() == v then
                    CharacterModel.Entity:SetSkin(LocalPlayer():GetSkin() or 0)
                    for k2, v2 in pairs(LocalPlayer():GetBodyGroups()) do
                        CharacterModel.Entity:SetBodygroup(v2.id, LocalPlayer():GetBodygroup(v2.id))
                    end
                end


                SetBodygroupSliders()

                ModelSelectorFrame:Close()
            end
        end



    end





    CharacterJobDropdown.OnSelect = function(self, index, value, data)
        --print("Selected job: ", value, data)

        local JobDetails = RPExtraTeams[data]

        if !JobDetails then
            CharacterJobContainer.BorderColor = Color(255,0,0,255)
            CharacterJobContainer.ErrorText = "Invalid job selected."
            return
        end

        CharacterJobContainer.BorderColor = Color(0,0,0,0)
        CharacterJobContainer.ErrorText = ""

        -- Set the model - required
        self.JobModels = JobDetails.model
        if istable(self.JobModels) then
            Player_model = table.Random(self.JobModels)
        else
            Player_model = self.JobModels
        end

        if isstring(Player_model) then
            Player_model = {Player_model}
        end

        if CharacterModel:GetModel() ~= Player_model and not table.HasValue(self.JobModels, CharacterModel:GetModel()) then

            // Check if the players current model is in the job models list, if so, set it to that model.
            if table.HasValue(self.JobModels, LocalPlayer():GetModel()) then
                Player_model = LocalPlayer():GetModel()
                CharacterModel:SetModel(Player_model)

                // Copy the skin and bodygroups from the player to the model
                CharacterModel.Entity:SetSkin(LocalPlayer():GetSkin() or 0)
                for k, v in pairs(LocalPlayer():GetBodyGroups()) do
                    CharacterModel.Entity:SetBodygroup(v.id, LocalPlayer():GetBodygroup(v.id))
                end

            else
                CharacterModel:SetModel(Player_model)
            end

        end

        SetBodygroupSliders()

    end

    // Auto select the first job
    CharacterJobDropdown:ChooseOptionID(1)



    // Create a button container docked to the bottom.
    local CreateCharacterButtonContainer = vgui.Create("DPanel", CharacterDetailsContainerRight)
    CreateCharacterButtonContainer:Dock(BOTTOM)
    CreateCharacterButtonContainer:SetTall( 85 )
    CreateCharacterButtonContainer:DockMargin( 0, 15, 0, 25 )

    CreateCharacterButtonContainer.Paint = function(self, w, h)
        --draw.RoundedBox( 0, 0, 0, w, h, Color(204,204,204,129) )
        --draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0,255) )
        --CHARACTER_PERSISTENCE.GUI.DrawFrame(0, 0, w, h, 10, Color(0, 0, 0), GUI_Theme.ButtonCorners)
    end

    // Create a button to create the character.
    local CreateCharacterButton = vgui.Create("DButton", CreateCharacterButtonContainer)
    CreateCharacterButton:Dock(RIGHT)
    CreateCharacterButton:SetWide( 300 )
    CreateCharacterButton:DockMargin( 0, 0, 25, 0 )
    CreateCharacterButton:SetText("")
    CreateCharacterButton:SetColor( GUI_Theme.TextColor )

    CreateCharacterButton.Paint = function(self, w, h)
        draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0,255) )

        local valid, errorText = VerifyName(CharacterNameEntry:GetText())

        local borderColor = GUI_Theme.TextColor

        if valid and self:IsHovered() then
            draw.RoundedBox( 0, 0, 0, w, h, Color(255,255,255,5) )
            self:SetCursor("hand")
        elseif !valid then
            draw.RoundedBox( 0, 0, 0, w, h, Color(53,53,53) )
            borderColor = Color(94,94,94)
            self:SetCursor("arrow")
        end

        CHARACTER_PERSISTENCE.GUI.DrawFrame(0, 0, w, h, 10, Color(0,0,0,255), GUI_Theme.ButtonCorners)
        --self:DrawTextEntryText( GUI_Theme.TextColor, Color(255,255,255), Color(255,255,255) )

        draw.SimpleText("CREATE", "CharCreatorLarge", w * .5, h * .5, borderColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end


    CreateCharacterButton.DoClick = function()
        local valid, errorText = VerifyName(CharacterNameEntry:GetText())

        if !valid then
            CharacterNameContainer.BorderColor = Color(255,0,0,255)
            CharacterNameContainer.ErrorText = errorText
            return
        end

        local JobDetails = RPExtraTeams[CharacterJobDropdown:GetOptionData(CharacterJobDropdown:GetSelectedID())]

        if !JobDetails then
            CharacterJobContainer.BorderColor = Color(255,0,0,255)
            CharacterJobContainer.ErrorText = "Invalid job selected."
            return
        end

        local CharacterData = {
            SlotName = CharSlot,
            Name = CharacterNameEntry:GetText(),
            Job = CharacterJobDropdown:GetOptionData(CharacterJobDropdown:GetSelectedID()),
            Model = CharacterModel.Entity:GetModel(),
            Skin = CharacterModel.Entity:GetSkin(),
            Bodygroups = {}
        }

        for k, v in pairs(CharacterModel.Entity:GetBodyGroups()) do
            CharacterData.Bodygroups[v.id] = CharacterModel.Entity:GetBodygroup(v.id)
        end

        --print("Sending Character Data:")
        --PrintTable(CharacterData)

        CHARACTER_PERSISTENCE.SendRequest("CreateCharacter", CharacterData, function(data)
            --print("Character creation response:")
            --PrintTable(data)

            if data.Success then
                print("Character created successfully.")

                CHARACTER_PERSISTENCE.NewCharWindowFrame:Close()

                if IsValid(CHARACTER_PERSISTENCE.ModelSelectorWindowFrame) then
                    CHARACTER_PERSISTENCE.ModelSelectorWindowFrame:Close()
                end
                
                CHARACTER_PERSISTENCE.OpenSelector()

            else
                --print("Character creation failed.")
                --print(data.ErrorMsg)

                CharacterNameContainer.BorderColor = Color(255,0,0,255)
                CharacterNameContainer.ErrorText = data.ErrorMsg
            end
        end)

        --WindowFrame:Close()
    end


    // Create a cancel button
    local CancelButton = vgui.Create("DButton", CreateCharacterButtonContainer)
    CancelButton:Dock(NODOCK)
    CancelButton:SetWide( 200 )
    CancelButton:SetHeight( 35 )
    CancelButton:DockMargin( 0, 0, 10, 0 )
    CancelButton:SetText("")
    CancelButton:SetColor( GUI_Theme.TextColor )

    CancelButton:SetPos(0, CreateCharacterButtonContainer:GetTall() - CancelButton:GetTall())

    CancelButton.Paint = function(self, w, h)
        draw.RoundedBox( 0, 0, 0, w, h, Color(0,0,0) )

        if self:IsHovered() then
            draw.RoundedBox( 0, 0, 0, w, h, Color(255,255,255,5) )
        end

        CHARACTER_PERSISTENCE.GUI.DrawFrame(0, 0, w, h, 10, Color(0, 0, 0, 0), GUI_Theme.ButtonCorners)
        --self:DrawTextEntryText( GUI_Theme.TextColor, Color(255,255,255), Color(255,255,255) )

        draw.SimpleText("CANCEL", "CharCreatorMedium", w * .5, h * .5, GUI_Theme.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    CancelButton.DoClick = function()
        WindowFrame:Close()
    end


end



if IsValid( CHARACTER_PERSISTENCE.NewCharWindowFrame ) and CHARACTER_PERSISTENCE.CharacterSlot then
    CHARACTER_PERSISTENCE.NewCharacter( CHARACTER_PERSISTENCE.CharacterSlot )
end