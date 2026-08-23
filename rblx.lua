-- ============================================================
--  CyRuZzz Universal & Fruit BG Hub (Modernized - FIXED)
--  Fly Lock Leveling + Clean Modern UI + Optimized
--  ERROR FIXES: DamageTag, HTTP 429, Asset Approval
-- ============================================================

local Players              = game:GetService("Players")
local RunService           = game:GetService("RunService")
local UserInputService     = game:GetService("UserInputService")
local TeleportService      = game:GetService("TeleportService")
local HttpService          = game:GetService("HttpService")
local VirtualUser          = game:GetService("VirtualUser")
local TweenService         = game:GetService("TweenService")
local ReplicatedStorage    = game:GetService("ReplicatedStorage")

local LP                   = Players.LocalPlayer
local Camera               = workspace.CurrentCamera
local PlayerGui            = LP:WaitForChild("PlayerGui")

-- Global States
local universalEspEnabled  = false
local fbgEspEnabled        = false
local npcEspEnabled        = false
local autoLevelingEnabled  = false
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

-- Leveling Safety Anchor Config
local levelingMode         = "Current Position"
local presetSafeCFrame     = CFrame.new(0, 500, 0)

local customAreas          = {}
local espObjects           = {}
local npcEspObjects        = {}
local skillConfigs         = {}
local connections          = {}
local toggleSetters        = {}

local flyConn, noclipConn, speedConn
local ReplicatorNoYield    = ReplicatedStorage:FindFirstChild("ReplicatorNoYield")

-- ============================================================
--  HTTP 429 FIX: Rate Limiter untuk API Calls
-- ============================================================
local RateLimiter = {
    lastCall = 0,
    minDelay = 1.5, -- Minimum 1.5 detik antara requests
    callCount = 0,
    maxCallsPerMinute = 20
}

function RateLimiter:WaitIfNeeded()
    local now = tick()
    local elapsed = now - self.lastCall
    
    if elapsed < self.minDelay then
        task.wait(self.minDelay - elapsed)
    end
    
    self.callCount = self.callCount + 1
    if self.callCount >= self.maxCallsPerMinute then
        task.wait(60) -- Reset setiap menit
        self.callCount = 0
    end
    
    self.lastCall = tick()
end

function RateLimiter:Reset()
    self.callCount = 0
    self.lastCall = 0
end

-- Safe wrapper untuk GetNameFromUserIdAsync
local function SafeGetNameFromUserId(userId)
    RateLimiter:WaitIfNeeded()
    
    local success, result = pcall(function()
        return Players:GetNameFromUserIdAsync(userId)
    end)
    
    if success then
        return result
    else
        -- Handle HTTP 429 atau error lainnya
        if string.find(tostring(result), "429") then
            warn("[Rate Limit] Terlalu banyak request, menunggu...")
            task.wait(5)
            return SafeGetNameFromUserId(userId) -- Retry
        end
        return "Unknown"
    end
end

-- Cleanup Old UI
if PlayerGui:FindFirstChild("CyRuZzz_UniversalHub") then
    PlayerGui.CyRuZzz_UniversalHub:Destroy()
end

-- ============================================================
--  GUI BASE SETUP (MODERN THEME)
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name           = "CyRuZzz_UniversalHub"
SG.ResetOnSpawn   = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder   = 9999
SG.Parent         = PlayerGui

-- Mini Widget
local MiniWidget = Instance.new("Frame")
MiniWidget.Name             = "MiniWidget"
MiniWidget.Size             = UDim2.new(0, 48, 0, 48)
MiniWidget.Position         = UDim2.new(0, 20, 0.5, -24)
MiniWidget.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
MiniWidget.BorderSizePixel  = 0
MiniWidget.Active           = true
MiniWidget.Draggable        = true
MiniWidget.Visible          = false
MiniWidget.Parent           = SG
Instance.new("UICorner", MiniWidget).CornerRadius = UDim.new(1, 0)
local miniStroke = Instance.new("UIStroke", MiniWidget)
miniStroke.Color = Color3.fromRGB(59, 130, 246)
miniStroke.Thickness = 2

local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(1,0,1,0)
MiniBtn.BackgroundTransparency = 1
MiniBtn.Text = "C"
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 22
MiniBtn.Parent = MiniWidget

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name             = "MainFrame"
MainFrame.Size             = UDim2.new(0, 640, 0, 460)
MainFrame.Position         = UDim2.new(0.5, -320, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 14, 20)
MainFrame.BorderSizePixel  = 0
MainFrame.Active           = true
MainFrame.Draggable        = true
MainFrame.Parent           = SG
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Color3.fromRGB(255, 255, 255)
mainStroke.Transparency = 0.9
mainStroke.Thickness = 1

-- Header
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local BrandTitle = Instance.new("TextLabel")
BrandTitle.Size = UDim2.new(0, 200, 1, 0)
BrandTitle.Position = UDim2.new(0, 16, 0, 0)
BrandTitle.BackgroundTransparency = 1
BrandTitle.Text = "CYRUZZZ HUB"
BrandTitle.TextColor3 = Color3.fromRGB(59, 130, 246)
BrandTitle.Font = Enum.Font.GothamBold
BrandTitle.TextSize = 14
BrandTitle.TextXAlignment = Enum.TextXAlignment.Left
BrandTitle.Parent = TopBar

local function createHeaderBtn(txt, posX, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 28, 0, 28)
    btn.Position = UDim2.new(1, posX, 0.5, -14)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Text = txt
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = TopBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local MinimizeBtn = createHeaderBtn("-", -66, Color3.fromRGB(45, 50, 75))
local CloseBtn = createHeaderBtn("×", -34, Color3.fromRGB(220, 50, 70))

MinimizeBtn.MouseEnter:Connect(function() MinimizeBtn.BackgroundColor3 = Color3.fromRGB(65, 70, 95) end)
MinimizeBtn.MouseLeave:Connect(function() MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 75) end)
CloseBtn.MouseEnter:Connect(function() CloseBtn.BackgroundColor3 = Color3.fromRGB(240, 70, 90) end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 70) end)

MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; MiniWidget.Visible = true end)
MiniBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; MiniWidget.Visible = false end)

-- Sidebar Navigation
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 160, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Padding = UDim.new(0, 6)
local SidePadding = Instance.new("UIPadding", Sidebar)
SidePadding.PaddingTop = UDim.new(0, 12)
SidePadding.PaddingLeft = UDim.new(0, 12)
SidePadding.PaddingRight = UDim.new(0, 12)

local ContentFolder = Instance.new("Frame")
ContentFolder.Size = UDim2.new(1, -160, 1, -42)
ContentFolder.Position = UDim2.new(0, 160, 0, 42)
ContentFolder.BackgroundTransparency = 1
ContentFolder.Parent = MainFrame

local tabs = {}
local function createTab(name)
    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Size = UDim2.new(1, -20, 1, -20)
    TabPage.Position = UDim2.new(0, 10, 0, 10)
    TabPage.BackgroundTransparency = 1
    TabPage.BorderSizePixel = 0
    TabPage.Visible = false
    TabPage.ScrollBarThickness = 4
    TabPage.ScrollBarImageColor3 = Color3.fromRGB(59, 130, 246)
    TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabPage.Parent = ContentFolder
    
    local PageLayout = Instance.new("UIListLayout", TabPage)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 10)

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 36)
    TabBtn.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(148, 163, 184)
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 11
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)
    local p = Instance.new("UIPadding", TabBtn)
    p.PaddingLeft = UDim.new(0, 14)

    TabBtn.MouseEnter:Connect(function() if TabBtn.BackgroundColor3 ~= Color3.fromRGB(59, 130, 246) then TabBtn.BackgroundColor3 = Color3.fromRGB(30, 33, 45) end end)
    TabBtn.MouseLeave:Connect(function() if TabBtn.BackgroundColor3 ~= Color3.fromRGB(59, 130, 246) then TabBtn.BackgroundColor3 = Color3.fromRGB(24, 26, 36) end end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do 
            t.Page.Visible = false
            t.Btn.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
            t.Btn.TextColor3 = Color3.fromRGB(148, 163, 184)
        end
        TabPage.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    tabs[name] = { Page = TabPage, Btn = TabBtn, Layout = PageLayout }
    return TabPage, PageLayout
end

local MainTab, MainLayout     = createTab("  Universal")
local FbgTab, FbgLayout       = createTab("  Fruit BG")
local ServerTab, ServerLayout = createTab("  Server")

tabs["Universal"].Page.Visible = true
tabs["Universal"].Btn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
tabs["Universal"].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- ============================================================
--  UI HELPER FUNCTIONS (MODERN)
-- ============================================================
local function addSectionHeader(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(text)
    lbl.TextColor3 = Color3.fromRGB(96, 115, 150)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
end

local function addToggle(parent, title, desc, defaultState, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -10, 0, 52)
    card.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
    card.BorderSizePixel = 0
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.92
    stroke.Thickness = 1

    local padding = Instance.new("UIPadding", card)
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(0.65, 0, 0, 18)
    tLbl.Position = UDim2.new(0, 0, 0, 2)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = title
    tLbl.TextColor3 = Color3.fromRGB(248, 250, 252)
    tLbl.Font = Enum.Font.GothamSemibold
    tLbl.TextSize = 12
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.Parent = card

    local dLbl = Instance.new("TextLabel")
    dLbl.Size = UDim2.new(0.65, 0, 0, 16)
    dLbl.Position = UDim2.new(0, 0, 0, 22)
    dLbl.BackgroundTransparency = 1
    dLbl.Text = desc
    dLbl.TextColor3 = Color3.fromRGB(148, 163, 184)
    dLbl.Font = Enum.Font.Gotham
    dLbl.TextSize = 10
    dLbl.TextXAlignment = Enum.TextXAlignment.Left
    dLbl.Parent = card

    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(0, 46, 0, 26)
    btnFrame.Position = UDim2.new(1, -60, 0.5, -13)
    btnFrame.BackgroundColor3 = defaultState and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(55, 65, 81)
    btnFrame.BorderSizePixel = 0
    btnFrame.Parent = card
    Instance.new("UICorner", btnFrame).CornerRadius = UDim.new(1, 0)

    local btnCircle = Instance.new("Frame")
    btnCircle.Size = UDim2.new(0, 20, 0, 20)
    btnCircle.Position = UDim2.new(0, defaultState and 23 or 3, 0.5, -10)
    btnCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btnCircle.BorderSizePixel = 0
    btnCircle.Parent = btnFrame
    Instance.new("UICorner", btnCircle).CornerRadius = UDim.new(1, 0)
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = btnFrame

    local currentState = defaultState

    local function updateVisual(newState)
        currentState = newState
        btnFrame.BackgroundColor3 = currentState and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(55, 65, 81)
        TweenService:Create(btnCircle, tweenInfo, {
            Position = UDim2.new(0, currentState and 23 or 3, 0.5, -10)
        }):Play()
        callback(currentState)
    end

    btn.MouseButton1Click:Connect(function()
        updateVisual(not currentState)
    end)

    toggleSetters[title] = function(forcedState)
        local targetState = forcedState ~= nil and forcedState or (not currentState)
        updateVisual(targetState)
    end

    return card, btnFrame
end

local function addButton(parent, title, btnText, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -10, 0, 46)
    card.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
    card.BorderSizePixel = 0
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.92
    stroke.Thickness = 1

    local padding = Instance.new("UIPadding", card)
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(0.6, 0, 1, 0)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = title
    tLbl.TextColor3 = Color3.fromRGB(248, 250, 252)
    tLbl.Font = Enum.Font.GothamSemibold
    tLbl.TextSize = 12
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.Parent = card

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 0, 28)
    btn.Position = UDim2.new(1, -104, 0.5, -14)
    btn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    btn.BorderSizePixel = 0
    btn.Text = btnText
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = card
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(37, 99, 235) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(59, 130, 246) end)

    btn.MouseButton1Click:Connect(callback)
    return card
end

local function addSliderRow(parent, title, val, minV, maxV, onUpdate)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -10, 0, 46)
    card.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
    card.BorderSizePixel = 0
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.92
    stroke.Thickness = 1

    local padding = Instance.new("UIPadding", card)
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(0.4, 0, 0, 18)
    tLbl.Position = UDim2.new(0, 0, 0, 2)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = title
    tLbl.TextColor3 = Color3.fromRGB(248, 250, 252)
    tLbl.Font = Enum.Font.GothamSemibold
    tLbl.TextSize = 12
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.Parent = card

    local vLbl = Instance.new("TextLabel")
    vLbl.Size = UDim2.new(0.2, 0, 0, 18)
    vLbl.Position = UDim2.new(0.4, 0, 0, 2)
    vLbl.BackgroundTransparency = 1
    vLbl.Text = tostring(val)
    vLbl.TextColor3 = Color3.fromRGB(59, 130, 246)
    vLbl.Font = Enum.Font.GothamBold
    vLbl.TextSize = 12
    vLbl.TextXAlignment = Enum.TextXAlignment.Center
    vLbl.Parent = card

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -80, 0, 6)
    barBg.Position = UDim2.new(0, 0, 1, -12)
    barBg.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
    barBg.BorderSizePixel = 0
    barBg.Parent = card
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new((val-minV)/(maxV-minV), 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

    local function makeBtn(txt, posX, delta)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 28, 0, 24)
        b.Position = UDim2.new(1, posX, 0, 0)
        b.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
        b.BorderSizePixel = 0
        b.Text = txt
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        b.Parent = card
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        
        b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(55, 60, 80) end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(40, 45, 60) end)
        
        b.MouseButton1Click:Connect(function()
            val = math.clamp(val + delta, minV, maxV)
            vLbl.Text = tostring(val)
            barFill.Size = UDim2.new((val-minV)/(maxV-minV), 0, 1, 0)
            onUpdate(val)
        end)
    end
    makeBtn("-", -66, -5)
    makeBtn("+", -34, 5)
end

-- ============================================================
--  1. UNIVERSAL TAB
-- ============================================================
addSectionHeader(MainTab, "Universal Visuals")
local EspCard = addToggle(MainTab, "Universal ESP", "Nama & Body Highlight Player", false, function(v) universalEspEnabled = v end)
local ReloadBtn = Instance.new("TextButton")
ReloadBtn.Size = UDim2.new(0, 60, 0, 24)
ReloadBtn.Position = UDim2.new(1, -74, 0.5, -12)
ReloadBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
ReloadBtn.BorderSizePixel = 0
ReloadBtn.Text = "RELOAD"
ReloadBtn.TextColor3 = Color3.fromRGB(200, 215, 255)
ReloadBtn.Font = Enum.Font.GothamBold
ReloadBtn.TextSize = 9
ReloadBtn.Parent = EspCard
Instance.new("UICorner", ReloadBtn).CornerRadius = UDim.new(0, 6)
ReloadBtn.MouseEnter:Connect(function() ReloadBtn.BackgroundColor3 = Color3.fromRGB(55, 60, 80) end)
ReloadBtn.MouseLeave:Connect(function() ReloadBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 60) end)

addSectionHeader(MainTab, "Player Mods")
addToggle(MainTab, "Infinite Dash", "Menghapus delay/cooldown dash", false, function(v) infDashEnabled = v end)
addToggle(MainTab, "Infinite Jump", "Lompat tanpa batas di udara", false, function(v) infJumpEnabled = v end)

addSectionHeader(MainTab, "Movement")
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
    card.Size = UDim2.new(1, -10, 0, 46)
    card.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
    card.BorderSizePixel = 0
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", card); stroke.Color = Color3.fromRGB(255,255,255); stroke.Transparency = 0.92; stroke.Thickness = 1
    local padding = Instance.new("UIPadding", card); padding.PaddingLeft = UDim.new(0,14); padding.PaddingRight = UDim.new(0,14); padding.PaddingTop = UDim.new(0,8); padding.PaddingBottom = UDim.new(0,8)

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(0.4, 0, 0, 18); tLbl.Position = UDim2.new(0, 0, 0, 2)
    tLbl.BackgroundTransparency = 1; tLbl.Text = title; tLbl.TextColor3 = Color3.fromRGB(248, 250, 255)
    tLbl.Font = Enum.Font.GothamSemibold; tLbl.TextSize = 12; tLbl.TextXAlignment = Enum.TextXAlignment.Left; tLbl.Parent = card

    local cLbl = Instance.new("TextLabel")
    cLbl.Size = UDim2.new(0.5, 0, 0, 14); cLbl.Position = UDim2.new(0, 0, 0, 22)
    cLbl.BackgroundTransparency = 1; cLbl.Text = "Not Set"; cLbl.TextColor3 = Color3.fromRGB(148, 163, 184)
    cLbl.Font = Enum.Font.Gotham; cLbl.TextSize = 10; cLbl.TextXAlignment = Enum.TextXAlignment.Left; cLbl.Parent = card

    local function makeBtn(txt, posX, color, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 44, 0, 26); b.Position = UDim2.new(1, posX, 0.5, -13)
        b.BackgroundColor3 = color; b.BorderSizePixel = 0; b.Text = txt
        b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Font = Enum.Font.GothamBold; b.TextSize = 10; b.Parent = card
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(color.R*0.8, color.G*0.8, color.B*0.8) end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = color end)
        b.MouseButton1Click:Connect(callback)
    end

    makeBtn("SET", -98, Color3.fromRGB(59, 130, 246), function()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local cf = hrp.CFrame
            if slot == 1 then tp1Pos = cf else tp2Pos = cf end
            cLbl.Text = string.format("%.0f, %.0f, %.0f", cf.X, cf.Y, cf.Z)
            cLbl.TextColor3 = Color3.fromRGB(34, 197, 94)
        end
    end)

    makeBtn("TP", -50, Color3.fromRGB(34, 197, 94), function()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local pos = slot == 1 and tp1Pos or tp2Pos
        if hrp and pos then hrp.CFrame = pos end
    end)
end

addTpCard(MainTab, "Teleport Slot 1 [H]", 1)
addTpCard(MainTab, "Teleport Slot 2 [J]", 2)

-- Player Teleport Dropdown
local PlrTpCard = Instance.new("Frame")
PlrTpCard.Size = UDim2.new(1, -10, 0, 46); PlrTpCard.BackgroundColor3 = Color3.fromRGB(24, 26, 36); PlrTpCard.BorderSizePixel = 0; PlrTpCard.Parent = MainTab
Instance.new("UICorner", PlrTpCard).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", PlrTpCard); stroke.Color = Color3.fromRGB(255,255,255); stroke.Transparency = 0.92; stroke.Thickness = 1
local padding = Instance.new("UIPadding", PlrTpCard); padding.PaddingLeft = UDim.new(0,14); padding.PaddingRight = UDim.new(0,14); padding.PaddingTop = UDim.new(0,8); padding.PaddingBottom = UDim.new(0,8)

local SelectPlrBtn = Instance.new("TextButton")
SelectPlrBtn.Size = UDim2.new(0.6, 0, 0, 28); SelectPlrBtn.Position = UDim2.new(0, 0, 0.5, -14)
SelectPlrBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 28); SelectPlrBtn.BorderSizePixel = 0
SelectPlrBtn.Text = "Pilih Player..."; SelectPlrBtn.TextColor3 = Color3.fromRGB(200, 210, 255)
SelectPlrBtn.Font = Enum.Font.GothamSemibold; SelectPlrBtn.TextSize = 11; SelectPlrBtn.Parent = PlrTpCard
Instance.new("UICorner", SelectPlrBtn).CornerRadius = UDim.new(0, 6)

local GotoPlrBtn = Instance.new("TextButton")
GotoPlrBtn.Size = UDim2.new(0, 75, 0, 28); GotoPlrBtn.Position = UDim2.new(1, -89, 0.5, -14)
GotoPlrBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246); GotoPlrBtn.BorderSizePixel = 0
GotoPlrBtn.Text = "GOTO"; GotoPlrBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GotoPlrBtn.Font = Enum.Font.GothamBold; GotoPlrBtn.TextSize = 11; GotoPlrBtn.Parent = PlrTpCard
Instance.new("UICorner", GotoPlrBtn).CornerRadius = UDim.new(0, 6)
GotoPlrBtn.MouseEnter:Connect(function() GotoPlrBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235) end)
GotoPlrBtn.MouseLeave:Connect(function() GotoPlrBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246) end)

local DropFrame = Instance.new("ScrollingFrame")
DropFrame.Size = UDim2.new(1, -10, 0, 100); DropFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 38); DropFrame.BorderSizePixel = 0; DropFrame.Visible = false; DropFrame.ZIndex = 20; DropFrame.ScrollBarThickness = 3; DropFrame.Parent = MainTab
Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 6)
local DropLayout = Instance.new("UIListLayout", DropFrame)

local function updatePlayerList()
    for _, child in ipairs(DropFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            count = count + 1
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, 0, 0, 26); pBtn.BackgroundColor3 = Color3.fromRGB(28, 32, 50); pBtn.BorderSizePixel = 0
            pBtn.Text = plr.Name; pBtn.TextColor3 = Color3.fromRGB(200, 210, 255); pBtn.Font = Enum.Font.Gotham; pBtn.TextSize = 11; pBtn.ZIndex = 21; pBtn.Parent = DropFrame
            pBtn.MouseEnter:Connect(function() pBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 70) end)
            pBtn.MouseLeave:Connect(function() pBtn.BackgroundColor3 = Color3.fromRGB(28, 32, 50) end)
            pBtn.MouseButton1Click:Connect(function() selectedPlayer = plr; SelectPlrBtn.Text = plr.Name; DropFrame.Visible = false end)
        end
    end
    DropFrame.CanvasSize = UDim2.new(0, 0, 0, count * 26)
end

SelectPlrBtn.MouseButton1Click:Connect(function() DropFrame.Visible = not DropFrame.Visible; if DropFrame.Visible then updatePlayerList() end end)
GotoPlrBtn.MouseButton1Click:Connect(function()
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if myHrp then myHrp.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 3) end
    end
end)

-- ============================================================
--  LOGIKA DETEKSI BUAH VIA MAIN_DATA
-- ============================================================
local function getExactFruitAndLevel(plr)
    local fruitName, fruitLevel = "Unknown", "0"
    local mainData = plr:FindFirstChild("MAIN_DATA")
    if mainData then
        local slotObj = mainData:FindFirstChild("Slot")
        local activeSlotNum = slotObj and tostring(slotObj.Value) or "1"
        local slotsFolder = mainData:FindFirstChild("Slots")
        if slotsFolder then
            local activeSlotFolder = slotsFolder:FindFirstChild(activeSlotNum)
            if activeSlotFolder then
                for _, child in ipairs(activeSlotFolder:GetChildren()) do
                    if child:IsA("StringValue") or child:IsA("ValueBase") then fruitName = tostring(child.Value); break end
                end
                if fruitName == "Unknown" then fruitName = activeSlotFolder.Name end
            end
        end
        local fruitsFolder = mainData:FindFirstChild("Fruits")
        if fruitsFolder and fruitName ~= "Unknown" then
            local targetObj = fruitsFolder:FindFirstChild(fruitName)
            if targetObj then
                local lvlObj = targetObj:FindFirstChild("Level")
                if lvlObj then fruitLevel = tostring(math.floor(lvlObj.Value)) end
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

addSectionHeader(FbgTab, "Area Teleport")

local AreaTpCard = Instance.new("Frame")
AreaTpCard.Size = UDim2.new(1, -10, 0, 46); AreaTpCard.BackgroundColor3 = Color3.fromRGB(24, 26, 36); AreaTpCard.BorderSizePixel = 0; AreaTpCard.Parent = FbgTab
Instance.new("UICorner", AreaTpCard).CornerRadius = UDim.new(0, 8)
local strokeA = Instance.new("UIStroke", AreaTpCard); strokeA.Color = Color3.fromRGB(255,255,255); strokeA.Transparency = 0.92; strokeA.Thickness = 1
local padA = Instance.new("UIPadding", AreaTpCard); padA.PaddingLeft = UDim.new(0,14); padA.PaddingRight = UDim.new(0,14); padA.PaddingTop = UDim.new(0,8); padA.PaddingBottom = UDim.new(0,8)

local SelectAreaBtn = Instance.new("TextButton")
SelectAreaBtn.Size = UDim2.new(0.6, 0, 0, 28); SelectAreaBtn.Position = UDim2.new(0, 0, 0.5, -14)
SelectAreaBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 28); SelectAreaBtn.BorderSizePixel = 0
SelectAreaBtn.Text = "Pilih Area Map..."; SelectAreaBtn.TextColor3 = Color3.fromRGB(200, 210, 255)
SelectAreaBtn.Font = Enum.Font.GothamSemibold; SelectAreaBtn.TextSize = 11; SelectAreaBtn.Parent = AreaTpCard
Instance.new("UICorner", SelectAreaBtn).CornerRadius = UDim.new(0, 6)

local GotoAreaBtn = Instance.new("TextButton")
GotoAreaBtn.Size = UDim2.new(0, 90, 0, 28); GotoAreaBtn.Position = UDim2.new(1, -104, 0.5, -14)
GotoAreaBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246); GotoAreaBtn.BorderSizePixel = 0
GotoAreaBtn.Text = "TELEPORT"; GotoAreaBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GotoAreaBtn.Font = Enum.Font.GothamBold; GotoAreaBtn.TextSize = 11; GotoAreaBtn.Parent = AreaTpCard
Instance.new("UICorner", GotoAreaBtn).CornerRadius = UDim.new(0, 6)
GotoAreaBtn.MouseEnter:Connect(function() GotoAreaBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235) end)
GotoAreaBtn.MouseLeave:Connect(function() GotoAreaBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246) end)

local AreaDropFrame = Instance.new("ScrollingFrame")
AreaDropFrame.Size = UDim2.new(1, -10, 0, 100); AreaDropFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 38); AreaDropFrame.BorderSizePixel = 0; AreaDropFrame.Visible = false; AreaDropFrame.ZIndex = 20; AreaDropFrame.ScrollBarThickness = 3; AreaDropFrame.Parent = FbgTab
Instance.new("UICorner", AreaDropFrame).CornerRadius = UDim.new(0, 6)
local AreaDropLayout = Instance.new("UIListLayout", AreaDropFrame)

local function updateAreaList()
    for _, child in ipairs(AreaDropFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local count = 0
    
    local areasFolder = workspace:FindFirstChild("Areas")
    if areasFolder then
        for _, area in ipairs(areasFolder:GetChildren()) do
            count = count + 1
            local aBtn = Instance.new("TextButton")
            aBtn.Size = UDim2.new(1, 0, 0, 26); aBtn.BackgroundColor3 = Color3.fromRGB(28, 32, 50); aBtn.BorderSizePixel = 0
            aBtn.Text = "[Map] " .. area.Name; aBtn.TextColor3 = Color3.fromRGB(200, 210, 255); aBtn.Font = Enum.Font.Gotham; aBtn.TextSize = 11; aBtn.ZIndex = 21; aBtn.Parent = AreaDropFrame
            aBtn.MouseEnter:Connect(function() aBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 70) end)
            aBtn.MouseLeave:Connect(function() aBtn.BackgroundColor3 = Color3.fromRGB(28, 32, 50) end)
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
        aBtn.Size = UDim2.new(1, 0, 0, 26); aBtn.BackgroundColor3 = Color3.fromRGB(35, 45, 65); aBtn.BorderSizePixel = 0
        aBtn.Text = "[Custom] " .. name; aBtn.TextColor3 = Color3.fromRGB(34, 197, 94); aBtn.Font = Enum.Font.GothamBold; aBtn.TextSize = 11; aBtn.ZIndex = 21; aBtn.Parent = AreaDropFrame
        aBtn.MouseEnter:Connect(function() aBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 85) end)
        aBtn.MouseLeave:Connect(function() aBtn.BackgroundColor3 = Color3.fromRGB(35, 45, 65) end)
        aBtn.MouseButton1Click:Connect(function()
            selectedArea = cframe
            SelectAreaBtn.Text = "[Custom] " .. name
            AreaDropFrame.Visible = false
        end)
    end
    
    AreaDropFrame.CanvasSize = UDim2.new(0, 0, 0, count * 26)
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
SaveAreaCard.Size = UDim2.new(1, -10, 0, 46); SaveAreaCard.BackgroundColor3 = Color3.fromRGB(24, 26, 36); SaveAreaCard.BorderSizePixel = 0; SaveAreaCard.Parent = FbgTab
Instance.new("UICorner", SaveAreaCard).CornerRadius = UDim.new(0, 8)
local strokeS = Instance.new("UIStroke", SaveAreaCard); strokeS.Color = Color3.fromRGB(255,255,255); strokeS.Transparency = 0.92; strokeS.Thickness = 1
local padS = Instance.new("UIPadding", SaveAreaCard); padS.PaddingLeft = UDim.new(0,14); padS.PaddingRight = UDim.new(0,14); padS.PaddingTop = UDim.new(0,8); padS.PaddingBottom = UDim.new(0,8)

local AreaNameBox = Instance.new("TextBox")
AreaNameBox.Size = UDim2.new(0.6, 0, 0, 28); AreaNameBox.Position = UDim2.new(0, 0, 0.5, -14)
AreaNameBox.BackgroundColor3 = Color3.fromRGB(15, 18, 28); AreaNameBox.BorderSizePixel = 0
AreaNameBox.PlaceholderText = "Ketik Nama Area..."; AreaNameBox.Text = ""
AreaNameBox.TextColor3 = Color3.fromRGB(255, 255, 255); AreaNameBox.Font = Enum.Font.Gotham; AreaNameBox.TextSize = 11; AreaNameBox.Parent = SaveAreaCard
Instance.new("UICorner", AreaNameBox).CornerRadius = UDim.new(0, 6)

local SavePosBtn = Instance.new("TextButton")
SavePosBtn.Size = UDim2.new(0, 90, 0, 28); SavePosBtn.Position = UDim2.new(1, -104, 0.5, -14)
SavePosBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94); SavePosBtn.BorderSizePixel = 0
SavePosBtn.Text = "SAVE POS"; SavePosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SavePosBtn.Font = Enum.Font.GothamBold; SavePosBtn.TextSize = 11; SavePosBtn.Parent = SaveAreaCard
Instance.new("UICorner", SavePosBtn).CornerRadius = UDim.new(0, 6)
SavePosBtn.MouseEnter:Connect(function() SavePosBtn.BackgroundColor3 = Color3.fromRGB(22, 163, 74) end)
SavePosBtn.MouseLeave:Connect(function() SavePosBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94) end)

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

addSectionHeader(FbgTab, "Auto Leveling Config")

local LevCardGroup = Instance.new("Frame")
LevCardGroup.Size = UDim2.new(1, -10, 0, 114); LevCardGroup.BackgroundColor3 = Color3.fromRGB(24, 26, 36); LevCardGroup.BorderSizePixel = 0; LevCardGroup.Parent = FbgTab
Instance.new("UICorner", LevCardGroup).CornerRadius = UDim.new(0, 8)
local strokeL = Instance.new("UIStroke", LevCardGroup); strokeL.Color = Color3.fromRGB(255,255,255); strokeL.Transparency = 0.92; strokeL.Thickness = 1
local padL = Instance.new("UIPadding", LevCardGroup); padL.PaddingLeft = UDim.new(0,14); padL.PaddingRight = UDim.new(0,14); padL.PaddingTop = UDim.new(0,10); padL.PaddingBottom = UDim.new(0,10)

local LevGroupTitle = Instance.new("TextLabel")
LevGroupTitle.Size = UDim2.new(1, -20, 0, 20); LevGroupTitle.Position = UDim2.new(0, 0, 0, 0)
LevGroupTitle.BackgroundTransparency = 1; LevGroupTitle.Text = "LEVELING SAFE POSITION MODE"
LevGroupTitle.TextColor3 = Color3.fromRGB(96, 115, 150); LevGroupTitle.Font = Enum.Font.GothamBold; LevGroupTitle.TextSize = 10; LevGroupTitle.TextXAlignment = Enum.TextXAlignment.Left; LevGroupTitle.Parent = LevCardGroup

local modeButtons = {}
local function createModeOption(title, modeVal, posY)
    local mBtn = Instance.new("TextButton")
    mBtn.Size = UDim2.new(1, -20, 0, 26); mBtn.Position = UDim2.new(0, 0, 0, posY)
    mBtn.BackgroundColor3 = (levelingMode == modeVal) and Color3.fromRGB(59, 130, 246) or Color3.fromRGB(15, 18, 28)
    mBtn.BorderSizePixel = 0
    mBtn.Text = (levelingMode == modeVal and "✓ " or "") .. title
    mBtn.TextColor3 = (levelingMode == modeVal) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 195, 230)
    mBtn.Font = Enum.Font.GothamSemibold; mBtn.TextSize = 10; mBtn.Parent = LevCardGroup
    Instance.new("UICorner", mBtn).CornerRadius = UDim.new(0, 6)

    mBtn.MouseEnter:Connect(function() if levelingMode ~= modeVal then mBtn.BackgroundColor3 = Color3.fromRGB(25, 30, 45) end end)
    mBtn.MouseLeave:Connect(function() if levelingMode ~= modeVal then mBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 28) end end)

    modeButtons[modeVal] = { Btn = mBtn, Title = title }

    mBtn.MouseButton1Click:Connect(function()
        levelingMode = modeVal
        for mv, data in pairs(modeButtons) do
            if mv == levelingMode then
                data.Btn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
                data.Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                data.Btn.Text = "✓ " .. data.Title
            else
                data.Btn.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
                data.Btn.TextColor3 = Color3.fromRGB(180, 195, 230)
                data.Btn.Text = data.Title
            end
        end
    end)
end

createModeOption("Current Position (Berdiri Bebas)", "Current Position", 26)
createModeOption("Preset High Safe Spot (Melayang)", "Preset High Safe Spot", 56)
createModeOption("Selected Area (Ke Area Dipilih)", "Selected Area", 86)

addToggle(FbgTab, "Auto Leveling Engine", "Rotasi skill otomatis dengan Safety Fly Anchor", false, function(v) autoLevelingEnabled = v end)

local SkillCardContainer = Instance.new("Frame")
SkillCardContainer.Size = UDim2.new(1, -10, 0, 150); SkillCardContainer.BackgroundColor3 = Color3.fromRGB(24, 26, 36); SkillCardContainer.BorderSizePixel = 0; SkillCardContainer.Parent = FbgTab
Instance.new("UICorner", SkillCardContainer).CornerRadius = UDim.new(0, 8)
local strokeSk = Instance.new("UIStroke", SkillCardContainer); strokeSk.Color = Color3.fromRGB(255,255,255); strokeSk.Transparency = 0.92; strokeSk.Thickness = 1

local SkillScroll = Instance.new("ScrollingFrame")
SkillScroll.Size = UDim2.new(1, -12, 1, -12); SkillScroll.Position = UDim2.new(0, 6, 0, 6)
SkillScroll.BackgroundTransparency = 1; SkillScroll.BorderSizePixel = 0; SkillScroll.ScrollBarThickness = 4; SkillScroll.Parent = SkillCardContainer
local SkillLayout = Instance.new("UIListLayout", SkillScroll); SkillLayout.SortOrder = Enum.SortOrder.LayoutOrder; SkillLayout.Padding = UDim.new(0, 6)

local function updateFbgSkills()
    for _, child in ipairs(SkillScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    local backpack = LP:FindFirstChild("Backpack")
    local count = 0

    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                count = count + 1; local name = tool.Name
                if not skillConfigs[name] then skillConfigs[name] = { Enabled = true, Hold = false, Duration = 1.0 } end

                local card = Instance.new("Frame")
                card.Size = UDim2.new(1, -6, 0, 40); card.BackgroundColor3 = Color3.fromRGB(15, 18, 28); card.BorderSizePixel = 0; card.Parent = SkillScroll
                Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
                local padC = Instance.new("UIPadding", card); padC.PaddingLeft = UDim.new(0,10); padC.PaddingRight = UDim.new(0,10); padC.PaddingTop = UDim.new(0,6); padC.PaddingBottom = UDim.new(0,6)

                local nLbl = Instance.new("TextLabel")
                nLbl.Size = UDim2.new(0, 90, 1, 0); nLbl.Position = UDim2.new(0, 0, 0, 2)
                nLbl.BackgroundTransparency = 1; nLbl.Text = name; nLbl.TextColor3 = Color3.fromRGB(220, 230, 255)
                nLbl.Font = Enum.Font.GothamSemibold; nLbl.TextSize = 11; nLbl.TextXAlignment = Enum.TextXAlignment.Left; nLbl.Parent = card

                local stateBtn = Instance.new("TextButton")
                stateBtn.Size = UDim2.new(0, 42, 0, 24); stateBtn.Position = UDim2.new(1, -170, 0.5, -12)
                stateBtn.BackgroundColor3 = skillConfigs[name].Enabled and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(190, 50, 60)
                stateBtn.BorderSizePixel = 0; stateBtn.Text = skillConfigs[name].Enabled and "ON" or "OFF"
                stateBtn.TextColor3 = Color3.fromRGB(255, 255, 255); stateBtn.Font = Enum.Font.GothamBold; stateBtn.TextSize = 10; stateBtn.Parent = card
                Instance.new("UICorner", stateBtn).CornerRadius = UDim.new(0, 5)

                local holdBtn = Instance.new("TextButton")
                holdBtn.Size = UDim2.new(0, 64, 0, 24); holdBtn.Position = UDim2.new(1, -124, 0.5, -12)
                holdBtn.BackgroundColor3 = skillConfigs[name].Hold and Color3.fromRGB(59, 130, 246) or Color3.fromRGB(55, 65, 81)
                holdBtn.BorderSizePixel = 0; holdBtn.Text = skillConfigs[name].Hold and "Hold: ON" or "Hold: OFF"
                holdBtn.TextColor3 = Color3.fromRGB(255, 255, 255); holdBtn.Font = Enum.Font.GothamBold; holdBtn.TextSize = 9; holdBtn.Parent = card
                Instance.new("UICorner", holdBtn).CornerRadius = UDim.new(0, 5)

                local durInput = Instance.new("TextBox")
                durInput.Size = UDim2.new(0, 54, 0, 24); durInput.Position = UDim2.new(1, -66, 0.5, -12)
                durInput.BackgroundColor3 = Color3.fromRGB(16, 18, 28); durInput.BorderSizePixel = 0
                durInput.Text = tostring(skillConfigs[name].Duration) .. "s"; durInput.TextColor3 = Color3.fromRGB(255, 220, 100)
                durInput.Font = Enum.Font.GothamBold; durInput.TextSize = 10; durInput.Parent = card
                Instance.new("UICorner", durInput).CornerRadius = UDim.new(0, 5)

                stateBtn.MouseButton1Click:Connect(function()
                    skillConfigs[name].Enabled = not skillConfigs[name].Enabled
                    stateBtn.Text = skillConfigs[name].Enabled and "ON" or "OFF"
                    stateBtn.BackgroundColor3 = skillConfigs[name].Enabled and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(190, 50, 60)
                end)
                holdBtn.MouseButton1Click:Connect(function()
                    skillConfigs[name].Hold = not skillConfigs[name].Hold
                    holdBtn.Text = skillConfigs[name].Hold and "Hold: ON" or "Hold: OFF"
                    holdBtn.BackgroundColor3 = skillConfigs[name].Hold and Color3.fromRGB(59, 130, 246) or Color3.fromRGB(55, 65, 81)
                end)
                durInput.FocusLost:Connect(function()
                    local val = tonumber(string.match(durInput.Text, "%d+%.?%d*"))
                    if val then skillConfigs[name].Duration = val; durInput.Text = tostring(val) .. "s" else durInput.Text = tostring(skillConfigs[name].Duration) .. "s" end
                end)
            end
        end
    end
    SkillScroll.CanvasSize = UDim2.new(0, 0, 0, count * 46)
end

updateFbgSkills()
table.insert(connections, LP.Backpack.ChildAdded:Connect(updateFbgSkills))
table.insert(connections, LP.Backpack.ChildRemoved:Connect(updateFbgSkills))

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
JoinBoxFrame.Size = UDim2.new(1, -10, 0, 46); JoinBoxFrame.BackgroundColor3 = Color3.fromRGB(24, 26, 36); JoinBoxFrame.BorderSizePixel = 0; JoinBoxFrame.Parent = ServerTab
Instance.new("UICorner", JoinBoxFrame).CornerRadius = UDim.new(0, 8)
local strokeJ = Instance.new("UIStroke", JoinBoxFrame); strokeJ.Color = Color3.fromRGB(255,255,255); strokeJ.Transparency = 0.92; strokeJ.Thickness = 1
local padJ = Instance.new("UIPadding", JoinBoxFrame); padJ.PaddingLeft = UDim.new(0,14); padJ.PaddingRight = UDim.new(0,14); padJ.PaddingTop = UDim.new(0,8); padJ.PaddingBottom = UDim.new(0,8)

local JobInput = Instance.new("TextBox")
JobInput.Size = UDim2.new(0.65, 0, 0, 28); JobInput.Position = UDim2.new(0, 0, 0.5, -14)
JobInput.BackgroundColor3 = Color3.fromRGB(15, 18, 28); JobInput.BorderSizePixel = 0
JobInput.PlaceholderText = "Paste JobID Here..."; JobInput.Text = ""
JobInput.TextColor3 = Color3.fromRGB(255, 255, 255); JobInput.Font = Enum.Font.Gotham; JobInput.TextSize = 11; JobInput.Parent = JoinBoxFrame
Instance.new("UICorner", JobInput).CornerRadius = UDim.new(0, 6)

local JoinBtn = Instance.new("TextButton")
JoinBtn.Size = UDim2.new(0, 75, 0, 28); JoinBtn.Position = UDim2.new(1, -89, 0.5, -14)
JoinBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246); JoinBtn.BorderSizePixel = 0
JoinBtn.Text = "JOIN"; JoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JoinBtn.Font = Enum.Font.GothamBold; JoinBtn.TextSize = 11; JoinBtn.Parent = JoinBoxFrame
Instance.new("UICorner", JoinBtn).CornerRadius = UDim.new(0, 6)
JoinBtn.MouseEnter:Connect(function() JoinBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235) end)
JoinBtn.MouseLeave:Connect(function() JoinBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246) end)
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
--  EXECUTION LOOPS & OPTIMIZED AUTO LEVELING
-- ============================================================

local function isSkillReady(skillName)
    local cdFolder = LP:FindFirstChild("Cooldowns")
    if cdFolder then
        local cdObj = cdFolder:FindFirstChild(skillName)
        if cdObj and cdObj.Value > 0 then return false end
    end
    return true
end

-- Fungsi Aktivasi Skill yang Lebih Aman & Stabil
local function useSkill(tool, hold, duration)
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or not tool or not tool.Parent then return end
    
    pcall(function()
        hum:EquipTool(tool)
        task.wait(0.15)
        
        if hold then
            tool:Activate()
            task.wait(duration)
            tool:Deactivate()
        else
            tool:Activate()
            task.wait(0.1)
            tool:Deactivate()
        end
        
        task.wait(0.2)
        hum:UnequipTools()
    end)
end

local function enforceSafetyAnchor()
    local char = LP.Character
    local myHrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not myHrp or not hum then return end

    if levelingMode ~= "Current Position" then
        local bv = myHrp:FindFirstChild("_CyLevBV") or Instance.new("BodyVelocity")
        bv.Name = "_CyLevBV"
        bv.Velocity = Vector3.zero
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Parent = myHrp
        hum.PlatformStand = true

        if levelingMode == "Preset High Safe Spot" then
            myHrp.CFrame = presetSafeCFrame
        elseif levelingMode == "Selected Area" and selectedArea then
            if typeof(selectedArea) == "CFrame" then
                myHrp.CFrame = selectedArea
            elseif typeof(selectedArea) == "Instance" then
                if selectedArea:IsA("BasePart") then myHrp.CFrame = selectedArea.CFrame * CFrame.new(0, 5, 0)
                elseif selectedArea:IsA("Model") then myHrp.CFrame = selectedArea:GetPivot() * CFrame.new(0, 5, 0) end
            end
        end
    else
        if myHrp:FindFirstChild("_CyLevBV") then myHrp._CyLevBV:Destroy() end
        if not flyEnabled then hum.PlatformStand = false end
    end
end

-- Auto Leveling Loop Engine (DIPERBAIKI)
task.spawn(function()
    while task.wait(0.5) do
        if autoLevelingEnabled then
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local backpack = LP:FindFirstChild("Backpack")
            
            -- Safety check: Jangan jalankan jika karakter mati atau tidak ada
            if not char or not hum or hum.Health <= 0 then 
                task.wait(1)
                continue 
            end

            enforceSafetyAnchor()
            task.wait(0.1)

            local toolsToUse = {}
            
            -- Kumpulkan skill dari Backpack
            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        local name = tool.Name
                        local cfg = skillConfigs[name] or { Enabled = true, Hold = false, Duration = 1.0 }
                        if cfg.Enabled and isSkillReady(name) then
                            table.insert(toolsToUse, { tool = tool, cfg = cfg })
                        end
                    end
                end
            end
            
            -- Kumpulkan skill yang sudah ter-equip di Karakter
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    local name = tool.Name
                    local cfg = skillConfigs[name] or { Enabled = true, Hold = false, Duration = 1.0 }
                    if cfg.Enabled and isSkillReady(name) then
                        table.insert(toolsToUse, { tool = tool, cfg = cfg })
                    end
                end
            end

            -- Eksekusi skill satu per satu dengan delay aman
            for _, item in ipairs(toolsToUse) do
                if not autoLevelingEnabled then break end
                useSkill(item.tool, item.cfg.Hold, item.cfg.Duration)
                task.wait(0.3) -- Delay antar skill untuk mencegah spam error
            end
        else
            -- Hapus Anti-Gravity Lock saat leveling mati
            local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if myHrp and myHrp:FindFirstChild("_CyLevBV") then 
                myHrp._CyLevBV:Destroy() 
            end
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum and not flyEnabled then 
                hum.PlatformStand = false 
            end
        end
    end
end)

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

    -- Player ESP
    for plr, data in pairs(espObjects) do
        local char = plr.Character; local isAnyEspOn = universalEspEnabled or fbgEspEnabled
        if isAnyEspOn and char and char:FindFirstChild("Head") then
            local hum = char:FindFirstChildOfClass("Humanoid"); local root = char:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 then
                data.Billboard.Adornee = char.Head; data.Billboard.Enabled = true; data.Highlight.Adornee = char; data.Highlight.Enabled = true

                if fbgEspEnabled then
                    data.FruitLbl.Visible = true; data.LevelLbl.Visible = true; data.DistLbl.Visible = true; data.HealthBg.Visible = true
                    local activeFruit, fruitLevel = getExactFruitAndLevel(plr)
                    data.FruitLbl.Text = "Fruit: " .. activeFruit
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
    local highlight  = Instance.new("Highlight"); highlight.Name = "_CyChams_" .. plr.Name; highlight.FillColor = Color3.fromRGB(59, 130, 246); highlight.OutlineColor = Color3.fromRGB(59, 130, 246); highlight.FillTransparency = 0.6
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

-- Global Two-Way Keyboard & UI Switch Sync Engine
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
    autoLevelingEnabled = false; autoAimEnabled = false; universalEspEnabled = false; fbgEspEnabled = false; npcEspEnabled = false; antiAfkEnabled = false
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

    local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if myHrp and myHrp:FindFirstChild("_CyLevBV") then myHrp._CyLevBV:Destroy() end

    SG:Destroy()
    print("[CyRuZzz Hub] Full Unloaded Successfully!")
end)

MainLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() tabs["Universal"].Page.CanvasSize = UDim2.new(0, 0, 0, MainLayout.AbsoluteContentSize.Y + 20) end)
FbgLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() tabs["Fruit BG"].Page.CanvasSize = UDim2.new(0, 0, 0, FbgLayout.AbsoluteContentSize.Y + 20) end)
ServerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() tabs["Server"].Page.CanvasSize = UDim2.new(0, 0, 0, ServerLayout.AbsoluteContentSize.Y + 20) end)

print("[CyRuZzz Universal Hub] Modernized & Auto Leveling Optimized Ready!")
