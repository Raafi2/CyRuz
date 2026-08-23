-- ============================================================
--  CyRuZzz Panel V2 (Full Master Edition) | Fruit Battlegrounds
--  All Features Included - Clean Code - No Syntax Errors
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LP:WaitForChild("PlayerGui")

-- ============================================================
--  GLOBAL STATES & CONFIGS
-- ============================================================
local Toggles = {
    ESP = false,
    AntiStun = false,
    InfDash = false,
    InfJump = false,
    Fly = false,
    Noclip = false,
    AutoSkill = false,
    AutoM1 = false
}

local Configs = {
    WalkSpeed = 100,
    FlySpeed = 60,
    Skill1 = 0.2,
    Skill2 = 0.2,
    Skill3 = 22.0,
    Skill4 = 7.0
}

local espObjects = {}
local flyConn = nil
local noclipConn = nil
local loopTask = nil
local selectedPlayer = nil
local tp1Pos = nil
local tp2Pos = nil

-- Clean GUI Lama
if PlayerGui:FindFirstChild("CyRuZzz_V2_Master") then
    PlayerGui.CyRuZzz_V2_Master:Destroy()
end

-- ============================================================
--  GUI BASE SETUP
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name = "CyRuZzz_V2_Master"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 270, 0, 440)
Main.Position = UDim2.new(0, 20, 0.5, -220)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = SG

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 60)
MainStroke.Thickness = 1.5
MainStroke.Parent = Main

-- Topbar
local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, 0, 0, 40)
Topbar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Topbar.BorderSizePixel = 0
Topbar.Parent = Main

local TopbarCorner = Instance.new("UICorner")
TopbarCorner.CornerRadius = UDim.new(0, 12)
TopbarCorner.Parent = Topbar

local TopbarPatch = Instance.new("Frame")
TopbarPatch.Size = UDim2.new(1, 0, 0, 10)
TopbarPatch.Position = UDim2.new(0, 0, 1, -10)
TopbarPatch.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TopbarPatch.BorderSizePixel = 0
TopbarPatch.Parent = Topbar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "✦ CyRuZzz V2 Master"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Topbar

local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.Position = UDim2.new(0, 0, 1, 0)
AccentLine.BorderSizePixel = 0
AccentLine.Parent = Topbar

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255))
})
Gradient.Parent = AccentLine

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 70)
CloseBtn.Text = "x"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = Topbar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    SG:Destroy()
end)

-- Scroll Container
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -16, 1, -50)
Content.Position = UDim2.new(0, 8, 0, 45)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.Parent = Main

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.Parent = Content

-- ============================================================
--  UI BUILDER HELPERS
-- ============================================================
local function CreateSectionHeader(text)
    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1, 0, 0, 22)
    Header.BackgroundTransparency = 1
    Header.Text = text
    Header.TextColor3 = Color3.fromRGB(0, 200, 255)
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 11
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = Content
end

local function CreateToggle(name, stateKey, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 36)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Frame.Parent = Content

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Pill = Instance.new("Frame")
    Pill.Size = UDim2.new(0, 38, 0, 20)
    Pill.Position = UDim2.new(1, -48, 0.5, -10)
    Pill.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Pill.Parent = Frame

    local PillCorner = Instance.new("UICorner")
    PillCorner.CornerRadius = UDim.new(1, 0)
    PillCorner.Parent = Pill

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 14, 0, 14)
    Circle.Position = UDim2.new(0, 3, 0.5, -7)
    Circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Circle.Parent = Pill

    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Frame

    Btn.MouseButton1Click:Connect(function()
        Toggles[stateKey] = not Toggles[stateKey]
        local s = Toggles[stateKey]
        
        TweenService:Create(Pill, TweenInfo.new(0.25), {
            BackgroundColor3 = s and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(40, 40, 50)
        }):Play()
        
        TweenService:Create(Circle, TweenInfo.new(0.25), {
            Position = s and UDim2.new(0, 21, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        }):Play()

        if callback then callback(s) end
    end)
end

local function CreateInput(name, configKey)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 36)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Frame.Parent = Content

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local BoxFrame = Instance.new("Frame")
    BoxFrame.Size = UDim2.new(0, 55, 0, 24)
    BoxFrame.Position = UDim2.new(1, -65, 0.5, -12)
    BoxFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    BoxFrame.Parent = Frame

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = BoxFrame

    local BoxStroke = Instance.new("UIStroke")
    BoxStroke.Color = Color3.fromRGB(50, 50, 65)
    BoxStroke.Parent = BoxFrame

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, 0, 1, 0)
    Box.BackgroundTransparency = 1
    Box.Text = tostring(Configs[configKey])
    Box.TextColor3 = Color3.fromRGB(255, 180, 50)
    Box.Font = Enum.Font.GothamBold
    Box.TextSize = 11
    Box.Parent = BoxFrame

    Box.FocusLost:Connect(function()
        local val = tonumber(Box.Text)
        if val then
            Configs[configKey] = val
        else
            Box.Text = tostring(Configs[configKey])
        end
    end)
end

-- ============================================================
--  BUILD ALL SECTIONS
-- ============================================================

-- 1. VISUALS & PLAYER MODS
CreateSectionHeader("VISUAL & PLAYER MODS")
CreateToggle("Advanced ESP (Full Info)", "ESP")
CreateToggle("Anti-Stun & Freeze", "AntiStun")
CreateToggle("Infinite Dash / Geppo", "InfDash")
CreateToggle("Infinite Jump", "InfJump")

-- 2. MOVEMENT
CreateSectionHeader("MOVEMENT MODS")
CreateToggle("Fly Mode", "Fly", function(s)
    if s then enableFly() else disableFly() end
end)
CreateToggle("Noclip", "Noclip", function(s)
    if s then enableNoclip() else disableNoclip() end
end)
CreateInput("Fly Speed", "FlySpeed")
CreateInput("Walk Speed Override", "WalkSpeed")

-- 3. TELEPORT SYSTEM
CreateSectionHeader("TELEPORT SYSTEM")

local TpRow = Instance.new("Frame")
TpRow.Size = UDim2.new(1, 0, 0, 36)
TpRow.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TpRow.Parent = Content
Instance.new("UICorner", TpRow).CornerRadius = UDim.new(0, 8)

local function MakeTpButton(text, pos, color, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 55, 0, 26)
    b.Position = pos
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.Parent = TpRow
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(callback)
end

MakeTpButton("SET TP1", UDim2.new(0, 8, 0.5, -13), Color3.fromRGB(45, 105, 225), function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then tp1Pos = hrp.CFrame end
end)

MakeTpButton("GO TP1", UDim2.new(0, 70, 0.5, -13), Color3.fromRGB(35, 145, 85), function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp and tp1Pos then hrp.CFrame = tp1Pos end
end)

MakeTpButton("SET TP2", UDim2.new(0, 132, 0.5, -13), Color3.fromRGB(180, 50, 100), function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then tp2Pos = hrp.CFrame end
end)

MakeTpButton("GO TP2", UDim2.new(0, 194, 0.5, -13), Color3.fromRGB(190, 80, 40), function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp and tp2Pos then hrp.CFrame = tp2Pos end
end)

-- TP To Player Row
local TpPlrRow = Instance.new("Frame")
TpPlrRow.Size = UDim2.new(1, 0, 0, 36)
TpPlrRow.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TpPlrRow.Parent = Content
Instance.new("UICorner", TpPlrRow).CornerRadius = UDim.new(0, 8)

local SelectBtn = Instance.new("TextButton")
SelectBtn.Size = UDim2.new(1, -70, 0, 26)
SelectBtn.Position = UDim2.new(0, 8, 0.5, -13)
SelectBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
SelectBtn.Text = "Pilih Player..."
SelectBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
SelectBtn.Font = Enum.Font.GothamSemibold
SelectBtn.TextSize = 10
SelectBtn.Parent = TpPlrRow
Instance.new("UICorner", SelectBtn).CornerRadius = UDim.new(0, 6)

local GoPlrBtn = Instance.new("TextButton")
GoPlrBtn.Size = UDim2.new(0, 50, 0, 26)
GoPlrBtn.Position = UDim2.new(1, -58, 0.5, -13)
GoPlrBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
GoPlrBtn.Text = "TP"
GoPlrBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GoPlrBtn.Font = Enum.Font.GothamBold
GoPlrBtn.TextSize = 10
GoPlrBtn.Parent = TpPlrRow
Instance.new("UICorner", GoPlrBtn).CornerRadius = UDim.new(0, 6)

-- Dropdown Container
local DropFrame = Instance.new("ScrollingFrame")
DropFrame.Size = UDim2.new(1, 0, 0, 90)
DropFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
DropFrame.Visible = false
DropFrame.ScrollBarThickness = 3
DropFrame.Parent = Content
Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 6)

local DropLayout = Instance.new("UIListLayout")
DropLayout.SortOrder = Enum.SortOrder.LayoutOrder
DropLayout.Parent = DropFrame

SelectBtn.MouseButton1Click:Connect(function()
    DropFrame.Visible = not DropFrame.Visible
    if DropFrame.Visible then
        for _, c in ipairs(DropFrame:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local count = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                count = count + 1
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1, 0, 0, 22)
                b.BackgroundTransparency = 1
                b.Text = p.Name
                b.TextColor3 = Color3.fromRGB(200, 210, 255)
                b.Font = Enum.Font.Gotham
                b.TextSize = 10
                b.Parent = DropFrame
                b.MouseButton1Click:Connect(function()
                    selectedPlayer = p
                    SelectBtn.Text = p.Name
                    DropFrame.Visible = false
                end)
            end
        end
        DropFrame.CanvasSize = UDim2.new(0, 0, 0, count * 22)
    end
end)

GoPlrBtn.MouseButton1Click:Connect(function()
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if myHrp then
            myHrp.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 3)
        end
    end
end)

-- 4. AUTO SKILL (SCREEN HOLD)
CreateSectionHeader("AUTO SKILL (SCREEN HOLD)")
CreateToggle("Enable Auto Skill", "AutoSkill", function(s)
    if s then startAutoFarm() end
end)
CreateToggle("Enable Auto M1 (Punch)", "AutoM1")
CreateInput("Skill 1 Hold (s)", "Skill1")
CreateInput("Skill 2 Hold (s)", "Skill2")
CreateInput("Skill 3 Hold (s)", "Skill3")
CreateInput("Skill 4 Hold (s)", "Skill4")

-- ============================================================
--  ADVANCED ESP CORE (FULL INFO)
-- ============================================================
local function getPlayerStat(plr, statName)
    local data = plr:FindFirstChild("leaderstats") or plr:FindFirstChild("Data") or plr:FindFirstChild("Stats")
    if data and data:FindFirstChild(statName) then
        return tostring(data[statName].Value)
    end
    return "N/A"
end

local function removeEspGui(plr)
    if espObjects[plr] then
        if espObjects[plr].Billboard then espObjects[plr].Billboard:Destroy() end
        if espObjects[plr].Highlight then espObjects[plr].Highlight:Destroy() end
        espObjects[plr] = nil
    end
end

local function createEspGui(plr)
    if plr == LP or espObjects[plr] then return end

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "CyESP_" .. plr.Name
    Billboard.AlwaysOnTop = true
    Billboard.Size = UDim2.new(0, 150, 0, 130)
    Billboard.StudsOffset = Vector3.new(0, 3.5, 0)

    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.Padding = UDim.new(0, 2)
    Layout.Parent = Billboard

    local function MakeLabel(color, font, size)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 16)
        l.BackgroundTransparency = 1
        l.TextColor3 = color
        l.TextStrokeTransparency = 0.2
        l.TextStrokeColor3 = Color3.new(0, 0, 0)
        l.Font = font
        l.TextSize = size
        l.Parent = Billboard
        return l
    end

    local NameLbl = MakeLabel(Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, 14)
    NameLbl.Text = plr.Name

    local FruitLbl = MakeLabel(Color3.fromRGB(0, 255, 255), Enum.Font.GothamBold, 13)
    local LevelLbl = MakeLabel(Color3.fromRGB(255, 255, 0), Enum.Font.GothamBold, 13)
    local BountyLbl = MakeLabel(Color3.fromRGB(255, 0, 0), Enum.Font.GothamBold, 13)
    local DistLbl = MakeLabel(Color3.fromRGB(200, 200, 200), Enum.Font.GothamSemibold, 12)

    -- Spacer
    local Spacer = Instance.new("Frame")
    Spacer.Size = UDim2.new(1, 0, 0, 6)
    Spacer.BackgroundTransparency = 1
    Spacer.Parent = Billboard

    -- Health Bar (Outlined)
    local HealthBg = Instance.new("Frame")
    HealthBg.Size = UDim2.new(0, 120, 0, 12)
    HealthBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    HealthBg.BorderSizePixel = 0
    HealthBg.Parent = Billboard

    local HealthFill = Instance.new("Frame")
    HealthFill.Size = UDim2.new(1, -2, 1, -2)
    HealthFill.Position = UDim2.new(0, 1, 0, 1)
    HealthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    HealthFill.BorderSizePixel = 0
    HealthFill.Parent = HealthBg

    -- Chams Highlight
    local Highlight = Instance.new("Highlight")
    Highlight.Name = "CyChams_" .. plr.Name
    Highlight.FillColor = Color3.fromRGB(255, 0, 0)
    Highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    Highlight.FillTransparency = 0.5
    Highlight.OutlineTransparency = 0.1

    Billboard.Parent = PlayerGui
    Highlight.Parent = PlayerGui

    espObjects[plr] = {
        Billboard = Billboard,
        Highlight = Highlight,
        FruitLbl = FruitLbl,
        LevelLbl = LevelLbl,
        BountyLbl = BountyLbl,
        DistLbl = DistLbl,
        HealthFill = HealthFill
    }
end

-- ============================================================
--  MOVEMENT LOGIC
-- ============================================================
local function getChar() return LP.Character end

function enableFly()
    local c = getChar(); if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand = true

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Name = "_CyBV"
    bv.Parent = hrp

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.D = 100; bg.P = 1e4
    bg.CFrame = hrp.CFrame
    bg.Name = "_CyBG"
    bg.Parent = hrp

    flyConn = RunService.RenderStepped:Connect(function()
        if not Toggles.Fly then return end
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
        
        bv.Velocity = dir.Magnitude > 0 and dir.Unit * Configs.FlySpeed or Vector3.zero
        bg.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + Camera.CFrame.LookVector)
    end)
end

function disableFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    local c = getChar(); if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if hum then hum.PlatformStand = false end
    if hrp then
        if hrp:FindFirstChild("_CyBV") then hrp._CyBV:Destroy() end
        if hrp:FindFirstChild("_CyBG") then hrp._CyBG:Destroy() end
    end
end

function enableNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        if not Toggles.Noclip then return end
        local c = getChar(); if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end

function disableNoclip()
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
end

-- ============================================================
--  AUTO SKILL & COOLDOWN FILTER
-- ============================================================
local function isSkillOnCooldown(slotName)
    local mainGui = PlayerGui:FindFirstChild("Main") or PlayerGui:FindFirstChild("HUD") or PlayerGui:FindFirstChild("Hotbar")
    if mainGui then
        local slotFrame = mainGui:FindFirstChild(tostring(slotName), true) or mainGui:FindFirstChild("Slot" .. slotName, true)
        if slotFrame then
            local cdFrame = slotFrame:FindFirstChild("Cooldown") or slotFrame:FindFirstChild("CD") or slotFrame:FindFirstChild("Overlay")
            if cdFrame then
                if cdFrame:IsA("TextLabel") and cdFrame.Text ~= "" and cdFrame.Text ~= "0" then return true
                elseif cdFrame:IsA("Frame") and cdFrame.Visible and cdFrame.BackgroundTransparency < 0.9 then return true end
            end
        end
    end
    return false
end

local function executeSkill(keyEnum, slotName, holdDuration)
    if isSkillOnCooldown(slotName) then return false end
    
    -- Press Key
    VirtualInputManager:SendKeyEvent(true, keyEnum, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, keyEnum, false, game)
    task.wait(0.1)

    -- Hold Layar
    if holdDuration > 0.2 then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        local elapsed = 0
        while elapsed < holdDuration do
            if not Toggles.AutoSkill then break end
            task.wait(0.1)
            elapsed = elapsed + 0.1
        end
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    else
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
    task.wait(0.2)
    return true
end

function startAutoFarm()
    if loopTask then return end
    loopTask = task.spawn(function()
        while Toggles.AutoSkill do
            executeSkill(Enum.KeyCode.One, "1", Configs.Skill1)
            executeSkill(Enum.KeyCode.Two, "2", Configs.Skill2)
            executeSkill(Enum.KeyCode.Three, "3", Configs.Skill3)
            executeSkill(Enum.KeyCode.Four, "4", Configs.Skill4)
            task.wait(0.1)
        end
        loopTask = nil
    end)
end

-- Auto M1 Loop
task.spawn(function()
    while true do
        if Toggles.AutoM1 then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            task.wait(0.25)
        else
            task.wait(0.5)
        end
    end
end)

-- ============================================================
--  RENDER LOOP (ESP, Anti-Stun, WalkSpeed, Inf Dash)
-- ============================================================
RunService.RenderStepped:Connect(function()
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

    -- WalkSpeed
    if myHum and myHum.WalkSpeed ~= Configs.WalkSpeed and not Toggles.AntiStun then
        if Configs.WalkSpeed > 16 then myHum.WalkSpeed = Configs.WalkSpeed end
    end

    -- Anti-Stun
    if Toggles.AntiStun and myChar then
        local stunObj = myChar:FindFirstChild("Stun") or myChar:FindFirstChild("Stunned") or myChar:FindFirstChild("Freeze")
        if stunObj then stunObj:Destroy() end
        if myHum and myHum.WalkSpeed == 0 then myHum.WalkSpeed = Configs.WalkSpeed end
    end

    -- Inf Dash
    if Toggles.InfDash and myChar then
        local dashCd = myChar:FindFirstChild("DashCooldown") or myChar:FindFirstChild("GeppoCooldown") or myChar:FindFirstChild("Dodging")
        if dashCd then dashCd:Destroy() end
    end

    -- Advanced ESP
    if Toggles.ESP then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                local char = plr.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local head = char and char:FindFirstChild("Head")
                local hum = char and char:FindFirstChildOfClass("Humanoid")

                if char and root and head and hum and hum.Health > 0 then
                    if not espObjects[plr] then createEspGui(plr) end
                    local data = espObjects[plr]
                    if data then
                        data.Billboard.Adornee = head
                        data.Billboard.Enabled = true
                        data.Highlight.Adornee = char
                        data.Highlight.Enabled = true

                        if myRoot then
                            data.DistLbl.Text = "Distance: " .. math.floor((myRoot.Position - root.Position).Magnitude) .. " studs"
                        end
                        data.FruitLbl.Text = "Fruit: " .. getPlayerStat(plr, "Fruit")
                        data.LevelLbl.Text = "Level: " .. getPlayerStat(plr, "Level")
                        data.BountyLbl.Text = "Bounty: " .. getPlayerStat(plr, "Bounty")

                        local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        data.HealthFill.Size = UDim2.new(hpPercent, -2, 1, -2)
                        data.HealthFill.BackgroundColor3 = hpPercent > 0.5 and Color3.fromRGB(0, 255, 0) or (hpPercent > 0.2 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 0, 0))
                    end
                else
                    if espObjects[plr] then
                        espObjects[plr].Billboard.Enabled = false
                        espObjects[plr].Highlight.Enabled = false
                    end
                end
            end
        end
    else
        for plr, data in pairs(espObjects) do
            data.Billboard.Enabled = false
            data.Highlight.Enabled = false
        end
    end
end)

Players.PlayerRemoving:Connect(removeEspGui)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfJump then
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Respawn Handler
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Toggles.Fly then enableFly() end
    if Toggles.Noclip then enableNoclip() end
end)

print("[CyRuZzz V2 Master Edition] Successfully Loaded!")
