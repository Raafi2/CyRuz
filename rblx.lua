-- ============================================================
--  CyRuZzz Universal & Game-Specific Hub
--  GitHub Deployment Edition (Complete Cleanup & Feature Fix)
-- ============================================================

local Players              = game:GetService("Players")
local RunService           = game:GetService("RunService")
local UserInputService     = game:GetService("UserInputService")
local TeleportService      = game:GetService("TeleportService")
local HttpService          = game:GetService("HttpService")
local VirtualUser          = game:GetService("VirtualUser")
local VirtualInputManager  = game:GetService("VirtualInputManager")
local ReplicatedStorage    = game:GetService("ReplicatedStorage")

local LP                   = Players.LocalPlayer
local Camera               = workspace.CurrentCamera
local PlayerGui            = LP:WaitForChild("PlayerGui")

-- Global States
local universalEspEnabled  = false
local fbgEspEnabled        = false
local autoLevelingEnabled  = false
local autoAimEnabled       = false
local antiAfkEnabled       = true

local espObjects           = {}
local skillConfigs         = {}
local connections          = {}

local ReplicatorNoYield = ReplicatedStorage:FindFirstChild("ReplicatorNoYield")

-- Clean Up Old Instances
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

-- Floating Mini Logo (Widget Saat UI Dikecilkan)
local MiniWidget = Instance.new("Frame")
MiniWidget.Name                   = "MiniWidget"
MiniWidget.Size                   = UDim2.new(0, 48, 0, 48)
MiniWidget.Position               = UDim2.new(0, 20, 0.5, -24)
MiniWidget.BackgroundColor3       = Color3.fromRGB(20, 24, 38)
MiniWidget.BorderSizePixel        = 0
MiniWidget.Active                 = true
MiniWidget.Draggable              = true
MiniWidget.Visible                = false
MiniWidget.Parent                 = SG
Instance.new("UICorner", MiniWidget).CornerRadius = UDim.new(1, 0)

local miniStroke = Instance.new("UIStroke")
miniStroke.Color = Color3.fromRGB(0, 170, 255); miniStroke.Thickness = 2; miniStroke.Parent = MiniWidget

local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(1, 0, 1, 0); MiniBtn.BackgroundTransparency = 1; MiniBtn.Text = "C"
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255); MiniBtn.Font = Enum.Font.GothamBold; MiniBtn.TextSize = 22
MiniBtn.Parent = MiniWidget

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name                   = "MainFrame"
MainFrame.Size                   = UDim2.new(0, 580, 0, 390)
MainFrame.Position               = UDim2.new(0.5, -290, 0.5, -195)
MainFrame.BackgroundColor3       = Color3.fromRGB(15, 17, 26)
MainFrame.BorderSizePixel        = 0
MainFrame.Active                 = true
MainFrame.Draggable              = true
MainFrame.Parent                 = SG
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(45, 55, 85); mainStroke.Thickness = 1; mainStroke.Parent = MainFrame

-- Top Bar Header
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38); TopBar.BackgroundColor3 = Color3.fromRGB(22, 26, 40)
TopBar.BorderSizePixel = 0; TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local BrandTitle = Instance.new("TextLabel")
BrandTitle.Size = UDim2.new(0, 200, 1, 0); BrandTitle.Position = UDim2.new(0, 14, 0, 0)
BrandTitle.BackgroundTransparency = 1; BrandTitle.Text = "CYRUZZZ HUB  ✦"
BrandTitle.TextColor3 = Color3.fromRGB(0, 170, 255); BrandTitle.Font = Enum.Font.GothamBold; BrandTitle.TextSize = 13
BrandTitle.TextXAlignment = Enum.TextXAlignment.Left; BrandTitle.Parent = TopBar

-- Minimize Button (-)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 26, 0, 26); MinimizeBtn.Position = UDim2.new(1, -62, 0.5, -13)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 42, 65); MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "-"; MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); MinimizeBtn.Font = Enum.Font.GothamBold; MinimizeBtn.TextSize = 14
MinimizeBtn.Parent = TopBar
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

-- Close Button (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26); CloseBtn.Position = UDim2.new(1, -32, 0.5, -13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(210, 45, 65); CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "×"; CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Control Navigation Logic
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniWidget.Visible = true
end)

MiniBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MiniWidget.Visible = false
end)

-- Sidebar Navigation Setup
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -38); Sidebar.Position = UDim2.new(0, 0, 0, 38)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 21, 32); Sidebar.BorderSizePixel = 0; Sidebar.Parent = MainFrame

local SideLayout = Instance.new("UIListLayout")
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder; SideLayout.Padding = UDim.new(0, 4); SideLayout.Parent = Sidebar
local SidePadding = Instance.new("UIPadding"); SidePadding.PaddingTop = UDim.new(0, 8); SidePadding.PaddingLeft = UDim.new(0, 8); SidePadding.Parent = Sidebar

local ContentFolder = Instance.new("Frame")
ContentFolder.Size = UDim2.new(1, -140, 1, -38); ContentFolder.Position = UDim2.new(0, 140, 0, 38)
ContentFolder.BackgroundTransparency = 1; ContentFolder.Parent = MainFrame

-- ============================================================
--  TAB NAVIGATION CONTROLLER
-- ============================================================
local tabs = {}
local function createTab(name, icon)
    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Size = UDim2.new(1, -16, 1, -16); TabPage.Position = UDim2.new(0, 8, 0, 8)
    TabPage.BackgroundTransparency = 1; TabPage.BorderSizePixel = 0; TabPage.Visible = false
    TabPage.ScrollBarThickness = 3; TabPage.CanvasSize = UDim2.new(0, 0, 0, 0); TabPage.Parent = ContentFolder

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder; PageLayout.Padding = UDim.new(0, 8); PageLayout.Parent = TabPage

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 124, 0, 32); TabBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
    TabBtn.BorderSizePixel = 0; TabBtn.Text = icon .. "  " .. name; TabBtn.TextColor3 = Color3.fromRGB(160, 175, 210)
    TabBtn.Font = Enum.Font.GothamSemibold; TabBtn.TextSize = 10; TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, 10); p.Parent = TabBtn

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Page.Visible = false
            t.Btn.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
            t.Btn.TextColor3 = Color3.fromRGB(160, 175, 210)
        end
        TabPage.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    tabs[name] = { Page = TabPage, Btn = TabBtn, Layout = PageLayout }
    return TabPage, PageLayout
end

local MainTab, MainLayout     = createTab("Universal", "🌐")
local FbgTab, FbgLayout       = createTab("Fruit BG", "🍎")
local ServerTab, ServerLayout = createTab("Server", "⚡")

tabs["Universal"].Page.Visible = true
tabs["Universal"].Btn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
tabs["Universal"].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- ============================================================
--  COMPONENTS BUILDER
-- ============================================================
local function addSectionHeader(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 20); lbl.BackgroundTransparency = 1
    lbl.Text = "— " .. string.upper(text) .. " —"; lbl.TextColor3 = Color3.fromRGB(100, 120, 170)
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 9; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = parent
end

local function addToggle(parent, title, desc, defaultState, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -10, 0, 42); card.BackgroundColor3 = Color3.fromRGB(22, 26, 40); card.BorderSizePixel = 0; card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(0.7, 0, 0, 18); tLbl.Position = UDim2.new(0, 10, 0, 4); tLbl.BackgroundTransparency = 1
    tLbl.Text = title; tLbl.TextColor3 = Color3.fromRGB(240, 245, 255); tLbl.Font = Enum.Font.GothamSemibold; tLbl.TextSize = 11; tLbl.TextXAlignment = Enum.TextXAlignment.Left; tLbl.Parent = card

    local dLbl = Instance.new("TextLabel")
    dLbl.Size = UDim2.new(0.7, 0, 0, 14); dLbl.Position = UDim2.new(0, 10, 0, 22); dLbl.BackgroundTransparency = 1
    dLbl.Text = desc; dLbl.TextColor3 = Color3.fromRGB(110, 125, 160); dLbl.Font = Enum.Font.Gotham; dLbl.TextSize = 9; dLbl.TextXAlignment = Enum.TextXAlignment.Left; dLbl.Parent = card

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 48, 0, 22); btn.Position = UDim2.new(1, -58, 0.5, -11)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(45, 180, 90) or Color3.fromRGB(45, 50, 75)
    btn.BorderSizePixel = 0; btn.Text = defaultState and "ON" or "OFF"; btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 9; btn.Parent = card
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(45, 180, 90) or Color3.fromRGB(45, 50, 75)
        callback(state)
    end)
end

local function addButton(parent, title, btnText, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -10, 0, 40); card.BackgroundColor3 = Color3.fromRGB(22, 26, 40); card.BorderSizePixel = 0; card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(0.6, 0, 1, 0); tLbl.Position = UDim2.new(0, 10, 0, 0); tLbl.BackgroundTransparency = 1
    tLbl.Text = title; tLbl.TextColor3 = Color3.fromRGB(240, 245, 255); tLbl.Font = Enum.Font.GothamSemibold; tLbl.TextSize = 11; tLbl.TextXAlignment = Enum.TextXAlignment.Left; tLbl.Parent = card

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 0, 24); btn.Position = UDim2.new(1, -100, 0.5, -12)
    btn.BackgroundColor3 = Color3.fromRGB(0, 140, 255); btn.BorderSizePixel = 0; btn.Text = btnText; btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 9; btn.Parent = card
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(callback)
end

-- ============================================================
--  1. UNIVERSAL TAB
-- ============================================================
addSectionHeader(MainTab, "Universal Visuals")
addToggle(MainTab, "Universal ESP", "Hanya menampilkan Nama & Body Highlight player", false, function(v)
    universalEspEnabled = v
end)

-- ============================================================
--  2. FRUIT BATTLEGROUNDS TAB
-- ============================================================
addSectionHeader(FbgTab, "Combat & Target")
addToggle(FbgTab, "Auto Aim (Gyro Lock)", "Otomatis mengunci arah ke musuh terdekat", false, function(v)
    autoAimEnabled = v
end)

addSectionHeader(FbgTab, "FBG Specific ESP")
addToggle(FbgTab, "Fruit & Level ESP", "Menampilkan Nama, Body, Darah, Jarak, Buah & Level", false, function(v)
    fbgEspEnabled = v
end)

addSectionHeader(FbgTab, "Auto Leveling Config")
addToggle(FbgTab, "Auto Leveling Engine", "Rotasi skill otomatis di luar safezone", false, function(v)
    autoLevelingEnabled = v
end)

local SkillCardContainer = Instance.new("Frame")
SkillCardContainer.Size = UDim2.new(1, -10, 0, 160); SkillCardContainer.BackgroundColor3 = Color3.fromRGB(20, 24, 38); SkillCardContainer.BorderSizePixel = 0; SkillCardContainer.Parent = FbgTab
Instance.new("UICorner", SkillCardContainer).CornerRadius = UDim.new(0, 6)

local SkillScroll = Instance.new("ScrollingFrame")
SkillScroll.Size = UDim2.new(1, -8, 1, -8); SkillScroll.Position = UDim2.new(0, 4, 0, 4)
SkillScroll.BackgroundTransparency = 1; SkillScroll.BorderSizePixel = 0; SkillScroll.ScrollBarThickness = 3; SkillScroll.Parent = SkillCardContainer

local SkillLayout = Instance.new("UIListLayout")
SkillLayout.SortOrder = Enum.SortOrder.LayoutOrder; SkillLayout.Padding = UDim.new(0, 4); SkillLayout.Parent = SkillScroll

local function updateFbgSkills()
    for _, child in ipairs(SkillScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local backpack = LP:FindFirstChild("Backpack")
    local count = 0

    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                count = count + 1
                local name = tool.Name

                if not skillConfigs[name] then
                    skillConfigs[name] = { Enabled = true, Hold = false, Duration = 1.0 }
                end

                local card = Instance.new("Frame")
                card.Size = UDim2.new(1, -6, 0, 38); card.BackgroundColor3 = Color3.fromRGB(28, 33, 50); card.BorderSizePixel = 0; card.Parent = SkillScroll
                Instance.new("UICorner", card).CornerRadius = UDim.new(0, 5)

                local nLbl = Instance.new("TextLabel")
                nLbl.Size = UDim2.new(0, 80, 1, 0); nLbl.Position = UDim2.new(0, 8, 0, 0); nLbl.BackgroundTransparency = 1
                nLbl.Text = name; nLbl.TextColor3 = Color3.fromRGB(220, 230, 255); nLbl.Font = Enum.Font.GothamSemibold; nLbl.TextSize = 10; nLbl.TextXAlignment = Enum.TextXAlignment.Left; nLbl.Parent = card

                local stateBtn = Instance.new("TextButton")
                stateBtn.Size = UDim2.new(0, 40, 0, 22); stateBtn.Position = UDim2.new(1, -165, 0.5, -11)
                stateBtn.BackgroundColor3 = skillConfigs[name].Enabled and Color3.fromRGB(45, 180, 90) or Color3.fromRGB(190, 50, 60)
                stateBtn.BorderSizePixel = 0; stateBtn.Text = skillConfigs[name].Enabled and "ON" or "OFF"; stateBtn.TextColor3 = Color3.fromRGB(255, 255, 255); stateBtn.Font = Enum.Font.GothamBold; stateBtn.TextSize = 9; stateBtn.Parent = card
                Instance.new("UICorner", stateBtn).CornerRadius = UDim.new(0, 4)

                local holdBtn = Instance.new("TextButton")
                holdBtn.Size = UDim2.new(0, 60, 0, 22); holdBtn.Position = UDim2.new(1, -120, 0.5, -11)
                holdBtn.BackgroundColor3 = skillConfigs[name].Hold and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 50, 75)
                holdBtn.BorderSizePixel = 0; holdBtn.Text = skillConfigs[name].Hold and "Hold: ON" or "Hold: OFF"; holdBtn.TextColor3 = Color3.fromRGB(255, 255, 255); holdBtn.Font = Enum.Font.GothamBold; holdBtn.TextSize = 9; holdBtn.Parent = card
                Instance.new("UICorner", holdBtn).CornerRadius = UDim.new(0, 4)

                local durInput = Instance.new("TextBox")
                durInput.Size = UDim2.new(0, 50, 0, 22); durInput.Position = UDim2.new(1, -55, 0.5, -11)
                durInput.BackgroundColor3 = Color3.fromRGB(16, 18, 28); durInput.BorderSizePixel = 0
                durInput.Text = tostring(skillConfigs[name].Duration) .. "s"; durInput.TextColor3 = Color3.fromRGB(255, 220, 100); durInput.Font = Enum.Font.GothamBold; durInput.TextSize = 10; durInput.Parent = card
                Instance.new("UICorner", durInput).CornerRadius = UDim.new(0, 4)

                stateBtn.MouseButton1Click:Connect(function()
                    skillConfigs[name].Enabled = not skillConfigs[name].Enabled
                    stateBtn.Text = skillConfigs[name].Enabled and "ON" or "OFF"
                    stateBtn.BackgroundColor3 = skillConfigs[name].Enabled and Color3.fromRGB(45, 180, 90) or Color3.fromRGB(190, 50, 60)
                end)

                holdBtn.MouseButton1Click:Connect(function()
                    skillConfigs[name].Hold = not skillConfigs[name].Hold
                    holdBtn.Text = skillConfigs[name].Hold and "Hold: ON" or "Hold: OFF"
                    holdBtn.BackgroundColor3 = skillConfigs[name].Hold and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 50, 75)
                end)

                durInput.FocusLost:Connect(function()
                    local val = tonumber(string.match(durInput.Text, "%d+%.?%d*"))
                    if val then skillConfigs[name].Duration = val; durInput.Text = tostring(val) .. "s" else durInput.Text = tostring(skillConfigs[name].Duration) .. "s" end
                end)
            end
        end
    end
    SkillScroll.CanvasSize = UDim2.new(0, 0, 0, count * 42)
end

updateFbgSkills()
table.insert(connections, LP.Backpack.ChildAdded:Connect(updateFbgSkills))
table.insert(connections, LP.Backpack.ChildRemoved:Connect(updateFbgSkills))

-- ============================================================
--  3. SERVER TAB
-- ============================================================
addSectionHeader(ServerTab, "Anti AFK & Reconnect")
addToggle(ServerTab, "Anti-AFK Protection", "Mencegah mencederai koneksi saat AFK lama", true, function(v)
    antiAfkEnabled = v
end)

table.insert(connections, LP.Idled:Connect(function()
    if antiAfkEnabled then
        VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
    end
end))

addSectionHeader(ServerTab, "Server Management")

addButton(ServerTab, "Copy Current JobID", "COPY", function()
    if setclipboard then
        setclipboard(game.JobId)
        print("[CyRuZzz] JobID copied!")
    end
end)

local JoinBoxFrame = Instance.new("Frame")
JoinBoxFrame.Size = UDim2.new(1, -10, 0, 42); JoinBoxFrame.BackgroundColor3 = Color3.fromRGB(22, 26, 40); JoinBoxFrame.BorderSizePixel = 0; JoinBoxFrame.Parent = ServerTab
Instance.new("UICorner", JoinBoxFrame).CornerRadius = UDim.new(0, 6)

local JobInput = Instance.new("TextBox")
JobInput.Size = UDim2.new(0.65, 0, 0, 26); JobInput.Position = UDim2.new(0, 10, 0.5, -13)
JobInput.BackgroundColor3 = Color3.fromRGB(15, 18, 28); JobInput.BorderSizePixel = 0
JobInput.PlaceholderText = "Paste JobID Here..."; JobInput.Text = ""; JobInput.TextColor3 = Color3.fromRGB(255, 255, 255)
JobInput.Font = Enum.Font.Gotham; JobInput.TextSize = 10; JobInput.Parent = JoinBoxFrame
Instance.new("UICorner", JobInput).CornerRadius = UDim.new(0, 5)

local JoinBtn = Instance.new("TextButton")
JoinBtn.Size = UDim2.new(0, 75, 0, 26); JoinBtn.Position = UDim2.new(1, -85, 0.5, -13)
JoinBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255); JoinBtn.BorderSizePixel = 0; JoinBtn.Text = "JOIN"; JoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JoinBtn.Font = Enum.Font.GothamBold; JoinBtn.TextSize = 10; JoinBtn.Parent = JoinBoxFrame
Instance.new("UICorner", JoinBtn).CornerRadius = UDim.new(0, 5)

JoinBtn.MouseButton1Click:Connect(function()
    if JobInput.Text ~= "" then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, JobInput.Text, LP)
    end
end)

addButton(ServerTab, "Server Hop (Random)", "HOP", function()
    local placeId = game.PlaceId
    local servers = {}
    local req = request or http_request or (syn and syn.request)

    if req then
        local res = req({ Url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100" })
        local body = HttpService:JSONDecode(res.Body)
        if body and body.data then
            for _, v in ipairs(body.data) do
                if type(v) == "table" and v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(servers, v.id)
                end
            end
        end
    end

    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], LP)
    else
        TeleportService:Teleport(placeId, LP)
    end
end)

-- ============================================================
--  EXECUTION LOOPS (AUTO AIM, ESP, AUTO LEVELING)
-- ============================================================
local function getClosestEnemy()
    local closestPlr = nil
    local shortestDist = math.huge
    local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

    if myHrp then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                local eChar = plr.Character
                local eHrp = eChar and eChar:FindFirstChild("HumanoidRootPart")
                local eHum = eChar and eChar:FindFirstChildOfClass("Humanoid")

                if eHrp and eHum and eHum.Health > 0 then
                    local dist = (myHrp.Position - eHrp.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestPlr = plr
                    end
                end
            end
        end
    end
    return closestPlr
end

-- RenderStepped Main Loop (Auto Aim & ESP)
table.insert(connections, RunService.RenderStepped:Connect(function()
    local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

    -- 1. FBG Auto Aim
    if autoAimEnabled and myHrp then
        local targetPlr = getClosestEnemy()
        if targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart") then
            local targetHrp = targetPlr.Character.HumanoidRootPart
            myHrp.CFrame = CFrame.lookAt(myHrp.Position, Vector3.new(targetHrp.Position.X, myHrp.Position.Y, targetHrp.Position.Z))
            if ReplicatorNoYield then
                pcall(function()
                    ReplicatorNoYield:FireServer("Effects", "GyroAim", {
                        HitLocation = targetHrp.Position,
                        Target = targetHrp
                    })
                end)
            end
        end
    end

    -- 2. ESP Updates
    for plr, data in pairs(espObjects) do
        local char = plr.Character
        local isAnyEspOn = universalEspEnabled or fbgEspEnabled

        if isAnyEspOn and char and char:FindFirstChild("Head") then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")

            if hum and hum.Health > 0 then
                data.Billboard.Adornee = char.Head; data.Billboard.Enabled = true
                data.Highlight.Adornee = char; data.Highlight.Enabled = true

                if fbgEspEnabled then
                    data.FruitLbl.Visible = true; data.LevelLbl.Visible = true
                    data.DistLbl.Visible = true; data.HealthBg.Visible = true

                    local mainData = plr:FindFirstChild("MAIN_DATA")
                    local fruitName, levelVal = "N/A", "N/A"
                    if mainData and mainData:FindFirstChild("Fruits") then
                        local activeObj = mainData.Fruits:GetChildren()[1]
                        if activeObj then
                            fruitName = activeObj.Name
                            local lvl = activeObj:FindFirstChild("Level")
                            if lvl then levelVal = tostring(math.floor(lvl.Value)) end
                        end
                    end

                    data.FruitLbl.Text = "Fruit: " .. fruitName
                    data.LevelLbl.Text = "Level: " .. levelVal
                    if myHrp and root then
                        data.DistLbl.Text = math.floor((myHrp.Position - root.Position).Magnitude) .. " studs"
                    end
                    local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    data.HealthFill.Size = UDim2.new(hp, -2, 1, -2)
                else
                    data.FruitLbl.Visible = false; data.LevelLbl.Visible = false
                    data.DistLbl.Visible = false; data.HealthBg.Visible = false
                end
            else
                data.Billboard.Enabled = false; data.Highlight.Enabled = false
            end
        else
            data.Billboard.Enabled = false; data.Highlight.Enabled = false
        end
    end
end))

-- ESP Management
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

    local layout = Instance.new("UIListLayout", holder)
    layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.Padding = UDim.new(0, 1)

    local function makeLbl(col, size)
        local l = Instance.new("TextLabel", holder)
        l.Size = UDim2.new(1,0,0,14); l.BackgroundTransparency = 1; l.TextColor3 = col; l.TextStrokeTransparency = 0.2; l.Font = Enum.Font.GothamBold; l.TextSize = size
        return l
    end

    local nameLbl   = makeLbl(Color3.fromRGB(255,255,255), 12); nameLbl.Text = plr.Name
    local fruitLbl  = makeLbl(Color3.fromRGB(0,255,255), 11); fruitLbl.Visible = false
    local levelLbl  = makeLbl(Color3.fromRGB(255,220,0), 11); levelLbl.Visible = false
    local distLbl   = makeLbl(Color3.fromRGB(200,200,200), 10); distLbl.Visible = false

    local healthBg   = Instance.new("Frame", holder); healthBg.Size = UDim2.new(0,100,0,8); healthBg.BackgroundColor3 = Color3.fromRGB(0,0,0); healthBg.BorderSizePixel = 0; healthBg.Visible = false
    local healthFill = Instance.new("Frame", healthBg); healthFill.Size = UDim2.new(1,-2,1,-2); healthFill.Position = UDim2.new(0,1,0,1); healthFill.BackgroundColor3 = Color3.fromRGB(0,255,0); healthFill.BorderSizePixel = 0

    local highlight  = Instance.new("Highlight")
    highlight.Name   = "_CyChams_" .. plr.Name; highlight.FillColor = Color3.fromRGB(0, 170, 255); highlight.OutlineColor = Color3.fromRGB(0, 170, 255); highlight.FillTransparency = 0.5

    holder.Parent = PlayerGui; highlight.Parent = PlayerGui

    espObjects[plr] = {
        Billboard = holder, Highlight = highlight, NameLbl = nameLbl,
        FruitLbl = fruitLbl, LevelLbl = levelLbl, DistLbl = distLbl,
        HealthBg = healthBg, HealthFill = healthFill
    }
end

table.insert(connections, Players.PlayerAdded:Connect(createEsp))
table.insert(connections, Players.PlayerRemoving:Connect(removeEsp))
for _, p in ipairs(Players:GetPlayers()) do createEsp(p) end

-- FBG Auto Leveling Loop
local function isSkillReady(skillName)
    local cdFolder = LP:FindFirstChild("Cooldowns")
    if cdFolder then
        local cdObj = cdFolder:FindFirstChild(skillName)
        if cdObj and cdObj.Value > 0 then return false end
    end
    return true
end

task.spawn(function()
    while task.wait(0.3) do
        if autoLevelingEnabled then
            local backpack = LP:FindFirstChild("Backpack")
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if backpack and hum then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if not autoLevelingEnabled then break end

                    if tool:IsA("Tool") and not tool:GetAttribute("Locked") then
                        local name = tool.Name
                        local cfg = skillConfigs[name] or { Enabled = true, Hold = false, Duration = 1.0 }

                        if cfg.Enabled and isSkillReady(name) then
                            hum:EquipTool(tool)
                            task.wait(0.15)

                            local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                            if cfg.Hold then
                                VirtualInputManager:SendMouseButtonEvent(centerPos.X, centerPos.Y, 0, true, game, 1)
                                task.wait(cfg.Duration)
                                VirtualInputManager:SendMouseButtonEvent(centerPos.X, centerPos.Y, 0, false, game, 1)
                            else
                                VirtualInputManager:SendMouseButtonEvent(centerPos.X, centerPos.Y, 0, true, game, 1)
                                task.wait(0.05)
                                VirtualInputManager:SendMouseButtonEvent(centerPos.X, centerPos.Y, 0, false, game, 1)
                            end

                            task.wait(0.2)
                            hum:UnequipTools()
                            task.wait(0.3)
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
--  TOTAL CLOSE HANDLER (SERTA DISCONNECT CONNS)
-- ============================================================
CloseBtn.MouseButton1Click:Connect(function()
    autoLevelingEnabled = false
    autoAimEnabled = false
    universalEspEnabled = false
    fbgEspEnabled = false
    antiAfkEnabled = false

    for _, conn in ipairs(connections) do
        if conn and conn.Connected then conn:Disconnect() end
    end
    table.clear(connections)

    for plr, _ in pairs(espObjects) do removeEsp(plr) end
    table.clear(espObjects)

    SG:Destroy()
    print("[CyRuZzz Hub] Completely Closed & Unloaded!")
end)

-- Adjust Dynamic Canvas
MainLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    tabs["Universal"].Page.CanvasSize = UDim2.new(0, 0, 0, MainLayout.AbsoluteContentSize.Y + 20)
end)
FbgLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    tabs["Fruit BG"].Page.CanvasSize = UDim2.new(0, 0, 0, FbgLayout.AbsoluteContentSize.Y + 20)
end)
ServerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    tabs["Server"].Page.CanvasSize = UDim2.new(0, 0, 0, ServerLayout.AbsoluteContentSize.Y + 20)
end)

print("[CyRuZzz Hub] Loaded Successfully!")
