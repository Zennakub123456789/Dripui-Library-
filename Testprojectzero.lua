-- [[ PROJECT ZERO LIBRARY - GROUPBOX EDITION ]]
-- STYLE: Original Project Zero (Groupboxes with Title on Border)
-- FEATURE: Auto-Groupbox (Wraps elements in a box automatically if not specified)
-- COMPATIBILITY: Works with your existing script structure

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

-- // CONFIGURATION //
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
    
    Icons = {
        Home = "rbxassetid://4562959382",
        Aim = "rbxassetid://11738355467",
        Visual = "rbxassetid://13321848320",
        Setting = "rbxassetid://7059346373",
        Default = "rbxassetid://4562959382"
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
    local target = CoreGui
    local s, e = pcall(function() return gethui() end)
    if s and e then target = e end
    return target
end

local function Protect(gui)
    if syn and syn.protect_gui then syn.protect_gui(gui) end
    if get_hidden_gui then get_hidden_gui(gui) end
end

local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

-- // MAIN LIBRARY //
function ProjectZero:Window(options)
    local self = {}
    
    options = options or {}
    local title = options.Title or "Project Zero"
    local configId = options.ConfigID or tostring(game.PlaceId)
    local width = options.Width or 750
    local height = options.Height or 500
    
    local SavedData = LoadConfig(configId)
    local function Save() SaveConfig(SavedData, configId) end
    
    -- Device Detection
    local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
    local WindowSize = IsMobile and UDim2.new(0, 500, 0, 300) or UDim2.new(0, width, 0, height)
    
    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "ProjectZero_" .. HttpService:GenerateGUID(false),
        Parent = GetSafeParent(),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        IgnoreGuiInset = true
    })
    Protect(ScreenGui)
    
    -- Toggle Button (Mobile)
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
        Create("ImageLabel", {
            Parent = ToggleBtn,
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(0.5,0,0.5,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            BackgroundTransparency = 1,
            Image = CFG.Icons.Home,
            ImageColor3 = CFG.Accent
        })
        ToggleBtn.MouseButton1Click:Connect(function()
            local Main = ScreenGui:FindFirstChild("MainFrame")
            if Main then Main.Visible = not Main.Visible end
        end)
    end
    
    -- Main Frame
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        Size = WindowSize,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = CFG.BgPanel,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = not IsMobile
    })
    Create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 6) })
    Create("UIStroke", { Parent = MainFrame, Color = CFG.Border, Thickness = 1 })
    
    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        Size = UDim2.new(0, 60, 1, 0),
        BackgroundColor3 = CFG.BgSidebar,
        BorderSizePixel = 0,
        ZIndex = 2
    })
    Create("UICorner", { Parent = Sidebar, CornerRadius = UDim.new(0, 6) })
    Create("Frame", { Parent = Sidebar, Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0), BackgroundColor3 = CFG.BgSidebar, BorderSizePixel = 0 })
    
    local IconContainer = Create("Frame", { Parent = Sidebar, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 })
    Create("UIListLayout", { Parent = IconContainer, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 10) })
    Create("UIPadding", { Parent = IconContainer, PaddingTop = UDim.new(0, 15) })
    
    local TabButtons = {}
    local Pages = {}
    
    -- // TAB SYSTEM //
    function self:Tab(name, icon)
        local Tab = {}
        icon = icon or CFG.Icons.Default
        
        -- Auto Icon Mapping
        if name == "Aimbot" then icon = CFG.Icons.Aim
        elseif name == "Visual" or name == "Draw" or name == "Player" then icon = CFG.Icons.Visual
        elseif name == "Vehicle" or name == "Setting" then icon = CFG.Icons.Setting end
        
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
        local TabIcon = Create("ImageLabel", {
            Parent = TabBtn,
            Size = UDim2.new(0, 22, 0, 22),
            Position = UDim2.new(0.5,0,0.5,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            BackgroundTransparency = 1,
            Image = icon,
            ImageColor3 = CFG.TextDim,
            ZIndex = 4
        })
        
        table.insert(TabButtons, {Btn = TabBtn, Icon = TabIcon})
        
        -- Page Frame
        local Page = Create("Frame", {
            Name = name.."Page",
            Parent = MainFrame,
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 60, 0, 0),
            BackgroundTransparency = 1,
            Visible = false
        })
        table.insert(Pages, Page)
        
        -- Page Header
        local Header = Create("TextLabel", {
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
        Create("Frame", {
            Parent = Page,
            Size = UDim2.new(1, -40, 0, 1),
            Position = UDim2.new(0, 20, 0, 40),
            BackgroundColor3 = CFG.Border,
            BorderSizePixel = 0
        })
        
        -- Content Scroll
        local Scroll = Create("ScrollingFrame", {
            Parent = Page,
            Size = UDim2.new(1, 0, 1, -50),
            Position = UDim2.new(0, 0, 0, 50),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = CFG.Accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0,0,0,0)
        })
        Create("UIPadding", { Parent = Scroll, PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) })
        Create("UIListLayout", { Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15) })
        
        -- Tab Click Logic
        TabBtn.MouseButton1Click:Connect(function()
            for _, p in ipairs(Pages) do p.Visible = false end
            for _, t in ipairs(TabButtons) do
                TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                TweenService:Create(t.Icon, TweenInfo.new(0.2), {ImageColor3 = CFG.TextDim}):Play()
            end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9, BackgroundColor3 = CFG.Accent}):Play()
            TweenService:Create(TabIcon, TweenInfo.new(0.2), {ImageColor3 = CFG.Accent}):Play()
        end)
        
        if #Pages == 1 then
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9, BackgroundColor3 = CFG.Accent}):Play()
            TweenService:Create(TabIcon, TweenInfo.new(0.2), {ImageColor3 = CFG.Accent}):Play()
        end
        
        -- // HELPER: CREATE GROUPBOX UI //
        local function CreateGroupboxUI(parent, title)
            local Box = Create("Frame", {
                Parent = parent,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = CFG.GroupBg,
                BorderSizePixel = 0
            })
            Create("UIStroke", { Parent = Box, Color = CFG.Border, Thickness = 1 })
            Create("UICorner", { Parent = Box, CornerRadius = UDim.new(0, 4) })
            
            -- Title Overlap
            local LabelCont = Create("Frame", {
                Parent = Box,
                BackgroundColor3 = CFG.BgPanel,
                Size = UDim2.new(0, 0, 0, 14),
                AutomaticSize = Enum.AutomaticSize.X,
                Position = UDim2.new(0, 10, 0, -8),
                BorderSizePixel = 0,
                ZIndex = 5
            })
            Create("TextLabel", {
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
            
            -- Inner Container
            local Inner = Create("Frame", {
                Parent = Box,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1
            })
            Create("UIPadding", { Parent = Inner, PaddingTop = UDim.new(0, 15), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) })
            Create("UIListLayout", { Parent = Inner, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) })
            
            return Inner -- Return the inner container to put elements in
        end
        
        -- Groupbox Management
        local CurrentGroupbox = nil
        
        -- // FUNCTION: GROUPBOX //
        function Tab:Groupbox(title)
            local Inner = CreateGroupboxUI(Scroll, title)
            
            local Group = {}
            -- Re-implement element functions for this specific groupbox
            function Group:Toggle(cfg) return self:_Element(Inner, "Toggle", cfg) end
            function Group:Slider(cfg) return self:_Element(Inner, "Slider", cfg) end
            function Group:Dropdown(cfg) return self:_Element(Inner, "Dropdown", cfg) end
            function Group:Button(cfg) return self:_Element(Inner, "Button", cfg) end
            
            -- Inherit the internal _Element builder
            Group._Element = Tab._Element
            
            CurrentGroupbox = Inner -- Update current default
            return Group
        end
        
        -- // INTERNAL ELEMENT BUILDER //
        function Tab:_Element(parent, type, cfg)
            if type == "Toggle" then
                local title = cfg.Title or "Toggle"
                local state = SavedData[title] or cfg.Default or false
                local cb = cfg.Callback or function() end
                
                local Btn = Create("TextButton", {
                    Parent = parent,
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
                Create("UIStroke", { Parent = Box, Color = Color3.fromHex("#444") })
                local Check = Create("Frame", {
                    Parent = Box,
                    Size = UDim2.new(1, -4, 1, -4),
                    Position = UDim2.new(0.5,0,0.5,0),
                    AnchorPoint = Vector2.new(0.5,0.5),
                    BackgroundColor3 = CFG.Accent,
                    BackgroundTransparency = state and 0 or 1
                })
                Create("UICorner", { Parent = Check, CornerRadius = UDim.new(0, 2) })
                Create("TextLabel", {
                    Parent = Btn,
                    Text = title,
                    Font = CFG.Font,
                    TextSize = 13,
                    TextColor3 = Color3.fromHex("#cccccc"),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 24, 0, 0),
                    BackgroundTransparency = 1
                })
                
                Btn.MouseButton1Click:Connect(function()
                    state = not state
                    TweenService:Create(Check, TweenInfo.new(0.1), {BackgroundTransparency = state and 0 or 1}):Play()
                    SavedData[title] = state
                    Save()
                    task.spawn(cb, state)
                end)
                if state then task.spawn(cb, true) end
                
            elseif type == "Slider" then
                local title = cfg.Title
                local min, max = cfg.Min or 0, cfg.Max or 100
                local val = SavedData[title] or cfg.Default or min
                local cb = cfg.Callback or function() end
                
                local Frame = Create("Frame", { Parent = parent, Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1 })
                Create("TextLabel", { Parent = Frame, Text = title, Font = CFG.Font, TextSize = 12, TextColor3 = Color3.fromHex("#888"), TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1 })
                local Value = Create("TextLabel", { Parent = Frame, Text = tostring(val), Font = CFG.Font, TextSize = 12, TextColor3 = CFG.Accent, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1 })
                
                local Track = Create("TextButton", { Parent = Frame, Text = "", Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 1, -6), BackgroundColor3 = Color3.fromHex("#252525"), AutoButtonColor = false })
                Create("UICorner", { Parent = Track, CornerRadius = UDim.new(0, 3) })
                local Fill = Create("Frame", { Parent = Track, Size = UDim2.new((val-min)/(max-min), 0, 1, 0), BackgroundColor3 = CFG.Accent, BorderSizePixel = 0 })
                Create("UICorner", { Parent = Fill, CornerRadius = UDim.new(0, 3) })
                
                local dragging = false
                local function Update(input)
                    local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    val = math.floor(min + (max - min) * pos)
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    Value.Text = tostring(val)
                    SavedData[title] = val
                    Save()
                    task.spawn(cb, val)
                end
                Track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true Update(i) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
                UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update(i) end end)
                if val ~= cfg.Default then task.spawn(cb, val) end
                
            elseif type == "Dropdown" then
                local title = cfg.Title
                local options = cfg.Options
                local current = SavedData[title] or cfg.Default or options[1]
                local cb = cfg.Callback or function() end
                
                local Frame = Create("Frame", { Parent = parent, Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, ClipsDescendants = true })
                Create("TextLabel", { Parent = Frame, Text = title, Font = CFG.Font, TextSize = 12, TextColor3 = Color3.fromHex("#888"), TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1 })
                
                local MainBtn = Create("TextButton", { Parent = Frame, Text = current, Size = UDim2.new(1, 0, 0, 25), Position = UDim2.new(0, 0, 0, 18), BackgroundColor3 = CFG.BgPanel, TextColor3 = CFG.TextMain, Font = CFG.Font, TextSize = 13 })
                Create("UICorner", { Parent = MainBtn, CornerRadius = UDim.new(0, 4) })
                Create("UIStroke", { Parent = MainBtn, Color = CFG.Border })
                
                local List = Create("Frame", { Parent = Frame, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 45), BackgroundColor3 = CFG.BgPanel, BorderSizePixel = 0, ClipsDescendants = true })
                Create("UIListLayout", { Parent = List, SortOrder = Enum.SortOrder.LayoutOrder })
                
                local isOpen = false
                for _, opt in ipairs(options) do
                    local B = Create("TextButton", { Parent = List, Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, Text = opt, TextColor3 = CFG.TextDim, Font = CFG.Font, TextSize = 13 })
                    B.MouseButton1Click:Connect(function()
                        current = opt
                        MainBtn.Text = opt
                        isOpen = false
                        Frame:TweenSize(UDim2.new(1,0,0,45), "Out", "Quad", 0.2, true)
                        SavedData[title] = current
                        Save()
                        task.spawn(cb, current)
                    end)
                end
                
                MainBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    Frame:TweenSize(UDim2.new(1,0,0, isOpen and 45+(#options*25) or 45), "Out", "Quad", 0.2, true)
                end)
                if current ~= cfg.Default then task.spawn(cb, current) end
            end
        end
        
        -- // AUTO GROUPBOX HANDLER //
        -- If user calls Tab:Toggle instead of Tab:Groupbox():Toggle(), we handle it here
        
        function Tab:GetAutoGroup()
            if not CurrentGroupbox then
                CurrentGroupbox = CreateGroupboxUI(Scroll, "Main")
            end
            return CurrentGroupbox
        end
        
        function Tab:Toggle(cfg) return self:_Element(self:GetAutoGroup(), "Toggle", cfg) end
        function Tab:Slider(cfg) return self:_Element(self:GetAutoGroup(), "Slider", cfg) end
        function Tab:Dropdown(cfg) return self:_Element(self:GetAutoGroup(), "Dropdown", cfg) end
        function Tab:Button(cfg) return self:_Element(self:GetAutoGroup(), "Button", cfg) end
        
        return Tab
    end
    
    return self
end

return ProjectZero
