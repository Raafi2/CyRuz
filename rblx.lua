-- ============================================================
--  CyRuZzz Universal & Fruit BG Hub (Full Final Clean Edition)
--  Feature Set: Movement, Mods, Teleport & FBG Precise ESP
-- ============================================================

local Players              = game:GetService("Players")
local RunService           = game:GetService("RunService")
local UserInputService     = game:GetService("UserInputService")
local TeleportService      = game:GetService("TeleportService")
local HttpService          = game:GetService("HttpService")
local VirtualUser          = game:GetService("VirtualUser")
local ReplicatedStorage    = game:GetService("ReplicatedStorage")

local LP                   = Players.LocalPlayer
local Camera               = workspace.CurrentCamera
local PlayerGui            = LP:WaitForChild("PlayerGui")

-- Global States
local universalEspEnabled  = false
local fbgEspEnabled        = false
local npcEspEnabled        = false
local autoAimEnabled       = false
local antiAfkEnabled       = true

local flyEnabled           = false
local noclipEnabled        = false
local speedEnabled         = false
local antiStunEnabled      = false
local infDashEnabled       = false
local infJumpEnabled       = false

local flySpeed             = 60
local walkSpeedVal         = 100
local tp1Pos               = nil
local tp2Pos               = nil
local selectedPlayer       = nil
local selectedArea         = nil

local customAreas          = {}
local espObjects           = {}
local npcEspObjects        = {}
local connections          = {}

local flyConn, noclipConn, speedConn
local ReplicatorNoYield    = ReplicatedStorage:FindFirstChild("ReplicatorNoYield")

-- Cleanup Old UI
if PlayerGui:FindFirstChild("CyRuZzz_UniversalHub") then
    PlayerGui.CyRuZzz_UniversalHub:Destroy()
end

-- ============================================================
--  GUI BASE SETUP
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name           = "CyRuZzz_UniversalHub"
SG.ResetOnSpawn   = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder   = 9999
SG.Parent         = PlayerGui

-- Mini Logo Melayang
local MiniWidget = Instance.new("Frame")
MiniWidget.Name                   = "MiniWidget"
MiniWidget.Size                   = UDim2.new(0, 48, 0, 48)
MiniWidget.Position               = UDim2.new(0, 20, 0.5, -24)
MiniWidget.BackgroundColor3       = Color3.fromRGB(20, 24, 38)
MiniWidget.BorderSizePixel        = 0; MiniWidget.Active = true; MiniWidget.Draggable = true; MiniWidget.Visible = false; MiniWidget.Parent = SG
Instance.new("UICorner", MiniWidget).CornerRadius = UDim.new(1, 0)
local miniStroke = Instance.new("UIStroke"); miniStroke.Color = Color3.fromRGB(0, 170, 255); miniStroke.Thickness = 2; miniStroke.Parent = MiniWidget

local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(1,0,1,0); MiniBtn.BackgroundTransparency = 1; MiniBtn.Text = "C"
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255); MiniBtn.Font = Enum.Font.GothamBold; MiniBtn.TextSize = 22; MiniBtn.Parent = MiniWidget

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name                   = "MainFrame"
MainFrame.Size                   = UDim2.new(0, 620, 0, 440)
MainFrame.Position               = UDim2.new(0.5, -310, 0.5, -220)
MainFrame.BackgroundColor3       = Color3.fromRGB(15, 17, 26)
MainFrame.BorderSizePixel        = 0; MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Parent = SG
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke"); mainStroke.Color = Color3.fromRGB(45, 55, 85); mainStroke.Thickness = 1; mainStroke.Parent = MainFrame

-- Header
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38); TopBar.BackgroundColor3 = Color3.fromRGB(22, 26, 40); TopBar.BorderSizePixel = 0; TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local BrandTitle = Instance.new("TextLabel")
BrandTitle.Size = UDim2.new(0, 200, 1, 0); BrandTitle.Position = UDim2.new(0, 14, 0, 0); BrandTitle.BackgroundTransparency = 1
BrandTitle.Text = "CYRUZZZ HUB"; BrandTitle.TextColor3 = Color3.fromRGB(0, 170, 255); BrandTitle.Font = Enum.Font.GothamBold; BrandTitle.TextSize = 13; BrandTitle.TextXAlignment = Enum.TextXAlignment.Left; BrandTitle.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 26, 0, 26); MinimizeBtn.Position = UDim2.new(1, -62, 0.5, -13); MinimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 42, 65); MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "-"; MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); MinimizeBtn.Font = Enum.Font.GothamBold; MinimizeBtn.TextSize = 14; MinimizeBtn.Parent = TopBar
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26); CloseBtn.Position = UDim2.new(1, -32, 0.5, -13); CloseBtn.BackgroundColor3 = Color3.fromRGB(210, 45, 65); CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "x"; CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 14; CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; MiniWidget.Visible = true end)
MiniBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; MiniWidget.Visible = false end)

-- Sidebar Navigation
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -38); Sidebar.Position = UDim2.new(0, 0, 0, 38); Sidebar.BackgroundColor3 = Color3.fromRGB(18, 21, 32); Sidebar.BorderSizePixel = 0; Sidebar.Parent = MainFrame
local SideLayout = Instance.new("UIListLayout"); SideLayout.SortOrder = Enum.SortOrder.LayoutOrder; SideLayout.Padding = UDim.new(0, 4); SideLayout.Parent = Sidebar
local SidePadding = Instance.new("UIPadding"); SidePadding.PaddingTop = UDim.new(0, 8); SidePadding.PaddingLeft = UDim.new(0, 8); SidePadding.Parent = Sidebar

local ContentFolder = Instance.new("Frame")
ContentFolder.Size = UDim2.new(1, -140, 1, -38); ContentFolder.Position = UDim2.new(0, 140, 0, 38); ContentFolder.BackgroundTransparency = 1; ContentFolder.Parent = MainFrame

local tabs = {}
local function createTab(name)
    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Size = UDim2.new(1, -16, 1, -16); TabPage.Position = UDim2.new(0, 8, 0, 8); TabPage.BackgroundTransparency = 1; TabPage.BorderSizePixel = 0; TabPage.Visible = false; TabPage.ScrollBarThickness = 3; TabPage.CanvasSize = UDim2.new(0, 0, 0, 0); TabPage.Parent = ContentFolder
    local PageLayout = Instance.new("UIListLayout"); PageLayout.SortOrder = Enum.SortOrder.LayoutOrder; PageLayout.Padding = UDim.new(0, 8); PageLayout.Parent = TabPage

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 124, 0, 32); TabBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 42); TabBtn.BorderSizePixel = 0; TabBtn.Text = name; TabBtn.TextColor3 = Color3.fromRGB(160, 175, 210); TabBtn.Font = Enum.Font.GothamSemibold; TabBtn.TextSize = 10; TabBtn.TextXAlignment = Enum.TextXAlignment.Left; TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, 10); p.Parent = TabBtn

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do t.Page.Visible = false; t.Btn.BackgroundColor3 = Color3.fromRGB(24, 28, 42); t.Btn.TextColor3 = Color3.fromRGB(160, 175, 210) end
        TabPage.Visible = true; TabBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255); TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    tabs[name] = { Page = TabPage, Btn = TabBtn, Layout = PageLayout }
    return TabPage, PageLayout
end

local MainTab, MainLayout     = createTab("Universal")
local FbgTab, FbgLayout       = createTab("Fruit BG")
local ServerTab, ServerLayout = createTab("Server")

tabs["Universal"].Page.Visible = true; tabs["Universal"].Btn.BackgroundColor3 = Color3.fromRGB(0, 140, 255); tabs["Universal"].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- UI Helper Functions
local function addSectionHeader(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 20); lbl.BackgroundTransparency = 1; lbl.Text = "- " .. string.upper(text) .. " -"; lbl.TextColor3 = Color3.fromRGB(100, 120, 170); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 9; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = parent
end

local toggleSetters = {}

local function addToggle(parent, title, desc, defaultState, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -10, 0, 42); card.BackgroundColor3 = Color3.fromRGB(22, 26, 40); card.BorderSizePixel = 0; card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(0.65, 0, 0, 18); tLbl.Position = UDim2.new(0, 10, 0, 4); tLbl.BackgroundTransparency = 1; tLbl.Text = title; tLbl.TextColor3 = Color3.fromRGB(240, 245, 255); tLbl.Font = Enum.Font.GothamSemibold; tLbl.TextSize = 11; tLbl.TextXAlignment = Enum.TextXAlignment.Left; tLbl.Parent = card

    local dLbl = Instance.new("TextLabel")
    dLbl.Size = UDim2.new(0.65, 0, 0, 14); dLbl.Position = UDim2.new(0, 10, 0, 22); dLbl.BackgroundTransparency = 1; dLbl.Text = desc; dLbl.TextColor3 = Color3.fromRGB(110, 125, 160); dLbl.Font = Enum.Font.Gotham; dLbl.TextSize = 9; dLbl.TextXAlignment = Enum.TextXAlignment.Left; dLbl.Parent = card

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 48, 0, 22); btn.Position = UDim2.new(1, -58, 0.5, -11); btn.BackgroundColor3 = defaultState and Color3.fromRGB(45, 180, 90) or Color3.fromRGB(45, 50, 75); btn.BorderSizePixel = 0; btn.Text = defaultState and "ON" or "OFF"; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.GothamBold; btn.TextSize = 9; btn.Parent = card
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local currentState = defaultState

    local function updateVisual(newState)
        currentState = newState
        btn.Text = currentState and "ON" or "OFF"
        btn.BackgroundColor3 = currentState and Color3.fromRGB(45, 180, 90) or Color3.fromRGB(45, 50, 75)
    end

    btn.MouseButton1Click:Connect(function()
        currentState = not currentState
        updateVisual(currentState)
        callback(currentState)
    end)

    toggleSetters[title] = function(forcedState)
        local targetState = forcedState ~= nil and forcedState or (not currentState)
        updateVisual(targetState)
        callback(targetState)
    end

    return card, btn
end

local function addButton(parent, title, btnText, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -10, 0, 40); card.BackgroundColor3 = Color3.fromRGB(22, 26, 40); card.BorderSizePixel = 0; card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(0.6, 0, 1, 0); tLbl.Position = UDim2.new(0, 10, 0, 0); tLbl.BackgroundTransparency = 1; tLbl.Text = title; tLbl.TextColor3 = Color3.fromRGB(240, 245, 255); tLbl.Font = Enum.Font.GothamSemibold; tLbl.TextSize = 11; tLbl.TextXAlignment = Enum.TextXAlignment.Left; tLbl.Parent = card

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 0, 24); btn.Position = UDim2.new(1, -100, 0.5, -12); btn.BackgroundColor3 = Color3.fromRGB(0, 140, 255); btn.BorderSizePixel = 0; btn.Text = btnText; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.GothamBold; btn.TextSize = 9; btn.Parent = card
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(callback)
    return card
end

local function addSliderRow(parent, title, val, minV, maxV, onUpdate)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -10, 0, 42); card.BackgroundColor3 = Color3.fromRGB(22, 26, 40); card.BorderSizePixel = 0; card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(0.4, 0, 0, 18); tLbl.Position = UDim2.new(0, 10, 0, 4); tLbl.BackgroundTransparency = 1; tLbl.Text = title; tLbl.TextColor3 = Color3.fromRGB(240, 245, 255); tLbl.Font = Enum.Font.GothamSemibold; tLbl.TextSize = 11; tLbl.TextXAlignment = Enum.TextXAlignment.Left; tLbl.Parent = card

    local vLbl = Instance.new("TextLabel")
    vLbl.Size = UDim2.new(0.2, 0, 0, 18); vLbl.Position = UDim2.new(0.4, 0, 0, 4); vLbl.BackgroundTransparency = 1; vLbl.Text = tostring(val); vLbl.TextColor3 = Color3.fromRGB(0, 170, 255); vLbl.Font = Enum.Font.GothamBold; vLbl.TextSize = 11; vLbl.TextXAlignment = Enum.TextXAlignment.Center; vLbl.Parent = card

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -20, 0, 4); barBg.Position = UDim2.new(0, 10, 1, -8); barBg.BackgroundColor3 = Color3.fromRGB(38, 45, 70); barBg.BorderSizePixel = 0; barBg.Parent = card
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new((val-minV)/(maxV-minV), 0, 1, 0); barFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255); barFill.BorderSizePixel = 0; barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

    local function makeBtn(txt, posX, delta)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 26, 0, 20); b.Position = UDim2.new(1, posX, 0, 4); b.BackgroundColor3 = Color3.fromRGB(38, 45, 70); b.BorderSizePixel = 0; b.Text = txt; b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Font = Enum.Font.GothamBold; b.TextSize = 12; b.Parent = card
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        b.MouseButton1Click:Connect(function()
            val = math.clamp(val + delta, minV, maxV); vLbl.Text = tostring(val)
            barFill.Size = UDim2.new((val-minV)/(maxV-minV), 0, 1, 0)
            onUpdate(val)
        end)
    end
    makeBtn("-", -58, -5)
    makeBtn("+", -28, 5)
end

-- ============================================================
--  1. UNIVERSAL TAB
-- ============================================================
addSectionHeader(MainTab, "Universal Visuals")
local EspCard = addToggle(MainTab, "Universal ESP", "Nama & Body Highlight Player", false, function(v) universalEspEnabled = v end)
local ReloadBtn = Instance.new("TextButton")
ReloadBtn.Size = UDim2.new(0, 55, 0, 22); ReloadBtn.Position = UDim2.new(1, -120, 0.5, -11)
ReloadBtn.BackgroundColor3 = Color3.fromRGB(38, 48, 75); ReloadBtn.BorderSizePixel = 0; ReloadBtn.Text = "RELOAD"; ReloadBtn.TextColor3 = Color3.fromRGB(200, 215, 255); ReloadBtn.Font = Enum.Font.GothamBold; ReloadBtn.TextSize = 8; ReloadBtn.Parent = EspCard
Instance.new("UICorner", ReloadBtn).CornerRadius = UDim.new(0, 5)

addSectionHeader(MainTab, "Player Mods")
addToggle(MainTab, "Infinite Dash", "Menghapus delay/cooldown dash", false, function(v) infDashEnabled = v end)
addToggle(MainTab, "Infinite Jump", "Lompat tanpa batas di udara", false, function(v) infJumpEnabled = v end)

addSectionHeader(MainTab, "Universal Movement")
local function enableFly()
    local c = LP.Character; if not c then return end
    local hrp, hum = c:FindFirstChild("HumanoidRootPart"), c:FindFirstChildOfClass("Humanoid")
    if hrp and hum then
        hum.PlatformStand = true
        local bv = Instance.new("BodyVelocity", hrp); bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(1e5,1e5,1e5); bv.Name = "_CyBV"
        local bg = Instance.new("BodyGyro", hrp); bg.MaxTorque = Vector3.new(1e5,1e5,1e5); bg.D = 100; bg.P = 1e4; bg.CFrame = hrp.CFrame; bg.Name = "_CyBG"

        flyConn = RunService.RenderStepped:Connect(function()
            if not flyEnabled then return end
            local h2 = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not h2 then return end
            local bv2, bg2 = h2:FindFirstChild("_CyBV"), h2:FindFirstChild("_CyBG")
            if not bv2 or not bg2 then return end
            local cf = Camera.CFrame; local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
            bv2.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
            bg2.CFrame = CFrame.lookAt(h2.Position, h2.Position + cf.LookVector)
        end)
    end
end

local function disableFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    local c = LP.Character
    if c then
        local hum, hrp = c:FindFirstChildOfClass("Humanoid"), c:FindFirstChild("HumanoidRootPart")
        if hum then hum.PlatformStand = false end
        if hrp then if hrp:FindFirstChild("_CyBV") then hrp._CyBV:Destroy() end if hrp:FindFirstChild("_CyBG") then hrp._CyBG:Destroy() end end
    end
end

addToggle(MainTab, "Fly Mode [T]", "Terbang bebas di udara", false, function(v) flyEnabled = v; if flyEnabled then enableFly() else disableFly() end end)
addToggle(MainTab, "Noclip Mode [C]", "Menembus semua tembok", false, function(v)
    noclipEnabled = v
    if noclipEnabled then
        noclipConn = RunService.Stepped:Connect(function()
            if LP.Character then for _, p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
        end)
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    end
end)
addToggle(MainTab, "Walk Speed [Q]", "Sesuai speed slider", false, function(v)
    speedEnabled = v
    if speedEnabled then
        speedConn = RunService.RenderStepped:Connect(function()
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = walkSpeedVal end
        end)
    else
        if speedConn then speedConn:Disconnect(); speedConn = nil end
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end)

addSliderRow(MainTab, "Fly Speed", flySpeed, 10, 300, function(v) flySpeed = v end)
addSliderRow(MainTab, "Walk Speed", walkSpeedVal, 16, 300, function(v) walkSpeedVal = v end)

addSectionHeader(MainTab, "Teleport Position")

local function addTpCard(parent, title, slot)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -10, 0, 42); card.BackgroundColor3 = Color3.fromRGB(22, 26, 40); card.BorderSizePixel = 0; card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(0.4, 0, 0, 18); tLbl.Position = UDim2.new(0, 10, 0, 4); tLbl.BackgroundTransparency = 1; tLbl.Text = title; tLbl.TextColor3 = Color3.fromRGB(240, 245, 255); tLbl.Font = Enum.Font.GothamSemibold; tLbl.TextSize = 11; tLbl.TextXAlignment = Enum.TextXAlignment.Left; tLbl.Parent = card

    local cLbl = Instance.new("TextLabel")
    cLbl.Size = UDim2.new(0.5, 0, 0, 14); cLbl.Position = UDim2.new(0, 10, 0, 22); cLbl.BackgroundTransparency = 1; cLbl.Text = "Not Set"; cLbl.TextColor3 = Color3.fromRGB(110, 125, 160); cLbl.Font = Enum.Font.Gotham; cLbl.TextSize = 9; cLbl.TextXAlignment = Enum.TextXAlignment.Left; cLbl.Parent = card

    local setBtn = Instance.new("TextButton")
    setBtn.Size = UDim2.new(0, 42, 0, 24); setBtn.Position = UDim2.new(1, -94, 0.5, -12); setBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255); setBtn.BorderSizePixel = 0; setBtn.Text = "SET"; setBtn.TextColor3 = Color3.fromRGB(255, 255, 255); setBtn.Font = Enum.Font.GothamBold; setBtn.TextSize = 9; setBtn.Parent = card
    Instance.new("UICorner", setBtn).CornerRadius = UDim.new(0, 5)

    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0, 42, 0, 24); tpBtn.Position = UDim2.new(1, -48, 0.5, -12); tpBtn.BackgroundColor3 = Color3.fromRGB(45, 180, 90); tpBtn.BorderSizePixel = 0; tpBtn.Text = "TP"; tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255); tpBtn.Font = Enum.Font.GothamBold; tpBtn.TextSize = 9; tpBtn.Parent = card
    Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 5)

    setBtn.MouseButton1Click:Connect(function()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local cf = hrp.CFrame
            if slot == 1 then tp1Pos = cf else tp2Pos = cf end
            cLbl.Text = string.format("%.0f, %.0f, %.0f", cf.X, cf.Y, cf.Z); cLbl.TextColor3 = Color3.fromRGB(0, 255, 150)
        end
    end)

    tpBtn.MouseButton1Click:Connect(function()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local pos = slot == 1 and tp1Pos or tp2Pos
        if hrp and pos then hrp.CFrame = pos end
    end)
end

addTpCard(MainTab, "Teleport Slot 1 [H]", 1)
addTpCard(MainTab, "Teleport Slot 2 [J]", 2)

-- Player Teleport Dropdown
local PlrTpCard = Instance.new("Frame")
PlrTpCard.Size = UDim2.new(1, -10, 0, 42); PlrTpCard.BackgroundColor3 = Color3.fromRGB(22, 26, 40); PlrTpCard.BorderSizePixel = 0; PlrTpCard.Parent = MainTab
Instance.new("UICorner", PlrTpCard).CornerRadius = UDim.new(0, 6)

local SelectPlrBtn = Instance.new("TextButton")
SelectPlrBtn.Size = UDim2.new(0.6, 0, 0, 26); SelectPlrBtn.Position = UDim2.new(0, 10, 0.5, -13); SelectPlrBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 28); SelectPlrBtn.BorderSizePixel = 0; SelectPlrBtn.Text = "Pilih Player..."; SelectPlrBtn.TextColor3 = Color3.fromRGB(200, 210, 255); SelectPlrBtn.Font = Enum.Font.GothamSemibold; SelectPlrBtn.TextSize = 10; SelectPlrBtn.Parent = PlrTpCard
Instance.new("UICorner", SelectPlrBtn).CornerRadius = UDim.new(0, 5)

local GotoPlrBtn = Instance.new("TextButton")
GotoPlrBtn.Size = UDim2.new(0, 75, 0, 26); GotoPlrBtn.Position = UDim2.new(1, -85, 0.5, -13); GotoPlrBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255); GotoPlrBtn.BorderSizePixel = 0; GotoPlrBtn.Text = "GOTO"; GotoPlrBtn.TextColor3 = Color3.fromRGB(255, 255, 255); GotoPlrBtn.Font = Enum.Font.GothamBold; GotoPlrBtn.TextSize = 10; GotoPlrBtn.Parent = PlrTpCard
Instance.new("UICorner", GotoPlrBtn).CornerRadius = UDim.new(0, 5)

local DropFrame = Instance.new("ScrollingFrame")
DropFrame.Size = UDim2.new(1, -10, 0, 100); DropFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 38); DropFrame.BorderSizePixel = 0; DropFrame.Visible = false; DropFrame.ZIndex = 20; DropFrame.ScrollBarThickness = 3; DropFrame.Parent = MainTab
Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 6)
local DropLayout = Instance.new("UIListLayout"); DropLayout.Parent = DropFrame

local function updatePlayerList()
    for _, child in ipairs(DropFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            count = count + 1
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, 0, 0, 24); pBtn.BackgroundColor3 = Color3.fromRGB(28, 32, 50); pBtn.BorderSizePixel = 0; pBtn.Text = plr.Name; pBtn.TextColor3 = Color3.fromRGB(200, 210, 255); pBtn.Font = Enum.Font.Gotham; pBtn.TextSize = 10; pBtn.ZIndex = 21; pBtn.Parent = DropFrame
            pBtn.MouseButton1Click:Connect(function() selectedPlayer = plr; SelectPlrBtn.Text = plr.Name; DropFrame.Visible = false end)
        end
    end
    DropFrame.CanvasSize = UDim2.new(0, 0, 0, count * 24)
end

SelectPlrBtn.MouseButton1Click:Connect(function() DropFrame.Visible = not DropFrame.Visible; if DropFrame.Visible then updatePlayerList() end end)
GotoPlrBtn.MouseButton1Click:Connect(function()
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if myHrp then myHrp.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 3) end
    end
end)

-- LOGIKA DETEKSI BUAH VIA SLOT, SLOTS, & FRUITS (PRESISI)
local function getExactFruitAndLevel(plr)
    local fruitName, fruitLevel = "None", "0"
    local mainData = plr:FindFirstChild("MAIN_DATA")
    
    if mainData then
        local activeSlotObj = mainData:FindFirstChild("Slot")
        local activeSlotNum = activeSlotObj and tostring(activeSlotObj.Value) or "1"
        
        local slotsFolder = mainData:FindFirstChild("Slots")
        if slotsFolder then
            local slotValObj = slotsFolder:FindFirstChild(activeSlotNum)
            if slotValObj then
                if slotValObj:IsA("ValueBase") then
                    fruitName = tostring(slotValObj.Value)
                else
                    for _, child in ipairs(slotValObj:GetChildren()) do
                        if child:IsA("StringValue") or child:IsA("ValueBase") then
                            fruitName = tostring(child.Value)
                            break
                        end
                    end
                end
            end
        end
        
        local fruitsFolder = mainData:FindFirstChild("Fruits")
        if fruitsFolder and fruitName ~= "None" and fruitName ~= "" then
            local fruitObj = fruitsFolder:FindFirstChild(fruitName)
            if fruitObj then
                local lvlObj = fruitObj:FindFirstChild("Level")
                if lvlObj then 
                    fruitLevel = tostring(math.floor(lvlObj.Value)) 
                end
            end
        end
    end
    
    return fruitName, fruitLevel
end

-- ============================================================
--  2. FRUIT BATTLEGROUNDS TAB
-- ============================================================
addSectionHeader(FbgTab, "Combat & Target")
addToggle(FbgTab, "Auto Aim (Gyro Lock)", "Otomatis mengunci ke musuh terdekat", false, function(v) autoAimEnabled = v end)
addToggle(FbgTab, "Advanced Anti-Stun", "Secara aktif menghapus efek freeze, stun & combo", false, function(v) antiStunEnabled = v end)

addSectionHeader(FbgTab, "FBG Specific ESP")
addToggle(FbgTab, "Fruit & Level ESP", "Darah, Jarak, Buah, Level & Body", false, function(v) fbgEspEnabled = v end)
addToggle(FbgTab, "NPC ESP (workspace.NPCs)", "Tampilkan teks penanda NPC map", false, function(v) npcEspEnabled = v end)

addSectionHeader(FbgTab, "Area Teleport (System & Custom Saved)")

local AreaTpCard = Instance.new("Frame")
AreaTpCard.Size = UDim2.new(1, -10, 0, 42); AreaTpCard.BackgroundColor3 = Color3.fromRGB(22, 26, 40); AreaTpCard.BorderSizePixel = 0; AreaTpCard.Parent = FbgTab
Instance.new("UICorner", AreaTpCard).CornerRadius = UDim.new(0, 6)

local SelectAreaBtn = Instance.new("TextButton")
SelectAreaBtn.Size = UDim2.new(0.6, 0, 0, 26); SelectAreaBtn.Position = UDim2.new(0, 10, 0.5, -13); SelectAreaBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 28); SelectAreaBtn.BorderSizePixel = 0; SelectAreaBtn.Text = "Pilih Area Map..."; SelectAreaBtn.TextColor3 = Color3.fromRGB(200, 210, 255); SelectAreaBtn.Font = Enum.Font.GothamSemibold; SelectAreaBtn.TextSize = 10; SelectAreaBtn.Parent = AreaTpCard
Instance.new("UICorner", SelectAreaBtn).CornerRadius = UDim.new(0, 5)

local GotoAreaBtn = Instance.new("TextButton")
GotoAreaBtn.Size = UDim2.new(0, 75, 0, 26); GotoAreaBtn.Position = UDim2.new(1, -85, 0.5, -13); GotoAreaBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255); GotoAreaBtn.BorderSizePixel = 0; GotoAreaBtn.Text = "TELEPORT"; GotoAreaBtn.TextColor3 = Color3.fromRGB(255, 255, 255); GotoAreaBtn.Font = Enum.Font.GothamBold; GotoAreaBtn.TextSize = 9; GotoAreaBtn.Parent = AreaTpCard
Instance.new("UICorner", GotoAreaBtn).CornerRadius = UDim.new(0, 5)

local AreaDropFrame = Instance.new("ScrollingFrame")
AreaDropFrame.Size = UDim2.new(1, -10, 0, 100); AreaDropFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 38); AreaDropFrame.BorderSizePixel = 0; AreaDropFrame.Visible = false; AreaDropFrame.ZIndex = 20; AreaDropFrame.ScrollBarThickness = 3; AreaDropFrame.Parent = FbgTab
Instance.new("UICorner", AreaDropFrame).CornerRadius = UDim.new(0, 6)
local AreaDropLayout = Instance.new("UIListLayout"); AreaDropLayout.Parent = AreaDropFrame

local function updateAreaList()
    for _, child in ipairs(AreaDropFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local count = 0
    
    local areasFolder = workspace:FindFirstChild("Areas")
    if areasFolder then
        for _, area in ipairs(areasFolder:GetChildren()) do
            count = count + 1
            local aBtn = Instance.new("TextButton")
            aBtn.Size = UDim2.new(1, 0, 0, 24); aBtn.BackgroundColor3 = Color3.fromRGB(28, 32, 50); aBtn.BorderSizePixel = 0; aBtn.Text = "[Map] " .. area.Name; aBtn.TextColor3 = Color3.fromRGB(200, 210, 255); aBtn.Font = Enum.Font.Gotham; aBtn.TextSize = 10; aBtn.ZIndex = 21; aBtn.Parent = AreaDropFrame
            aBtn.MouseButton1Click:Connect(function()
                selectedArea = area
                SelectAreaBtn.Text = "[Map] " .. area.Name
                AreaDropFrame.Visible = false
            end)
        end
    end
    
    for name, cframe in pairs(customAreas) do
        count = count + 1
        local aBtn = Instance.new("TextButton")
        aBtn.Size = UDim2.new(1, 0, 0, 24); aBtn.BackgroundColor3 = Color3.fromRGB(35, 45, 65); aBtn.BorderSizePixel = 0; aBtn.Text = "[Custom] " .. name; aBtn.TextColor3 = Color3.fromRGB(0, 255, 180); aBtn.Font = Enum.Font.GothamBold; aBtn.TextSize = 10; aBtn.ZIndex = 21; aBtn.Parent = AreaDropFrame
        aBtn.MouseButton1Click:Connect(function()
            selectedArea = cframe
            SelectAreaBtn.Text = "[Custom] " .. name
            AreaDropFrame.Visible = false
        end)
    end
    
    AreaDropFrame.CanvasSize = UDim2.new(0, 0, 0, count * 24)
end

SelectAreaBtn.MouseButton1Click:Connect(function() AreaDropFrame.Visible = not AreaDropFrame.Visible; if AreaDropFrame.Visible then updateAreaList() end end)
GotoAreaBtn.MouseButton1Click:Connect(function()
    local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if myHrp and selectedArea then
        if typeof(selectedArea) == "CFrame" then
            myHrp.CFrame = selectedArea
        elseif typeof(selectedArea) == "Instance" then
            if selectedArea:IsA("BasePart") then myHrp.CFrame = selectedArea.CFrame * CFrame.new(0, 5, 0)
            elseif selectedArea:IsA("Model") then myHrp.CFrame = selectedArea:GetPivot() * CFrame.new(0, 5, 0) end
        end
    end
end)

local SaveAreaCard = Instance.new("Frame")
SaveAreaCard.Size = UDim2.new(1, -10, 0, 42); SaveAreaCard.BackgroundColor3 = Color3.fromRGB(22, 26, 40); SaveAreaCard.BorderSizePixel = 0; SaveAreaCard.Parent = FbgTab
Instance.new("UICorner", SaveAreaCard).CornerRadius = UDim.new(0, 6)

local AreaNameBox = Instance.new("TextBox")
AreaNameBox.Size = UDim2.new(0.6, 0, 0, 26); AreaNameBox.Position = UDim2.new(0, 10, 0.5, -13); AreaNameBox.BackgroundColor3 = Color3.fromRGB(15, 18, 28); AreaNameBox.BorderSizePixel = 0; AreaNameBox.PlaceholderText = "Ketik Nama Area..."; AreaNameBox.Text = ""; AreaNameBox.TextColor3 = Color3.fromRGB(255, 255, 255); AreaNameBox.Font = Enum.Font.Gotham; AreaNameBox.TextSize = 10; AreaNameBox.Parent = SaveAreaCard
Instance.new("UICorner", AreaNameBox).CornerRadius = UDim.new(0, 5)

local SavePosBtn = Instance.new("TextButton")
SavePosBtn.Size = UDim2.new(0, 75, 0, 26); SavePosBtn.Position = UDim2.new(1, -85, 0.5, -13); SavePosBtn.BackgroundColor3 = Color3.fromRGB(45, 180, 90); SavePosBtn.BorderSizePixel = 0; SavePosBtn.Text = "SAVE POS"; SavePosBtn.TextColor3 = Color3.fromRGB(255, 255, 255); SavePosBtn.Font = Enum.Font.GothamBold; SavePosBtn.TextSize = 9; SavePosBtn.Parent = SaveAreaCard
Instance.new("UICorner", SavePosBtn).CornerRadius = UDim.new(0, 5)

SavePosBtn.MouseButton1Click:Connect(function()
    local name = AreaNameBox.Text ~= "" and AreaNameBox.Text or ("Area_" .. tostring(#customAreas + 1))
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        customAreas[name] = hrp.CFrame
        AreaNameBox.Text = ""
        SelectAreaBtn.Text = "[Custom] " .. name
        selectedArea = hrp.CFrame
        print("[CyRuZzz] Custom Area Saved: " .. name)
    end
end)

-- ============================================================
--  3. SERVER TAB
-- ============================================================
addSectionHeader(ServerTab, "Anti AFK Protection")
addToggle(ServerTab, "Anti-AFK Protection", "Mencegah kick AFK", true, function(v) antiAfkEnabled = v end)

table.insert(connections, LP.Idled:Connect(function()
    if antiAfkEnabled then VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame); task.wait(1); VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame) end
end))

addSectionHeader(ServerTab, "Server Management")
addButton(ServerTab, "Copy Current JobID", "COPY", function() if setclipboard then setclipboard(game.JobId); print("[CyRuZzz] JobID copied!") end end)

local JoinBoxFrame = Instance.new("Frame")
JoinBoxFrame.Size = UDim2.new(1, -10, 0, 42); JoinBoxFrame.BackgroundColor3 = Color3.fromRGB(22, 26, 40); JoinBoxFrame.BorderSizePixel = 0; JoinBoxFrame.Parent = ServerTab
Instance.new("UICorner", JoinBoxFrame).CornerRadius = UDim.new(0, 6)

local JobInput = Instance.new("TextBox")
JobInput.Size = UDim2.new(0.65, 0, 0, 26); JobInput.Position = UDim2.new(0, 10, 0.5, -13); JobInput.BackgroundColor3 = Color3.fromRGB(15, 18, 28); JobInput.BorderSizePixel = 0; JobInput.PlaceholderText = "Paste JobID Here..."; JobInput.Text = ""; JobInput.TextColor3 = Color3.fromRGB(255, 255, 255); JobInput.Font = Enum.Font.Gotham; JobInput.TextSize = 10; JobInput.Parent = JoinBoxFrame
Instance.new("UICorner", JobInput).CornerRadius = UDim.new(0, 5)

local JoinBtn = Instance.new("TextButton")
JoinBtn.Size = UDim2.new(0, 75, 0, 26); JoinBtn.Position = UDim2.new(1, -85, 0.5, -13); JoinBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255); JoinBtn.BorderSizePixel = 0; JoinBtn.Text = "JOIN"; JoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255); JoinBtn.Font = Enum.Font.GothamBold; JoinBtn.TextSize = 10; JoinBtn.Parent = JoinBoxFrame
Instance.new("UICorner", JoinBtn).CornerRadius = UDim.new(0, 5)
JoinBtn.MouseButton1Click:Connect(function() if JobInput.Text ~= "" then TeleportService:TeleportToPlaceInstance(game.PlaceId, JobInput.Text, LP) end end)

addButton(ServerTab, "Server Hop (Random)", "HOP", function()
    local placeId = game.PlaceId; local servers = {}; local req = request or http_request or (syn and syn.request)
    if req then
        local res = req({ Url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100" })
        local body = HttpService:JSONDecode(res.Body)
        if body and body.data then
            for _, v in ipairs(body.data) do if type(v) == "table" and v.playing < v.maxPlayers and v.id ~= game.JobId then table.insert(servers, v.id) end end
        end
    end
    if #servers > 0 then TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], LP) else TeleportService:Teleport(placeId, LP) end
end)

-- ============================================================
--  EXECUTION LOOPS
-- ============================================================
local function getClosestEnemy()
    local closestPlr = nil; local shortestDist = math.huge
    local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if myHrp then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                local eChar = plr.Character; local eHrp = eChar and eChar:FindFirstChild("HumanoidRootPart"); local eHum = eChar and eChar:FindFirstChildOfClass("Humanoid")
                if eHrp and eHum and eHum.Health > 0 then
                    local dist = (myHrp.Position - eHrp.Position).Magnitude
                    if dist < shortestDist then shortestDist = dist; closestPlr = plr end
                end
            end
        end
    end
    return closestPlr
end

-- Main RenderStepped Loop
table.insert(connections, RunService.RenderStepped:Connect(function()
    local myChar = LP.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

    -- Advanced Anti Stun Loop
    if antiStunEnabled and myChar then
        for _, child in ipairs(myChar:GetChildren()) do
            local name = string.lower(child.Name)
            if string.find(name, "stun") or string.find(name, "freeze") or string.find(name, "action") or string.find(name, "combo") then
                child:Destroy()
            end
        end
        local hum = myChar:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.WalkSpeed == 0 then hum.WalkSpeed = speedEnabled and walkSpeedVal or 16 end
            if hum.PlatformStand then hum.PlatformStand = false end
            if hum.AutoRotate == false then hum.AutoRotate = true end
        end
    end

    -- Infinite Dash Loop
    if infDashEnabled and myChar then
        local dashCd = myChar:FindFirstChild("DashCooldown") or myChar:FindFirstChild("GeppoCooldown") or myChar:FindFirstChild("Dodging")
        if dashCd then dashCd:Destroy() end
    end

    -- Auto Aim
    if autoAimEnabled and myHrp then
        local targetPlr = getClosestEnemy()
        if targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart") then
            local targetHrp = targetPlr.Character.HumanoidRootPart
            myHrp.CFrame = CFrame.lookAt(myHrp.Position, Vector3.new(targetHrp.Position.X, myHrp.Position.Y, targetHrp.Position.Z))
            if ReplicatorNoYield then
                pcall(function() ReplicatorNoYield:FireServer("Effects", "GyroAim", { HitLocation = targetHrp.Position, Target = targetHrp }) end)
            end
        end
    end

    -- Player ESP (Detailed Fruit Slot/Slots Data Sync)
    for plr, data in pairs(espObjects) do
        local char = plr.Character; local isAnyEspOn = universalEspEnabled or fbgEspEnabled
        if isAnyEspOn and char and char:FindFirstChild("Head") then
            local hum = char:FindFirstChildOfClass("Humanoid"); local root = char:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 then
                data.Billboard.Adornee = char.Head; data.Billboard.Enabled = true; data.Highlight.Adornee = char; data.Highlight.Enabled = true

                if fbgEspEnabled then
                    data.FruitLbl.Visible = true; data.LevelLbl.Visible = true; data.DistLbl.Visible = true; data.HealthBg.Visible = true
                    
                    local activeFruit, fruitLevel = getExactFruitAndLevel(plr)
                    
                    data.FruitLbl.Text = "Fruit: " .. string.upper(activeFruit)
                    data.LevelLbl.Text = "Level: " .. fruitLevel
                    if myHrp and root then data.DistLbl.Text = math.floor((myHrp.Position - root.Position).Magnitude) .. " studs" end
                    local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    data.HealthFill.Size = UDim2.new(hp, -2, 1, -2)
                else
                    data.FruitLbl.Visible = false; data.LevelLbl.Visible = false; data.DistLbl.Visible = false; data.HealthBg.Visible = false
                end
            else
                data.Billboard.Enabled = false; data.Highlight.Enabled = false
            end
        else
            data.Billboard.Enabled = false; data.Highlight.Enabled = false
        end
    end

    -- NPC ESP
    if npcEspEnabled then
        local npcsFolder = workspace:FindFirstChild("NPCs")
        if npcsFolder then
            for _, model in ipairs(npcsFolder:GetChildren()) do
                if model:IsA("Model") and model:FindFirstChild("Head") then
                    if not npcEspObjects[model] then
                        local bg = Instance.new("BillboardGui")
                        bg.Name = "_CyNpcESP"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0, 140, 0, 30); bg.StudsOffset = Vector3.new(0, 3, 0)
                        local lbl = Instance.new("TextLabel", bg)
                        lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(255, 100, 100); lbl.TextStrokeTransparency = 0.2; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11; lbl.Text = "[NPC] " .. model.Name
                        bg.Adornee = model.Head; bg.Parent = PlayerGui
                        npcEspObjects[model] = bg
                    end
                end
            end
        end
    else
        for model, bg in pairs(npcEspObjects) do bg:Destroy() end
        table.clear(npcEspObjects)
    end
end))

-- Infinite Jump Request Event
table.insert(connections, UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end))

-- ESP Manager Setup
local function removeEsp(plr)
    if espObjects[plr] then
        if espObjects[plr].Billboard then espObjects[plr].Billboard:Destroy() end
        if espObjects[plr].Highlight then espObjects[plr].Highlight:Destroy() end
        espObjects[plr] = nil
    end
end

local function createEsp(plr)
    if plr == LP or espObjects[plr] then return end
    local holder = Instance.new("BillboardGui")
    holder.Name = "_CyESP_" .. plr.Name; holder.AlwaysOnTop = true; holder.Size = UDim2.new(0, 160, 0, 130); holder.StudsOffset = Vector3.new(0, 3.2, 0)
    local layout = Instance.new("UIListLayout", holder); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.Padding = UDim.new(0, 1)

    local function makeLbl(col, size)
        local l = Instance.new("TextLabel", holder); l.Size = UDim2.new(1,0,0,14); l.BackgroundTransparency = 1; l.TextColor3 = col; l.TextStrokeTransparency = 0.2; l.Font = Enum.Font.GothamBold; l.TextSize = size
        return l
    end

    local nameLbl   = makeLbl(Color3.fromRGB(255,255,255), 12); nameLbl.Text = plr.Name
    local fruitLbl  = makeLbl(Color3.fromRGB(0,255,255), 11); fruitLbl.Visible = false
    local levelLbl  = makeLbl(Color3.fromRGB(255,220,0), 11); levelLbl.Visible = false
    local distLbl   = makeLbl(Color3.fromRGB(200,200,200), 10); distLbl.Visible = false
    local healthBg   = Instance.new("Frame", holder); healthBg.Size = UDim2.new(0,100,0,8); healthBg.BackgroundColor3 = Color3.fromRGB(0,0,0); healthBg.BorderSizePixel = 0; healthBg.Visible = false
    local healthFill = Instance.new("Frame", healthBg); healthFill.Size = UDim2.new(1,-2,1,-2); healthFill.Position = UDim2.new(0,1,0,1); healthFill.BackgroundColor3 = Color3.fromRGB(0,255,0); healthFill.BorderSizePixel = 0
    local highlight  = Instance.new("Highlight"); highlight.Name = "_CyChams_" .. plr.Name; highlight.FillColor = Color3.fromRGB(0, 170, 255); highlight.OutlineColor = Color3.fromRGB(0, 170, 255); highlight.FillTransparency = 0.5
    holder.Parent = PlayerGui; highlight.Parent = PlayerGui

    espObjects[plr] = { Billboard = holder, Highlight = highlight, NameLbl = nameLbl, FruitLbl = fruitLbl, LevelLbl = levelLbl, DistLbl = distLbl, HealthBg = healthBg, HealthFill = healthFill }
end

local function reloadEsp()
    for plr, _ in pairs(espObjects) do removeEsp(plr) end
    table.clear(espObjects)
    for _, p in ipairs(Players:GetPlayers()) do createEsp(p) end
end

ReloadBtn.MouseButton1Click:Connect(reloadEsp)

table.insert(connections, Players.PlayerAdded:Connect(createEsp))
table.insert(connections, Players.PlayerRemoving:Connect(removeEsp))
for _, p in ipairs(Players:GetPlayers()) do createEsp(p) end

-- Keyboard & UI Switch Sync Engine
table.insert(connections, UserInputService.InputBegan:Connect(function(inp, gameProcessed)
    if gameProcessed then return end
    
    local k = inp.KeyCode
    if k == Enum.KeyCode.T then
        if toggleSetters["Fly Mode [T]"] then toggleSetters["Fly Mode [T]"]() end
    elseif k == Enum.KeyCode.C then
        if toggleSetters["Noclip Mode [C]"] then toggleSetters["Noclip Mode [C]"]() end
    elseif k == Enum.KeyCode.Q then
        if toggleSetters["Walk Speed [Q]"] then toggleSetters["Walk Speed [Q]"]() end
    elseif k == Enum.KeyCode.H then
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp and tp1Pos then hrp.CFrame = tp1Pos end
    elseif k == Enum.KeyCode.J then
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp and tp2Pos then hrp.CFrame = tp2Pos end
    end
end))

-- Total Cleanup
CloseBtn.MouseButton1Click:Connect(function()
    autoAimEnabled = false; universalEspEnabled = false; fbgEspEnabled = false; npcEspEnabled = false; antiAfkEnabled = false
    antiStunEnabled = false; infDashEnabled = false; infJumpEnabled = false
    if flyConn then flyConn:Disconnect() end
    if noclipConn then noclipConn:Disconnect() end
    if speedConn then speedConn:Disconnect() end

    for _, conn in ipairs(connections) do if conn and conn.Connected then conn:Disconnect() end end
    table.clear(connections)

    for plr, _ in pairs(espObjects) do removeEsp(plr) end
    table.clear(espObjects)

    for _, bg in pairs(npcEspObjects) do bg:Destroy() end
    table.clear(npcEspObjects)

    SG:Destroy()
    print("[CyRuZzz Hub] Unloaded Successfully!")
end)

MainLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() tabs["Universal"].Page.CanvasSize = UDim2.new(0, 0, 0, MainLayout.AbsoluteContentSize.Y + 20) end)
FbgLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() tabs["Fruit BG"].Page.CanvasSize = UDim2.new(0, 0, 0, FbgLayout.AbsoluteContentSize.Y + 20) end)
ServerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() tabs["Server"].Page.CanvasSize = UDim2.new(0, 0, 0, ServerLayout.AbsoluteContentSize.Y + 20) end)

print("[CyRuZzz Hub] Full Code Loaded - Fruit ESP Updated with Slot & Fruits Sync!")
