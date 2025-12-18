-- [[ DRIP CLIENT | MOBILE GUI LIBRARY - COMPLETE VERSION ]]
-- Full Implementation: Logic from original file + New Mobile Design
-- No abbreviations, full detailed code for production use

local DripUI = {}

-- // SERVICES //
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- // CONFIGURATION & PERSISTENCE LOGIC //
local ConfigFolder = "DripUI_Config"

local function EnsureConfigFolder()
    if not isfolder(ConfigFolder) then
        local success, err = pcall(function()
            makefolder(ConfigFolder)
        end)
        if not success then warn("DripUI: Failed to create config folder: " .. tostring(err)) end
    end
end

local function SaveData(data, idmap)
    EnsureConfigFolder()
    local fileName = ConfigFolder .. "/" .. tostring(idmap) .. "_Config.json"
    local success, err = pcall(function()
        writefile(fileName, HttpService:JSONEncode(data))
    end)
    if not success then warn("DripUI: Failed to save data: " .. tostring(err)) end
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

-- // GUI UTILITIES //
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

-- // MODERN THEME CONFIG //
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

-- // DRAGGABLE LOGIC FOR MOBILE/PC //
local function MakeDraggable(topbarobject, object)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        object.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
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
            update(input)
        end
    end)
end

-- // MAIN WINDOW CLASS //
function DripUI:Window(config)
    local self = {}
    self.Tabs = {}
    self.SelectedTab = nil
    self.IsCollapsed = false
    
    config = config or {}
    local idmap = tostring(game.PlaceId)
    self.ConfigID = config.ConfigID or idmap
    
    local SavedData = LoadData(self.ConfigID)
    local function SaveConfigData()
        SaveData(SavedData, self.ConfigID)
    end
    
    -- Main ScreenGui
    local ScreenGui = create("ScreenGui", {
        Parent = getSafeParent(),
        Name = config.Name or "DripUI_Mobile_" .. HttpService:GenerateGUID(false),
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false
    })
    protectGui(ScreenGui)
    
    -- Main Frame
    local MainFrame = create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0, Theme.DefaultWidth, 0, Theme.DefaultHeight),
        Position = UDim2.new(0.5, -Theme.DefaultWidth/2, 0.5, -Theme.DefaultHeight/2),
        BackgroundColor3 = Theme.Container,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true
    })
    create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 4) })
    create("UIStroke", { Parent = MainFrame, Color = Theme.Stroke, Thickness = 1 })
    
    -- Header Section
    local Header = create("TextButton", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, Theme.HeaderHeight),
        BackgroundColor3 = Theme.Container,
        Text = config.Title or "DRIP CLIENT | MOBILE",
        TextColor3 = Theme.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 5
    })
    create("UICorner", { Parent = Header, CornerRadius = UDim.new(0, 4) })
    
    local PinkLine = create("Frame", {
        Parent = Header,
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 6
    })

    MakeDraggable(Header, MainFrame)

    -- Tab System UI
    local TabContainer = create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, Theme.HeaderHeight),
        BackgroundColor3 = Theme.Container,
        BorderSizePixel = 0,
        ZIndex = 4
    })
    
    local TabListLayout = create("UIListLayout", {
        Parent = TabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Left
    })
    
    -- Pages Container
    local PagesContainer = create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, -20, 1, -(Theme.HeaderHeight + 35)),
        Position = UDim2.new(0, 10, 0, Theme.HeaderHeight + 35),
        BackgroundTransparency = 1,
        ZIndex = 2
    })
    
    -- Collapse Functionality
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
    
    -- // SELECT TAB LOGIC //
    function self:SelectTab(name)
        for _, tabData in pairs(self.Tabs) do
            if tabData.Name == name then
                tabData.Button.TextColor3 = Theme.TextMain
                tabData.Page.Visible = true
                self.SelectedTab = name
            else
                tabData.Button.TextColor3 = Theme.TextDim
                tabData.Page.Visible = false
            end
        end
    end
    
    -- // TAB CREATOR //
    function self:Tab(name)
        local tab = { Name = name, Elements = {} }
        
        local TabBtn = create("TextButton", {
            Parent = TabContainer,
            Size = UDim2.new(0.25, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = Theme.TextDim,
            BorderSizePixel = 0,
            ZIndex = 5
        })
        
        local Page = create("ScrollingFrame", {
            Parent = PagesContainer,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            Visible = false,
            ScrollBarImageColor3 = Theme.Accent,
            ZIndex = 3,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        
        local PageLayout = create("UIListLayout", {
            Parent = Page,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6)
        })
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)
        
        TabBtn.MouseButton1Click:Connect(function()
            self:SelectTab(name)
        end)
        
        tab.Button = TabBtn
        tab.Page = Page
        self.Tabs[name] = tab
        
        -- Initial selection
        if not self.SelectedTab then
            self:SelectTab(name)
        end
        
        -- // ELEMENT: TOGGLE //
        function tab:Toggle(cfg)
            local toggleData = { State = SavedData[cfg.Title] or cfg.Default or false }
            
            local ToggleBtn = create("TextButton", {
                Parent = Page,
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 10
            })
            
            local RowLayout = create("UIListLayout", {
                Parent = ToggleBtn,
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 12)
            })
            
            -- Checkbox Design (Circular)
            local Checkbox = create("Frame", {
                Parent = ToggleBtn,
                Size = UDim2.new(0, 18, 0, 18),
                BackgroundColor3 = toggleData.State and Theme.Accent or Theme.ElementBG,
                ZIndex = 11
            })
            create("UICorner", { Parent = Checkbox, CornerRadius = UDim.new(1, 0) })
            
            local CheckStroke = create("UIStroke", {
                Parent = Checkbox,
                Color = toggleData.State and Theme.Accent or Color3.fromRGB(51, 51, 51),
                Thickness = 1
            })
            
            local Label = create("TextLabel", {
                Parent = ToggleBtn,
                Text = cfg.Title or "Toggle",
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextColor3 = Color3.fromRGB(221, 221, 221),
                Size = UDim2.new(0, 200, 1, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 11
            })
            
            local function Update(val)
                toggleData.State = val
                tween(Checkbox, 0.2, { BackgroundColor3 = toggleData.State and Theme.Accent or Theme.ElementBG })
                tween(CheckStroke, 0.2, { Color = toggleData.State and Theme.Accent or Color3.fromRGB(51, 51, 51) })
                
                SavedData[cfg.Title] = toggleData.State
                SaveConfigData()
                
                if cfg.Callback then
                    task.spawn(function()
                        local ok, err = pcall(cfg.Callback, toggleData.State)
                        if not ok then warn("DripUI: Toggle Callback Error: " .. tostring(err)) end
                    end)
                end
            end
            
            ToggleBtn.MouseButton1Click:Connect(function()
                Update(not toggleData.State)
            end)
            
            -- Initial Callback execution
            if toggleData.State then
                task.spawn(function() pcall(cfg.Callback, toggleData.State) end)
            end
            
            return {
                Set = function(_, v) Update(v) end,
                Get = function() return toggleData.State end
            }
        end
        
        -- // ELEMENT: DROPDOWN //
        function tab:Dropdown(cfg)
            local options = cfg.Options or {}
            local currentVal = SavedData[cfg.Title] or cfg.Default or options[1] or "Select..."
            local isOpen = false
            
            local DropdownContainer = create("Frame", {
                Parent = Page,
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundTransparency = 1,
                ZIndex = 15
            })
            
            -- Separator Line
            create("Frame", {
                Parent = DropdownContainer,
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Stroke,
                BorderSizePixel = 0
            })
            
            local Label = create("TextLabel", {
                Parent = DropdownContainer,
                Text = cfg.Title or "Dropdown",
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextColor3 = Color3.fromRGB(221, 221, 221),
                Size = UDim2.new(0, 80, 0, 30),
                Position = UDim2.new(0, 0, 0, 10),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 16
            })
            
            local DropBox = create("TextButton", {
                Parent = DropdownContainer,
                Size = UDim2.new(1, -90, 0, 28),
                Position = UDim2.new(0, 90, 0, 10),
                BackgroundColor3 = Theme.ElementBG,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 17
            })
            create("UICorner", { Parent = DropBox, CornerRadius = UDim.new(0, 3) })
            create("UIStroke", { Parent = DropBox, Color = Color3.fromRGB(51, 51, 51) })
            
            local SelectedText = create("TextLabel", {
                Parent = DropBox,
                Text = currentVal,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = Color3.fromRGB(221, 221, 221),
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 18
            })
            
            local Arrow = create("ImageLabel", {
                Parent = DropBox,
                Image = "rbxassetid://6034818372",
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(1, -22, 0.5, -6),
                BackgroundTransparency = 1,
                ImageColor3 = Theme.Accent,
                ZIndex = 18
            })
            
            local OptionsFrame = create("Frame", {
                Parent = DropBox,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 1, 3),
                BackgroundColor3 = Color3.fromRGB(21, 21, 21),
                BorderSizePixel = 0,
                ClipsDescendants = true,
                ZIndex = 50
            })
            create("UICorner", { Parent = OptionsFrame, CornerRadius = UDim.new(0, 3) })
            create("UIStroke", { Parent = OptionsFrame, Color = Theme.Stroke })
            
            local OptLayout = create("UIListLayout", {
                Parent = OptionsFrame,
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            
            local function ToggleMenu()
                isOpen = not isOpen
                local targetHeight = isOpen and (#options * 28) or 0
                tween(OptionsFrame, 0.3, { Size = UDim2.new(1, 0, 0, targetHeight) })
                tween(Arrow, 0.3, { Rotation = isOpen and 180 or 0 })
            end
            
            DropBox.MouseButton1Click:Connect(ToggleMenu)
            
            for _, optName in ipairs(options) do
                local OptBtn = create("TextButton", {
                    Parent = OptionsFrame,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    Text = optName,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(153, 153, 153),
                    ZIndex = 51
                })
                
                OptBtn.MouseButton1Click:Connect(function()
                    currentVal = optName
                    SelectedText.Text = optName
                    ToggleMenu()
                    
                    SavedData[cfg.Title] = currentVal
                    SaveConfigData()
                    
                    if cfg.Callback then
                        task.spawn(function() pcall(cfg.Callback, currentVal) end)
                    end
                end)
                
                -- Hover Effects
                OptBtn.MouseEnter:Connect(function() tween(OptBtn, 0.1, { BackgroundTransparency = 0.9, BackgroundColor3 = Color3.new(1,1,1) }) end)
                OptBtn.MouseLeave:Connect(function() tween(OptBtn, 0.1, { BackgroundTransparency = 1 }) end)
            end

            if currentVal ~= cfg.Default then
                task.spawn(function() pcall(cfg.Callback, currentVal) end)
            end
            
            return {
                Set = function(_, v) SelectedText.Text = v currentVal = v end,
                Get = function() return currentVal end
            }
        end
        
        -- // ELEMENT: SLIDER //
        function tab:Slider(cfg)
            local min = cfg.Min or 0
            local max = cfg.Max or 100
            local current = SavedData[cfg.Title] or cfg.Default or min
            
            local SliderContainer = create("Frame", {
                Parent = Page,
                Size = UDim2.new(1, 0, 0, 48),
                BackgroundTransparency = 1,
                ZIndex = 10
            })
            
            local Label = create("TextLabel", {
                Parent = SliderContainer,
                Text = cfg.Title or "Slider",
                Size = UDim2.new(1, -50, 0, 20),
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(221, 221, 221),
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 11
            })
            
            local ValueLabel = create("TextLabel", {
                Parent = SliderContainer,
                Text = tostring(current),
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -40, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = Theme.Accent,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 11
            })
            
            local Track = create("Frame", {
                Parent = SliderContainer,
                Size = UDim2.new(1, 0, 0, 6),
                Position = UDim2.new(0, 0, 0, 28),
                BackgroundColor3 = Theme.ElementBG,
                BorderSizePixel = 0,
                ZIndex = 11
            })
            create("UICorner", { Parent = Track, CornerRadius = UDim.new(1, 0) })
            
            local Fill = create("Frame", {
                Parent = Track,
                Size = UDim2.new((current - min)/(max - min), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                ZIndex = 12
            })
            create("UICorner", { Parent = Fill, CornerRadius = UDim.new(1, 0) })
            
            local Knob = create("Frame", {
                Parent = Track,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new((current - min)/(max - min), -7, 0.5, -7),
                BackgroundColor3 = Theme.TextMain,
                ZIndex = 13
            })
            create("UICorner", { Parent = Knob, CornerRadius = UDim.new(1, 0) })
            
            local dragging = false
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                
                current = val
                ValueLabel.Text = tostring(val)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                Knob.Position = UDim2.new(pos, -7, 0.5, -7)
                
                SavedData[cfg.Title] = current
                SaveConfigData()
                
                if cfg.Callback then pcall(cfg.Callback, current) end
            end
            
            Knob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)
            
            -- Manual Track Click
            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    UpdateSlider(input)
                end
            end)

            if current ~= cfg.Default then
                task.spawn(function() pcall(cfg.Callback, current) end)
            end
            
            return {
                Set = function(_, v)
                    local p = math.clamp((v - min)/(max - min), 0, 1)
                    Fill.Size = UDim2.new(p, 0, 1, 0)
                    Knob.Position = UDim2.new(p, -7, 0.5, -7)
                    ValueLabel.Text = tostring(v)
                    current = v
                end,
                Get = function() return current end
            }
        end
        
        -- // ELEMENT: BUTTON //
        function tab:Button(cfg)
            local Btn = create("TextButton", {
                Parent = Page,
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = Theme.ElementBG,
                Text = cfg.Title or "Button",
                TextColor3 = Theme.TextMain,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                AutoButtonColor = true,
                ZIndex = 10
            })
            create("UICorner", { Parent = Btn, CornerRadius = UDim.new(0, 4) })
            create("UIStroke", { Parent = Btn, Color = Theme.Stroke, Thickness = 1 })
            
            Btn.MouseButton1Click:Connect(function()
                if cfg.Callback then pcall(cfg.Callback) end
                -- Click Animation
                tween(Btn, 0.1, { BackgroundColor3 = Theme.Accent })
                task.delay(0.1, function() tween(Btn, 0.2, { BackgroundColor3 = Theme.ElementBG }) end)
            end)
            
            return {
                SetTitle = function(_, t) Btn.Text = t end
            }
        end
        
        -- // ELEMENT: LABEL //
        function tab:Label(cfg)
            local Lbl = create("TextLabel", {
                Parent = Page,
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                Text = cfg.Text or "Label",
                TextColor3 = Theme.TextDim,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 10
            })
            
            return {
                SetText = function(_, t) Lbl.Text = t end
            }
        end

        return tab
    end
    
    -- // GLOBAL METHODS //
    function self:SetAccent(color)
        Theme.Accent = color
        PinkLine.BackgroundColor3 = color
    end
    
    function self:ToggleVisibility()
        self.IsCollapsed = not self.IsCollapsed
        if self.IsCollapsed then
            MainFrame.Visible = false
        else
            MainFrame.Visible = true
        end
    end
    
    function self:Destroy()
        ScreenGui:Destroy()
    end
    
    return self
end

return DripUI
