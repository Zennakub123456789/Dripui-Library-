-- [[ DRIP CLIENT | MOBILE GUI LIBRARY - VERSION 2.7 ULTIMATE ]]
-- COMPLETE IMPLEMENTATION: VERBOSE PROPERTY ASSIGNMENTS
-- FIXED: COLOR THEME (BACK TO ORIGINAL GRAY)
-- FIXED: DROPDOWN CLOSES ON COLLAPSE/TAB SWITCH
-- DESIGN: COMPACT MOBILE (280x280)

local DripUI = {}

-- // ROBLOX SERVICES //
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- // INTERNAL CONFIGURATION //
local ConfigFolder = "DripUI_Config"

-- // PERSISTENCE LOGIC //

local function EnsureConfigFolder()
    local success, exists = pcall(function()
        return isfolder(ConfigFolder)
    end)
    if success and not exists then
        pcall(function()
            makefolder(ConfigFolder)
        end)
    end
end

local function SaveConfig(data, id)
    EnsureConfigFolder()
    local filePath = ConfigFolder .. "/" .. tostring(id) .. "_Config.json"
    local success, json = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    if success then
        pcall(function()
            writefile(filePath, json)
        end)
    end
end

local function LoadConfig(id)
    EnsureConfigFolder()
    local filePath = ConfigFolder .. "/" .. tostring(id) .. "_Config.json"
    if isfile(filePath) then
        local content = readfile(filePath)
        if content == "[]" or content == "" then 
            return {} 
        end
        local success, result = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if success then 
            return result 
        else 
            return {} 
        end
    end
    return {}
end

-- // UTILITY FUNCTIONS //

local function GetGuiParent()
    local targetParent = CoreGui
    local success, gethui = pcall(function() 
        return gethui 
    end)
    if success and type(gethui) == "function" then
        local hui = gethui()
        if typeof(hui) == "Instance" then 
            targetParent = hui 
        end
    end
    return targetParent
end

local function ProtectInstance(instance)
    pcall(function() 
        if syn and syn.protect_gui then 
            syn.protect_gui(instance) 
        end 
    end)
    pcall(function() 
        if get_hidden_gui then 
            get_hidden_gui(instance) 
        end 
    end)
end

local function RunTween(instance, duration, properties)
    if not instance or not instance.Parent then 
        return nil 
    end
    local tweenInfo = TweenInfo.new(
        duration, 
        Enum.EasingStyle.Quad, 
        Enum.EasingDirection.Out
    )
    local tweenObject = TweenService:Create(instance, tweenInfo, properties)
    tweenObject:Play()
    return tweenObject
end

-- // THEME DATA (RESTORED TO ORIGINAL GRAY) //
local Theme = {
    Background = Color3.fromRGB(32, 32, 38), -- Original Gray
    Container = Color3.fromRGB(38, 38, 44),  -- Original Darker Gray
    Accent = Color3.fromRGB(255, 0, 255),    -- Neon Pink
    TextMain = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 185), -- Original Dimmed Text
    ElementBG = Color3.fromRGB(25, 25, 30),  -- Content Background
    Stroke = Color3.fromRGB(60, 60, 68),    -- Original Border
    HeaderHeight = 32,
    WindowWidth = 280,
    WindowHeight = 280
}

-- // DRAGGABLE LOGIC //

local function ApplyDragging(dragTarget, moveTarget)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    local function update(input)
        local delta = input.Position - dragStart
        moveTarget.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end

    dragTarget.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = moveTarget.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragTarget.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- // MAIN LIBRARY //

function DripUI:Window(options)
    local self = {}
    self.Tabs = {}
    self.SelectedTabName = nil
    self.IsCollapsed = false
    self.ActiveDropdown = nil
    
    options = options or {}
    local placeId = tostring(game.PlaceId)
    self.ConfigID = options.ConfigID or placeId
    
    local SavedSettings = LoadConfig(self.ConfigID)
    local function SaveCurrentConfig()
        SaveConfig(SavedSettings, self.ConfigID)
    end
    
    -- Main ScreenGui
    local DripScreenGui = Instance.new("ScreenGui")
    DripScreenGui.Name = "DripClient_" .. HttpService:GenerateGUID(false)
    DripScreenGui.Parent = GetGuiParent()
    DripScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    DripScreenGui.ResetOnSpawn = false
    ProtectInstance(DripScreenGui)
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = DripScreenGui
    MainFrame.Size = UDim2.new(0, Theme.WindowWidth, 0, Theme.WindowHeight)
    MainFrame.Position = UDim2.new(0.5, -Theme.WindowWidth/2, 0.5, -Theme.WindowHeight/2)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 4)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Name = "MainStroke"
    MainStroke.Color = Theme.Stroke
    MainStroke.Thickness = 1
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = MainFrame
    
    -- Header
    local Header = Instance.new("TextButton")
    Header.Name = "Header"
    Header.Parent = MainFrame
    Header.Size = UDim2.new(1, 0, 0, Theme.HeaderHeight)
    Header.BackgroundColor3 = Theme.Container
    Header.BorderSizePixel = 0
    Header.Text = options.Title or "DRIP CLIENT | MOBILE"
    Header.TextColor3 = Theme.TextMain
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 12
    Header.AutoButtonColor = false
    Header.ZIndex = 5
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 4)
    HeaderCorner.Parent = Header
    
    local AccentLine = Instance.new("Frame")
    AccentLine.Name = "AccentLine"
    AccentLine.Parent = Header
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.Position = UDim2.new(0, 0, 1, -2)
    AccentLine.BackgroundColor3 = Theme.Accent
    AccentLine.BorderSizePixel = 0
    AccentLine.ZIndex = 6

    ApplyDragging(Header, MainFrame)

    -- Tab System Container
    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Parent = MainFrame
    TabBar.Size = UDim2.new(1, 0, 0, 26)
    TabBar.Position = UDim2.new(0, 0, 0, Theme.HeaderHeight)
    TabBar.BackgroundColor3 = Theme.Container
    TabBar.BorderSizePixel = 0
    TabBar.ZIndex = 4
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabBar
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Content Container
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Name = "ContentHolder"
    ContentHolder.Parent = MainFrame
    ContentHolder.Size = UDim2.new(1, -16, 1, -(Theme.HeaderHeight + 32))
    ContentHolder.Position = UDim2.new(0, 8, 0, Theme.HeaderHeight + 32)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.ZIndex = 2
    
    -- Global Close Dropdown
    local function GlobalCloseDropdown()
        if self.ActiveDropdown then
            self.ActiveDropdown:Close()
            self.ActiveDropdown = nil
        end
    end

    -- Header Click Collapse
    Header.MouseButton1Click:Connect(function()
        -- FIXED: ปิด Dropdown ก่อนย่อเฟรม
        GlobalCloseDropdown()
        
        self.IsCollapsed = not self.IsCollapsed
        if self.IsCollapsed then
            RunTween(MainFrame, 0.4, { Size = UDim2.new(0, Theme.WindowWidth, 0, Theme.HeaderHeight) })
            TabBar.Visible = false
            ContentHolder.Visible = false
        else
            RunTween(MainFrame, 0.4, { Size = UDim2.new(0, Theme.WindowWidth, 0, Theme.WindowHeight) })
            task.delay(0.2, function()
                TabBar.Visible = true
                ContentHolder.Visible = true
            end)
        end
    end)
    
    -- Tab Selection Logic
    function self:SelectTab(name)
        -- FIXED: ปิด Dropdown เมื่อสลับ Tab
        GlobalCloseDropdown()
        
        for tabName, tabObj in pairs(self.Tabs) do
            if tabName == name then
                if tabObj.ButtonInstance then
                    tabObj.ButtonInstance.TextColor3 = Theme.TextMain
                end
                tabObj.PageFrame.Visible = true
                self.SelectedTabName = name
            else
                if tabObj.ButtonInstance then
                    tabObj.ButtonInstance.TextColor3 = Theme.TextDim
                end
                tabObj.PageFrame.Visible = false
            end
        end
    end
    
    -- // TAB CLASS //
    function self:Tab(name)
        local tabObject = { Name = name }
        
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name .. "_TabBtn"
        TabButton.Parent = TabBar
        TabButton.Size = UDim2.new(0, 60, 1, 0)
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel = 0
        TabButton.Text = name
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextSize = 10
        TabButton.TextColor3 = Theme.TextDim
        TabButton.ZIndex = 5
        
        local PageScroll = Instance.new("ScrollingFrame")
        PageScroll.Name = name .. "_Page"
        PageScroll.Parent = ContentHolder
        PageScroll.Size = UDim2.new(1, 0, 1, 0)
        PageScroll.BackgroundTransparency = 1
        PageScroll.BorderSizePixel = 0
        PageScroll.ScrollBarThickness = 1
        PageScroll.ScrollBarImageColor3 = Theme.Accent
        PageScroll.Visible = false
        PageScroll.ZIndex = 3
        PageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        PageScroll.ScrollBarImageTransparency = 0.5
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = PageScroll
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 4)
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            PageScroll.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            self:SelectTab(name)
        end)
        
        tabObject.ButtonInstance = TabButton
        tabObject.PageFrame = PageScroll
        self.Tabs[name] = tabObject
        
        if self.SelectedTabName == nil then
            self:SelectTab(name)
        end
        
        -- // ELEMENT: TOGGLE //
        function tabObject:Toggle(config)
            local toggleConfig = config or {}
            local toggleTitle = toggleConfig.Title or "Toggle"
            local toggleDefault = toggleConfig.Default or false
            local toggleCallback = toggleConfig.Callback or function() end
            
            local toggleValue = SavedSettings[toggleTitle]
            if toggleValue == nil then
                toggleValue = toggleDefault
            end
            
            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Name = "Toggle_" .. toggleTitle
            ToggleFrame.Parent = PageScroll
            ToggleFrame.Size = UDim2.new(1, 0, 0, 26)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.Text = ""
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.ZIndex = 10
            
            local ToggleLayout = Instance.new("UIListLayout")
            ToggleLayout.Parent = ToggleFrame
            ToggleLayout.FillDirection = Enum.FillDirection.Horizontal
            ToggleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            ToggleLayout.Padding = UDim.new(0, 10)
            
            local CheckBox = Instance.new("Frame")
            CheckBox.Name = "CheckBox"
            CheckBox.Parent = ToggleFrame
            CheckBox.Size = UDim2.new(0, 14, 0, 14)
            CheckBox.BackgroundColor3 = toggleValue and Theme.Accent or Theme.ElementBG
            CheckBox.BorderSizePixel = 0
            CheckBox.ZIndex = 11
            
            local CheckCorner = Instance.new("UICorner")
            CheckCorner.CornerRadius = UDim.new(1, 0)
            CheckCorner.Parent = CheckBox
            
            local CheckStroke = Instance.new("UIStroke")
            CheckStroke.Name = "CheckStroke"
            CheckStroke.Parent = CheckBox
            CheckStroke.Thickness = 1
            CheckStroke.Color = toggleValue and Theme.Accent or Color3.fromRGB(80, 80, 88)
            CheckStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = "Label"
            ToggleLabel.Parent = ToggleFrame
            ToggleLabel.Size = UDim2.new(0, 180, 1, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.BorderSizePixel = 0
            ToggleLabel.Text = toggleTitle
            ToggleLabel.Font = Enum.Font.GothamMedium
            ToggleLabel.TextSize = 11
            ToggleLabel.TextColor3 = Theme.TextMain
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.ZIndex = 11
            
            local function UpdateVisuals(state)
                local targetColor = state and Theme.Accent or Theme.ElementBG
                local strokeColor = state and Theme.Accent or Color3.fromRGB(80, 80, 88)
                RunTween(CheckBox, 0.2, { BackgroundColor3 = targetColor })
                RunTween(CheckStroke, 0.2, { Color = strokeColor })
            end
            
            local function SetState(state)
                toggleValue = state
                UpdateVisuals(state)
                SavedSettings[toggleTitle] = state
                SaveCurrentConfig()
                task.spawn(function()
                    local success, err = pcall(toggleCallback, state)
                    if not success then warn("DripUI Toggle Error: " .. tostring(err)) end
                end)
            end
            
            ToggleFrame.MouseButton1Click:Connect(function()
                SetState(not toggleValue)
            end)
            
            if toggleValue then
                task.spawn(function() pcall(toggleCallback, true) end)
            end
            
            return {
                Set = function(_, v) SetState(v) end,
                Get = function() return toggleValue end
            }
        end
        
        -- // ELEMENT: DROPDOWN (FLOATING) //
        function tabObject:Dropdown(config)
            local dropConfig = config or {}
            local dropTitle = dropConfig.Title or "Dropdown"
            local dropOptions = dropConfig.Options or {}
            local dropDefault = dropConfig.Default or dropOptions[1] or "Select"
            local dropCallback = dropConfig.Callback or function() end
            
            local dropValue = SavedSettings[dropTitle]
            if dropValue == nil then
                dropValue = dropDefault
            end
            
            local isMenuOpen = false
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = "Dropdown_" .. dropTitle
            DropdownFrame.Parent = PageScroll
            DropdownFrame.Size = UDim2.new(1, 0, 0, 44)
            DropdownFrame.BackgroundTransparency = 1
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.ZIndex = 15
            
            local Separator = Instance.new("Frame")
            Separator.Name = "Separator"
            Separator.Parent = DropdownFrame
            Separator.Size = UDim2.new(1, 0, 0, 1)
            Separator.BackgroundColor3 = Theme.Stroke
            Separator.BorderSizePixel = 0
            
            local Label = Instance.new("TextLabel")
            Label.Name = "Label"
            Label.Parent = DropdownFrame
            Label.Size = UDim2.new(0, 70, 0, 26)
            Label.Position = UDim2.new(0, 0, 0, 8)
            Label.BackgroundTransparency = 1
            Label.Text = dropTitle
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 11
            Label.TextColor3 = Theme.TextMain
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 16
            
            local DropBox = Instance.new("TextButton")
            DropBox.Name = "DropBox"
            DropBox.Parent = DropdownFrame
            DropBox.Size = UDim2.new(1, -75, 0, 24)
            DropBox.Position = UDim2.new(0, 75, 0, 8)
            DropBox.BackgroundColor3 = Theme.ElementBG
            DropBox.Text = ""
            DropBox.AutoButtonColor = false
            DropBox.BorderSizePixel = 0
            DropBox.ZIndex = 17
            
            local DropCorner = Instance.new("UICorner")
            DropCorner.CornerRadius = UDim.new(0, 3)
            DropCorner.Parent = DropBox
            
            local DropStroke = Instance.new("UIStroke")
            DropStroke.Thickness = 1
            DropStroke.Color = Theme.Stroke
            DropStroke.Parent = DropBox
            
            local SelectedText = Instance.new("TextLabel")
            SelectedText.Name = "SelectedText"
            SelectedText.Parent = DropBox
            SelectedText.Size = UDim2.new(1, -24, 1, 0)
            SelectedText.Position = UDim2.new(0, 8, 0, 0)
            SelectedText.BackgroundTransparency = 1
            SelectedText.Text = dropValue
            SelectedText.Font = Enum.Font.Gotham
            SelectedText.TextSize = 10
            SelectedText.TextColor3 = Theme.TextMain
            SelectedText.TextXAlignment = Enum.TextXAlignment.Left
            SelectedText.ZIndex = 18
            
            local ArrowIcon = Instance.new("ImageLabel")
            ArrowIcon.Name = "Arrow"
            ArrowIcon.Parent = DropBox
            ArrowIcon.Size = UDim2.new(0, 10, 0, 10)
            ArrowIcon.Position = UDim2.new(1, -18, 0.5, -5)
            ArrowIcon.BackgroundTransparency = 1
            ArrowIcon.Image = "rbxassetid://6034818372"
            ArrowIcon.ImageColor3 = Theme.Accent
            ArrowIcon.ZIndex = 18
            
            -- FLOATING OPTIONS CONTAINER
            local OptionsFrame = Instance.new("Frame")
            OptionsFrame.Name = "DropdownOptions_" .. dropTitle
            OptionsFrame.Parent = DripScreenGui
            OptionsFrame.Size = UDim2.new(0, 205, 0, 0)
            OptionsFrame.BackgroundColor3 = Theme.Container
            OptionsFrame.BorderSizePixel = 0
            OptionsFrame.ClipsDescendants = true
            OptionsFrame.Visible = false
            OptionsFrame.ZIndex = 1000
            
            local OptCorner = Instance.new("UICorner")
            OptCorner.CornerRadius = UDim.new(0, 3)
            OptCorner.Parent = OptionsFrame
            
            local OptStroke = Instance.new("UIStroke")
            OptStroke.Thickness = 1
            OptStroke.Color = Theme.Stroke
            OptStroke.Parent = OptionsFrame
            
            local OptLayout = Instance.new("UIListLayout")
            OptLayout.Parent = OptionsFrame
            OptLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local function CloseThisMenu()
                isMenuOpen = false
                RunTween(OptionsFrame, 0.2, { Size = UDim2.new(0, DropBox.AbsoluteSize.X, 0, 0) })
                RunTween(ArrowIcon, 0.2, { Rotation = 0 })
                task.delay(0.2, function() 
                    OptionsFrame.Visible = false 
                end)
            end

            local function ToggleThisMenu()
                if isMenuOpen then
                    CloseThisMenu()
                else
                    GlobalCloseDropdown()
                    self.ActiveDropdown = { Close = CloseThisMenu }
                    isMenuOpen = true
                    
                    local absPos = DropBox.AbsolutePosition
                    local absSize = DropBox.AbsoluteSize
                    
                    OptionsFrame.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + 2)
                    OptionsFrame.Size = UDim2.new(0, absSize.X, 0, 0)
                    OptionsFrame.Visible = true
                    
                    local fullHeight = math.min(#dropOptions * 24, 150)
                    RunTween(OptionsFrame, 0.3, { Size = UDim2.new(0, absSize.X, 0, fullHeight) })
                    RunTween(ArrowIcon, 0.3, { Rotation = 180 })
                end
            end
            
            DropBox.MouseButton1Click:Connect(ToggleThisMenu)
            
            local positionUpdateConn = RunService.RenderStepped:Connect(function()
                if isMenuOpen and OptionsFrame and OptionsFrame.Visible then
                    -- FIXED: ตรวจสอบการย่อเฟรมหรือการซ่อน GUI
                    if not DropBox or not DropBox.Parent or not MainFrame or not MainFrame.Visible or self.IsCollapsed then
                        CloseThisMenu()
                        return
                    end
                    
                    local currentAbsPos = DropBox.AbsolutePosition
                    local currentAbsSize = DropBox.AbsoluteSize
                    
                    OptionsFrame.Position = UDim2.fromOffset(currentAbsPos.X, currentAbsPos.Y + currentAbsSize.Y + 2)
                    
                    if OptionsFrame.Size.X.Offset ~= currentAbsSize.X then
                         OptionsFrame.Size = UDim2.new(0, currentAbsSize.X, 0, OptionsFrame.Size.Y.Offset)
                    end
                end
            end)

            for _, optionName in ipairs(dropOptions) do
                local Item = Instance.new("TextButton")
                Item.Name = "Item_" .. optionName
                Item.Parent = OptionsFrame
                Item.Size = UDim2.new(1, 0, 0, 24)
                Item.BackgroundTransparency = 1
                Item.BorderSizePixel = 0
                Item.Text = optionName
                Item.Font = Enum.Font.Gotham
                Item.TextSize = 10
                Item.TextColor3 = Theme.TextDim
                Item.ZIndex = 1001
                
                Item.MouseButton1Click:Connect(function()
                    dropValue = optionName
                    SelectedText.Text = optionName
                    CloseThisMenu()
                    SavedSettings[dropTitle] = optionName
                    SaveCurrentConfig()
                    task.spawn(function()
                        local s, e = pcall(dropCallback, optionName)
                        if not s then warn("DripUI Dropdown Callback Error: "..tostring(e)) end
                    end)
                end)
                
                Item.MouseEnter:Connect(function() 
                    RunTween(Item, 0.1, { BackgroundTransparency = 0.9, BackgroundColor3 = Color3.new(1, 1, 1) })
                end)
                Item.MouseLeave:Connect(function() 
                    RunTween(Item, 0.1, { BackgroundTransparency = 1 }) 
                end)
            end

            if dropValue ~= dropDefault then
                task.spawn(function() pcall(dropCallback, dropValue) end)
            end
            
            return {
                Set = function(_, v) SelectedText.Text = v dropValue = v end,
                Get = function() return dropValue end
            }
        end
        
        -- // ELEMENT: SLIDER //
        function tabObject:Slider(config)
            local sliderConfig = config or {}
            local sTitle = sliderConfig.Title or "Slider"
            local sMin = sliderConfig.Min or 0
            local sMax = sliderConfig.Max or 100
            local sDefault = sliderConfig.Default or sMin
            local sCallback = sliderConfig.Callback or function() end
            
            local sValue = SavedSettings[sTitle] or sDefault
            
            local SliderContainer = Instance.new("Frame")
            SliderContainer.Name = "Slider_" .. sTitle
            SliderContainer.Parent = PageScroll
            SliderContainer.Size = UDim2.new(1, 0, 0, 42)
            SliderContainer.BackgroundTransparency = 1
            SliderContainer.ZIndex = 10
            
            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Name = "Label"
            SliderLabel.Parent = SliderContainer
            SliderLabel.Size = UDim2.new(1, -40, 0, 18)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Text = sTitle
            SliderLabel.Font = Enum.Font.GothamMedium
            SliderLabel.TextSize = 11
            SliderLabel.TextColor3 = Theme.TextMain
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.ZIndex = 11
            
            local ValueText = Instance.new("TextLabel")
            ValueText.Name = "Value"
            ValueText.Parent = SliderContainer
            ValueText.Size = UDim2.new(0, 30, 0, 18)
            ValueText.Position = UDim2.new(1, -30, 0, 0)
            ValueText.BackgroundTransparency = 1
            ValueText.Text = tostring(sValue)
            ValueText.Font = Enum.Font.GothamBold
            ValueText.TextSize = 11
            ValueText.TextColor3 = Theme.Accent
            ValueText.TextXAlignment = Enum.TextXAlignment.Right
            ValueText.ZIndex = 11
            
            local SliderTrack = Instance.new("Frame")
            SliderTrack.Name = "Track"
            SliderTrack.Parent = SliderContainer
            SliderTrack.Size = UDim2.new(1, 0, 0, 4)
            SliderTrack.Position = UDim2.new(0, 0, 0, 24)
            SliderTrack.BackgroundColor3 = Theme.ElementBG
            SliderTrack.BorderSizePixel = 0
            SliderTrack.ZIndex = 11
            
            local TrackCorner = Instance.new("UICorner")
            TrackCorner.CornerRadius = UDim.new(1, 0)
            TrackCorner.Parent = SliderTrack
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "Fill"
            SliderFill.Parent = SliderTrack
            SliderFill.Size = UDim2.new((sValue - sMin)/(sMax - sMin), 0, 1, 0)
            SliderFill.BackgroundColor3 = Theme.Accent
            SliderFill.BorderSizePixel = 0
            SliderFill.ZIndex = 12
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = SliderFill
            
            local SliderKnob = Instance.new("Frame")
            SliderKnob.Name = "Knob"
            SliderKnob.Parent = SliderTrack
            SliderKnob.Size = UDim2.new(0, 12, 0, 12)
            SliderKnob.Position = UDim2.new((sValue - sMin)/(sMax - sMin), -6, 0.5, -6)
            SliderKnob.BackgroundColor3 = Theme.TextMain
            SliderKnob.ZIndex = 13
            
            local KnobCorner = Instance.new("UICorner")
            KnobCorner.CornerRadius = UDim.new(1, 0)
            KnobCorner.Parent = SliderKnob
            
            local draggingSlider = false
            
            local function UpdateSlider(input)
                local percentage = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                local calculatedValue = math.floor(sMin + (sMax - sMin) * percentage)
                
                sValue = calculatedValue
                ValueText.Text = tostring(calculatedValue)
                SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                SliderKnob.Position = UDim2.new(percentage, -6, 0.5, -6)
                
                SavedSettings[sTitle] = sValue
                SaveCurrentConfig()
                task.spawn(function()
                    pcall(sCallback, sValue)
                end)
            end
            
            SliderKnob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = true
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)
            
            SliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    UpdateSlider(input)
                end
            end)

            if sValue ~= sDefault then
                task.spawn(function() pcall(sCallback, sValue) end)
            end
            
            return {
                Set = function(_, v)
                    local p = math.clamp((v - sMin)/(sMax - sMin), 0, 1)
                    SliderFill.Size = UDim2.new(p, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(p, -6, 0.5, -6)
                    ValueText.Text = tostring(v)
                    sValue = v
                end,
                Get = function() return sValue end
            }
        end
        
        -- // ELEMENT: BUTTON //
        function tabObject:Button(config)
            local btnConfig = config or {}
            local btnTitle = btnConfig.Title or "Button"
            local btnCallback = btnConfig.Callback or function() end
            
            local BtnInstance = Instance.new("TextButton")
            BtnInstance.Name = "Button_" .. btnTitle
            BtnInstance.Parent = PageScroll
            BtnInstance.Size = UDim2.new(1, 0, 0, 28)
            BtnInstance.BackgroundColor3 = Theme.Container
            BtnInstance.BorderSizePixel = 0
            BtnInstance.Text = btnTitle
            BtnInstance.Font = Enum.Font.GothamBold
            BtnInstance.TextSize = 11
            BtnInstance.TextColor3 = Theme.TextMain
            BtnInstance.AutoButtonColor = true
            BtnInstance.ZIndex = 10
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 4)
            BtnCorner.Parent = BtnInstance
            
            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Thickness = 1
            BtnStroke.Color = Theme.Stroke
            BtnStroke.Parent = BtnInstance
            
            BtnInstance.MouseButton1Click:Connect(function()
                task.spawn(function()
                    local ok, err = pcall(btnCallback)
                    if not ok then warn("DripUI Button Error: " .. tostring(err)) end
                end)
                local originalColor = BtnInstance.BackgroundColor3
                RunTween(BtnInstance, 0.1, { BackgroundColor3 = Theme.Accent })
                task.delay(0.1, function() 
                    RunTween(BtnInstance, 0.2, { BackgroundColor3 = originalColor }) 
                end)
            end)
            
            return {
                SetTitle = function(_, t) BtnInstance.Text = t end
            }
        end
        
        -- // ELEMENT: LABEL //
        function tabObject:Label(config)
            local lblConfig = config or {}
            local lblText = lblConfig.Text or "Label"
            
            local LabelObj = Instance.new("TextLabel")
            LabelObj.Name = "Label_" .. lblText
            LabelObj.Parent = PageScroll
            LabelObj.Size = UDim2.new(1, 0, 0, 18)
            LabelObj.BackgroundTransparency = 1
            LabelObj.BorderSizePixel = 0
            LabelObj.Text = lblText
            LabelObj.Font = Enum.Font.Gotham
            LabelObj.TextSize = 10
            LabelObj.TextColor3 = Theme.TextDim
            LabelObj.TextXAlignment = Enum.TextXAlignment.Left
            LabelObj.ZIndex = 10
            
            return {
                SetText = function(_, t) LabelObj.Text = t end
            }
        end

        return tabObject
    end
    
    -- // GLOBAL API //
    function self:SetAccent(color)
        Theme.Accent = color
        AccentLine.BackgroundColor3 = color
    end
    
    function self:ToggleVisibility()
        GlobalCloseDropdown()
        MainFrame.Visible = not MainFrame.Visible
    end
    
    function self:Destroy()
        GlobalCloseDropdown()
        DripScreenGui:Destroy()
    end
    
    return self
end

return DripUI
