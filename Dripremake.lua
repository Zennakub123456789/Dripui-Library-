-- [[ DRIP CLIENT | MOBILE GUI LIBRARY - VERSION 3.0 ULTIMATE ]]
-- COMPLETE IMPLEMENTATION: NO ABBREVIATIONS, FULL VERBOSE PROPERTY SETTINGS
-- FIXED: Dropdown Visibility with 0.5s Interval Check Logic
-- RESTORED: MainFrame Background color to Theme.Container
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
        local makeSuccess, makeErr = pcall(function()
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
        local writeSuccess, writeErr = pcall(function()
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

-- // THEME DATA (Compact) //
local Theme = {
    Background = Color3.fromRGB(10, 10, 10),
    Container = Color3.fromRGB(26, 26, 26),
    Accent = Color3.fromRGB(255, 0, 255),
    TextMain = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(119, 119, 119),
    ElementBG = Color3.fromRGB(17, 17, 17),
    Stroke = Color3.fromRGB(37, 37, 37),
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
            
            local changedConn
            changedConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    changedConn:Disconnect()
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
    DripScreenGui.Name = "DripClient_MobileUI"
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
    MainFrame.BackgroundColor3 = Theme.Container -- Restored to Container Color
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

    -- Tab System Bar
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
    
    -- Content Container (IMPORTANT FOR VISIBILITY CHECK)
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Name = "ContentHolder"
    ContentHolder.Parent = MainFrame
    ContentHolder.Size = UDim2.new(1, -16, 1, -(Theme.HeaderHeight + 32))
    ContentHolder.Position = UDim2.new(0, 8, 0, Theme.HeaderHeight + 32)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.ZIndex = 2
    
    local function GlobalCloseDropdown()
        if self.ActiveDropdown then
            self.ActiveDropdown:Close()
            self.ActiveDropdown = nil
        end
    end

    -- Header Click Collapse
    Header.MouseButton1Click:Connect(function()
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
            CheckStroke.Color = toggleValue and Theme.Accent or Color3.fromRGB(51, 51, 51)
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
            ToggleLabel.TextColor3 = Color3.fromRGB(221, 221, 221)
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.ZIndex = 11
            
            local function UpdateVisuals(state)
                local targetColor = state and Theme.Accent or Theme.ElementBG
                local strokeColor = state and Theme.Accent or Color3.fromRGB(51, 51, 51)
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
        
        -- // ELEMENT: DROPDOWN (LOGIC FIXED) //
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
            
            local SeparatorLine = Instance.new("Frame")
            SeparatorLine.Name = "Separator"
            SeparatorLine.Parent = DropdownFrame
            SeparatorLine.Size = UDim2.new(1, 0, 0, 1)
            SeparatorLine.BackgroundColor3 = Theme.Stroke
            SeparatorLine.BorderSizePixel = 0
            
            local DropLabel = Instance.new("TextLabel")
            DropLabel.Name = "Label"
            DropLabel.Parent = DropdownFrame
            DropLabel.Size = UDim2.new(0, 70, 0, 26)
            DropLabel.Position = UDim2.new(0, 0, 0, 8)
            DropLabel.BackgroundTransparency = 1
            DropLabel.Text = dropTitle
            DropLabel.Font = Enum.Font.GothamMedium
            DropLabel.TextSize = 11
            DropLabel.TextColor3 = Color3.fromRGB(221, 221, 221)
            DropLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropLabel.ZIndex = 16
            
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
            
            local DropBoxCorner = Instance.new("UICorner")
            DropBoxCorner.CornerRadius = UDim.new(0, 3)
            DropBoxCorner.Parent = DropBox
            
            local DropBoxStroke = Instance.new("UIStroke")
            DropBoxStroke.Thickness = 1
            DropBoxStroke.Color = Color3.fromRGB(51, 51, 51)
            DropBoxStroke.Parent = DropBox
            
            local CurrentValueText = Instance.new("TextLabel")
            CurrentValueText.Name = "SelectedText"
            CurrentValueText.Parent = DropBox
            CurrentValueText.Size = UDim2.new(1, -24, 1, 0)
            CurrentValueText.Position = UDim2.new(0, 8, 0, 0)
            CurrentValueText.BackgroundTransparency = 1
            CurrentValueText.Text = dropValue
            CurrentValueText.Font = Enum.Font.Gotham
            CurrentValueText.TextSize = 10
            CurrentValueText.TextColor3 = Color3.fromRGB(221, 221, 221)
            CurrentValueText.TextXAlignment = Enum.TextXAlignment.Left
            CurrentValueText.ZIndex = 18
            
            local ArrowIconLabel = Instance.new("ImageLabel")
            ArrowIconLabel.Name = "Arrow"
            ArrowIconLabel.Parent = DropBox
            ArrowIconLabel.Size = UDim2.new(0, 10, 0, 10)
            ArrowIconLabel.Position = UDim2.new(1, -18, 0.5, -5)
            ArrowIconLabel.BackgroundTransparency = 1
            ArrowIconLabel.Image = "rbxassetid://6034818372"
            ArrowIconLabel.ImageColor3 = Theme.Accent
            ArrowIconLabel.ZIndex = 18
            
            -- FLOATING OPTIONS (Parented to ScreenGui)
            local OptionsFrame = Instance.new("Frame")
            OptionsFrame.Name = "DropdownFloating_" .. dropTitle
            OptionsFrame.Parent = DripScreenGui
            OptionsFrame.Size = UDim2.new(0, 205, 0, 0)
            OptionsFrame.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
            OptionsFrame.BorderSizePixel = 0
            OptionsFrame.ClipsDescendants = true
            OptionsFrame.Visible = false
            OptionsFrame.ZIndex = 1000
            
            local OptionsCorner = Instance.new("UICorner")
            OptionsCorner.CornerRadius = UDim.new(0, 3)
            OptionsCorner.Parent = OptionsFrame
            
            local OptionsStroke = Instance.new("UIStroke")
            OptionsStroke.Thickness = 1
            OptionsStroke.Color = Theme.Stroke
            OptionsStroke.Parent = OptionsFrame
            
            local OptionsLayout = Instance.new("UIListLayout")
            OptionsLayout.Parent = OptionsFrame
            OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local function CloseThisMenu()
                isMenuOpen = false
                RunTween(OptionsFrame, 0.2, { Size = UDim2.new(0, DropBox.AbsoluteSize.X, 0, 0) })
                RunTween(ArrowIconLabel, 0.2, { Rotation = 0 })
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
                    
                    local absolutePosition = DropBox.AbsolutePosition
                    local absoluteSize = DropBox.AbsoluteSize
                    
                    OptionsFrame.Position = UDim2.fromOffset(absolutePosition.X, absolutePosition.Y + absoluteSize.Y + 2)
                    OptionsFrame.Size = UDim2.new(0, absoluteSize.X, 0, 0)
                    OptionsFrame.Visible = true
                    
                    local maxVisibleItems = 6
                    local itemHeight = 24
                    local targetHeight = math.min(#dropOptions * itemHeight, maxVisibleItems * itemHeight)
                    
                    RunTween(OptionsFrame, 0.3, { Size = UDim2.new(0, absoluteSize.X, 0, targetHeight) })
                    RunTween(ArrowIconLabel, 0.3, { Rotation = 180 })
                end
            end
            
            DropBox.MouseButton1Click:Connect(ToggleThisMenu)
            
            -- [[ LOGIC: 0.5S INTERVAL VISIBILITY CHECK ]]
            task.spawn(function()
                while task.wait(0.5) do
                    if not DropBox or not DropBox.Parent then break end
                    
                    if isMenuOpen then
                        -- ตรวจสอบ ContentHolder และ Page Visibility ตามโจทย์
                        local isWindowOpen = (MainFrame.Visible == true) and (not self.IsCollapsed)
                        local isHolderVisible = (ContentHolder.Visible == true)
                        local isPageActive = (PageScroll.Visible == true)
                        
                        if not isWindowOpen or not isHolderVisible or not isPageActive then
                            -- ถ้าอย่างใดอย่างหนึ่งถูกซ่อน ให้สั่ง Visible = false ทันที
                            OptionsFrame.Visible = false
                        else
                            -- ถ้ากลับมาแสดงผลปกติ และเมนูยังถูกเปิดอยู่ ให้แสดงผลต่อ
                            OptionsFrame.Visible = true
                            
                            -- อัปเดตตำแหน่งกรณีลากหน้าต่าง
                            local absPos = DropBox.AbsolutePosition
                            local absSize = DropBox.AbsoluteSize
                            OptionsFrame.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + 2)
                            OptionsFrame.Size = UDim2.new(0, absSize.X, 0, OptionsFrame.Size.Y.Offset)
                        end
                    else
                        if OptionsFrame.Visible then 
                            OptionsFrame.Visible = false 
                        end
                    end
                end
            end)

            for _, optionName in ipairs(dropOptions) do
                local ItemButton = Instance.new("TextButton")
                ItemButton.Name = "OptionItem_" .. optionName
                ItemButton.Parent = OptionsFrame
                ItemButton.Size = UDim2.new(1, 0, 0, 24)
                ItemButton.BackgroundTransparency = 1
                ItemButton.BorderSizePixel = 0
                ItemButton.Text = optionName
                ItemButton.Font = Enum.Font.Gotham
                ItemButton.TextSize = 10
                ItemButton.TextColor3 = Color3.fromRGB(153, 153, 153)
                ItemButton.ZIndex = 1001
                
                ItemButton.MouseButton1Click:Connect(function()
                    dropValue = optionName
                    CurrentValueText.Text = optionName
                    CloseThisMenu()
                    SavedSettings[dropTitle] = optionName
                    SaveCurrentConfig()
                    task.spawn(function()
                        local success, err = pcall(dropCallback, optionName)
                        if not success then warn("Dropdown Callback Error: " .. tostring(err)) end
                    end)
                end)
                
                ItemButton.MouseEnter:Connect(function() 
                    RunTween(ItemButton, 0.1, { BackgroundTransparency = 0.9, BackgroundColor3 = Color3.new(1, 1, 1) })
                end)
                ItemButton.MouseLeave:Connect(function() 
                    RunTween(ItemButton, 0.1, { BackgroundTransparency = 1 }) 
                end)
            end

            if dropValue ~= dropDefault then
                task.spawn(function() pcall(dropCallback, dropValue) end)
            end
            
            return {
                Set = function(_, v) CurrentValueText.Text = v dropValue = v end,
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
            SliderLabel.TextColor3 = Color3.fromRGB(221, 221, 221)
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
            
            local ButtonInstance = Instance.new("TextButton")
            ButtonInstance.Name = "Button_" .. btnTitle
            ButtonInstance.Parent = PageScroll
            ButtonInstance.Size = UDim2.new(1, 0, 0, 28)
            ButtonInstance.BackgroundColor3 = Theme.ElementBG
            ButtonInstance.BorderSizePixel = 0
            ButtonInstance.Text = btnTitle
            ButtonInstance.Font = Enum.Font.GothamBold
            ButtonInstance.TextSize = 11
            ButtonInstance.TextColor3 = Theme.TextMain
            ButtonInstance.AutoButtonColor = true
            ButtonInstance.ZIndex = 10
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 4)
            ButtonCorner.Parent = ButtonInstance
            
            local ButtonStroke = Instance.new("UIStroke")
            ButtonStroke.Thickness = 1
            ButtonStroke.Color = Theme.Stroke
            ButtonStroke.Parent = ButtonInstance
            
            ButtonInstance.MouseButton1Click:Connect(function()
                task.spawn(function()
                    local ok, err = pcall(btnCallback)
                    if not ok then warn("Button Error: " .. tostring(err)) end
                end)
                local originalColor = ButtonInstance.BackgroundColor3
                RunTween(ButtonInstance, 0.1, { BackgroundColor3 = Theme.Accent })
                task.delay(0.1, function() 
                    RunTween(ButtonInstance, 0.2, { BackgroundColor3 = originalColor }) 
                end)
            end)
            
            return {
                SetTitle = function(_, t) ButtonInstance.Text = t end
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
