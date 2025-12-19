-- [[ BR MODS UI LIBRARY - VERSION 2.0 ULTRA VERBOSE ]]
-- STYLE: BR MODS ORIGINAL (Double Frame, Cyan Theme)
-- DROPDOWN: Expanding (In-Layout) - Pushes content down
-- WINDOW: Drag Only (No Collapse on Title)
-- CODE STYLE: Fully Expanded Property Assignments (No shortcuts)

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
    -- FIXED: Check if instance exists to prevent "Unable to cast value to Object"
    if not instance or not instance.Parent then 
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
    Dark = Color3.fromRGB(15, 15, 15),
    Black = Color3.fromRGB(0, 0, 0),
    Grey = Color3.fromRGB(56, 56, 72),
    SliderFill = Color3.fromRGB(123, 146, 185),
    BorderGrey = Color3.fromRGB(110, 110, 110),
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
    MainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
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
    MainInner.BackgroundColor3 = Colors.Dark
    MainInner.BorderSizePixel = 0
    MainInner.ClipsDescendants = true
    
    local InnerCorner = Instance.new("UICorner")
    InnerCorner.CornerRadius = UDim.new(0, 15)
    InnerCorner.Parent = MainInner
    
    -- Title Label (Static, Drag Target)
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Parent = MainInner
    TitleLabel.Size = UDim2.new(1, 0, 0, 35)
    TitleLabel.Position = UDim2.new(0, 0, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "B R   M O D S"
    TitleLabel.Font = Enum.Font.GothamBlack
    TitleLabel.TextSize = 22
    TitleLabel.TextColor3 = Colors.TextWhite
    TitleLabel.BorderSizePixel = 0
    
    -- Enable Dragging on Title area
    ApplyDragging(TitleLabel, MainFrame)
    ApplyDragging(MainInner, MainFrame) -- Allow dragging on background too
    
    -- Tab Container Frame
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainInner
    TabContainer.Size = UDim2.new(1, -20, 0, 30)
    TabContainer.Position = UDim2.new(0, 10, 0, 45)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    
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
    
    -- Close Button (Outer Frame)
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
    
    -- Close Button (Inner Frame)
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
    
    -- Close Text Button
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
    
    -- Hover Effect for Close Button
    CloseBtn.MouseEnter:Connect(function()
        RunTween(CloseInner, 0.2, { BackgroundColor3 = Colors.Cyan })
        RunTween(CloseBtn, 0.2, { TextColor3 = Colors.Black })
    end)
    
    CloseBtn.MouseLeave:Connect(function()
        RunTween(CloseInner, 0.2, { BackgroundColor3 = Colors.Black })
        RunTween(CloseBtn, 0.2, { TextColor3 = Colors.TextWhite })
    end)
    
    -- // TAB CREATION LOGIC //
    function self:Tab(name)
        local tabObject = { Name = name }
        
        -- Tab Button Instance
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = name .. "_TabButton"
        TabBtn.Parent = TabContainer
        TabBtn.Size = UDim2.new(0.5, -3, 1, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 14
        TabBtn.TextColor3 = Colors.TextGrey
        TabBtn.BorderSizePixel = 0
        
        -- Active Indicator Line
        local ActiveLine = Instance.new("Frame")
        ActiveLine.Name = "ActiveLine"
        ActiveLine.Parent = TabBtn
        ActiveLine.BackgroundColor3 = Colors.Cyan
        ActiveLine.BorderSizePixel = 0
        ActiveLine.Position = UDim2.new(0, 0, 1, -2)
        ActiveLine.Size = UDim2.new(0, 0, 0, 2) -- Start with 0 width (Hidden)
        
        -- Page Scrolling Frame
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
        PageLayout.Padding = UDim.new(0, 5)
        
        -- Auto Canvas Size Logic
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            PageScroll.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)
        
        tabObject.Button = TabBtn
        tabObject.Page = PageScroll
        
        -- Tab Click Event
        TabBtn.MouseButton1Click:Connect(function()
            -- Reset styling for all tabs
            for _, existingTab in pairs(self.Tabs) do
                RunTween(existingTab.Button, 0.2, { TextColor3 = Colors.TextGrey })
                
                local line = existingTab.Button:FindFirstChild("ActiveLine")
                if line then
                    RunTween(line, 0.2, { Size = UDim2.new(0, 0, 0, 2) })
                end
                
                existingTab.Page.Visible = false
            end
            
            -- Set active styling for this tab
            RunTween(TabBtn, 0.2, { TextColor3 = Colors.Cyan })
            RunTween(ActiveLine, 0.2, { Size = UDim2.new(1, 0, 0, 2) })
            
            PageScroll.Visible = true
            self.SelectedTab = name
        end)
        
        table.insert(self.Tabs, tabObject)
        
        -- Automatically select the first tab
        if #self.Tabs == 1 then
            RunTween(TabBtn, 0.2, { TextColor3 = Colors.Cyan })
            RunTween(ActiveLine, 0.2, { Size = UDim2.new(1, 0, 0, 2) })
            PageScroll.Visible = true
            self.SelectedTab = name
        end
        
        -- // ELEMENT: SECTION (GRADIENT LABEL) //
        function tabObject:Section(text)
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
                ColorSequenceKeypoint.new(1, Color3.fromRGB(13, 56, 53))
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
        end
        
        -- // ELEMENT: TOGGLE (BR MODS STYLE) //
        function tabObject:Toggle(config)
            local title = config.Title or "Toggle"
            local defaultState = config.Default or false
            local callback = config.Callback or function() end
            
            local currentState = SavedSettings[title]
            if currentState == nil then
                currentState = defaultState
            end
            
            -- Outer Border Frame
            local ToggleBorder = Instance.new("Frame")
            ToggleBorder.Name = "ToggleBorder_" .. title
            ToggleBorder.Parent = PageScroll
            ToggleBorder.Size = UDim2.new(1, 0, 0, 35)
            ToggleBorder.BackgroundColor3 = currentState and Colors.Cyan or Colors.Dark
            ToggleBorder.BorderSizePixel = 0
            
            local BorderCorner = Instance.new("UICorner")
            BorderCorner.CornerRadius = UDim.new(0, 10)
            BorderCorner.Parent = ToggleBorder
            
            -- Inner Background Frame
            local ToggleInner = Instance.new("Frame")
            ToggleInner.Name = "Inner"
            ToggleInner.Parent = ToggleBorder
            ToggleInner.Size = UDim2.new(1, -2, 1, -2)
            ToggleInner.Position = UDim2.new(0.5, 0, 0.5, 0)
            ToggleInner.AnchorPoint = Vector2.new(0.5, 0.5)
            ToggleInner.BackgroundColor3 = currentState and Colors.Cyan or Colors.Dark
            ToggleInner.BorderSizePixel = 0
            
            local InnerCorner = Instance.new("UICorner")
            InnerCorner.CornerRadius = UDim.new(0, 10)
            InnerCorner.Parent = ToggleInner
            
            -- Interaction Button
            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Name = "Button"
            ToggleBtn.Parent = ToggleInner
            ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
            ToggleBtn.BackgroundTransparency = 1
            ToggleBtn.Text = title
            ToggleBtn.TextColor3 = currentState and Colors.Black or Colors.TextWhite
            ToggleBtn.Font = Enum.Font.GothamSemibold
            ToggleBtn.TextSize = 13
            ToggleBtn.BorderSizePixel = 0
            
            local function UpdateVisuals()
                if currentState then
                    RunTween(ToggleInner, 0.2, { BackgroundColor3 = Colors.Cyan })
                    RunTween(ToggleBtn, 0.2, { TextColor3 = Colors.Black })
                else
                    RunTween(ToggleInner, 0.2, { BackgroundColor3 = Colors.Dark })
                    RunTween(ToggleBtn, 0.2, { TextColor3 = Colors.TextWhite })
                end
                
                SavedSettings[title] = currentState
                SaveCurrentConfig()
                
                task.spawn(function()
                    local success, err = pcall(callback, currentState)
                    if not success then warn("Toggle Callback Error: " .. tostring(err)) end
                end)
            end
            
            ToggleBtn.MouseButton1Click:Connect(function()
                currentState = not currentState
                UpdateVisuals()
            end)
            
            if currentState then
                task.spawn(function() pcall(callback, true) end)
            end
            
            return {
                Set = function(_, value)
                    currentState = value
                    UpdateVisuals()
                end
            }
        end
        
        -- // ELEMENT: BUTTON (STATELESS) //
        function tabObject:Button(config)
            local title = config.Title or "Button"
            local callback = config.Callback or function() end
            
            local BtnBorder = Instance.new("Frame")
            BtnBorder.Name = "BtnBorder_" .. title
            BtnBorder.Parent = PageScroll
            BtnBorder.Size = UDim2.new(1, 0, 0, 35)
            BtnBorder.BackgroundColor3 = Colors.Cyan
            BtnBorder.BorderSizePixel = 0
            
            local BorderCorner = Instance.new("UICorner")
            BorderCorner.CornerRadius = UDim.new(0, 10)
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
            InnerCorner.CornerRadius = UDim.new(0, 10)
            InnerCorner.Parent = BtnInner
            
            local ActionBtn = Instance.new("TextButton")
            ActionBtn.Name = "ActionBtn"
            ActionBtn.Parent = BtnInner
            ActionBtn.Size = UDim2.new(1, 0, 1, 0)
            ActionBtn.BackgroundTransparency = 1
            ActionBtn.Text = title
            ActionBtn.TextColor3 = Colors.TextWhite
            ActionBtn.Font = Enum.Font.GothamSemibold
            ActionBtn.TextSize = 13
            ActionBtn.BorderSizePixel = 0
            
            ActionBtn.MouseButton1Click:Connect(function()
                task.spawn(function()
                    local success, err = pcall(callback)
                    if not success then warn("Button Callback Error: " .. tostring(err)) end
                end)
                
                -- Click Animation
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
            SliderContainer.Size = UDim2.new(1, 0, 0, 40)
            SliderContainer.BackgroundTransparency = 1
            SliderContainer.BorderSizePixel = 0
            
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
            SliderLabel.BorderSizePixel = 0
            
            local SliderTrackOuter = Instance.new("Frame")
            SliderTrackOuter.Name = "TrackOuter"
            SliderTrackOuter.Parent = SliderContainer
            SliderTrackOuter.Size = UDim2.new(0.9, 0, 0, 8)
            SliderTrackOuter.Position = UDim2.new(0.5, 0, 0.7, 0)
            SliderTrackOuter.AnchorPoint = Vector2.new(0.5, 0.5)
            SliderTrackOuter.BackgroundColor3 = Colors.BorderGrey
            SliderTrackOuter.BorderSizePixel = 0
            
            local OuterCorner = Instance.new("UICorner")
            OuterCorner.CornerRadius = UDim.new(1, 0)
            OuterCorner.Parent = SliderTrackOuter
            
            local SliderTrackInner = Instance.new("Frame")
            SliderTrackInner.Name = "TrackInner"
            SliderTrackInner.Parent = SliderTrackOuter
            SliderTrackInner.Size = UDim2.new(1, -4, 1, -4)
            SliderTrackInner.Position = UDim2.new(0.5, 0, 0.5, 0)
            SliderTrackInner.AnchorPoint = Vector2.new(0.5, 0.5)
            SliderTrackInner.BackgroundColor3 = Colors.Grey
            SliderTrackInner.BorderSizePixel = 0
            
            local InnerCorner = Instance.new("UICorner")
            InnerCorner.CornerRadius = UDim.new(1, 0)
            InnerCorner.Parent = SliderTrackInner
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "Fill"
            SliderFill.Parent = SliderTrackInner
            SliderFill.Size = UDim2.new((currentVal - minVal) / (maxVal - minVal), 0, 1, 0)
            SliderFill.BackgroundColor3 = Colors.SliderFill
            SliderFill.BorderSizePixel = 0
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = SliderFill
            
            local SliderKnob = Instance.new("Frame")
            SliderKnob.Name = "Knob"
            SliderKnob.Parent = SliderTrackInner
            SliderKnob.Size = UDim2.new(0, 18, 0, 18)
            SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
            SliderKnob.Position = UDim2.new((currentVal - minVal) / (maxVal - minVal), 0, 0.5, 0)
            SliderKnob.BackgroundColor3 = Colors.TextWhite
            SliderKnob.BorderSizePixel = 0
            
            local KnobCorner = Instance.new("UICorner")
            KnobCorner.CornerRadius = UDim.new(1, 0)
            KnobCorner.Parent = SliderKnob
            
            local KnobDot = Instance.new("Frame")
            KnobDot.Name = "Dot"
            KnobDot.Parent = SliderKnob
            KnobDot.Size = UDim2.new(1, -4, 1, -4)
            KnobDot.Position = UDim2.new(0.5, 0, 0.5, 0)
            KnobDot.AnchorPoint = Vector2.new(0.5, 0.5)
            KnobDot.BackgroundColor3 = Colors.Cyan
            KnobDot.BorderSizePixel = 0
            
            local DotCorner = Instance.new("UICorner")
            DotCorner.CornerRadius = UDim.new(1, 0)
            DotCorner.Parent = KnobDot
            
            local isDragging = false
            
            local function UpdateSliderLogic(input)
                local pos = math.clamp((input.Position.X - SliderTrackInner.AbsolutePosition.X) / SliderTrackInner.AbsoluteSize.X, 0, 1)
                local newValue = math.floor(minVal + (maxVal - minVal) * pos)
                
                currentVal = newValue
                SliderLabel.Text = title .. ": " .. currentVal
                SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                SliderKnob.Position = UDim2.new(pos, 0, 0.5, 0)
                
                SavedSettings[title] = currentVal
                SaveCurrentConfig()
                
                task.spawn(function()
                    pcall(callback, currentVal)
                end)
            end
            
            SliderKnob.InputBegan:Connect(function(input)
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
                    UpdateSliderLogic(input)
                end
            end)
            
            -- Initial Callback
            if currentVal ~= defaultVal then
                task.spawn(function() pcall(callback, currentVal) end)
            end
        end
        
        -- // ELEMENT: DROPDOWN (EXPANDING / IN-LAYOUT) //
        function tabObject:Dropdown(config)
            local title = config.Title or "Dropdown"
            local options = config.Options or {}
            local defaultVal = config.Default or options[1] or "Select"
            local callback = config.Callback or function() end
            
            local currentVal = SavedSettings[title] or defaultVal
            
            local DropdownContainer = Instance.new("Frame")
            DropdownContainer.Name = "Dropdown_" .. title
            DropdownContainer.Parent = PageScroll
            DropdownContainer.Size = UDim2.new(1, 0, 0, 50) -- Default height
            DropdownContainer.BackgroundTransparency = 1
            DropdownContainer.ClipsDescendants = true
            DropdownContainer.BorderSizePixel = 0
            
            local DropLabel = Instance.new("TextLabel")
            DropLabel.Name = "Label"
            DropLabel.Parent = DropdownContainer
            DropLabel.Text = title
            DropLabel.Size = UDim2.new(1, 0, 0, 15)
            DropLabel.BackgroundTransparency = 1
            DropLabel.TextColor3 = Colors.TextWhite
            DropLabel.Font = Enum.Font.GothamMedium
            DropLabel.TextSize = 12
            DropLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropLabel.Position = UDim2.new(0, 5, 0, 0)
            DropLabel.BorderSizePixel = 0
            
            local DropBorder = Instance.new("Frame")
            DropBorder.Name = "Border"
            DropBorder.Parent = DropdownContainer
            DropBorder.Size = UDim2.new(1, 0, 0, 30)
            DropBorder.Position = UDim2.new(0, 0, 0, 18)
            DropBorder.BackgroundColor3 = Colors.Cyan
            DropBorder.BorderSizePixel = 0
            
            local BorderCorner = Instance.new("UICorner")
            BorderCorner.CornerRadius = UDim.new(0, 10)
            BorderCorner.Parent = DropBorder
            
            local DropInner = Instance.new("Frame")
            DropInner.Name = "Inner"
            DropInner.Parent = DropBorder
            DropInner.Size = UDim2.new(1, -2, 1, -2)
            DropInner.Position = UDim2.new(0.5, 0, 0.5, 0)
            DropInner.AnchorPoint = Vector2.new(0.5, 0.5)
            DropInner.BackgroundColor3 = Colors.Dark
            DropInner.BorderSizePixel = 0
            
            local InnerCorner = Instance.new("UICorner")
            InnerCorner.CornerRadius = UDim.new(0, 10)
            InnerCorner.Parent = DropInner
            
            local MainButton = Instance.new("TextButton")
            MainButton.Name = "MainButton"
            MainButton.Parent = DropInner
            MainButton.Size = UDim2.new(1, 0, 1, 0)
            MainButton.BackgroundTransparency = 1
            MainButton.Text = currentVal
            MainButton.TextColor3 = Colors.TextWhite
            MainButton.Font = Enum.Font.GothamBold
            MainButton.TextSize = 12
            MainButton.BorderSizePixel = 0
            
            -- List Container (Inside the main container)
            local ListFrame = Instance.new("Frame")
            ListFrame.Name = "ListFrame"
            ListFrame.Parent = DropdownContainer
            ListFrame.Size = UDim2.new(1, 0, 0, 0)
            ListFrame.Position = UDim2.new(0, 0, 0, 50) -- Below the main button area
            ListFrame.BackgroundTransparency = 1
            ListFrame.ClipsDescendants = true
            ListFrame.BorderSizePixel = 0
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Parent = ListFrame
            ListLayout.Padding = UDim.new(0, 2)
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local isOpen = false
            local itemHeight = 27
            local totalHeight = #options * itemHeight
            
            for _, optionName in ipairs(options) do
                local OptionBtn = Instance.new("TextButton")
                OptionBtn.Name = "Option_" .. optionName
                OptionBtn.Parent = ListFrame
                OptionBtn.Text = optionName
                OptionBtn.Size = UDim2.new(1, 0, 0, 25)
                OptionBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                OptionBtn.BackgroundTransparency = 0.2
                OptionBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                OptionBtn.Font = Enum.Font.Gotham
                OptionBtn.TextSize = 12
                OptionBtn.BorderSizePixel = 0
                
                local OptionCorner = Instance.new("UICorner")
                OptionCorner.CornerRadius = UDim.new(0, 6)
                OptionCorner.Parent = OptionBtn
                
                OptionBtn.MouseButton1Click:Connect(function()
                    currentVal = optionName
                    MainButton.Text = optionName
                    
                    -- Close Logic
                    isOpen = false
                    if Container then -- Check existence
                        DropdownContainer:TweenSize(UDim2.new(1, 0, 0, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                        ListFrame:TweenSize(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                    end
                    
                    SavedSettings[title] = currentVal
                    SaveCurrentConfig()
                    
                    task.spawn(function()
                        pcall(callback, currentVal)
                    end)
                end)
            end
            
            MainButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                
                if isOpen then
                    -- Expand
                    ListFrame:TweenSize(UDim2.new(1, 0, 0, totalHeight), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                    DropdownContainer:TweenSize(UDim2.new(1, 0, 0, 50 + totalHeight), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                else
                    -- Collapse
                    ListFrame:TweenSize(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                    DropdownContainer:TweenSize(UDim2.new(1, 0, 0, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                end
            end)
            
            if currentVal ~= defaultVal then
                task.spawn(function() pcall(callback, currentVal) end)
            end
            
            return {
                Set = function(_, val)
                    currentVal = val
                    MainButton.Text = val
                end
            }
        end
        
        return tabObject
    end
    
    return self
end

return BrMods
