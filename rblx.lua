-- ============================================================
--  CyRuZzz Panel V2 (Xeno Fixed) | Fruit Battlegrounds
--  All-in-One: ESP, Player Mods, Movement, & Auto Skill
--  Fix: No CoreGui Error
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ============================================================
--  STATE VARIABLES
-- ============================================================
local Toggles = {
    ESP = false, AntiStun = false, InfDash = false, InfJump = false,
    Fly = false, Noclip = false, AutoSkill = false, AutoM1 = false
}

local Configs = {
    WalkSpeed = 100, FlySpeed = 60,
    Skill1 = 0.2, Skill2 = 0.2, Skill3 = 22.0, Skill4 = 7.0
}

local espObjects = {}
local flyConn = nil
local noclipConn = nil
local loopTask = nil

-- ============================================================
--  SAFE GUI CONTAINER (PlayerGui Only)
-- ============================================================
local playerGui = LP:WaitForChild("PlayerGui")

-- Hapus GUI lama jika ada
if playerGui:FindFirstChild("CyRuZzz_V2_Ultimate") then
    playerGui.CyRuZzz_V2_Ultimate:Destroy()
end

local SG = Instance.new("ScreenGui")
SG.Name = "CyRuZzz_V2_Ultimate"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = playerGui

local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, 260, 0, 420)
Main.Position = UDim2.new(0, 20, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(40, 40, 50)

local Topbar = Instance.new("Frame", Main)
Topbar.Size = UDim2.new(1, 0, 0, 40)
Topbar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Topbar.BorderSizePixel = 0
Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 12)
local TopbarPatch = Instance.new("Frame", Topbar); TopbarPatch.Size = UDim2.new(1, 0, 0, 10); TopbarPatch.Position = UDim2.new(0, 0, 1, -10); TopbarPatch.BackgroundColor3 = Color3.fromRGB(20, 20, 28); TopbarPatch.BorderSizePixel = 0
local Title = Instance.new("TextLabel", Topbar); Title.Size = UDim2.new(1, -50, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0); Title.BackgroundTransparency = 1; Title.Text = "CyRuZzz V2 Ultimate"; Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Font = Enum.Font.GothamBold; Title.TextSize = 13; Title.TextXAlignment = Enum.TextXAlignment.Left
local AccentLine = Instance.new("Frame", Topbar); AccentLine.Size = UDim2.new(1, 0, 0, 2); AccentLine.Position = UDim2.new(0, 0, 1, 0); AccentLine.BorderSizePixel = 0
local Gradient = Instance.new("UIGradient", AccentLine); Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255))})
local CloseBtn = Instance.new("TextButton", Topbar); CloseBtn.Size = UDim2.new(0, 24, 0, 24); CloseBtn.Position = UDim2.new(1, -34, 0.5, -12); CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 70); CloseBtn.Text = ""; Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)
CloseBtn.MouseButton1Click:Connect(function() SG:Destroy() end)

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 45)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 2
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
local Layout = Instance.new("UIListLayout", Content); Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 8)

local function MakeHeader(text)
    local lbl = Instance.new("TextLabel", Content)
    lbl.Size = UDim2.new(1, 0, 0, 20); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(150, 150, 255)
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left
end

local function MakeToggle(name, stateKey, callback)
    local f = Instance.new("Frame", Content); f.Size = UDim2.new(1, 0, 0, 36); f.BackgroundColor3 = Color3.fromRGB(25, 25, 35); Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    local lbl = Instance.new("TextLabel", f); lbl.Size = UDim2.new(1, -60, 1, 0); lbl.Position = UDim2.new(0, 15, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local pill = Instance.new("Frame", f); pill.Size = UDim2.new(0, 36, 0, 18); pill.Position = UDim2.new(1, -46, 0.5, -9); pill.BackgroundColor3 = Color3.fromRGB(40, 40, 50); Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
    local circle = Instance.new("Frame", pill); circle.Size = UDim2.new(0, 12, 0, 12); circle.Position = UDim2.new(0, 3, 0.5, -6); circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200); Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""
    btn.MouseButton1Click:Connect(function()
        Toggles[stateKey] = not Toggles[stateKey]
        local s = Toggles[stateKey]
        TweenService:Create(pill, TweenInfo.new(0.3), {BackgroundColor3 = s and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(40, 40, 50)}):Play()
        TweenService:Create(circle, TweenInfo.new(0.3), {Position = s and UDim2.new(0, 21, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)}):Play()
        if callback then callback(s) end
    end)
end

local function MakeInput(name, configKey)
    local f = Instance.new("Frame", Content); f.Size = UDim2.new(1, 0, 0, 36); f.BackgroundColor3 = Color3.fromRGB(25, 25, 35); Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    local lbl = Instance.new("TextLabel", f); lbl.Size = UDim2.new(1, -70, 1, 0); lbl.Position = UDim2.new(0, 15, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Color3.fromRGB(200, 200, 200); lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local boxBg = Instance.new("Frame", f); boxBg.Size = UDim2.new(0, 50, 0, 24); boxBg.Position = UDim2.new(1, -60, 0.5, -12); boxBg.BackgroundColor3 = Color3.fromRGB(15, 15, 20); Instance.new("UICorner", boxBg).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", boxBg).Color = Color3.fromRGB(50, 50, 60)
    local box = Instance.new("TextBox", boxBg); box.Size = UDim2.new(1, 0, 1, 0); box.BackgroundTransparency = 1; box.Text = tostring(Configs[configKey]); box.TextColor3 = Color3.fromRGB(255, 180, 50); box.Font = Enum.Font.GothamBold; box.TextSize = 11
    box.FocusLost:Connect(function()
        local val = tonumber(box.Text)
        if val then Configs[configKey] = val else box.Text = tostring(Configs[configKey]) end
    end)
end

-- ============================================================
--  BUILDING THE UI
-- ============================================================
MakeHeader("VISUAL & PLAYER MODS")
MakeToggle("Advanced ESP (All Info)", "ESP")
MakeToggle("Anti-Stun & Freeze", "AntiStun")
MakeToggle("Infinite Dash", "InfDash")
MakeToggle("Infinite Jump", "InfJump")

MakeHeader("MOVEMENT")
MakeToggle("Fly Mode", "Fly", function(state) if state then enableFly() else disableFly() end end)
MakeToggle("Noclip", "Noclip", function(state) if state then enableNoclip() else disableNoclip() end end)
MakeInput("Fly Speed", "FlySpeed")
MakeInput("Walk Speed Override", "WalkSpeed")

MakeHeader("AUTO SKILL (SCREEN HOLD)")
MakeToggle("Enable Auto Skill", "AutoSkill", function(state) if state then startAutoFarm() end end)
MakeToggle("Enable Auto M1 (Punch)", "AutoM1")
MakeInput("Skill 1 Hold (s)", "Skill1")
MakeInput("Skill 2 Hold (s)", "Skill2")
MakeInput("Skill 3 Hold (s)", "Skill3")
MakeInput("Skill 4 Hold (s)", "Skill4")

-- ============================================================
--  ESP LOGIC (PlayerGui Target Only)
-- ============================================================
local function getPlayerStat(plr, statName)
    local data = plr:FindFirstChild("leaderstats") or plr:FindFirstChild("Data") or plr:FindFirstChild("Stats")
    if data and data:FindFirstChild(statName) then return tostring(data[statName].Value) end
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
    local espHolder = Instance.new("BillboardGui"); espHolder.Name = "CyESP_" .. plr.Name; espHolder.AlwaysOnTop = true; espHolder.Size = UDim2.new(0, 150, 0, 120); espHolder.StudsOffset = Vector3.new(0, 3.5, 0)
    local Layout = Instance.new("UIListLayout", espHolder); Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; Layout.Padding = UDim.new(0, 2)

    local function makeText(color, font, size)
        local lbl = Instance.new("TextLabel", espHolder); lbl.Size = UDim2.new(1, 0, 0, 16); lbl.BackgroundTransparency = 1; lbl.TextColor3 = color; lbl.TextStrokeTransparency = 0.2; lbl.TextStrokeColor3 = Color3.new(0, 0, 0); lbl.Font = font; lbl.TextSize = size
        return lbl
    end

    local NameLbl = makeText(Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, 14); NameLbl.Text = plr.Name
    local FruitLbl = makeText(Color3.fromRGB(0, 255, 255), Enum.Font.GothamBold, 13)
    local LevelLbl = makeText(Color3.fromRGB(255, 255, 0), Enum.Font.GothamBold, 13)
    local BountyLbl = makeText(Color3.fromRGB(255, 0, 0), Enum.Font.GothamBold, 13)
    local DistLbl = makeText(Color3.fromRGB(200, 200, 200), Enum.Font.GothamSemibold, 12)
    local Spacer = Instance.new("Frame", espHolder); Spacer.Size = UDim2.new(1, 0, 0, 10); Spacer.BackgroundTransparency = 1

    local HealthBg = Instance.new("Frame", espHolder); HealthBg.Size = UDim2.new(0, 120, 0, 12); HealthBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0); HealthBg.BorderSizePixel = 0
    local HealthFill = Instance.new("Frame", HealthBg); HealthFill.Size = UDim2.new(1, -2, 1, -2); HealthFill.Position = UDim2.new(0, 1, 0, 1); HealthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0); HealthFill.BorderSizePixel = 0

    local Highlight = Instance.new("Highlight"); Highlight.Name = "CyChams_" .. plr.Name; Highlight.FillColor = Color3.fromRGB(255, 0, 0); Highlight.OutlineColor = Color3.fromRGB(255, 0, 0); Highlight.FillTransparency = 0.5; Highlight.OutlineTransparency = 0.1

    -- Simpan langsung ke PlayerGui agar Xeno tidak error
    espHolder.Parent = playerGui
    Highlight.Parent = playerGui

    espObjects[plr] = {Billboard = espHolder, Highlight = Highlight, FruitLbl = FruitLbl, LevelLbl = LevelLbl, BountyLbl = BountyLbl, DistLbl = DistLbl, HealthFill = HealthFill}
end

-- ============================================================
--  MOVEMENT LOGIC
-- ============================================================
local function getChar() return LP.Character end

function enableFly()
    local c = getChar(); if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart"); local hum = c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand = true
    local bv = Instance.new("BodyVelocity", hrp); bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(1e5,1e5,1e5); bv.Name = "_CyBV"
    local bg = Instance.new("BodyGyro", hrp); bg.MaxTorque = Vector3.new(1e5,1e5,1e5); bg.D = 100; bg.P = 1e4; bg.CFrame = hrp.CFrame; bg.Name = "_CyBG"

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
    local hum = c:FindFirstChildOfClass("Humanoid"); local hrp = c:FindFirstChild("HumanoidRootPart")
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
        for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end)
end

function disableNoclip()
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
end

-- ============================================================
--  AUTO SKILL LOGIC
-- ============================================================
local function isSkillOnCooldown(slotName)
    local pGui = LP:FindFirstChild("PlayerGui")
    if not pGui then return false end
    local mainGui = pGui:FindFirstChild("Main") or pGui:FindFirstChild("HUD") or pGui:FindFirstChild("Hotbar")
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
    VirtualInputManager:SendKeyEvent(true, keyEnum, false, game); task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, keyEnum, false, game); task.wait(0.1)

    if holdDuration > 0.2 then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        local elapsed = 0
        while elapsed < holdDuration do
            if not Toggles.AutoSkill then break end
            task.wait(0.1); elapsed = elapsed + 0.1
        end
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    else
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0); task.wait(0.05)
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

task.spawn(function()
    while true do
        if Toggles.AutoM1 then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0); task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0); task.wait(0.25)
        else
            task.wait(0.5)
        end
    end
end)

-- ============================================================
--  RENDER LOOP
-- ============================================================
RunService.RenderStepped:Connect(function()
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

    if myHum and myHum.WalkSpeed ~= Configs.WalkSpeed and not Toggles.AntiStun then
        if Configs.WalkSpeed > 16 then myHum.WalkSpeed = Configs.WalkSpeed end
    end

    if Toggles.AntiStun and myChar then
        local stunObj = myChar:FindFirstChild("Stun") or myChar:FindFirstChild("Stunned") or myChar:FindFirstChild("Freeze")
        if stunObj then stunObj:Destroy() end
        if myHum and myHum.WalkSpeed == 0 then myHum.WalkSpeed = Configs.WalkSpeed end
    end

    if Toggles.InfDash and myChar then
        local dashCd = myChar:FindFirstChild("DashCooldown") or myChar:FindFirstChild("GeppoCooldown") or myChar:FindFirstChild("Dodging")
        if dashCd then dashCd:Destroy() end
    end

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
                        data.Billboard.Adornee = head; data.Billboard.Enabled = true
                        data.Highlight.Adornee = char; data.Highlight.Enabled = true
                        
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
                    if espObjects[plr] then espObjects[plr].Billboard.Enabled = false; espObjects[plr].Highlight.Enabled = false end
                end
            end
        end
    else
        for plr, data in pairs(espObjects) do data.Billboard.Enabled = false; data.Highlight.Enabled = false end
    end
end)

Players.PlayerRemoving:Connect(removeEspGui)

UserInputService.JumpRequest:Connect(function()
    if Toggles.InfJump then
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Toggles.Fly then enableFly() end
    if Toggles.Noclip then enableNoclip() end
end)

print("[CyRuZzz V2] Fixed & Loaded via PlayerGui!")
