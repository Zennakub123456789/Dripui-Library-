-- [[ BR MODS UI LIBRARY - VERSION 4.0 FINAL ]]
-- THEME: BR MODS (Cyan/Dark/Black)
-- STRUCTURE: Full Library Implementation (Window/Tabs/Elements)
-- FEATURES: Smart Dropdown (Floating), Auto-Config Save, Dragging
-- STYLE: Rounded Corners, Gradient Sections, Cyan Borders

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

-- // HELPER FUNCTIONS //
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
    local path = ConfigFolder .. "/" .. tostring(id) .. ".json"
    pcall(function() 
        writefile(path, HttpService:JSONEncode(data)) 
    end)
end

local function LoadConfig(id)
    EnsureConfigFolder()
    local path = ConfigFolder .. "/" .. tostring(id) .. ".json"
    if isfile(path) then
        local content = readfile(path)
        local success, result = pcall(function() 
            return HttpService:JSONDecode(content) 
        end)
        if success then 
            return result 
        end
    end
    return {}
end

local function GetSafeParent()
    local target = CoreGui
    pcall(function() 
        if gethui then 
            target = gethui() 
        end 
    end)
    return target
end

local function Protect(gui)
    pcall(function() 
        if syn and syn.protect_gui then 
            syn.protect_gui(gui) 
        end 
    end)
end

local function Tween(obj, time, goals)
    local info = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(obj, info, goals):Play()
end

-- // THEME COLORS //
local Colors = {
    Cyan = Color3.fromRGB(0, 219, 197),
    Dark = Color3.fromRGB(15, 15, 15),
    Black = Color3.fromRGB(0, 0, 0),
    Grey = Color3.fromRGB(56, 56, 72),
    SliderFill = Color3.fromRGB(123, 146, 185),
    BorderGrey = Color3.fromRGB(110, 110, 110),
    TextWhite = Color3.fromRGB(255, 255, 255),
    MainBg = Color3.fromRGB(50, 50, 50)
}

-- // MAIN LIBRARY //
function BrMods:Window(options)
    local Library = {}
    Library.Tabs = {}
    Library.ActiveTab = nil
    
    local placeId = game.PlaceId
    local ConfigData = LoadConfig(placeId)
    
    local function Save()
        SaveConfig(ConfigData, placeId)
    end

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BR_MODS_UI_LIB"
    ScreenGui.Parent = GetSafeParent()
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false
    Protect(ScreenGui)

    -- Main Frame (Outer)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 300, 0, 420) -- Slightly wider for tabs
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -210)
    MainFrame.BackgroundColor3 = Colors.MainBg
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 15)
    MainCorner.Parent = MainFrame

    -- Inner Frame (Dark Content)
    local InnerFrame = Instance.new("Frame")
    InnerFrame.Name = "Inner"
    InnerFrame.Size = UDim2.new(1, -2, 1, -2)
    InnerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    InnerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    InnerFrame.BackgroundColor3 = Colors.Dark
    InnerFrame.BorderSizePixel = 0
    InnerFrame.Parent = MainFrame

    local InnerCorner = Instance.new("UICorner")
    InnerCorner.CornerRadius = UDim.new(0, 15)
    InnerCorner.Parent = InnerFrame

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    InnerFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then 
                    dragging = false 
                end
            end)
        end
    end)
    InnerFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X, 
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Text = options.Title or "B R   M O D S"
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 22
    Title.TextColor3 = Colors.TextWhite
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.Position = UDim2.new(0, 0, 0, 5)
    Title.Parent = InnerFrame

    -- Tab Container
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -20, 0, 35)
    TabContainer.Position = UDim2.new(0, 10, 0, 45)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.X
    TabContainer.Parent = InnerFrame

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabContainer
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)

    -- Pages Container
    local PagesContainer = Instance.new("Frame")
    PagesContainer.Name = "PagesContainer"
    PagesContainer.Size = UDim2.new(1, -16, 1, -130)
    PagesContainer.Position = UDim2.new(0, 8, 0, 90)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.Parent = InnerFrame

    -- Close Button Area
    local CloseBorder = Instance.new("Frame")
    CloseBorder.Name = "CloseBorder"
    CloseBorder.Size = UDim2.new(0, 90, 0, 32)
    CloseBorder.AnchorPoint = Vector2.new(1, 1)
    CloseBorder.Position = UDim2.new(1, -10, 1, -10)
    CloseBorder.BackgroundColor3 = Colors.Cyan
    CloseBorder.Parent = InnerFrame
    
    local CBCorner = Instance.new("UICorner")
    CBCorner.CornerRadius = UDim.new(0, 12)
    CBCorner.Parent = CloseBorder

    local CloseInner = Instance.new("Frame")
    CloseInner.Name = "CloseInner"
    CloseInner.Size = UDim2.new(1, -3, 1, -3)
    CloseInner.Position = UDim2.new(0.5, 0, 0.5, 0)
    CloseInner.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseInner.BackgroundColor3 = Colors.Black
    CloseInner.Parent = CloseBorder
    
    local CICorner = Instance.new("UICorner")
    CICorner.CornerRadius = UDim.new(0, 12)
    CICorner.Parent = CloseInner

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Text = "CLOSE"
    CloseBtn.Size = UDim2.new(1, 0, 1, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.TextColor3 = Colors.TextWhite
    CloseBtn.Font = Enum.Font.GothamBlack
    CloseBtn.TextSize = 13
    CloseBtn.Parent = CloseInner

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseInner, 0.2, {BackgroundColor3 = Colors.Cyan})
        Tween(CloseBtn, 0.2, {TextColor3 = Colors.Black})
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseInner, 0.2, {BackgroundColor3 = Colors.Black})
        Tween(CloseBtn, 0.2, {TextColor3 = Colors.TextWhite})
    end)
    
    -- // TAB CREATION //
    function Library:Tab(name)
        local TabObj = {}
        
        -- Tab Button Styling
        local TabBtnBorder = Instance.new("Frame")
        TabBtnBorder.Name = name .. "_Tab"
        TabBtnBorder.Size = UDim2.new(0, 0, 1, 0)
        TabBtnBorder.AutomaticSize = Enum.AutomaticSize.X
        TabBtnBorder.BackgroundColor3 = Colors.Dark
        TabBtnBorder.Parent = TabContainer
        
        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 8)
        TabBtnCorner.Parent = TabBtnBorder
        
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 0, 1, 0)
        TabBtn.AutomaticSize = Enum.AutomaticSize.X
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = "  " .. name .. "  "
        TabBtn.TextColor3 = Colors.TextWhite
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 12
        TabBtn.Parent = TabBtnBorder
        
        -- Page Frame
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
        
        -- Tab Switch Logic
        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Library.Tabs) do
                t.Page.Visible = false
                Tween(t.BtnBorder, 0.2, {BackgroundColor3 = Colors.Dark})
                Tween(t.BtnText, 0.2, {TextColor3 = Colors.TextWhite})
            end
            Page.Visible = true
            Tween(TabBtnBorder, 0.2, {BackgroundColor3 = Colors.Cyan})
            Tween(TabBtn, 0.2, {TextColor3 = Colors.Black})
        end)
        
        TabObj.Page = Page
        TabObj.BtnBorder = TabBtnBorder
        TabObj.BtnText = TabBtn
        table.insert(Library.Tabs, TabObj)
        
        -- Auto Select First
        if #Library.Tabs == 1 then
            Page.Visible = true
            TabBtnBorder.BackgroundColor3 = Colors.Cyan
            TabBtn.TextColor3 = Colors.Black
        end
        
        -- // SECTION (Gradient Label) //
        function TabObj:Section(text)
            local Container = Instance.new("Frame")
            Container.Name = "Section_" .. text
            Container.Size = UDim2.new(1, 0, 0, 22)
            Container.BackgroundColor3 = Color3.new(1,1,1)
            Container.BorderSizePixel = 0
            Container.Parent = Page
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 5)
            Corner.Parent = Container
            
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
        
        -- // BUTTON //
        function TabObj:Button(cfg)
            local text = cfg.Title or "Button"
            local cb = cfg.Callback or function() end
            
            local Border = Instance.new("Frame")
            Border.Name = "Button_" .. text
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
            Btn.Text = text
            Btn.TextColor3 = Colors.TextWhite
            Btn.Font = Enum.Font.GothamSemibold
            Btn.TextSize = 13
            Btn.Parent = Inner
            
            Btn.MouseButton1Click:Connect(function()
                Tween(Inner, 0.1, {BackgroundColor3 = Colors.Cyan})
                Tween(Btn, 0.1, {TextColor3 = Colors.Black})
                task.delay(0.1, function()
                    Tween(Inner, 0.2, {BackgroundColor3 = Colors.Dark})
                    Tween(Btn, 0.2, {TextColor3 = Colors.TextWhite})
                end)
                cb()
            end)
        end
        
        -- // TOGGLE //
        function TabObj:Toggle(cfg)
            local text = cfg.Title or "Toggle"
            local default = cfg.Default or false
            local cb = cfg.Callback or function() end
            
            local state = ConfigData[text] or default
            
            local Border = Instance.new("Frame")
            Border.Name = "Toggle_" .. text
            Border.Size = UDim2.new(1, 0, 0, 35)
            Border.BackgroundColor3 = state and Colors.Cyan or Colors.Grey
            Border.Parent = Page
            Instance.new("UICorner", Border).CornerRadius = UDim.new(0, 10)
            
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
            Btn.Text = text
            Btn.TextColor3 = state and Colors.Black or Colors.TextWhite
            Btn.Font = Enum.Font.GothamSemibold
            Btn.TextSize = 13
            Btn.Parent = Inner
            
            local function Update()
                Tween(Border, 0.2, {BackgroundColor3 = state and Colors.Cyan or Colors.Grey})
                Tween(Inner, 0.2, {BackgroundColor3 = state and Colors.Cyan or Colors.Dark})
                Tween(Btn, 0.2, {TextColor3 = state and Colors.Black or Colors.TextWhite})
                
                ConfigData[text] = state
                Save()
                cb(state)
            end
            
            Btn.MouseButton1Click:Connect(function()
                state = not state
                Update()
            end)
            
            if state then Update() end
        end
        
        -- // SLIDER //
        function TabObj:Slider(cfg)
            local text = cfg.Title or "Slider"
            local min = cfg.Min or 0
            local max = cfg.Max or 100
            local default = cfg.Default or min
            local cb = cfg.Callback or function() end
            
            local value = ConfigData[text] or default
            
            local Container = Instance.new("Frame")
            Container.Name = "Slider_" .. text
            Container.Size = UDim2.new(1, 0, 0, 40)
            Container.BackgroundTransparency = 1
            Container.Parent = Page
            
            local Label = Instance.new("TextLabel")
            Label.Text = text .. ": " .. math.floor(value)
            Label.Size = UDim2.new(1, 0, 0, 15)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Colors.TextWhite
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.Parent = Container
            
            local TrackBorder = Instance.new("Frame")
            TrackBorder.Size = UDim2.new(0.95, 0, 0, 8)
            TrackBorder.Position = UDim2.new(0.5, 0, 0.7, 0)
            TrackBorder.AnchorPoint = Vector2.new(0.5, 0.5)
            TrackBorder.BackgroundColor3 = Colors.BorderGrey
            TrackBorder.Parent = Container
            Instance.new("UICorner", TrackBorder).CornerRadius = UDim.new(1, 0)
            
            local TrackInner = Instance.new("Frame")
            TrackInner.Size = UDim2.new(1, -2, 1, -2)
            TrackInner.Position = UDim2.new(0.5, 0, 0.5, 0)
            TrackInner.AnchorPoint = Vector2.new(0.5, 0.5)
            TrackInner.BackgroundColor3 = Colors.Grey
            TrackInner.Parent = TrackBorder
            Instance.new("UICorner", TrackInner).CornerRadius = UDim.new(1, 0)
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Colors.SliderFill
            Fill.BorderSizePixel = 0
            Fill.Parent = TrackInner
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
            
            local Thumb = Instance.new("Frame")
            Thumb.Size = UDim2.new(0, 16, 0, 16)
            Thumb.AnchorPoint = Vector2.new(0.5, 0.5)
            Thumb.Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0)
            Thumb.BackgroundColor3 = Colors.TextWhite
            Thumb.Parent = TrackInner
            Instance.new("UICorner", Thumb).CornerRadius = UDim.new(1, 0)
            
            local ThumbInner = Instance.new("Frame")
            ThumbInner.Size = UDim2.new(1, -4, 1, -4)
            ThumbInner.AnchorPoint = Vector2.new(0.5, 0.5)
            ThumbInner.Position = UDim2.new(0.5, 0, 0.5, 0)
            ThumbInner.BackgroundColor3 = Colors.Cyan
            ThumbInner.Parent = Thumb
            Instance.new("UICorner", ThumbInner).CornerRadius = UDim.new(1, 0)
            
            local Trigger = Instance.new("TextButton")
            Trigger.BackgroundTransparency = 1
            Trigger.Size = UDim2.new(1, 0, 1, 0)
            Trigger.Text = ""
            Trigger.Parent = TrackInner
            
            local dragging = false
            local function Update(input)
                local pos = input.Position.X
                local trackPos = TrackInner.AbsolutePosition.X
                local trackSize = TrackInner.AbsoluteSize.X
                local rel = math.clamp((pos - trackPos) / trackSize, 0, 1)
                value = math.floor(min + (max - min) * rel)
                
                Label.Text = text .. ": " .. value
                Fill.Size = UDim2.new(rel, 0, 1, 0)
                Thumb.Position = UDim2.new(rel, 0, 0.5, 0)
                
                ConfigData[text] = value
                Save()
                cb(value)
            end
            
            Trigger.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    Update(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input)
                end
            end)
        end
        
        -- // DROPDOWN (SMART FLOATING - BR MODS STYLE) //
        function TabObj:Dropdown(cfg)
            local text = cfg.Title or "Dropdown"
            local options = cfg.Options or {}
            local default = cfg.Default or options[1]
            local cb = cfg.Callback or function() end
            
            local currentVal = ConfigData[text] or default
            local isDropdownOpen = false
            
            local Container = Instance.new("Frame")
            Container.Name = "Dropdown_" .. text
            Container.Size = UDim2.new(1, 0, 0, 50)
            Container.BackgroundTransparency = 1
            Container.Parent = Page
            
            local Label = Instance.new("TextLabel")
            Label.Text = text
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
            MainBtn.Text = currentVal
            MainBtn.TextColor3 = Colors.TextWhite
            MainBtn.Font = Enum.Font.GothamBold
            MainBtn.TextSize = 12
            MainBtn.Parent = Inner
            
            -- Floating List
            local ListFrame = Instance.new("Frame")
            ListFrame.Name = "List_" .. text
            ListFrame.Parent = ScreenGui -- Parent to ScreenGui for floating effect
            ListFrame.Size = UDim2.new(0, 0, 0, 0)
            ListFrame.BackgroundColor3 = Colors.Dark
            ListFrame.BorderSizePixel = 0
            ListFrame.ClipsDescendants = true
            ListFrame.Visible = false
            ListFrame.ZIndex = 100
            
            local ListBorder = Instance.new("UIStroke")
            ListBorder.Color = Colors.Cyan
            ListBorder.Thickness = 1
            ListBorder.Parent = ListFrame
            
            Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 8)
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Parent = ListFrame
            ListLayout.Padding = UDim.new(0, 2)
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local function Close()
                isDropdownOpen = false
                ListFrame.Visible = false
            end
            
            -- Generate Options
            for _, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 25)
                OptBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                OptBtn.BackgroundTransparency = 0.5
                OptBtn.Text = opt
                OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 12
                OptBtn.Parent = ListFrame
                
                OptBtn.MouseButton1Click:Connect(function()
                    currentVal = opt
                    MainBtn.Text = opt
                    ConfigData[text] = opt
                    Save()
                    cb(opt)
                    Close()
                end)
            end
            
            MainBtn.MouseButton1Click:Connect(function()
                if isDropdownOpen then
                    Close()
                else
                    -- Open Logic
                    isDropdownOpen = true
                    ListFrame.Visible = true
                    
                    -- Calculate Position & Smart Direction
                    local absPos = Inner.AbsolutePosition
                    local absSize = Inner.AbsoluteSize
                    local screenHeight = ScreenGui.AbsoluteSize.Y
                    local listHeight = math.min(#options * 27, 200)
                    
                    ListFrame.Size = UDim2.new(0, absSize.X, 0, listHeight)
                    
                    if absPos.Y + absSize.Y + listHeight > screenHeight then
                        -- Go Up
                        ListFrame.Position = UDim2.fromOffset(absPos.X, absPos.Y - listHeight - 5)
                    else
                        -- Go Down
                        ListFrame.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + 5)
                    end
                    
                    -- Auto Close Logic Loop
                    task.spawn(function()
                        while isDropdownOpen and ListFrame.Visible do
                            if not MainFrame.Visible or not Page.Visible then
                                Close()
                                break
                            end
                            -- Update Position while dragging
                            local curPos = Inner.AbsolutePosition
                            if absPos.Y + absSize.Y + listHeight > screenHeight then
                                ListFrame.Position = UDim2.fromOffset(curPos.X, curPos.Y - listHeight - 5)
                            else
                                ListFrame.Position = UDim2.fromOffset(curPos.X, curPos.Y + absSize.Y + 5)
                            end
                            task.wait(0.05)
                        end
                    end)
                end
            end)
        end
        
        return TabObj
    end
    
    return Library
end

return BrMods
