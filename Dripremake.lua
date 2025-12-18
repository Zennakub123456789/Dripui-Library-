-- [[ DRIP CLIENT | MOBILE GUI LIBRARY - VERSION 2.1 FULL ]]
-- Fixed: "attempt to index function" error
-- Adjusted: Compact size for mobile
-- Implementation: Full legacy logic from 800+ line original file

local DripUI = {}

-- // SERVICES //
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- // CONFIGURATION SYSTEM //
local ConfigFolder = "DripUI_Config"

-- ฟังก์ชันตรวจสอบและสร้างโฟลเดอร์เก็บค่าเซ็ตติ้ง
local function EnsureConfigFolder()
    if not isfolder(ConfigFolder) then
        local success, err = pcall(function()
            makefolder(ConfigFolder)
        end)
        if not success then
            warn("DripUI: Critical error creating config folder: " .. tostring(err))
        end
    end
end

-- ฟังก์ชันบันทึกข้อมูลลง JSON
local function SaveData(data, idmap)
    EnsureConfigFolder()
    local fileName = ConfigFolder .. "/" .. tostring(idmap) .. "_Config.json"
    local success, err = pcall(function()
        local json = HttpService:JSONEncode(data)
        writefile(fileName, json)
    end)
    if not success then
        warn("DripUI: Failed to save config: " .. tostring(err))
    end
end

-- ฟังก์ชันโหลดข้อมูลจาก JSON
local function LoadData(idmap)
    EnsureConfigFolder()
    local fileName = ConfigFolder .. "/" .. tostring(idmap) .. "_Config.json"
    if isfile(fileName) then
        local content = readfile(fileName)
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

-- // CORE UTILITIES //
local function getSafeParent()
    local parent = CoreGui
    local ok, gethui = pcall(function() return gethui end)
    if ok and type(gethui) == "function" then
        local gui = gethui()
        if typeof(gui) == "Instance" then 
            parent = gui 
        end
    end
    return parent
end

local function protectGui(gui)
    pcall(function() 
        if syn and syn.protect_gui then 
            syn.protect_gui(gui) 
        end 
    end)
    pcall(function() 
        if get_hidden_gui then 
            get_hidden_gui(gui) 
        end 
    end)
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
    local tweenInfo = TweenInfo.new(
        tweenTime, 
        Enum.EasingStyle.Quad, 
        Enum.EasingDirection.Out
    )
    local success, t = pcall(function()
        return TweenService:Create(obj, tweenInfo, props)
    end)
    if success and t then
        t:Play()
        return t
    end
    return nil
end

-- // THEME SETTINGS (Compact) //
local Theme = {
    Background = Color3.fromRGB(10, 10, 10),
    Container = Color3.fromRGB(26, 26, 26),
    Accent = Color3.fromRGB(255, 0, 255),
    TextMain = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(119, 119, 119),
    ElementBG = Color3.fromRGB(17, 17, 17),
    Stroke = Color3.fromRGB(37, 37, 37),
    HeaderHeight = 32, -- ลดลงจาก 40
    WindowWidth = 280, -- ลดลงจาก 320
    WindowHeight = 280 -- ลดลงจาก 350
}

-- // DRAGGABLE IMPLEMENTATION //
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

-- // WINDOW CLASS //
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
    
    -- Main GUI Structure
    local ScreenGui = create("ScreenGui", {
        Parent = getSafeParent(),
        Name = config.Name or "DripUI_Mobile_" .. HttpService:GenerateGUID(false),
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false
    })
    protectGui(ScreenGui)
    
    local MainFrame = create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0, Theme.WindowWidth, 0, Theme.WindowHeight),
        Position = UDim2.new(0.5, -Theme.WindowWidth/2, 0.5, -Theme.WindowHeight/2),
        BackgroundColor3 = Theme.Container,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true
    })
    create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 4) })
    create("UIStroke", { Parent = MainFrame, Color = Theme.Stroke, Thickness = 1 })
    
    local Header = create("TextButton", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, Theme.HeaderHeight),
        BackgroundColor3 = Theme.Container,
        Text = config.Title or "DRIP CLIENT | MOBILE",
        TextColor3 = Theme.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 12, -- ลดลงนิดหน่อย
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 5
    })
    create("UICorner", { Parent = Header, CornerRadius = UDim.new(0, 4) })
    
    local PinkLine = create("Frame", {
        Parent = Header,
        Size = UDim2.new(1, 0, 0, 2), -- เล็กลง
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 6
    })

    MakeDraggable(Header, MainFrame)

    local TabContainer = create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, 26),
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
    
    local PagesContainer = create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, -16, 1, -(Theme.HeaderHeight + 32)),
        Position = UDim2.new(0, 8, 0, Theme.HeaderHeight + 32),
        BackgroundTransparency = 1,
        ZIndex = 2
    })
    
    Header.MouseButton1Click:Connect(function()
        self.IsCollapsed = not self.IsCollapsed
        if self.IsCollapsed then
            tween(MainFrame, 0.4, { Size = UDim2.new(0, Theme.WindowWidth, 0, Theme.HeaderHeight) })
            TabContainer.Visible = false
            PagesContainer.Visible = false
        else
            tween(MainFrame, 0.4, { Size = UDim2.new(0, Theme.WindowWidth, 0, Theme.WindowHeight) })
            task.delay(0.2, function()
                TabContainer.Visible = true
                PagesContainer.Visible = true
            end)
        end
    end)
    
    function self:SelectTab(name)
        for _, tabData in pairs(self.Tabs) do
            if tabData.Name == name then
                -- แก้ไขจุดที่ทำให้เกิด Error: ใช้ _TabButton แทน Button
                if tabData._TabButton then
                    tabData._TabButton.TextColor3 = Theme.TextMain
                end
                tabData.Page.Visible = true
                self.SelectedTab = name
            else
                if tabData._TabButton then
                    tabData._TabButton.TextColor3 = Theme.TextDim
                end
                tabData.Page.Visible = false
            end
        end
    end
    
    -- // TAB CREATOR //
    function self:Tab(name)
        local tab = { 
            Name = name, 
            Elements = {} 
        }
        
        -- เปลี่ยนชื่อ Property เป็น _TabButton เพื่อไม่ให้ชนกับฟังก์ชัน Button()
        local TabBtnInstance = create("TextButton", {
            Parent = TabContainer,
            Size = UDim2.new(0, 60, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextColor3 = Theme.TextDim,
            BorderSizePixel = 0,
            ZIndex = 5
        })
        
        local PageInstance = create("ScrollingFrame", {
            Parent = PagesContainer,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 1, -- บางลง
            Visible = false,
            ScrollBarImageColor3 = Theme.Accent,
            ZIndex = 3,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        
        local PageLayoutInstance = create("UIListLayout", {
            Parent = PageInstance,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4)
        })
        
        PageLayoutInstance:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            PageInstance.CanvasSize = UDim2.new(0, 0, 0, PageLayoutInstance.AbsoluteContentSize.Y + 10)
        end)
        
        TabBtnInstance.MouseButton1Click:Connect(function()
            self:SelectTab(name)
        end)
        
        tab._TabButton = TabBtnInstance
        tab.Page = PageInstance
        self.Tabs[name] = tab
        
        if not self.SelectedTab then
            self:SelectTab(name)
        end
        
        -- // ELEMENT: TOGGLE //
        function tab:Toggle(cfg)
            local toggleState = { Value = SavedData[cfg.Title] or cfg.Default or false }
            
            local ToggleHolder = create("TextButton", {
                Parent = PageInstance,
                Size = UDim2.new(1, 0, 0, 26), -- เล็กลง
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 10
            })
            
            local Layout = create("UIListLayout", {
                Parent = ToggleHolder,
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 10)
            })
            
            local CheckBox = create("Frame", {
                Parent = ToggleHolder,
                Size = UDim2.new(0, 14, 0, 14),
                BackgroundColor3 = toggleState.Value and Theme.Accent or Theme.ElementBG,
                ZIndex = 11
            })
            create("UICorner", { Parent = CheckBox, CornerRadius = UDim.new(1, 0) })
            
            local CheckStroke = create("UIStroke", {
                Parent = CheckBox,
                Color = toggleState.Value and Theme.Accent or Color3.fromRGB(51, 51, 51),
                Thickness = 1
            })
            
            local Label = create("TextLabel", {
                Parent = ToggleHolder,
                Text = cfg.Title or "Toggle",
                Font = Enum.Font.GothamMedium,
                TextSize = 11,
                TextColor3 = Color3.fromRGB(221, 221, 221),
                Size = UDim2.new(0, 180, 1, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 11
            })
            
            local function UpdateToggle(val)
                toggleState.Value = val
                tween(CheckBox, 0.2, { BackgroundColor3 = val and Theme.Accent or Theme.ElementBG })
                tween(CheckStroke, 0.2, { Color = val and Theme.Accent or Color3.fromRGB(51, 51, 51) })
                
                SavedData[cfg.Title] = val
                SaveConfigData()
                
                if cfg.Callback then
                    task.spawn(function()
                        local success, err = pcall(cfg.Callback, val)
                        if not success then warn("Toggle Callback Error: " .. tostring(err)) end
                    end)
                end
            end
            
            ToggleHolder.MouseButton1Click:Connect(function()
                UpdateToggle(not toggleState.Value)
            end)
            
            if toggleState.Value then
                task.spawn(function() pcall(cfg.Callback, true) end)
            end
            
            return {
                Set = function(_, v) UpdateToggle(v) end,
                Get = function() return toggleState.Value end
            }
        end
        
        -- // ELEMENT: DROPDOWN //
        function tab:Dropdown(cfg)
            local dropOptions = cfg.Options or {}
            local currentVal = SavedData[cfg.Title] or cfg.Default or dropOptions[1] or "Select"
            local menuOpen = false
            
            local DropFrame = create("Frame", {
                Parent = PageInstance,
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundTransparency = 1,
                ZIndex = 15
            })
            
            create("Frame", {
                Parent = DropFrame,
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Stroke,
                BorderSizePixel = 0
            })
            
            local DropLabel = create("TextLabel", {
                Parent = DropFrame,
                Text = cfg.Title or "Dropdown",
                Font = Enum.Font.GothamMedium,
                TextSize = 11,
                TextColor3 = Color3.fromRGB(221, 221, 221),
                Size = UDim2.new(0, 70, 0, 26),
                Position = UDim2.new(0, 0, 0, 8),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 16
            })
            
            local DropBoxBtn = create("TextButton", {
                Parent = DropFrame,
                Size = UDim2.new(1, -75, 0, 24),
                Position = UDim2.new(0, 75, 0, 8),
                BackgroundColor3 = Theme.ElementBG,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 17
            })
            create("UICorner", { Parent = DropBoxBtn, CornerRadius = UDim.new(0, 3) })
            create("UIStroke", { Parent = DropBoxBtn, Color = Color3.fromRGB(51, 51, 51) })
            
            local MainText = create("TextLabel", {
                Parent = DropBoxBtn,
                Text = currentVal,
                Font = Enum.Font.Gotham,
                TextSize = 10,
                TextColor3 = Color3.fromRGB(221, 221, 221),
                Size = UDim2.new(1, -24, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 18
            })
            
            local IconArrow = create("ImageLabel", {
                Parent = DropBoxBtn,
                Image = "rbxassetid://6034818372",
                Size = UDim2.new(0, 10, 0, 10),
                Position = UDim2.new(1, -18, 0.5, -5),
                BackgroundTransparency = 1,
                ImageColor3 = Theme.Accent,
                ZIndex = 18
            })
            
            local OptionsContainer = create("Frame", {
                Parent = DropBoxBtn,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 1, 2),
                BackgroundColor3 = Color3.fromRGB(21, 21, 21),
                BorderSizePixel = 0,
                ClipsDescendants = true,
                ZIndex = 50
            })
            create("UICorner", { Parent = OptionsContainer, CornerRadius = UDim.new(0, 3) })
            create("UIStroke", { Parent = OptionsContainer, Color = Theme.Stroke })
            
            local OptLayout = create("UIListLayout", {
                Parent = OptionsContainer,
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            
            local function ToggleDropdownMenu()
                menuOpen = not menuOpen
                local newHeight = menuOpen and (#dropOptions * 24) or 0
                tween(OptionsContainer, 0.3, { Size = UDim2.new(1, 0, 0, newHeight) })
                tween(IconArrow, 0.3, { Rotation = menuOpen and 180 or 0 })
            end
            
            DropBoxBtn.MouseButton1Click:Connect(ToggleDropdownMenu)
            
            for _, item in ipairs(dropOptions) do
                local ItemBtn = create("TextButton", {
                    Parent = OptionsContainer,
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Text = item,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextColor3 = Color3.fromRGB(153, 153, 153),
                    ZIndex = 51
                })
                
                ItemBtn.MouseButton1Click:Connect(function()
                    currentVal = item
                    MainText.Text = item
                    ToggleDropdownMenu()
                    SavedData[cfg.Title] = item
                    SaveConfigData()
                    if cfg.Callback then pcall(cfg.Callback, item) end
                end)
                
                ItemBtn.MouseEnter:Connect(function() 
                    tween(ItemBtn, 0.1, { BackgroundTransparency = 0.9, BackgroundColor3 = Color3.new(1,1,1) }) 
                end)
                ItemBtn.MouseLeave:Connect(function() 
                    tween(ItemBtn, 0.1, { BackgroundTransparency = 1 }) 
                end)
            end

            if currentVal ~= cfg.Default then
                task.spawn(function() pcall(cfg.Callback, currentVal) end)
            end
            
            return {
                Set = function(_, v) MainText.Text = v currentVal = v end,
                Get = function() return currentVal end
            }
        end
        
        -- // ELEMENT: SLIDER //
        function tab:Slider(cfg)
            local sMin = cfg.Min or 0
            local sMax = cfg.Max or 100
            local sCurrent = SavedData[cfg.Title] or cfg.Default or sMin
            
            local SliderBox = create("Frame", {
                Parent = PageInstance,
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundTransparency = 1,
                ZIndex = 10
            })
            
            local SLabel = create("TextLabel", {
                Parent = SliderBox,
                Text = cfg.Title or "Slider",
                Size = UDim2.new(1, -40, 0, 18),
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(221, 221, 221),
                Font = Enum.Font.GothamMedium,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 11
            })
            
            local SValue = create("TextLabel", {
                Parent = SliderBox,
                Text = tostring(sCurrent),
                Size = UDim2.new(0, 30, 0, 18),
                Position = UDim2.new(1, -30, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = Theme.Accent,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 11
            })
            
            local STrack = create("Frame", {
                Parent = SliderBox,
                Size = UDim2.new(1, 0, 0, 4),
                Position = UDim2.new(0, 0, 0, 24),
                BackgroundColor3 = Theme.ElementBG,
                BorderSizePixel = 0,
                ZIndex = 11
            })
            create("UICorner", { Parent = STrack, CornerRadius = UDim.new(1, 0) })
            
            local SFill = create("Frame", {
                Parent = STrack,
                Size = UDim2.new((sCurrent - sMin)/(sMax - sMin), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                ZIndex = 12
            })
            create("UICorner", { Parent = SFill, CornerRadius = UDim.new(1, 0) })
            
            local SKnob = create("Frame", {
                Parent = STrack,
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new((sCurrent - sMin)/(sMax - sMin), -6, 0.5, -6),
                BackgroundColor3 = Theme.TextMain,
                ZIndex = 13
            })
            create("UICorner", { Parent = SKnob, CornerRadius = UDim.new(1, 0) })
            
            local isDraggingSlider = false
            
            local function UpdateSliderUI(input)
                local percent = math.clamp((input.Position.X - STrack.AbsolutePosition.X) / STrack.AbsoluteSize.X, 0, 1)
                local newValue = math.floor(sMin + (sMax - sMin) * percent)
                
                sCurrent = newValue
                SValue.Text = tostring(newValue)
                SFill.Size = UDim2.new(percent, 0, 1, 0)
                SKnob.Position = UDim2.new(percent, -6, 0.5, -6)
                
                SavedData[cfg.Title] = sCurrent
                SaveConfigData()
                if cfg.Callback then pcall(cfg.Callback, sCurrent) end
            end
            
            SKnob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDraggingSlider = true
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDraggingSlider = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if isDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSliderUI(input)
                end
            end)
            
            STrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    UpdateSliderUI(input)
                end
            end)

            if sCurrent ~= cfg.Default then
                task.spawn(function() pcall(cfg.Callback, sCurrent) end)
            end
            
            return {
                Set = function(_, v)
                    local p = math.clamp((v - sMin)/(sMax - sMin), 0, 1)
                    SFill.Size = UDim2.new(p, 0, 1, 0)
                    SKnob.Position = UDim2.new(p, -6, 0.5, -6)
                    SValue.Text = tostring(v)
                    sCurrent = v
                end,
                Get = function() return sCurrent end
            }
        end
        
        -- // ELEMENT: BUTTON //
        function tab:Button(cfg)
            local ActionBtn = create("TextButton", {
                Parent = PageInstance,
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = Theme.ElementBG,
                Text = cfg.Title or "Button",
                TextColor3 = Theme.TextMain,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                AutoButtonColor = true,
                ZIndex = 10
            })
            create("UICorner", { Parent = ActionBtn, CornerRadius = UDim.new(0, 4) })
            create("UIStroke", { Parent = ActionBtn, Color = Theme.Stroke, Thickness = 1 })
            
            ActionBtn.MouseButton1Click:Connect(function()
                if cfg.Callback then pcall(cfg.Callback) end
                local oldColor = ActionBtn.BackgroundColor3
                tween(ActionBtn, 0.1, { BackgroundColor3 = Theme.Accent })
                task.delay(0.1, function() tween(ActionBtn, 0.2, { BackgroundColor3 = oldColor }) end)
            end)
            
            return {
                SetTitle = function(_, t) ActionBtn.Text = t end
            }
        end
        
        -- // ELEMENT: LABEL //
        function tab:Label(cfg)
            local TextLabelObj = create("TextLabel", {
                Parent = PageInstance,
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = cfg.Text or "Label",
                TextColor3 = Theme.TextDim,
                Font = Enum.Font.Gotham,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 10
            })
            
            return {
                SetText = function(_, t) TextLabelObj.Text = t end
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
        MainFrame.Visible = not MainFrame.Visible
    end
    
    function self:Destroy()
        ScreenGui:Destroy()
    end
    
    return self
end

return DripUI
