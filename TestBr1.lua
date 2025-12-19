-- [[ BR MODS UI LIBRARY - MOBILE SMART EDITION ]]
-- STYLE: BR MODS (Double Frame, Cyan/Dark Theme)
-- CORE: Smart Dropdown (Auto-Direction + Floating) + Save System
-- VERSION: 1.0 (Converted from DripUI logic)

local BrMods = {}

-- // SERVICES //
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- // CONFIGURATION //
local ConfigFolder = "BrMods_Config"

-- // PERSISTENCE LOGIC //
local function EnsureConfigFolder()
    local success, exists = pcall(function() return isfolder(ConfigFolder) end)
    if success and not exists then pcall(function() makefolder(ConfigFolder) end) end
end

local function SaveConfig(data, id)
    EnsureConfigFolder()
    local filePath = ConfigFolder .. "/" .. tostring(id) .. "_Config.json"
    pcall(function() writefile(filePath, HttpService:JSONEncode(data)) end)
end

local function LoadConfig(id)
    EnsureConfigFolder()
    local filePath = ConfigFolder .. "/" .. tostring(id) .. "_Config.json"
    if isfile(filePath) then
        local content = readfile(filePath)
        if content == "[]" or content == "" then return {} end
        local success, result = pcall(function() return HttpService:JSONDecode(content) end)
        if success then return result else return {} end
    end
    return {}
end

-- // UTILITY //
local function GetGuiParent()
    local target = CoreGui
    local s, e = pcall(function() return gethui() end)
    if s and e then target = e end
    return target
end

local function ProtectInstance(inst)
    if syn and syn.protect_gui then syn.protect_gui(inst) end
    if get_hidden_gui then get_hidden_gui(inst) end
end

local function RunTween(inst, time, props)
    if not inst then return end
    local info = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tw = TweenService:Create(inst, info, props)
    tw:Play()
    return tw
end

-- // THEME COLORS (From BR MODS) //
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

-- // DRAGGING LOGIC //
local function ApplyDrag(dragObj, moveObj)
    local dragging, dragStart, startPos
    dragObj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = moveObj.Position
            
            local inputChanged
            inputChanged = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    inputChanged:Disconnect()
                end
            end)
        end
    end)
    dragObj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                moveObj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
end

-- // LIBRARY START //
function BrMods:Window(options)
    local self = {}
    self.Tabs = {}
    self.SelectedTab = nil
    self.ActiveDropdown = nil
    self.IsCollapsed = false
    
    local placeId = tostring(game.PlaceId)
    local ConfigID = options.ConfigID or placeId
    local SavedSettings = LoadConfig(ConfigID)
    
    local function Save() SaveConfig(SavedSettings, ConfigID) end
    
    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BR_MODS_UI"
    ScreenGui.Parent = GetGuiParent()
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ProtectInstance(ScreenGui)
    
    -- Main Frame (Double Frame Style)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 250, 0, 325)
    MainFrame.Position = UDim2.new(0.5, -125, 0.5, -162)
    MainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Outer Border Color
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 15)
    MainCorner.Parent = MainFrame
    
    local MainInner = Instance.new("Frame")
    MainInner.Name = "Inner"
    MainInner.Size = UDim2.new(1, -2, 1, -2)
    MainInner.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainInner.AnchorPoint = Vector2.new(0.5, 0.5)
    MainInner.BackgroundColor3 = Colors.Dark
    MainInner.BorderSizePixel = 0
    MainInner.ClipsDescendants = true
    MainInner.Parent = MainFrame
    
    local InnerCorner = Instance.new("UICorner")
    InnerCorner.CornerRadius = UDim.new(0, 15)
    InnerCorner.Parent = MainInner
    
    -- Title
    local Title = Instance.new("TextButton") -- Use button for collapse
    Title.Text = "B R   M O D S"
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 22
    Title.TextColor3 = Colors.TextWhite
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.Position = UDim2.new(0, 0, 0, 5)
    Title.Parent = MainInner
    
    ApplyDrag(Title, MainFrame)
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, -20, 0, 30)
    TabContainer.Position = UDim2.new(0, 10, 0, 45)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainInner
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabContainer
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)
    
    -- Content Container
    local PagesContainer = Instance.new("Frame")
    PagesContainer.Size = UDim2.new(1, -16, 1, -120)
    PagesContainer.Position = UDim2.new(0, 8, 0, 80)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.Parent = MainInner
    
    -- Global Dropdown Closer
    local function CloseDropdown()
        if self.ActiveDropdown then
            self.ActiveDropdown:Close()
            self.ActiveDropdown = nil
        end
    end
    
    -- Collapse Logic
    Title.MouseButton1Click:Connect(function()
        CloseDropdown()
        self.IsCollapsed = not self.IsCollapsed
        if self.IsCollapsed then
            RunTween(MainFrame, 0.3, {Size = UDim2.new(0, 250, 0, 45)})
            TabContainer.Visible = false
            PagesContainer.Visible = false
        else
            RunTween(MainFrame, 0.3, {Size = UDim2.new(0, 250, 0, 325)})
            task.delay(0.2, function()
                TabContainer.Visible = true
                PagesContainer.Visible = true
            end)
        end
    end)
    
    -- Close Button (Bottom Right)
    local CloseBorder = Instance.new("Frame")
    CloseBorder.Size = UDim2.new(0, 80, 0, 28)
    CloseBorder.AnchorPoint = Vector2.new(1, 1)
    CloseBorder.Position = UDim2.new(1, -10, 1, -10)
    CloseBorder.BackgroundColor3 = Colors.Cyan
    CloseBorder.Parent = MainInner
    Instance.new("UICorner", CloseBorder).CornerRadius = UDim.new(0, 8)
    
    local CloseInner = Instance.new("Frame")
    CloseInner.Size = UDim2.new(1, -2, 1, -2)
    CloseInner.Position = UDim2.new(0.5, 0, 0.5, 0)
    CloseInner.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseInner.BackgroundColor3 = Colors.Black
    CloseInner.Parent = CloseBorder
    Instance.new("UICorner", CloseInner).CornerRadius = UDim.new(0, 8)
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "CLOSE"
    CloseBtn.Size = UDim2.new(1, 0, 1, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.TextColor3 = Colors.TextWhite
    CloseBtn.Font = Enum.Font.GothamBlack
    CloseBtn.TextSize = 12
    CloseBtn.Parent = CloseInner
    
    CloseBtn.MouseButton1Click:Connect(function() 
        CloseDropdown()
        ScreenGui:Destroy() 
    end)
    
    -- // TABS //
    function self:Tab(name)
        local tabData = { Name = name }
        
        -- Tab Button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = TabContainer
        TabBtn.Size = UDim2.new(0.5, -3, 1, 0)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 14
        TabBtn.TextColor3 = Colors.TextGrey
        TabBtn.Parent = TabContainer
        
        local Line = Instance.new("Frame")
        Line.BackgroundColor3 = Colors.Cyan
        Line.BorderSizePixel = 0
        Line.Position = UDim2.new(0, 0, 1, -2)
        Line.Size = UDim2.new(0, 0, 0, 2)
        Line.Parent = TabBtn
        
        -- Page
        local Page = Instance.new("ScrollingFrame")
        Page.Name = name .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Colors.Cyan
        Page.Visible = false
        Page.Parent = PagesContainer
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = Page
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 5)
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)
        
        tabData.Button = TabBtn
        tabData.Page = Page
        
        TabBtn.MouseButton1Click:Connect(function()
            CloseDropdown()
            -- Reset all tabs
            for _, t in pairs(self.Tabs) do
                RunTween(t.Button, 0.2, {TextColor3 = Colors.TextGrey})
                RunTween(t.Button:FindFirstChild("Frame"), 0.2, {Size = UDim2.new(0,0,0,2)}) -- Line
                t.Page.Visible = false
            end
            -- Activate this tab
            RunTween(TabBtn, 0.2, {TextColor3 = Colors.Cyan})
            RunTween(Line, 0.2, {Size = UDim2.new(1,0,0,2)})
            Page.Visible = true
            self.SelectedTab = name
        end)
        
        table.insert(self.Tabs, tabData)
        
        -- Select first tab automatically
        if #self.Tabs == 1 then
            RunTween(TabBtn, 0.2, {TextColor3 = Colors.Cyan})
            RunTween(Line, 0.2, {Size = UDim2.new(1,0,0,2)})
            Page.Visible = true
            self.SelectedTab = name
        end
        
        -- // SECTION (Gradient Label) //
        function tabData:Section(text)
            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 0, 22)
            Container.BackgroundColor3 = Color3.new(1,1,1)
            Container.BorderSizePixel = 0
            Container.Parent = Page
            
            Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 5)
            
            local Gradient = Instance.new("UIGradient")
            Gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Colors.Cyan),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(13, 56, 53))
            })
            Gradient.Parent = Container
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Colors.Black
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 12
            Label.Parent = Container
        end
        
        -- // TOGGLE (Using BR Mods Button Style) //
        function tabData:Toggle(config)
            local title = config.Title or "Toggle"
            local state = SavedSettings[title] or config.Default or false
            
            -- Border Frame
            local Border = Instance.new("Frame")
            Border.Size = UDim2.new(1, 0, 0, 35)
            Border.BackgroundColor3 = state and Colors.Cyan or Colors.Dark -- Initial Color
            Border.Parent = Page
            Instance.new("UICorner", Border).CornerRadius = UDim.new(0, 10)
            
            -- Inner Frame
            local Inner = Instance.new("Frame")
            Inner.Size = UDim2.new(1, -2, 1, -2)
            Inner.Position = UDim2.new(0.5, 0, 0.5, 0)
            Inner.AnchorPoint = Vector2.new(0.5, 0.5)
            Inner.BackgroundColor3 = state and Colors.Cyan or Colors.Dark
            Inner.Parent = Border
            Instance.new("UICorner", Inner).CornerRadius = UDim.new(0, 10)
            
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = title
            Btn.TextColor3 = state and Colors.Black or Colors.TextWhite
            Btn.Font = Enum.Font.GothamSemibold
            Btn.TextSize = 13
            Btn.Parent = Inner
            
            local function Update()
                if state then
                    RunTween(Inner, 0.2, {BackgroundColor3 = Colors.Cyan})
                    RunTween(Btn, 0.2, {TextColor3 = Colors.Black})
                else
                    RunTween(Inner, 0.2, {BackgroundColor3 = Colors.Dark})
                    RunTween(Btn, 0.2, {TextColor3 = Colors.TextWhite})
                end
                
                SavedSettings[title] = state
                Save()
                if config.Callback then task.spawn(config.Callback, state) end
            end
            
            Btn.MouseButton1Click:Connect(function()
                state = not state
                Update()
            end)
            
            -- Initial Callback
            if state then task.spawn(config.Callback, true) end
            
            return {
                Set = function(_, val) state = val Update() end
            }
        end
        
        -- // BUTTON (Stateless) //
        function tabData:Button(config)
            local title = config.Title or "Button"
            
            local Border = Instance.new("Frame")
            Border.Size = UDim2.new(1, 0, 0, 35)
            Border.BackgroundColor3 = Colors.Cyan
            Border.Parent = Page
            Instance.new("UICorner", Border).CornerRadius = UDim.new(0, 10)
            
            local Inner = Instance.new("Frame")
            Inner.Size = UDim2.new(1, -2, 1, -2)
            Inner.Position = UDim2.new(0.5, 0, 0.5, 0)
            Inner.AnchorPoint = Vector2.new(0.5, 0.5)
            Inner.BackgroundColor3 = Colors.Dark
            Inner.Parent = Border
            Instance.new("UICorner", Inner).CornerRadius = UDim.new(0, 10)
            
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = title
            Btn.TextColor3 = Colors.TextWhite
            Btn.Font = Enum.Font.GothamSemibold
            Btn.TextSize = 13
            Btn.Parent = Inner
            
            Btn.MouseButton1Click:Connect(function()
                if config.Callback then task.spawn(config.Callback) end
                -- Click Animation
                RunTween(Inner, 0.1, {BackgroundColor3 = Colors.Cyan})
                RunTween(Btn, 0.1, {TextColor3 = Colors.Black})
                task.delay(0.1, function()
                    RunTween(Inner, 0.2, {BackgroundColor3 = Colors.Dark})
                    RunTween(Btn, 0.2, {TextColor3 = Colors.TextWhite})
                end)
            end)
        end
        
        -- // SLIDER //
        function tabData:Slider(config)
            local title = config.Title or "Slider"
            local min, max = config.Min or 0, config.Max or 100
            local val = SavedSettings[title] or config.Default or min
            
            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 0, 40)
            Container.BackgroundTransparency = 1
            Container.Parent = Page
            
            local Label = Instance.new("TextLabel")
            Label.Text = title .. ": " .. val
            Label.Size = UDim2.new(1, 0, 0, 15)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Colors.TextWhite
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.Parent = Container
            
            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(0.9, 0, 0, 8)
            Track.Position = UDim2.new(0.5, 0, 0.7, 0)
            Track.AnchorPoint = Vector2.new(0.5, 0.5)
            Track.BackgroundColor3 = Colors.BorderGrey
            Track.Parent = Container
            Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
            
            local InnerTrack = Instance.new("Frame")
            InnerTrack.Size = UDim2.new(1, -4, 1, -4)
            InnerTrack.Position = UDim2.new(0.5, 0, 0.5, 0)
            InnerTrack.AnchorPoint = Vector2.new(0.5, 0.5)
            InnerTrack.BackgroundColor3 = Colors.Grey
            InnerTrack.Parent = Track
            Instance.new("UICorner", InnerTrack).CornerRadius = UDim.new(1, 0)
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((val-min)/(max-min), 0, 1, 0)
            Fill.BackgroundColor3 = Colors.SliderFill
            Fill.BorderSizePixel = 0
            Fill.Parent = InnerTrack
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
            
            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 18, 0, 18)
            Knob.AnchorPoint = Vector2.new(0.5, 0.5)
            Knob.Position = UDim2.new((val-min)/(max-min), 0, 0.5, 0)
            Knob.BackgroundColor3 = Colors.TextWhite
            Knob.Parent = InnerTrack
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
            
            local KnobInner = Instance.new("Frame")
            KnobInner.Size = UDim2.new(1, -4, 1, -4)
            KnobInner.Position = UDim2.new(0.5, 0, 0.5, 0)
            KnobInner.AnchorPoint = Vector2.new(0.5, 0.5)
            KnobInner.BackgroundColor3 = Colors.Cyan
            KnobInner.Parent = Knob
            Instance.new("UICorner", KnobInner).CornerRadius = UDim.new(1, 0)
            
            local dragging = false
            
            local function Update(input)
                local pos = math.clamp((input.Position.X - InnerTrack.AbsolutePosition.X) / InnerTrack.AbsoluteSize.X, 0, 1)
                val = math.floor(min + (max-min) * pos)
                
                Label.Text = title .. ": " .. val
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                Knob.Position = UDim2.new(pos, 0, 0.5, 0)
                
                SavedSettings[title] = val
                Save()
                if config.Callback then task.spawn(config.Callback, val) end
            end
            
            Knob.InputBegan:Connect(function(i) 
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end 
            end)
            UserInputService.InputEnded:Connect(function(i) 
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end 
            end)
            UserInputService.InputChanged:Connect(function(i) 
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update(i) end 
            end)
            
            if val ~= config.Default then task.spawn(config.Callback, val) end
        end
        
        -- // DROPDOWN (SMART + FLOATING + BR MODS STYLE) //
        function tabData:Dropdown(config)
            local title = config.Title or "Dropdown"
            local options = config.Options or {}
            local default = config.Default or options[1]
            local val = SavedSettings[title] or default
            
            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 0, 50)
            Container.BackgroundTransparency = 1
            Container.Parent = Page
            
            local Label = Instance.new("TextLabel")
            Label.Text = title
            Label.Size = UDim2.new(1, 0, 0, 15)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Colors.TextWhite
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.Parent = Container
            
            local Border = Instance.new("Frame")
            Border.Size = UDim2.new(1, 0, 0, 30)
            Border.Position = UDim2.new(0, 0, 0, 18)
            Border.BackgroundColor3 = Colors.Cyan
            Border.Parent = Container
            Instance.new("UICorner", Border).CornerRadius = UDim.new(0, 10)
            
            local Inner = Instance.new("Frame")
            Inner.Size = UDim2.new(1, -2, 1, -2)
            Inner.Position = UDim2.new(0.5, 0, 0.5, 0)
            Inner.AnchorPoint = Vector2.new(0.5, 0.5)
            Inner.BackgroundColor3 = Colors.Dark
            Inner.Parent = Border
            Instance.new("UICorner", Inner).CornerRadius = UDim.new(0, 10)
            
            local MainBtn = Instance.new("TextButton")
            MainBtn.Size = UDim2.new(1, 0, 1, 0)
            MainBtn.BackgroundTransparency = 1
            MainBtn.Text = val
            MainBtn.TextColor3 = Colors.TextWhite
            MainBtn.Font = Enum.Font.GothamBold
            MainBtn.TextSize = 12
            MainBtn.Parent = Inner
            
            -- FLOATING OPTIONS (The key part)
            local OptionsFrame = Instance.new("Frame")
            OptionsFrame.Name = "Options_" .. title
            OptionsFrame.Parent = ScreenGui -- Float on top
            OptionsFrame.BackgroundColor3 = Colors.Dark
            OptionsFrame.Size = UDim2.new(0, 0, 0, 0)
            OptionsFrame.Visible = false
            OptionsFrame.ClipsDescendants = true
            OptionsFrame.ZIndex = 1000
            
            local OptBorder = Instance.new("UIStroke")
            OptBorder.Color = Colors.Cyan
            OptBorder.Thickness = 1
            OptBorder.Parent = OptionsFrame
            
            Instance.new("UICorner", OptionsFrame).CornerRadius = UDim.new(0, 10)
            
            local OptList = Instance.new("UIListLayout")
            OptList.Parent = OptionsFrame
            OptList.Padding = UDim.new(0, 2)
            OptList.SortOrder = Enum.SortOrder.LayoutOrder
            
            local isOpen = false
            
            local function Close()
                isOpen = false
                RunTween(OptionsFrame, 0.2, {Size = UDim2.new(0, MainBtn.AbsoluteSize.X, 0, 0)})
                task.delay(0.2, function() OptionsFrame.Visible = false end)
            end
            
            local function Toggle()
                if isOpen then
                    Close()
                else
                    CloseDropdown() -- Close others
                    self.ActiveDropdown = { Close = Close }
                    isOpen = true
                    
                    local absPos = Inner.AbsolutePosition
                    local absSize = Inner.AbsoluteSize
                    
                    -- Smart Direction Logic
                    local itemHeight = 27
                    local totalHeight = math.min(#options * itemHeight, 6 * itemHeight) -- Max 6 items
                    local spaceBelow = ScreenGui.AbsoluteSize.Y - (absPos.Y + absSize.Y + 10)
                    local openUp = spaceBelow < totalHeight
                    
                    OptionsFrame.Visible = true
                    OptionsFrame.Size = UDim2.new(0, absSize.X, 0, 0)
                    
                    if openUp then
                        OptionsFrame.AnchorPoint = Vector2.new(0, 1)
                        OptionsFrame.Position = UDim2.fromOffset(absPos.X, absPos.Y - 2)
                    else
                        OptionsFrame.AnchorPoint = Vector2.new(0, 0)
                        OptionsFrame.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + 2)
                    end
                    
                    RunTween(OptionsFrame, 0.3, {Size = UDim2.new(0, absSize.X, 0, totalHeight)})
                end
            end
            
            MainBtn.MouseButton1Click:Connect(Toggle)
            
            -- Visibility Check Loop (0.05s)
            task.spawn(function()
                while task.wait(0.05) do
                    if not MainBtn or not MainBtn.Parent then break end
                    if isOpen then
                        local winOpen = (MainFrame.Visible and not self.IsCollapsed)
                        local pageOpen = (Page.Visible)
                        
                        if not winOpen or not pageOpen then
                            OptionsFrame.Visible = false
                        else
                            OptionsFrame.Visible = true
                            -- Update Pos
                            local absPos = Inner.AbsolutePosition
                            local absSize = Inner.AbsoluteSize
                            local itemHeight = 27
                            local totalHeight = math.min(#options * itemHeight, 6 * itemHeight)
                            local spaceBelow = ScreenGui.AbsoluteSize.Y - (absPos.Y + absSize.Y + 10)
                            local openUp = spaceBelow < totalHeight
                            
                            if openUp then
                                OptionsFrame.AnchorPoint = Vector2.new(0, 1)
                                OptionsFrame.Position = UDim2.fromOffset(absPos.X, absPos.Y - 2)
                            else
                                OptionsFrame.AnchorPoint = Vector2.new(0, 0)
                                OptionsFrame.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + 2)
                            end
                            OptionsFrame.Size = UDim2.new(0, absSize.X, 0, OptionsFrame.Size.Y.Offset)
                        end
                    else
                        if OptionsFrame.Visible then OptionsFrame.Visible = false end
                    end
                end
            end)
            
            for _, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Text = opt
                OptBtn.Size = UDim2.new(1, 0, 0, 25)
                OptBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                OptBtn.BackgroundTransparency = 0.2
                OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 12
                OptBtn.Parent = OptionsFrame
                Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 6)
                
                OptBtn.MouseButton1Click:Connect(function()
                    val = opt
                    MainBtn.Text = opt
                    Close()
                    SavedSettings[title] = opt
                    Save()
                    if config.Callback then task.spawn(config.Callback, opt) end
                end)
            end
            
            if val ~= default then task.spawn(config.Callback, val) end
        end
        
        return tabData
    end
    
    return self
end

return BrMods
