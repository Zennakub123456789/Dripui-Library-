-- [[ DRIP CLIENT | MOBILE GUI LIBRARY FULL IMPLEMENTATION ]]
-- Combined legacy functionality (800+ lines logic) with new modern design

local DripUI = {}

-- // SERVICES //
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- // CONFIGURATION & PERSISTENCE //
local ConfigFolder = "DripUI_Config"

local function EnsureConfigFolder()
    if not isfolder(ConfigFolder) then
        pcall(makefolder, ConfigFolder)
    end
end

local function SaveData(data, idmap)
    EnsureConfigFolder()
    local fileName = ConfigFolder .. "/" .. tostring(idmap) .. "_Config.json"
    pcall(writefile, fileName, HttpService:JSONEncode(data))
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

-- // THEME CONFIGURATION //
local Theme = {
    Background = Color3.fromRGB(10, 10, 10), -- #0a0a0a
    Container = Color3.fromRGB(26, 26, 26),  -- #1a1a1a
    Accent = Color3.fromRGB(255, 0, 255),    -- #ff00ff (Pink)
    TextMain = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(119, 119, 119), -- #777777
    ElementBG = Color3.fromRGB(17, 17, 17),  -- #111111
    Stroke = Color3.fromRGB(37, 37, 37),
    HeaderHeight = 40,
    DefaultWidth = 320,
    DefaultHeight = 350
}

-- // UTILITIES //
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
    local t = TweenService:Create(obj, tweenInfo, props)
    t:Play()
    return t
end

local function MakeDraggable(topbarobject, object)
    local dragging, dragInput, dragStart, startPos
    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- // WINDOW CONSTRUCTOR //
function DripUI:Window(config)
    local self = {
        Tabs = {},
        SelectedTab = nil,
        IsCollapsed = false,
        ConfigID = config.ConfigID or tostring(game.PlaceId)
    }
    
    local SavedData = LoadData(self.ConfigID)
    local function SaveConfigData() SaveData(SavedData, self.ConfigID) end

    -- GUI Setup
    local ScreenGui = create("ScreenGui", {
        Parent = getSafeParent(),
        Name = config.Name or "DripUI_" .. HttpService:GenerateGUID(false),
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false
    })
    protectGui(ScreenGui)

    local MainFrame = create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0, Theme.DefaultWidth, 0, Theme.DefaultHeight),
        Position = UDim2.new(0.5, -Theme.DefaultWidth/2, 0.5, -Theme.DefaultHeight/2),
        BackgroundColor3 = Theme.Container,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 4) })
    local MainStroke = create("UIStroke", { Parent = MainFrame, Color = Theme.Stroke, Thickness = 1 })

    -- Header
    local Header = create("TextButton", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, Theme.HeaderHeight),
        BackgroundColor3 = Theme.Container,
        Text = config.Title or "DRIP CLIENT | MOBILE",
        TextColor3 = Theme.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        AutoButtonColor = false
    })
    create("UICorner", { Parent = Header, CornerRadius = UDim.new(0, 4) })
    local PinkLine = create("Frame", {
        Parent = Header,
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0
    })

    MakeDraggable(Header, MainFrame)

    -- Tab System UI
    local TabContainer = create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, Theme.HeaderHeight),
        BackgroundColor3 = Theme.Container,
        BorderSizePixel = 0
    })
    local TabListLayout = create("UIListLayout", {
        Parent = TabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local PagesContainer = create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, -20, 1, -(Theme.HeaderHeight + 35)),
        Position = UDim2.new(0, 10, 0, Theme.HeaderHeight + 35),
        BackgroundTransparency = 1
    })

    -- Header Click Collapse
    Header.MouseButton1Click:Connect(function()
        self.IsCollapsed = not self.IsCollapsed
        if self.IsCollapsed then
            tween(MainFrame, 0.4, { Size = UDim2.new(0, Theme.DefaultWidth, 0, Theme.HeaderHeight) })
            TabContainer.Visible = false
            PagesContainer.Visible = false
        else
            tween(MainFrame, 0.4, { Size = UDim2.new(0, Theme.DefaultWidth, 0, Theme.DefaultHeight) })
            task.delay(0.2, function()
                TabContainer.Visible = true
                PagesContainer.Visible = true
            end)
        end
    end)

    -- // TAB CREATOR //
    function self:Tab(name)
        local tab = { Index = #self.Tabs + 1 }
        
        local TabBtn = create("TextButton", {
            Parent = TabContainer,
            Size = UDim2.new(0.25, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = (tab.Index == 1) and Theme.TextMain or Theme.TextDim
        })
        
        local Page = create("ScrollingFrame", {
            Parent = PagesContainer,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            Visible = (tab.Index == 1),
            ScrollBarImageColor3 = Theme.Accent
        })
        local PageLayout = create("UIListLayout", {
            Parent = Page,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5)
        })
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(self.Tabs) do
                t.Button.TextColor3 = Theme.TextDim
                t.Page.Visible = false
            end
            TabBtn.TextColor3 = Theme.TextMain
            Page.Visible = true
        end)

        tab.Button = TabBtn
        tab.Page = Page
        table.insert(self.Tabs, tab)

        -- // ELEMENT: TOGGLE //
        function tab:Toggle(cfg)
            local toggleState = SavedData[cfg.Title] or cfg.Default or false
            
            local ToggleBtn = create("TextButton", {
                Parent = Page,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Text = ""
            })
            create("UIListLayout", {
                Parent = ToggleBtn,
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 12)
            })
            
            local Checkbox = create("Frame", {
                Parent = ToggleBtn,
                Size = UDim2.new(0, 16, 0, 16),
                BackgroundColor3 = toggleState and Theme.Accent or Theme.ElementBG
            })
            create("UICorner", { Parent = Checkbox, CornerRadius = UDim.new(1, 0) })
            local CheckboxStroke = create("UIStroke", {
                Parent = Checkbox,
                Color = toggleState and Theme.Accent or Color3.fromRGB(51, 51, 51),
                Thickness = 1
            })
            
            local Label = create("TextLabel", {
                Parent = ToggleBtn,
                Text = cfg.Title,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextColor3 = Color3.fromRGB(221, 221, 221),
                Size = UDim2.new(0, 200, 1, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local function Update(val)
                toggleState = val
                tween(Checkbox, 0.2, { BackgroundColor3 = toggleState and Theme.Accent or Theme.ElementBG })
                tween(CheckboxStroke, 0.2, { Color = toggleState and Theme.Accent or Color3.fromRGB(51, 51, 51) })
                SavedData[cfg.Title] = toggleState
                SaveConfigData()
                if cfg.Callback then pcall(cfg.Callback, toggleState) end
            end

            ToggleBtn.MouseButton1Click:Connect(function() Update(not toggleState) end)
            if toggleState then task.spawn(function() pcall(cfg.Callback, toggleState) end) end

            return { Set = Update, Get = function() return toggleState end }
        end

        -- // ELEMENT: DROPDOWN //
        function tab:Dropdown(cfg)
            local options = cfg.Options or {}
            local selectedValue = SavedData[cfg.Title] or cfg.Default or options[1] or "Select..."
            
            local DropdownContainer = create("Frame", {
                Parent = Page,
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundTransparency = 1
            })
            create("Frame", { -- Separator
                Parent = DropdownContainer,
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Stroke,
                BorderSizePixel = 0
            })
            
            local Label = create("TextLabel", {
                Parent = DropdownContainer,
                Text = cfg.Title,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextColor3 = Color3.fromRGB(221, 221, 221),
                Size = UDim2.new(0, 80, 0, 30),
                Position = UDim2.new(0, 0, 0, 10),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local DropBtn = create("TextButton", {
                Parent = DropdownContainer,
                Size = UDim2.new(1, -90, 0, 28),
                Position = UDim2.new(0, 90, 0, 10),
                BackgroundColor3 = Theme.ElementBG,
                Text = "",
                AutoButtonColor = false
            })
            create("UIStroke", { Parent = DropBtn, Color = Color3.fromRGB(51, 51, 51) })
            create("UICorner", { Parent = DropBtn, CornerRadius = UDim.new(0, 3) })
            
            local SelectedLabel = create("TextLabel", {
                Parent = DropBtn,
                Text = selectedValue,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = Color3.fromRGB(221, 221, 221),
                Size = UDim2.new(1, -25, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Arrow = create("ImageLabel", {
                Parent = DropBtn,
                Image = "rbxassetid://6034818372",
                Size = UDim2.new(0, 11, 0, 11),
                Position = UDim2.new(1, -20, 0.5, -5),
                BackgroundTransparency = 1,
                ImageColor3 = Theme.Accent
            })
            
            local OptionsFrame = create("Frame", {
                Parent = DropBtn,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 1, 2),
                BackgroundColor3 = Color3.fromRGB(21, 21, 21),
                ClipsDescendants = true,
                ZIndex = 10
            })
            create("UICorner", { Parent = OptionsFrame, CornerRadius = UDim.new(0, 3) })
            create("UIListLayout", { Parent = OptionsFrame })
            
            local isOpen = false
            local function ToggleMenu()
                isOpen = not isOpen
                local h = isOpen and (#options * 28) or 0
                tween(OptionsFrame, 0.3, { Size = UDim2.new(1, 0, 0, h) })
                tween(Arrow, 0.3, { Rotation = isOpen and 180 or 0 })
            end
            
            DropBtn.MouseButton1Click:Connect(ToggleMenu)

            for _, opt in ipairs(options) do
                local OptBtn = create("TextButton", {
                    Parent = OptionsFrame,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    Text = opt,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(153, 153, 153),
                    ZIndex = 11
                })
                OptBtn.MouseButton1Click:Connect(function()
                    selectedValue = opt
                    SelectedLabel.Text = opt
                    ToggleMenu()
                    SavedData[cfg.Title] = selectedValue
                    SaveConfigData()
                    if cfg.Callback then pcall(cfg.Callback, opt) end
                end)
            end

            if selectedValue ~= cfg.Default then task.spawn(function() pcall(cfg.Callback, selectedValue) end) end
            
            return { Set = function(_, v) SelectedLabel.Text = v end, Get = function() return selectedValue end }
        end

        -- // ELEMENT: SLIDER //
        function tab:Slider(cfg)
            local min = cfg.Min or 0
            local max = cfg.Max or 100
            local current = SavedData[cfg.Title] or cfg.Default or min
            
            local SliderFrame = create("Frame", {
                Parent = Page,
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundTransparency = 1
            })
            
            local Label = create("TextLabel", {
                Parent = SliderFrame,
                Text = cfg.Title,
                Size = UDim2.new(1, -50, 0, 20),
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(221, 221, 221),
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ValueLabel = create("TextLabel", {
                Parent = SliderFrame,
                Text = tostring(current),
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -40, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = Theme.Accent,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right
            })
            
            local Track = create("Frame", {
                Parent = SliderFrame,
                Size = UDim2.new(1, 0, 0, 6),
                Position = UDim2.new(0, 0, 0, 25),
                BackgroundColor3 = Theme.ElementBG,
                BorderSizePixel = 0
            })
            create("UICorner", { Parent = Track, CornerRadius = UDim.new(1, 0) })
            
            local Fill = create("Frame", {
                Parent = Track,
                Size = UDim2.new((current - min)/(max - min), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0
            })
            create("UICorner", { Parent = Fill, CornerRadius = UDim.new(1, 0) })
            
            local dragging = false
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                current = val
                ValueLabel.Text = tostring(val)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                
                SavedData[cfg.Title] = current
                SaveConfigData()
                if cfg.Callback then pcall(cfg.Callback, current) end
            end
            
            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    UpdateSlider(input)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            if current ~= cfg.Default then task.spawn(function() pcall(cfg.Callback, current) end) end
            
            return { Set = function(_, v) 
                local p = math.clamp((v - min)/(max - min), 0, 1)
                Fill.Size = UDim2.new(p, 0, 1, 0)
                ValueLabel.Text = tostring(v)
                current = v
            end, Get = function() return current end }
        end

        -- // ELEMENT: BUTTON //
        function tab:Button(cfg)
            local Btn = create("TextButton", {
                Parent = Page,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Theme.ElementBG,
                Text = cfg.Title,
                TextColor3 = Theme.TextMain,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                AutoButtonColor = true
            })
            create("UICorner", { Parent = Btn, CornerRadius = UDim.new(0, 4) })
            create("UIStroke", { Parent = Btn, Color = Theme.Stroke })
            
            Btn.MouseButton1Click:Connect(function()
                if cfg.Callback then pcall(cfg.Callback) end
            end)
            
            return { SetTitle = function(_, t) Btn.Text = t end }
        end

        -- // ELEMENT: LABEL //
        function tab:Label(cfg)
            local Lbl = create("TextLabel", {
                Parent = Page,
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = cfg.Text or "Label",
                TextColor3 = Theme.TextDim,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            return { SetText = function(_, t) Lbl.Text = t end }
        end

        return tab
    end

    function self:SetAccent(color)
        Theme.Accent = color
        PinkLine.BackgroundColor3 = color
    end

    function self:Destroy()
        ScreenGui:Destroy()
    end

    return self
end

return DripUI
