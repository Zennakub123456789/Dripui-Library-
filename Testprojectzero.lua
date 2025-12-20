-- [[ PROJECT ZERO LIBRARY - STABLE MODULE ]]
-- AUTO-DETECT: Mobile (500x300 + Toggle Button) / PC (750x500)
-- STYLE: Modern Dark Panel, Sidebar, Groupboxes, Accent #3b82f6
-- FEATURES: Save/Load System, Full Element Suite (Toggle, Slider, Dropdown, Button)

local ProjectZero = {}

-- // SERVICES //
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- // CONFIGURATION & THEME //
local CFG = {
    BgBody = Color3.fromHex("#121212"),
    BgPanel = Color3.fromHex("#1e1e1e"),
    BgSidebar = Color3.fromHex("#181818"),
    GroupBg = Color3.fromHex("#141414"),
    Accent = Color3.fromHex("#3b82f6"),
    TextMain = Color3.fromHex("#e0e0e0"),
    TextDim = Color3.fromHex("#757575"),
    Border = Color3.fromHex("#333333"),
    Font = Enum.Font.Roboto,
    
    -- Default Icons if none provided
    Icons = {
        Default = "rbxassetid://4562959382", -- Home Icon
        Settings = "rbxassetid://7059346373"
    }
}

-- // SAVE SYSTEM //
local ConfigFolder = "ProjectZero_Config"

local function EnsureConfigFolder()
    if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
end

local function SaveConfig(data, id)
    EnsureConfigFolder()
    local path = ConfigFolder .. "/" .. tostring(id) .. "_Config.json"
    pcall(function() writefile(path, HttpService:JSONEncode(data)) end)
end

local function LoadConfig(id)
    EnsureConfigFolder()
    local path = ConfigFolder .. "/" .. tostring(id) .. "_Config.json"
    if isfile(path) then
        local s, r = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
        if s then return r end
    end
    return {}
end

-- // UTILS //
local function GetSafeParent()
    return gethui and gethui() or CoreGui
end

local function Protect(gui)
    if syn and syn.protect_gui then syn.protect_gui(gui) end
end

local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

-- // LIBRARY CORE //
function ProjectZero:Window(options)
    options = options or {}
    local windowTitle = options.Title or "Project Zero"
    local configId = options.ConfigID or tostring(game.PlaceId)
    
    local SavedData = LoadConfig(configId)
    local function Save() SaveConfig(SavedData, configId) end
    
    local Library = { Tabs = {}, PageMap = {} }
    
    -- Device Check
    local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
    local WindowSize = IsMobile and UDim2.new(0, 500, 0, 300) or UDim2.new(0, 750, 0, 500)
    
    -- 1. ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "ProjectZero_" .. HttpService:GenerateGUID(false),
        Parent = GetSafeParent(),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Global
    })
    Protect(ScreenGui)
    
    -- 2. Toggle Button (Mobile)
    if IsMobile then
        local ToggleBtn = Create("ImageButton", {
            Name = "ToggleUI",
            Parent = ScreenGui,
            Size = UDim2.new(0, 45, 0, 45),
            Position = UDim2.new(0.05, 0, 0.1, 0),
            BackgroundColor3 = CFG.BgPanel,
            BorderColor3 = CFG.Accent,
            BorderSizePixel = 2
        })
        Create("UICorner", { Parent = ToggleBtn, CornerRadius = UDim.new(1, 0) })
        
        local TIcon = Create("ImageLabel", {
            Parent = ToggleBtn,
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Image = CFG.Icons.Default,
            ImageColor3 = CFG.Accent
        })
        
        ToggleBtn.MouseButton1Click:Connect(function()
            local Main = ScreenGui:FindFirstChild("MainFrame")
            if Main then Main.Visible = not Main.Visible end
        end)
    end
    
    -- 3. Main Frame
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        Size = WindowSize,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = CFG.BgPanel,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = not IsMobile -- Hidden by default on mobile
    })
    Create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 6) })
    Create("UIStroke", { Parent = MainFrame, Color = CFG.Border, Thickness = 1 })
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- 4. Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        Size = UDim2.new(0, 60, 1, 0),
        BackgroundColor3 = CFG.BgSidebar,
        BorderSizePixel = 0,
        ZIndex = 2
    })
    Create("UICorner", { Parent = Sidebar, CornerRadius = UDim.new(0, 6) })
    Create("Frame", { -- Fix Corner
        Parent = Sidebar,
        Size = UDim2.new(0, 10, 1, 0),
        Position = UDim2.new(1, -10, 0, 0),
        BackgroundColor3 = CFG.BgSidebar,
        BorderSizePixel = 0
    })
    
    local IconContainer = Create("Frame", {
        Parent = Sidebar,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1
    })
    local IconList = Create("UIListLayout", {
        Parent = IconContainer,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 10)
    })
    Create("UIPadding", { Parent = IconContainer, PaddingTop = UDim.new(0, 15) })
    
    -- // TAB SYSTEM //
    function Library:Tab(name, iconId)
        local Tab = {}
        iconId = iconId or CFG.Icons.Default
        
        -- Tab Button
        local TabBtn = Create("ImageButton", {
            Name = name,
            Parent = IconContainer,
            Size = UDim2.new(0, 40, 0, 40),
            BackgroundColor3 = Color3.new(0,0,0),
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            ZIndex = 3
        })
        Create("UICorner", { Parent = TabBtn, CornerRadius = UDim.new(0, 8) })
        
        local Icon = Create("ImageLabel", {
            Parent = TabBtn,
            Size = UDim2.new(0, 22, 0, 22),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Image = iconId,
            ImageColor3 = CFG.TextDim,
            ZIndex = 4
        })
        
        -- Page Frame
        local Page = Create("Frame", {
            Name = name.."Page",
            Parent = MainFrame,
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 60, 0, 0),
            BackgroundTransparency = 1,
            Visible = false
        })
        
        -- Header Title
        local Title = Create("TextLabel", {
            Parent = Page,
            Text = name,
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextColor3 = CFG.TextMain,
            Size = UDim2.new(1, -40, 0, 40),
            Position = UDim2.new(0, 20, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1
        })
        Create("Frame", { -- Divider
            Parent = Page,
            Size = UDim2.new(1, -40, 0, 1),
            Position = UDim2.new(0, 20, 0, 40),
            BackgroundColor3 = CFG.Border,
            BorderSizePixel = 0
        })
        
        -- Column Logic (Mobile vs PC)
        local ParentContainer
        if IsMobile then
            local Scroll = Create("ScrollingFrame", {
                Parent = Page,
                Size = UDim2.new(1, 0, 1, -50),
                Position = UDim2.new(0, 0, 0, 50),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = CFG.Accent,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                CanvasSize = UDim2.new(0,0,0,0)
            })
            Create("UIPadding", { Parent = Scroll, PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10), PaddingTop = UDim.new(0,10) })
            
            local ColCont = Create("Frame", {
                Parent = Scroll,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1
            })
            Create("UIListLayout", { Parent = ColCont, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10) })
            ParentContainer = ColCont
        else
            local ContentFrame = Create("Frame", {
                Parent = Page,
                Size = UDim2.new(1, -40, 1, -60),
                Position = UDim2.new(0, 20, 0, 50),
                BackgroundTransparency = 1
            })
            Create("UIListLayout", { Parent = ContentFrame, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 20) })
            ParentContainer = ContentFrame
        end
        
        -- Columns
        local LeftCol = Create("Frame", {
            Parent = ParentContainer,
            Size = IsMobile and UDim2.new(0.5, -5, 0, 0) or UDim2.new(0.5, -10, 1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1
        })
        Create("UIListLayout", { Parent = LeftCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15) })
        
        local RightCol = Create("Frame", {
            Parent = ParentContainer,
            Size = IsMobile and UDim2.new(0.5, -5, 0, 0) or UDim2.new(0.5, -10, 1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1
        })
        Create("UIListLayout", { Parent = RightCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15) })
        
        local Columns = {LeftCol, RightCol}
        local ColIndex = 1
        
        -- Switch Logic
        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(Library.PageMap) do p.Visible = false end
            Page.Visible = true
            
            for _, t in pairs(Library.Tabs) do
                TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                TweenService:Create(t.Icon, TweenInfo.new(0.2), {ImageColor3 = CFG.TextDim}):Play()
            end
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9, BackgroundColor3 = CFG.Accent}):Play()
            TweenService:Create(Icon, TweenInfo.new(0.2), {ImageColor3 = CFG.Accent}):Play()
        end)
        
        table.insert(Library.Tabs, {Name = name, Btn = TabBtn, Icon = Icon})
        Library.PageMap[name] = Page
        
        -- Auto Select First
        if #Library.Tabs == 1 then
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9, BackgroundColor3 = CFG.Accent}):Play()
            TweenService:Create(Icon, TweenInfo.new(0.2), {ImageColor3 = CFG.Accent}):Play()
        end
        
        -- // SECTION (GROUPBOX) //
        function Tab:Section(title)
            local targetCol = Columns[ColIndex]
            ColIndex = (ColIndex % 2) + 1
            
            local Group = Create("Frame", {
                Parent = targetCol,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = CFG.GroupBg,
                BorderSizePixel = 0
            })
            Create("UIStroke", { Parent = Group, Color = CFG.Border, Thickness = 1 })
            Create("UICorner", { Parent = Group, CornerRadius = UDim.new(0, 4) })
            
            -- Label
            local LabelCont = Create("Frame", {
                Parent = Group,
                BackgroundColor3 = CFG.BgPanel,
                Size = UDim2.new(0, 0, 0, 14),
                AutomaticSize = Enum.AutomaticSize.X,
                Position = UDim2.new(0, 10, 0, -8),
                BorderSizePixel = 0,
                ZIndex = 5
            })
            local GLabel = Create("TextLabel", {
                Parent = LabelCont,
                Text = title,
                TextColor3 = CFG.Accent,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1
            })
            Create("UIPadding", { Parent = LabelCont, PaddingLeft = UDim.new(0,5), PaddingRight = UDim.new(0,5) })
            
            -- Container for Elements
            local Inner = Create("Frame", {
                Parent = Group,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1
            })
            Create("UIPadding", { Parent = Inner, PaddingTop = UDim.new(0, 15), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) })
            Create("UIListLayout", { Parent = Inner, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10) })
            
            local Section = {}
            
            -- [ELEMENT] TOGGLE
            function Section:Toggle(cfg)
                local tName = cfg.Title or "Toggle"
                local state = SavedData[tName] or cfg.Default or false
                
                local Btn = Create("TextButton", {
                    Parent = Inner,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = ""
                })
                
                local Box = Create("Frame", {
                    Parent = Btn,
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.fromHex("#252525")
                })
                Create("UICorner", { Parent = Box, CornerRadius = UDim.new(0, 3) })
                local BS = Create("UIStroke", { Parent = Box, Color = Color3.fromHex("#444") })
                
                local Check = Create("Frame", {
                    Parent = Box,
                    Size = UDim2.new(1, -4, 1, -4),
                    Position = UDim2.new(0.5,0,0.5,0),
                    AnchorPoint = Vector2.new(0.5,0.5),
                    BackgroundColor3 = CFG.Accent,
                    BackgroundTransparency = state and 0 or 1
                })
                Create("UICorner", { Parent = Check, CornerRadius = UDim.new(0, 2) })
                
                local Label = Create("TextLabel", {
                    Parent = Btn,
                    Text = tName,
                    Font = CFG.Font,
                    TextSize = 13,
                    TextColor3 = Color3.fromHex("#cccccc"),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 24, 0, 0),
                    BackgroundTransparency = 1
                })
                
                local function Update()
                    TweenService:Create(Check, TweenInfo.new(0.1), {BackgroundTransparency = state and 0 or 1}):Play()
                    TweenService:Create(BS, TweenInfo.new(0.1), {Color = state and CFG.Accent or Color3.fromHex("#444")}):Play()
                    SavedData[tName] = state
                    Save()
                    if cfg.Callback then task.spawn(cfg.Callback, state) end
                end
                
                Btn.MouseButton1Click:Connect(function()
                    state = not state
                    Update()
                end)
                
                if state then task.spawn(cfg.Callback, true) end
                return { Set = function(_, v) state = v Update() end }
            end
            
            -- [ELEMENT] SLIDER
            function Section:Slider(cfg)
                local sName = cfg.Title or "Slider"
                local min, max = cfg.Min or 0, cfg.Max or 100
                local val = SavedData[sName] or cfg.Default or min
                
                local Frame = Create("Frame", {
                    Parent = Inner,
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1
                })
                
                local Label = Create("TextLabel", {
                    Parent = Frame,
                    Text = sName,
                    Font = CFG.Font,
                    TextSize = 12,
                    TextColor3 = Color3.fromHex("#888"),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, 0, 0, 15),
                    BackgroundTransparency = 1
                })
                
                local Value = Create("TextLabel", {
                    Parent = Frame,
                    Text = tostring(val),
                    Font = CFG.Font,
                    TextSize = 12,
                    TextColor3 = CFG.Accent,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Size = UDim2.new(1, 0, 0, 15),
                    BackgroundTransparency = 1
                })
                
                local Track = Create("TextButton", {
                    Parent = Frame,
                    Text = "",
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 1, -6),
                    BackgroundColor3 = Color3.fromHex("#252525"),
                    AutoButtonColor = false
                })
                Create("UICorner", { Parent = Track, CornerRadius = UDim.new(0, 3) })
                
                local Fill = Create("Frame", {
                    Parent = Track,
                    Size = UDim2.new((val-min)/(max-min), 0, 1, 0),
                    BackgroundColor3 = CFG.Accent,
                    BorderSizePixel = 0
                })
                Create("UICorner", { Parent = Fill, CornerRadius = UDim.new(0, 3) })
                
                local dragging = false
                local function Update(input)
                    local pos = input.Position.X
                    local tPos = Track.AbsolutePosition.X
                    local tSize = Track.AbsoluteSize.X
                    local rel = math.clamp((pos - tPos) / tSize, 0, 1)
                    val = math.floor(min + (max - min) * rel)
                    
                    Fill.Size = UDim2.new(rel, 0, 1, 0)
                    Value.Text = tostring(val)
                    
                    SavedData[sName] = val
                    Save()
                    if cfg.Callback then task.spawn(cfg.Callback, val) end
                end
                
                Track.InputBegan:Connect(function(input)
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
                
                if val ~= cfg.Default then task.spawn(cfg.Callback, val) end
            end
            
            -- [ELEMENT] BUTTON
            function Section:Button(cfg)
                local bName = cfg.Title or "Button"
                
                local Btn = Create("TextButton", {
                    Parent = Inner,
                    Size = UDim2.new(1, 0, 0, 25),
                    BackgroundColor3 = CFG.BgPanel,
                    Text = bName,
                    Font = CFG.Font,
                    TextSize = 13,
                    TextColor3 = CFG.TextMain,
                    AutoButtonColor = true
                })
                Create("UICorner", { Parent = Btn, CornerRadius = UDim.new(0, 4) })
                Create("UIStroke", { Parent = Btn, Color = CFG.Border })
                
                Btn.MouseButton1Click:Connect(function()
                    if cfg.Callback then task.spawn(cfg.Callback) end
                    TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = CFG.Accent, TextColor3 = Color3.new(0,0,0)}):Play()
                    task.delay(0.1, function()
                        TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = CFG.BgPanel, TextColor3 = CFG.TextMain}):Play()
                    end)
                end)
            end
            
            -- [ELEMENT] DROPDOWN
            function Section:Dropdown(cfg)
                local dName = cfg.Title or "Dropdown"
                local options = cfg.Options or {}
                local default = cfg.Default or options[1]
                local current = SavedData[dName] or default
                
                local Container = Create("Frame", {
                    Parent = Inner,
                    Size = UDim2.new(1, 0, 0, 45),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true
                })
                
                local Label = Create("TextLabel", {
                    Parent = Container,
                    Text = dName,
                    Size = UDim2.new(1, 0, 0, 15),
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.fromHex("#888"),
                    Font = CFG.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local DropBtn = Create("TextButton", {
                    Parent = Container,
                    Text = current,
                    Size = UDim2.new(1, 0, 0, 25),
                    Position = UDim2.new(0, 0, 0, 18),
                    BackgroundColor3 = CFG.BgPanel,
                    TextColor3 = CFG.TextMain,
                    Font = CFG.Font,
                    TextSize = 13
                })
                Create("UICorner", { Parent = DropBtn, CornerRadius = UDim.new(0, 4) })
                Create("UIStroke", { Parent = DropBtn, Color = CFG.Border })
                
                local List = Create("Frame", {
                    Parent = Container,
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 45),
                    BackgroundColor3 = CFG.BgPanel,
                    BorderSizePixel = 0,
                    ClipsDescendants = true
                })
                Create("UIListLayout", { Parent = List, SortOrder = Enum.SortOrder.LayoutOrder })
                
                local isOpen = false
                local itemH = 25
                
                for _, opt in ipairs(options) do
                    local OptBtn = Create("TextButton", {
                        Parent = List,
                        Text = opt,
                        Size = UDim2.new(1, 0, 0, itemH),
                        BackgroundTransparency = 1,
                        TextColor3 = CFG.TextDim,
                        Font = CFG.Font,
                        TextSize = 13
                    })
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        current = opt
                        DropBtn.Text = opt
                        isOpen = false
                        Container:TweenSize(UDim2.new(1, 0, 0, 45), "Out", "Quad", 0.2, true)
                        
                        SavedData[dName] = current
                        Save()
                        if cfg.Callback then task.spawn(cfg.Callback, current) end
                    end)
                end
                
                DropBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        Container:TweenSize(UDim2.new(1, 0, 0, 45 + (#options * itemH)), "Out", "Quad", 0.2, true)
                    else
                        Container:TweenSize(UDim2.new(1, 0, 0, 45), "Out", "Quad", 0.2, true)
                    end
                end)
                
                if current ~= default then task.spawn(cfg.Callback, current) end
            end
            
            return Section
        end
        
        return Tab
    end
    
    return Library
end

return ProjectZero
