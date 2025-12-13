-- DRIP CLIENT | MOBILE UI Library
-- Compact version with mobile/PC drag support (FIXED)
local DripUI = {}

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ConfigFolder = "DripUI_Config"

local function EnsureConfigFolder()
    if not isfolder(ConfigFolder) then
        makefolder(ConfigFolder)
    end
end

local function SaveData(data, idmap)
    EnsureConfigFolder()
    local fileName = ConfigFolder .. "/" .. tostring(idmap) .. "_Config.json"
    writefile(fileName, HttpService:JSONEncode(data))
end

local function LoadData(idmap)
    EnsureConfigFolder()
    local fileName = ConfigFolder .. "/" .. tostring(idmap) .. "_Config.json"
    if isfile(fileName) then
        local content = readfile(fileName)
        if content == "[]" or content == "" then return {} end
        local success, result = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if success then return result else return {} end
    end
    return {}
end

local function getSafeParent()
    local parent = CoreGui
    local ok, gethui = pcall(function() return gethui end)
    if ok and type(gethui) == "function" then
        local gui = gethui()
        if typeof(gui) == "Instance" then parent = gui end
    end
    return parent
end

local function protectGui(gui)
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    pcall(function() if get_hidden_gui then get_hidden_gui(gui) end end)
end

local function create(class, props)
    local obj = Instance.new(class)
    for i, v in pairs(props) do
        obj[i] = v
    end
    return obj
end

local function tween(obj, tweenTime, props)
    if not obj or not obj.Parent then return nil end
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local success, t = pcall(function()
        return TweenService:Create(obj, tweenInfo, props)
    end)
    if success and t then
        t:Play()
        return t
    end
    return nil
end

local DripTheme = {
    Background = Color3.fromRGB(32, 32, 38),
    TitleBar = Color3.fromRGB(38, 38, 44),
    Content = Color3.fromRGB(32, 32, 38),
    Accent = Color3.fromRGB(235, 30, 200),
    TabInactive = Color3.fromRGB(38, 38, 44),
    TabActive = Color3.fromRGB(58, 58, 66),
    TabHover = Color3.fromRGB(48, 48, 56),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 185),
    ToggleOff = Color3.fromRGB(80, 80, 88),
    ToggleOn = Color3.fromRGB(52, 199, 89),
    ToggleKnob = Color3.fromRGB(255, 255, 255),
    Border = Color3.fromRGB(60, 60, 68),
    DropdownBg = Color3.fromRGB(38, 38, 44),
    DropdownItem = Color3.fromRGB(45, 45, 52),
    DropdownItemHover = Color3.fromRGB(55, 55, 62)
}

function DripUI:Window(config)
    local self = {}
    self.Tabs = {}
    self.SelectedTab = nil
    self.IsExpanded = true
    
    config = config or {}
    local idmap = tostring(game.PlaceId)
    self.ConfigID = config.ConfigID or idmap
    
    local SavedData = LoadData(self.ConfigID)
    
    local function SaveConfigData()
        SaveData(SavedData, self.ConfigID)
    end
    
    local ScreenGui = create("ScreenGui", {
        Parent = getSafeParent(),
        Name = config.Name or "DripUI_" .. HttpService:GenerateGUID(false),
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false
    })
    protectGui(ScreenGui)
    
    local windowWidth = config.Width or 200
    local windowHeight = config.Height or 190
    local titleBarHeight = 20
    local tabBarHeight = 20
    local accentLineHeight = 2
    local collapsedHeight = titleBarHeight + accentLineHeight
    
    local MainFrame = create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0, windowWidth, 0, windowHeight),
        Position = UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2),
        BackgroundColor3 = DripTheme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 8) })
    create("UIStroke", { Parent = MainFrame, Color = DripTheme.Border, Thickness = 1 })
    
    local TitleBar = create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, titleBarHeight),
        BackgroundColor3 = DripTheme.TitleBar,
        BorderSizePixel = 0,
        ZIndex = 10
    })
    create("UICorner", { Parent = TitleBar, CornerRadius = UDim.new(0, 8) })
    
    local TitleBarMask = create("Frame", {
        Parent = TitleBar,
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 1, -8),
        BackgroundColor3 = DripTheme.TitleBar,
        BorderSizePixel = 0,
        ZIndex = 10
    })
    
    local TitleText = create("TextLabel", {
        Parent = TitleBar,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Title or "DRIP CLIENT",
        TextColor3 = DripTheme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 8,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 11
    })
    
    local AccentLine = create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, accentLineHeight),
        Position = UDim2.new(0, 0, 0, titleBarHeight),
        BackgroundColor3 = DripTheme.Accent,
        BorderSizePixel = 0,
        ZIndex = 10
    })
    
    local TabBar = create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, tabBarHeight),
        Position = UDim2.new(0, 0, 0, titleBarHeight + accentLineHeight),
        BackgroundColor3 = DripTheme.TitleBar,
        BorderSizePixel = 0,
        ZIndex = 5
    })
    
    local TabContainer = create("Frame", {
        Parent = TabBar,
        Size = UDim2.new(1, -10, 1, -4),
        Position = UDim2.new(0, 5, 0, 2),
        BackgroundTransparency = 1,
        ZIndex = 6
    })
    
    local TabLayout = create("UIListLayout", {
        Parent = TabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 4)
    })
    
    local ContentFrame = create("ScrollingFrame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 1, -(titleBarHeight + accentLineHeight + tabBarHeight)),
        Position = UDim2.new(0, 0, 0, titleBarHeight + accentLineHeight + tabBarHeight),
        BackgroundColor3 = DripTheme.Content,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = DripTheme.TextSecondary,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 2
    })
    
    local ContentLayout = create("UIListLayout", {
        Parent = ContentFrame,
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 4)
    })
    
    create("UIPadding", {
        Parent = ContentFrame,
        PaddingTop = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 6)
    })
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local hasMoved = false
    
    local function updateDrag(input)
        if dragging and dragStart and startPos then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
                hasMoved = true
            end
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            hasMoved = false
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if not hasMoved then
                self.IsExpanded = not self.IsExpanded
                if self.IsExpanded then
                    tween(MainFrame, 0.3, { Size = UDim2.new(0, windowWidth, 0, windowHeight) })
                else
                    tween(MainFrame, 0.3, { Size = UDim2.new(0, windowWidth, 0, collapsedHeight) })
                end
            end
            dragging = false
            dragStart = nil
            startPos = nil
            hasMoved = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            updateDrag(input)
        end
    end)
    
    function self:SelectTab(index)
        if not self.Tabs[index] then return end
        
        self.SelectedTab = index
        
        for i, tab in ipairs(self.Tabs) do
            if tab.Page then
                tab.Page.Visible = (i == index)
            end
            if tab.TabButton and tab.TabButton.Parent then
                if i == index then
                    tween(tab.TabButton, 0.2, { BackgroundTransparency = 0 })
                    tab.TabButton.BackgroundColor3 = DripTheme.TabActive
                else
                    tween(tab.TabButton, 0.2, { BackgroundTransparency = 1 })
                end
            end
        end
    end
    
    function self:Tab(name)
        local tab = {}
        local tabIndex = #self.Tabs + 1
        
        local TabButton = create("TextButton", {
            Parent = TabContainer,
            Size = UDim2.new(0, 38, 1, -2),
            BackgroundColor3 = DripTheme.TabActive,
            BackgroundTransparency = tabIndex == 1 and 0 or 1,
            BorderSizePixel = 0,
            Text = name,
            TextColor3 = DripTheme.TextPrimary,
            Font = Enum.Font.GothamMedium,
            TextSize = 7,
            AutoButtonColor = false,
            ZIndex = 7
        })
        create("UICorner", { Parent = TabButton, CornerRadius = UDim.new(0, 4) })
        
        TabButton.MouseEnter:Connect(function()
            if self.SelectedTab ~= tabIndex and TabButton.Parent then
                tween(TabButton, 0.15, { BackgroundTransparency = 0 })
                TabButton.BackgroundColor3 = DripTheme.TabHover
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if self.SelectedTab ~= tabIndex and TabButton.Parent then
                tween(TabButton, 0.15, { BackgroundTransparency = 1 })
            end
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            self:SelectTab(tabIndex)
        end)
        
        local TabPage = create("Frame", {
            Parent = ContentFrame,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Visible = tabIndex == 1,
            ZIndex = 3
        })
        
        create("UIListLayout", {
            Parent = TabPage,
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Padding = UDim.new(0, 4)
        })
        
        tab.TabButton = TabButton
        tab.Page = TabPage
        tab.Index = tabIndex
        tab.Name = name
        
        function tab:Toggle(cfg)
            local toggleState = SavedData[cfg.Title] or cfg.Default or false
            
            local holder = create("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                ZIndex = 10
            })
            
            local toggleBg = create("Frame", {
                Parent = holder,
                Size = UDim2.new(0, 22, 0, 12),
                Position = UDim2.new(0, 0, 0.5, -6),
                BackgroundColor3 = toggleState and DripTheme.ToggleOn or DripTheme.ToggleOff,
                BorderSizePixel = 0,
                ZIndex = 11
            })
            create("UICorner", { Parent = toggleBg, CornerRadius = UDim.new(1, 0) })
            
            local toggleKnob = create("Frame", {
                Parent = toggleBg,
                Size = UDim2.new(0, 8, 0, 8),
                Position = toggleState and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4),
                BackgroundColor3 = DripTheme.ToggleKnob,
                BorderSizePixel = 0,
                ZIndex = 12
            })
            create("UICorner", { Parent = toggleKnob, CornerRadius = UDim.new(1, 0) })
            
            local label = create("TextLabel", {
                Parent = holder,
                Size = UDim2.new(1, -28, 1, 0),
                Position = UDim2.new(0, 26, 0, 0),
                BackgroundTransparency = 1,
                Text = cfg.Title or "Toggle",
                TextColor3 = DripTheme.TextPrimary,
                Font = Enum.Font.GothamMedium,
                TextSize = 7,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 11
            })
            
            local btn = create("TextButton", {
                Parent = holder,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 13
            })
            
            btn.MouseButton1Click:Connect(function()
                toggleState = not toggleState
                tween(toggleBg, 0.2, { BackgroundColor3 = toggleState and DripTheme.ToggleOn or DripTheme.ToggleOff })
                tween(toggleKnob, 0.2, { Position = toggleState and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4) })
                SavedData[cfg.Title] = toggleState
                SaveConfigData()
                if cfg.Callback then cfg.Callback(toggleState) end
            end)
            
            local toggleAPI = {
                Set = function(_, value)
                    toggleState = value
                    tween(toggleBg, 0.2, { BackgroundColor3 = toggleState and DripTheme.ToggleOn or DripTheme.ToggleOff })
                    tween(toggleKnob, 0.2, { Position = toggleState and UDim2.new(1, -10, 0.5, -4) or UDim2.new(0, 2, 0.5, -4) })
                    SavedData[cfg.Title] = toggleState
                    SaveConfigData()
                    if cfg.Callback then cfg.Callback(toggleState) end
                end,
                Get = function() return toggleState end
            }
            
            if cfg.Callback and SavedData[cfg.Title] ~= nil then
                task.spawn(function() cfg.Callback(toggleState) end)
            end
            
            return toggleAPI
        end
        
        function tab:Dropdown(cfg)
            local selectedValue = cfg.Default or (cfg.Options and cfg.Options[1]) or "Select"
            local isOpen = false
            
            local holder = create("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                ZIndex = 10,
                ClipsDescendants = false
            })
            
            local label = create("TextLabel", {
                Parent = holder,
                Size = UDim2.new(0.35, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = (cfg.Title or "Option") .. ":",
                TextColor3 = DripTheme.TextPrimary,
                Font = Enum.Font.GothamMedium,
                TextSize = 7,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 11
            })
            
            local dropBtn = create("TextButton", {
                Parent = holder,
                Size = UDim2.new(0.6, 0, 0, 14),
                Position = UDim2.new(0.35, 3, 0.5, -7),
                BackgroundColor3 = DripTheme.DropdownBg,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 11
            })
            create("UICorner", { Parent = dropBtn, CornerRadius = UDim.new(0, 3) })
            create("UIStroke", { Parent = dropBtn, Color = DripTheme.Border, Thickness = 1 })
            
            local selectedLabel = create("TextLabel", {
                Parent = dropBtn,
                Size = UDim2.new(1, -12, 1, 0),
                Position = UDim2.new(0, 4, 0, 0),
                BackgroundTransparency = 1,
                Text = selectedValue,
                TextColor3 = DripTheme.TextPrimary,
                Font = Enum.Font.Gotham,
                TextSize = 6,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 12
            })
            
            local arrow = create("TextLabel", {
                Parent = dropBtn,
                Size = UDim2.new(0, 10, 1, 0),
                Position = UDim2.new(1, -10, 0, 0),
                BackgroundTransparency = 1,
                Text = "▼",
                TextColor3 = DripTheme.TextPrimary,
                Font = Enum.Font.GothamBold,
                TextSize = 5,
                ZIndex = 12
            })
            
            local optionsFrame = create("Frame", {
                Parent = holder,
                Size = UDim2.new(0.6, 0, 0, 0),
                Position = UDim2.new(0.35, 3, 0, 16),
                BackgroundColor3 = DripTheme.DropdownBg,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Visible = false,
                ZIndex = 100
            })
            create("UICorner", { Parent = optionsFrame, CornerRadius = UDim.new(0, 3) })
            create("UIStroke", { Parent = optionsFrame, Color = DripTheme.Border, Thickness = 1 })
            
            local optionsList = create("ScrollingFrame", {
                Parent = optionsFrame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = DripTheme.TextSecondary,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ZIndex = 101
            })
            
            create("UIListLayout", {
                Parent = optionsList,
                Padding = UDim.new(0, 1),
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            })
            
            create("UIPadding", { Parent = optionsList, PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2) })
            
            if cfg.Options then
                for _, option in ipairs(cfg.Options) do
                    local optionBtn = create("TextButton", {
                        Parent = optionsList,
                        Size = UDim2.new(1, -4, 0, 12),
                        BackgroundColor3 = DripTheme.DropdownItem,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Text = option,
                        TextColor3 = DripTheme.TextPrimary,
                        Font = Enum.Font.Gotham,
                        TextSize = 6,
                        AutoButtonColor = false,
                        ZIndex = 102
                    })
                    create("UICorner", { Parent = optionBtn, CornerRadius = UDim.new(0, 3) })
                    
                    optionBtn.MouseEnter:Connect(function()
                        if optionBtn.Parent then
                            tween(optionBtn, 0.1, { BackgroundTransparency = 0 })
                            optionBtn.BackgroundColor3 = DripTheme.DropdownItemHover
                        end
                    end)
                    
                    optionBtn.MouseLeave:Connect(function()
                        if optionBtn.Parent then
                            tween(optionBtn, 0.1, { BackgroundTransparency = 1 })
                        end
                    end)
                    
                    optionBtn.MouseButton1Click:Connect(function()
                        selectedValue = option
                        selectedLabel.Text = option
                        isOpen = false
                        optionsFrame.Visible = false
                        tween(optionsFrame, 0.2, { Size = UDim2.new(0.6, 0, 0, 0) })
                        arrow.Text = "▼"
                        SavedData[cfg.Title] = selectedValue
                        SaveConfigData()
                        if cfg.Callback then cfg.Callback(option) end
                    end)
                end
            end
            
            dropBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    optionsFrame.Visible = true
                    local optionCount = cfg.Options and #cfg.Options or 0
                    local height = math.min(optionCount * 14 + 4, 60)
                    tween(optionsFrame, 0.2, { Size = UDim2.new(0.6, 0, 0, height) })
                    arrow.Text = "▲"
                else
                    tween(optionsFrame, 0.2, { Size = UDim2.new(0.6, 0, 0, 0) })
                    task.delay(0.2, function() optionsFrame.Visible = false end)
                    arrow.Text = "▼"
                end
            end)
            
            return {
                Set = function(_, value)
                    selectedValue = value
                    selectedLabel.Text = value
                    SavedData[cfg.Title] = selectedValue
                    SaveConfigData()
                    if cfg.Callback then cfg.Callback(value) end
                end,
                Get = function() return selectedValue end
            }
        end
        
        function tab:Button(cfg)
            local holder = create("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                ZIndex = 10
            })
            
            local btn = create("TextButton", {
                Parent = holder,
                Size = UDim2.new(1, 0, 0, 15),
                Position = UDim2.new(0, 0, 0.5, -7),
                BackgroundColor3 = DripTheme.Accent,
                BorderSizePixel = 0,
                Text = cfg.Title or "Button",
                TextColor3 = DripTheme.TextPrimary,
                Font = Enum.Font.GothamMedium,
                TextSize = 7,
                AutoButtonColor = false,
                ZIndex = 11
            })
            create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 4) })
            
            btn.MouseEnter:Connect(function()
                if btn.Parent then
                    tween(btn, 0.15, { BackgroundColor3 = Color3.new(DripTheme.Accent.R * 0.8, DripTheme.Accent.G * 0.8, DripTheme.Accent.B * 0.8) })
                end
            end)
            
            btn.MouseLeave:Connect(function()
                if btn.Parent then
                    tween(btn, 0.15, { BackgroundColor3 = DripTheme.Accent })
                end
            end)
            
            btn.MouseButton1Click:Connect(function()
                if cfg.Callback then cfg.Callback() end
            end)
            
            return { SetTitle = function(_, text) btn.Text = text end }
        end
        
        function tab:Slider(cfg)
            local min = cfg.Min or 0
            local max = cfg.Max or 100
            local value = SavedData[cfg.Title] or cfg.Default or min
            
            local holder = create("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                ZIndex = 10
            })
            
            local titleLabel = create("TextLabel", {
                Parent = holder,
                Size = UDim2.new(0.7, 0, 0, 10),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = cfg.Title or "Slider",
                TextColor3 = DripTheme.TextPrimary,
                Font = Enum.Font.GothamMedium,
                TextSize = 7,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 11
            })
            
            local valueLabel = create("TextLabel", {
                Parent = holder,
                Size = UDim2.new(0.3, 0, 0, 10),
                Position = UDim2.new(0.7, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(value),
                TextColor3 = DripTheme.Accent,
                Font = Enum.Font.GothamBold,
                TextSize = 7,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 11
            })
            
            local sliderBg = create("Frame", {
                Parent = holder,
                Size = UDim2.new(1, 0, 0, 3),
                Position = UDim2.new(0, 0, 0, 13),
                BackgroundColor3 = DripTheme.ToggleOff,
                BorderSizePixel = 0,
                ZIndex = 11
            })
            create("UICorner", { Parent = sliderBg, CornerRadius = UDim.new(1, 0) })
            
            local sliderFill = create("Frame", {
                Parent = sliderBg,
                Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = DripTheme.Accent,
                BorderSizePixel = 0,
                ZIndex = 12
            })
            create("UICorner", { Parent = sliderFill, CornerRadius = UDim.new(1, 0) })
            
            local sliderKnob = create("Frame", {
                Parent = sliderBg,
                Size = UDim2.new(0, 8, 0, 8),
                Position = UDim2.new((value - min) / (max - min), -4, 0.5, -4),
                BackgroundColor3 = DripTheme.TextPrimary,
                BorderSizePixel = 0,
                ZIndex = 13
            })
            create("UICorner", { Parent = sliderKnob, CornerRadius = UDim.new(1, 0) })
            
            local draggingSlider = false
            
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * pos)
                valueLabel.Text = tostring(value)
                sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                sliderKnob.Position = UDim2.new(pos, -4, 0.5, -4)
                SavedData[cfg.Title] = value
                SaveConfigData()
                if cfg.Callback then cfg.Callback(value) end
            end
            
            sliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = true
                    updateSlider(input)
                end
            end)
            
            sliderBg.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)
            
            if cfg.Callback and SavedData[cfg.Title] ~= nil then
                task.spawn(function() cfg.Callback(value) end)
            end
            
            return {
                Set = function(_, newValue)
                    value = math.clamp(newValue, min, max)
                    local pos = (value - min) / (max - min)
                    valueLabel.Text = tostring(value)
                    sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    sliderKnob.Position = UDim2.new(pos, -4, 0.5, -4)
                    SavedData[cfg.Title] = value
                    SaveConfigData()
                    if cfg.Callback then cfg.Callback(value) end
                end,
                Get = function() return value end
            }
        end
        
        function tab:Label(cfg)
            local lbl = create("TextLabel", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 12),
                BackgroundTransparency = 1,
                Text = cfg.Text or "Label",
                TextColor3 = DripTheme.TextSecondary,
                Font = Enum.Font.Gotham,
                TextSize = 7,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 11
            })
            return { SetText = function(_, text) lbl.Text = text end }
        end
        
        table.insert(self.Tabs, tab)
        
        if tabIndex == 1 then
            self.SelectedTab = 1
        end
        
        return tab
    end
    
    function self:SetAccent(color)
        DripTheme.Accent = color
        AccentLine.BackgroundColor3 = color
    end
    
    function self:Toggle()
        self.IsExpanded = not self.IsExpanded
        if self.IsExpanded then
            tween(MainFrame, 0.3, { Size = UDim2.new(0, windowWidth, 0, windowHeight) })
        else
            tween(MainFrame, 0.3, { Size = UDim2.new(0, windowWidth, 0, collapsedHeight) })
        end
    end
    
    function self:Destroy()
        ScreenGui:Destroy()
    end
    
    return self
end

return DripUI
