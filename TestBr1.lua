-- [[ BR MODS UI LIBRARY - VERSION 3.1 FINAL STYLE ]]
-- STYLE FIX: Toggle (Cyan Border Always -> Cyan Fill on Active)
-- FEATURE: Functional Section (Gradient Header)
-- TAB SYSTEM: Scrolling Tabs
-- CODE STYLE: Ultra Verbose (No shortcuts)

local BrMods = {}

-- // ROBLOX SERVICES //
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- // INTERNAL CONFIGURATION //
local ConfigFolder = "BrMods_Config"

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
    if typeof(instance) ~= "Instance" then
        return nil
    end
    if not instance.Parent then
        return nil
    end
    
    local tweenInfo = TweenInfo.new(
        duration, 
        Enum.EasingStyle.Quad, 
        Enum.EasingDirection.Out
    )
    
    local success, tweenObject = pcall(function()
        return TweenService:Create(instance, tweenInfo, properties)
    end)
    
    if success and tweenObject then
        tweenObject:Play()
        return tweenObject
    end
    return nil
end

-- // THEME COLORS //
local Colors = {
    Cyan = Color3.fromRGB(0, 219, 197),
    Dark = Color3.fromRGB(20, 20, 20),
    Background = Color3.fromRGB(15, 15, 15),
    Black = Color3.fromRGB(0, 0, 0),
    Grey = Color3.fromRGB(56, 56, 72),
    SliderFill = Color3.fromRGB(123, 146, 185),
    BorderGrey = Color3.fromRGB(60, 60, 60),
    TextWhite = Color3.new(1, 1, 1),
    TextGrey = Color3.fromRGB(150, 150, 150)
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

function BrMods:Window(options)
    local self = {}
    self.Tabs = {}
    self.SelectedTab = nil
    
    options = options or {}
    local placeId = tostring(game.PlaceId)
    self.ConfigID = options.ConfigID or placeId
    
    local SavedSettings = LoadConfig(self.ConfigID)
    local function SaveCurrentConfig()
        SaveConfig(SavedSettings, self.ConfigID)
    end
    
    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BR_MODS_UI_" .. HttpService:GenerateGUID(false)
    ScreenGui.Parent = GetGuiParent()
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false
    ProtectInstance(ScreenGui)
    
    -- Main Frame (Outer Border)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.Size = UDim2.new(0, 250, 0, 325)
    MainFrame.Position = UDim2.new(0.5, -125, 0.5, -162)
    MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 15)
    MainCorner.Parent = MainFrame
    
    -- Inner Frame (Content Area)
    local MainInner = Instance.new("Frame")
    MainInner.Name = "Inner"
    MainInner.Parent = MainFrame
    MainInner.Size = UDim2.new(1, -2, 1, -2)
    MainInner.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainInner.AnchorPoint = Vector2.new(0.5, 0.5)
    MainInner.BackgroundColor3 = Colors.Background
    MainInner.BorderSizePixel = 0
    MainInner.ClipsDescendants = true
    
    local InnerCorner = Instance.new("UICorner")
    InnerCorner.CornerRadius = UDim.new(0, 15)
    InnerCorner.Parent = MainInner
    
    -- Title Label
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Parent = MainInner
    TitleLabel.Size = UDim2.new(1, 0, 0, 35)
    TitleLabel.Position = UDim2.new(0, 0, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "B R   M O D S"
    TitleLabel.Font = Enum.Font.GothamBlack
    TitleLabel.TextSize = 20
    TitleLabel.TextColor3 = Colors.TextWhite
    TitleLabel.BorderSizePixel = 0
    
    ApplyDragging(MainInner, MainFrame)
    
    -- Tab Container (Scrolling)
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainInner
    TabContainer.Size = UDim2.new(1, -20, 0, 30)
    TabContainer.Position = UDim2.new(0, 10, 0, 45)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 0
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.X
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabContainer
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)
    
    -- Pages Container Frame
    local PagesContainer = Instance.new("Frame")
    PagesContainer.Name = "PagesContainer"
    PagesContainer.Parent = MainInner
    PagesContainer.Size = UDim2.new(1, -16, 1, -120)
    PagesContainer.Position = UDim2.new(0, 8, 0, 80)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.BorderSizePixel = 0
    
    -- Close Button Area
    local CloseBorder = Instance.new("Frame")
    CloseBorder.Name = "CloseBorder"
    CloseBorder.Parent = MainInner
    CloseBorder.Size = UDim2.new(0, 80, 0, 28)
    CloseBorder.AnchorPoint = Vector2.new(1, 1)
    CloseBorder.Position = UDim2.new(1, -10, 1, -10)
    CloseBorder.BackgroundColor3 = Colors.Cyan
    CloseBorder.BorderSizePixel = 0
    
    local CloseBorderCorner = Instance.new("UICorner")
    CloseBorderCorner.CornerRadius = UDim.new(0, 8)
    CloseBorderCorner.Parent = CloseBorder
    
    local CloseInner = Instance.new("Frame")
    CloseInner.Name = "CloseInner"
    CloseInner.Parent = CloseBorder
    CloseInner.Size = UDim2.new(1, -2, 1, -2)
    CloseInner.Position = UDim2.new(0.5, 0, 0.5, 0)
    CloseInner.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseInner.BackgroundColor3 = Colors.Black
    CloseInner.BorderSizePixel = 0
    
    local CloseInnerCorner = Instance.new("UICorner")
    CloseInnerCorner.CornerRadius = UDim.new(0, 8)
    CloseInnerCorner.Parent = CloseInner
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseButton"
    CloseBtn.Parent = CloseInner
    CloseBtn.Size = UDim2.new(1, 0, 1, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "CLOSE"
    CloseBtn.TextColor3 = Colors.TextWhite
    CloseBtn.Font = Enum.Font.GothamBlack
    CloseBtn.TextSize = 12
    CloseBtn.BorderSizePixel = 0
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- // TAB CREATION //
    function self:Tab(name)
        local tabObject = { Name = name }
        
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = name .. "_TabButton"
        TabBtn.Parent = TabContainer
        TabBtn.Size = UDim2.new(0, 75, 1, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 12
        TabBtn.TextColor3 = Colors.TextGrey
        TabBtn.BorderSizePixel = 0
        
        local ActiveLine = Instance.new("Frame")
        ActiveLine.Name = "ActiveLine"
        ActiveLine.Parent = TabBtn
        ActiveLine.BackgroundColor3 = Colors.Cyan
        ActiveLine.BorderSizePixel = 0
        ActiveLine.Position = UDim2.new(0, 0, 1, -2)
        ActiveLine.Size = UDim2.new(0, 0, 0, 2)
        
        local PageScroll = Instance.new("ScrollingFrame")
        PageScroll.Name = name .. "_Page"
        PageScroll.Parent = PagesContainer
        PageScroll.Size = UDim2.new(1, 0, 1, 0)
        PageScroll.BackgroundTransparency = 1
        PageScroll.BorderSizePixel = 0
        PageScroll.ScrollBarThickness = 2
        PageScroll.ScrollBarImageColor3 = Colors.Cyan
        PageScroll.Visible = false
        PageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = PageScroll
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 6)
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            PageScroll.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)
        
        tabObject.ButtonInstance = TabBtn
        tabObject.PageFrame = PageScroll
        
        TabBtn.MouseButton1Click:Connect(function()
            for _, existingTab in pairs(self.Tabs) do
                RunTween(existingTab.ButtonInstance, 0.2, { TextColor3 = Colors.TextGrey })
                local line = existingTab.ButtonInstance:FindFirstChild("ActiveLine")
                if line then
                    RunTween(line, 0.2, { Size = UDim2.new(0, 0, 0, 2) })
                end
                existingTab.PageFrame.Visible = false
            end
            
            RunTween(TabBtn, 0.2, { TextColor3 = Colors.Cyan })
            RunTween(ActiveLine, 0.2, { Size = UDim2.new(1, 0, 0, 2) })
            PageScroll.Visible = true
            self.SelectedTab = name
        end)
        
        table.insert(self.Tabs, tabObject)
        
        if #self.Tabs == 1 then
            RunTween(TabBtn, 0.2, { TextColor3 = Colors.Cyan })
            RunTween(ActiveLine, 0.2, { Size = UDim2.new(1, 0, 0, 2) })
            PageScroll.Visible = true
            self.SelectedTab = name
        end
        
        -- // ELEMENT: SECTION (FUNCTIONAL) //
        function tabObject:Section(options)
            -- Support both string and table input
            local text = "Section"
            if type(options) == "string" then
                text = options
            elseif type(options) == "table" and options.Text then
                text = options.Text
            end
            
            local SectionContainer = Instance.new("Frame")
            SectionContainer.Name = "Section_" .. text
            SectionContainer.Parent = PageScroll
            SectionContainer.Size = UDim2.new(1, 0, 0, 22)
            SectionContainer.BackgroundColor3 = Color3.new(1, 1, 1)
            SectionContainer.BorderSizePixel = 0
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 5)
            SectionCorner.Parent = SectionContainer
            
            local SectionGradient = Instance.new("UIGradient")
            SectionGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Colors.Cyan),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 40, 40))
            })
            SectionGradient.Parent = SectionContainer
            
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Name = "Label"
            SectionLabel.Parent = SectionContainer
            SectionLabel.Size = UDim2.new(1, 0, 1, 0)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Text = text
            SectionLabel.TextColor3 = Colors.Black
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.TextSize = 12
            SectionLabel.BorderSizePixel = 0
            
            return {
                SetText = function(_, newText)
                    SectionLabel.Text = newText
                end
            }
        end
        
        -- // ELEMENT: TOGGLE (FIXED STYLE - CYAN BORDER ALWAYS) //
        function tabObject:Toggle(config)
            local title = config.Title or "Toggle"
            local defaultState = config.Default or false
            local callback = config.Callback or function() end
            
            local currentState = SavedSettings[title]
            if currentState == nil then currentState = defaultState end
            
            -- Outer Border Frame (ALWAYS CYAN)
            local ToggleBorder = Instance.new("Frame")
            ToggleBorder.Name = "Toggle_" .. title
            ToggleBorder.Parent = PageScroll
            ToggleBorder.Size = UDim2.new(1, 0, 0, 36)
            ToggleBorder.BackgroundColor3 = Colors.Cyan -- Always Cyan
            ToggleBorder.BorderSizePixel = 0
            
            local BorderCorner = Instance.new("UICorner")
            BorderCorner.CornerRadius = UDim.new(0, 8)
            BorderCorner.Parent = ToggleBorder
            
            -- Inner Frame (Background Fill)
            local ToggleInner = Instance.new("Frame")
            ToggleInner.Name = "Inner"
            ToggleInner.Parent = ToggleBorder
            ToggleInner.Size = UDim2.new(1, -2, 1, -2)
            ToggleInner.Position = UDim2.new(0.5, 0, 0.5, 0)
            ToggleInner.AnchorPoint = Vector2.new(0.5, 0.5)
            -- Init Color based on state
            ToggleInner.BackgroundColor3 = currentState and Colors.Cyan or Colors.Dark
            ToggleInner.BorderSizePixel = 0
            
            local InnerCorner = Instance.new("UICorner")
            InnerCorner.CornerRadius = UDim.new(0, 8)
            InnerCorner.Parent = ToggleInner
            
            -- Interaction Button
            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Name = "Button"
            ToggleBtn.Parent = ToggleInner
            ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
            ToggleBtn.BackgroundTransparency = 1
            ToggleBtn.Text = title
            -- Init Text Color based on state
            ToggleBtn.TextColor3 = currentState and Colors.Black or Colors.TextWhite
            ToggleBtn.Font = Enum.Font.GothamSemibold
            ToggleBtn.TextSize = 12
            
            local function UpdateVisuals()
                if currentState then
                    -- Active: Inner becomes Cyan (Filled), Text becomes Black
                    RunTween(ToggleInner, 0.2, { BackgroundColor3 = Colors.Cyan })
                    RunTween(ToggleBtn, 0.2, { TextColor3 = Colors.Black })
                else
                    -- Inactive: Inner becomes Dark (Hollow), Text becomes White
                    RunTween(ToggleInner, 0.2, { BackgroundColor3 = Colors.Dark })
                    RunTween(ToggleBtn, 0.2, { TextColor3 = Colors.TextWhite })
                end
                
                SavedSettings[title] = currentState
                SaveCurrentConfig()
                
                task.spawn(function()
                    local s, e = pcall(callback, currentState)
                    if not s then warn("Callback Error: " .. tostring(e)) end
                end)
            end
            
            ToggleBtn.MouseButton1Click:Connect(function()
                currentState = not currentState
                UpdateVisuals()
            end)
            
            if currentState then task.spawn(function() pcall(callback, true) end) end
            
            return {
                Set = function(_, v) currentState = v UpdateVisuals() end
            }
        end
        
        -- // ELEMENT: BUTTON //
        function tabObject:Button(config)
            local title = config.Title or "Button"
            local callback = config.Callback or function() end
            
            local BtnBorder = Instance.new("Frame")
            BtnBorder.Name = "Btn_" .. title
            BtnBorder.Parent = PageScroll
            BtnBorder.Size = UDim2.new(1, 0, 0, 36)
            BtnBorder.BackgroundColor3 = Colors.Cyan
            BtnBorder.BorderSizePixel = 0
            
            local BorderCorner = Instance.new("UICorner")
            BorderCorner.CornerRadius = UDim.new(0, 8)
            BorderCorner.Parent = BtnBorder
            
            local BtnInner = Instance.new("Frame")
            BtnInner.Name = "Inner"
            BtnInner.Parent = BtnBorder
            BtnInner.Size = UDim2.new(1, -2, 1, -2)
            BtnInner.Position = UDim2.new(0.5, 0, 0.5, 0)
            BtnInner.AnchorPoint = Vector2.new(0.5, 0.5)
            BtnInner.BackgroundColor3 = Colors.Dark
            BtnInner.BorderSizePixel = 0
            
            local InnerCorner = Instance.new("UICorner")
            InnerCorner.CornerRadius = UDim.new(0, 8)
            InnerCorner.Parent = BtnInner
            
            local ActionBtn = Instance.new("TextButton")
            ActionBtn.Name = "Button"
            ActionBtn.Parent = BtnInner
            ActionBtn.Size = UDim2.new(1, 0, 1, 0)
            ActionBtn.BackgroundTransparency = 1
            ActionBtn.Text = title
            ActionBtn.TextColor3 = Colors.TextWhite
            ActionBtn.Font = Enum.Font.GothamSemibold
            ActionBtn.TextSize = 12
            
            ActionBtn.MouseButton1Click:Connect(function()
                task.spawn(callback)
                -- Click Effect
                RunTween(BtnInner, 0.1, { BackgroundColor3 = Colors.Cyan })
                RunTween(ActionBtn, 0.1, { TextColor3 = Colors.Black })
                task.delay(0.1, function()
                    RunTween(BtnInner, 0.2, { BackgroundColor3 = Colors.Dark })
                    RunTween(ActionBtn, 0.2, { TextColor3 = Colors.TextWhite })
                end)
            end)
        end
        
        -- // ELEMENT: SLIDER //
        function tabObject:Slider(config)
            local title = config.Title or "Slider"
            local minVal = config.Min or 0
            local maxVal = config.Max or 100
            local defaultVal = config.Default or minVal
            local callback = config.Callback or function() end
            local currentVal = SavedSettings[title] or defaultVal
            
            local SliderContainer = Instance.new("Frame")
            SliderContainer.Name = "Slider_" .. title
            SliderContainer.Parent = PageScroll
            SliderContainer.Size = UDim2.new(1, 0, 0, 42)
            SliderContainer.BackgroundTransparency = 1
            
            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Name = "Label"
            SliderLabel.Parent = SliderContainer
            SliderLabel.Text = title .. ": " .. currentVal
            SliderLabel.Size = UDim2.new(1, 0, 0, 15)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.TextColor3 = Colors.TextWhite
            SliderLabel.Font = Enum.Font.GothamMedium
            SliderLabel.TextSize = 12
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Position = UDim2.new(0, 5, 0, 0)
            
            local TrackBorder = Instance.new("Frame")
            TrackBorder.Name = "TrackBorder"
            TrackBorder.Parent = SliderContainer
            TrackBorder.Size = UDim2.new(0.9, 0, 0, 8)
            TrackBorder.Position = UDim2.new(0.5, 0, 0.7, 0)
            TrackBorder.AnchorPoint = Vector2.new(0.5, 0.5)
            TrackBorder.BackgroundColor3 = Colors.BorderGrey
            
            local TrackCorner = Instance.new("UICorner")
            TrackCorner.CornerRadius = UDim.new(1, 0)
            TrackCorner.Parent = TrackBorder
            
            local TrackInner = Instance.new("Frame")
            TrackInner.Name = "TrackInner"
            TrackInner.Parent = TrackBorder
            TrackInner.Size = UDim2.new(1, -2, 1, -2)
            TrackInner.Position = UDim2.new(0.5, 0, 0.5, 0)
            TrackInner.AnchorPoint = Vector2.new(0.5, 0.5)
            TrackInner.BackgroundColor3 = Colors.Grey
            
            local InnerCorner = Instance.new("UICorner")
            InnerCorner.CornerRadius = UDim.new(1, 0)
            InnerCorner.Parent = TrackInner
            
            local Fill = Instance.new("Frame")
            Fill.Name = "Fill"
            Fill.Parent = TrackInner
            Fill.Size = UDim2.new((currentVal - minVal) / (maxVal - minVal), 0, 1, 0)
            Fill.BackgroundColor3 = Colors.SliderFill
            Fill.BorderSizePixel = 0
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = Fill
            
            local Knob = Instance.new("Frame")
            Knob.Name = "Knob"
            Knob.Parent = TrackInner
            Knob.Size = UDim2.new(0, 16, 0, 16)
            Knob.AnchorPoint = Vector2.new(0.5, 0.5)
            Knob.Position = UDim2.new((currentVal - minVal) / (maxVal - minVal), 0, 0.5, 0)
            Knob.BackgroundColor3 = Colors.TextWhite
            
            local KnobCorner = Instance.new("UICorner")
            KnobCorner.CornerRadius = UDim.new(1, 0)
            KnobCorner.Parent = Knob
            
            local isDragging = false
            
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - TrackInner.AbsolutePosition.X) / TrackInner.AbsoluteSize.X, 0, 1)
                local newVal = math.floor(minVal + (maxVal - minVal) * pos)
                currentVal = newVal
                
                SliderLabel.Text = title .. ": " .. currentVal
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                Knob.Position = UDim2.new(pos, 0, 0.5, 0)
                
                SavedSettings[title] = currentVal
                SaveCurrentConfig()
                task.spawn(function() pcall(callback, currentVal) end)
            end
            
            Knob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)
            
            if currentVal ~= defaultVal then task.spawn(callback, currentVal) end
        end
        
        -- // DROPDOWN (EXPANDING) //
        function tabObject:Dropdown(config)
            local title = config.Title or "Dropdown"
            local options = config.Options or {}
            local default = config.Default or options[1] or "..."
            local callback = config.Callback or function() end
            local currentVal = SavedSettings[title] or default
            
            local DropContainer = Instance.new("Frame")
            DropContainer.Name = "Dropdown_" .. title
            DropContainer.Parent = PageScroll
            DropContainer.Size = UDim2.new(1, 0, 0, 50)
            DropContainer.BackgroundTransparency = 1
            DropContainer.ClipsDescendants = true
            
            local Label = Instance.new("TextLabel")
            Label.Name = "Label"
            Label.Parent = DropContainer
            Label.Text = title
            Label.Size = UDim2.new(1, 0, 0, 15)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Colors.TextWhite
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Position = UDim2.new(0, 5, 0, 0)
            
            local DropBorder = Instance.new("Frame")
            DropBorder.Name = "Border"
            DropBorder.Parent = DropContainer
            DropBorder.Size = UDim2.new(1, 0, 0, 30)
            DropBorder.Position = UDim2.new(0, 0, 0, 18)
            DropBorder.BackgroundColor3 = Colors.Cyan
            
            local BorderCorner = Instance.new("UICorner")
            BorderCorner.CornerRadius = UDim.new(0, 8)
            BorderCorner.Parent = DropBorder
            
            local DropInner = Instance.new("Frame")
            DropInner.Name = "Inner"
            DropInner.Parent = DropBorder
            DropInner.Size = UDim2.new(1, -2, 1, -2)
            DropInner.Position = UDim2.new(0.5, 0, 0.5, 0)
            DropInner.AnchorPoint = Vector2.new(0.5, 0.5)
            DropInner.BackgroundColor3 = Colors.Dark
            
            local InnerCorner = Instance.new("UICorner")
            InnerCorner.CornerRadius = UDim.new(0, 8)
            InnerCorner.Parent = DropInner
            
            local MainBtn = Instance.new("TextButton")
            MainBtn.Name = "Main"
            MainBtn.Parent = DropInner
            MainBtn.Size = UDim2.new(1, 0, 1, 0)
            MainBtn.BackgroundTransparency = 1
            MainBtn.Text = currentVal
            MainBtn.TextColor3 = Colors.TextWhite
            MainBtn.Font = Enum.Font.GothamBold
            MainBtn.TextSize = 12
            
            local ListFrame = Instance.new("Frame")
            ListFrame.Name = "List"
            ListFrame.Parent = DropContainer
            ListFrame.Size = UDim2.new(1, 0, 0, 0)
            ListFrame.Position = UDim2.new(0, 0, 0, 50)
            ListFrame.BackgroundTransparency = 1
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Parent = ListFrame
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Padding = UDim.new(0, 2)
            
            local isOpen = false
            local itemHeight = 27
            local totalHeight = #options * itemHeight
            
            for _, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Name = "Option_" .. opt
                OptBtn.Parent = ListFrame
                OptBtn.Size = UDim2.new(1, 0, 0, 25)
                OptBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                OptBtn.BackgroundTransparency = 0.5
                OptBtn.Text = opt
                OptBtn.TextColor3 = Colors.TextGrey
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 11
                
                local OptCorner = Instance.new("UICorner")
                OptCorner.CornerRadius = UDim.new(0, 6)
                OptCorner.Parent = OptBtn
                
                OptBtn.MouseButton1Click:Connect(function()
                    currentVal = opt
                    MainBtn.Text = opt
                    
                    isOpen = false
                    RunTween(DropContainer, 0.2, { Size = UDim2.new(1, 0, 0, 50) })
                    RunTween(ListFrame, 0.2, { Size = UDim2.new(1, 0, 0, 0) })
                    
                    SavedSettings[title] = currentVal
                    SaveCurrentConfig()
                    task.spawn(function() pcall(callback, currentVal) end)
                end)
            end
            
            MainBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    RunTween(ListFrame, 0.2, { Size = UDim2.new(1, 0, 0, totalHeight) })
                    RunTween(DropContainer, 0.2, { Size = UDim2.new(1, 0, 0, 50 + totalHeight) })
                else
                    RunTween(ListFrame, 0.2, { Size = UDim2.new(1, 0, 0, 0) })
                    RunTween(DropContainer, 0.2, { Size = UDim2.new(1, 0, 0, 50) })
                end
            end)
            
            if currentVal ~= default then task.spawn(callback, currentVal) end
        end
        
        return tabObject
    end
    
    return self
end

return BrMods
