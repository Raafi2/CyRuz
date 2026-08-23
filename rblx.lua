-- ============================================================
--  CyRuZzz Panel V2 | Fruit Battlegrounds Advanced
--  Modern UI, Advanced ESP, Anti-Stun, Inf Dash, Inf Jump
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Toggles State
local Toggles = {
    ESP = false,
    AntiStun = false,
    InfDash = false,
    InfJump = false
}

-- ESP Data
local espObjects = {}
local espConn = nil

-- ============================================================
--  MODERN GUI CREATION
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name = "CyRuZzz_V2"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() SG.Parent = CoreGui end)
if SG.Parent ~= CoreGui then SG.Parent = LP:WaitForChild("PlayerGui") end

-- Main Frame (Modern Dark Theme)
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 260, 0, 340)
Main.Position = UDim2.new(0, 20, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = SG
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(40, 40, 50)

-- Topbar
local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, 0, 0, 40)
Topbar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Topbar.BorderSizePixel = 0
Topbar.Parent = Main
Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 12)

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
Title.Text = "CyRuZzz V2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
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
CloseBtn.Text = ""
CloseBtn.Parent = Topbar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)
CloseBtn.MouseButton1Click:Connect(function() SG:Destroy() end)

-- Content Container
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 2
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = Main
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = Content

-- Modern Toggle Function
local function CreateToggle(name, stateKey)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    ToggleFrame.Parent = Content
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local Pill = Instance.new("Frame")
    Pill.Size = UDim2.new(0, 40, 0, 20)
    Pill.Position = UDim2.new(1, -50, 0.5, -10)
    Pill.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Pill.Parent = ToggleFrame
    Instance.new("UICorner", Pill).CornerRadius = UDim.new(1, 0)

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 14, 0, 14)
    Circle.Position = UDim2.new(0, 3, 0.5, -7)
    Circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Circle.Parent = Pill
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.Parent = ToggleFrame

    Button.MouseButton1Click:Connect(function()
        Toggles[stateKey] = not Toggles[stateKey]
        local state = Toggles[stateKey]
        
        local targetColor = state and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(40, 40, 50)
        local targetPos = state and UDim2.new(0, 23, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        local labelColor = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 220, 220)

        TweenService:Create(Pill, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = targetPos}):Play()
        TweenService:Create(Label, TweenInfo.new(0.3), {TextColor3 = labelColor}):Play()
    end)
end

CreateToggle("Advanced ESP", "ESP")
CreateToggle("Anti-Stun", "AntiStun")
CreateToggle("Infinite Dash", "InfDash")
CreateToggle("Infinite Jump", "InfJump")

-- ============================================================
--  UTILITY FUNCTIONS
-- ============================================================

-- Fungsi untuk mengambil stats pemain dengan aman
local function getPlayerStat(plr, statName)
    if plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild(statName) then
        return tostring(plr.leaderstats[statName].Value)
    end
    -- Fallback jika ada di folder lain (FBG biasanya menyimpan di Data/Stats)
    local data = plr:FindFirstChild("Data") or plr:FindFirstChild("Stats") or plr:FindFirstChild("ReplicatedData")
    if data and data:FindFirstChild(statName) then
        return tostring(data[statName].Value)
    end
    return "N/A"
end

-- ============================================================
--  ESP LOGIC
-- ============================================================

local function removeEspGui(plr)
    if espObjects[plr] then
        if espObjects[plr].Billboard then espObjects[plr].Billboard:Destroy() end
        if espObjects[plr].Highlight then espObjects[plr].Highlight:Destroy() end
        espObjects[plr] = nil
    end
end

local function createEspGui(plr)
    if plr == LP or espObjects[plr] then return end
    
    -- 1. Billboard GUI
    local espHolder = Instance.new("BillboardGui")
    espHolder.Name = "CyESP_" .. plr.Name
    espHolder.AlwaysOnTop = true
    espHolder.Size = UDim2.new(0, 150, 0, 120)
    espHolder.StudsOffset = Vector3.new(0, 3.5, 0)
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.Padding = UDim.new(0, 2)
    ListLayout.Parent = espHolder

    -- Helper untuk membuat TextLabel
    local function makeText(name, color, font, size)
        local lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.Size = UDim2.new(1, 0, 0, 16)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = color
        lbl.TextStrokeTransparency = 0.2
        lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
        lbl.Font = font
        lbl.TextSize = size
        lbl.Parent = espHolder
        return lbl
    end

    local NameLbl = makeText("Name", Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, 14)
    NameLbl.Text = plr.Name
    
    local FruitLbl = makeText("Fruit", Color3.fromRGB(0, 255, 255), Enum.Font.GothamBold, 13)
    local LevelLbl = makeText("Level", Color3.fromRGB(255, 255, 0), Enum.Font.GothamBold, 13)
    local BountyLbl = makeText("Bounty", Color3.fromRGB(255, 0, 0), Enum.Font.GothamBold, 13)
    local DistLbl = makeText("Distance", Color3.fromRGB(200, 200, 200), Enum.Font.GothamSemibold, 12)

    -- Spacer untuk Health Bar
    local Spacer = Instance.new("Frame")
    Spacer.Size = UDim2.new(1, 0, 0, 10)
    Spacer.BackgroundTransparency = 1
    Spacer.Parent = espHolder

    -- Health Bar Background (Hitam tebal)
    local HealthBg = Instance.new("Frame")
    HealthBg.Size = UDim2.new(0, 120, 0, 12)
    HealthBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    HealthBg.BorderSizePixel = 0
    HealthBg.Parent = espHolder

    -- Health Bar Fill (Hijau)
    local HealthFill = Instance.new("Frame")
    HealthFill.Size = UDim2.new(1, -2, 1, -2) -- Diberi padding sedikit agar terlihat outline hitam
    HealthFill.Position = UDim2.new(0, 1, 0, 1)
    HealthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    HealthFill.BorderSizePixel = 0
    HealthFill.Parent = HealthBg

    -- 2. Red Body Highlight (Chams)
    local Highlight = Instance.new("Highlight")
    Highlight.Name = "CyChams_" .. plr.Name
    Highlight.FillColor = Color3.fromRGB(255, 0, 0)
    Highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    Highlight.FillTransparency = 0.5
    Highlight.OutlineTransparency = 0.1

    -- Terapkan
    pcall(function() 
        espHolder.Parent = CoreGui
        Highlight.Parent = CoreGui
    end)
    if espHolder.Parent ~= CoreGui then 
        espHolder.Parent = LP:WaitForChild("PlayerGui")
        Highlight.Parent = LP:WaitForChild("PlayerGui")
    end

    espObjects[plr] = {
        Billboard = espHolder,
        Highlight = Highlight,
        FruitLbl = FruitLbl,
        LevelLbl = LevelLbl,
        BountyLbl = BountyLbl,
        DistLbl = DistLbl,
        HealthFill = HealthFill,
        HealthBg = HealthBg
    }
end

-- ============================================================
--  MAIN LOOP (RENDER STEPPED)
-- ============================================================
RunService.RenderStepped:Connect(function()
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    -- 1. ESP LOGIC
    if Toggles.ESP then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                local char = plr.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local head = char and char:FindFirstChild("Head")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if char and root and head and hum and hum.Health > 0 then
                    -- Buat jika belum ada
                    if not espObjects[plr] then createEspGui(plr) end
                    
                    local data = espObjects[plr]
                    if data then
                        data.Billboard.Adornee = head
                        data.Billboard.Enabled = true
                        data.Highlight.Adornee = char
                        data.Highlight.Enabled = true
                        
                        -- Update Jarak
                        if myRoot then
                            local dist = math.floor((myRoot.Position - root.Position).Magnitude)
                            data.DistLbl.Text = "Distance: " .. dist .. " studs"
                        end

                        -- Update Stats (Sesuai FBG)
                        data.FruitLbl.Text = "Fruit: " .. getPlayerStat(plr, "Fruit")
                        data.LevelLbl.Text = "Level: " .. getPlayerStat(plr, "Level")
                        data.BountyLbl.Text = "Bounty: " .. getPlayerStat(plr, "Bounty")

                        -- Update Health Bar
                        local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        data.HealthFill.Size = UDim2.new(hpPercent, -2, 1, -2)
                        
                        -- Ubah warna HP Bar jika darah menipis (Opsional, efek keren)
                        if hpPercent > 0.5 then
                            data.HealthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Hijau
                        elseif hpPercent > 0.2 then
                            data.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 255, 0) -- Kuning
                        else
                            data.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Merah
                        end
                    end
                else
                    -- Sembunyikan jika mati / tidak ada karakter
                    if espObjects[plr] then
                        espObjects[plr].Billboard.Enabled = false
                        espObjects[plr].Highlight.Enabled = false
                    end
                end
            end
        end
    else
        -- Jika ESP dimatikan, sembunyikan semua
        for plr, data in pairs(espObjects) do
            data.Billboard.Enabled = false
            data.Highlight.Enabled = false
        end
    end

    -- 2. ANTI-STUN LOGIC
    if Toggles.AntiStun and myChar then
        -- FBG biasanya menggunakan objek bernama "Stun", "Stunned", atau "Action" di dalam karakter
        local stunObj = myChar:FindFirstChild("Stun") or myChar:FindFirstChild("Stunned") or myChar:FindFirstChild("Freeze")
        if stunObj then
            stunObj:Destroy()
        end
        
        -- Memastikan WalkSpeed tidak dikunci ke 0
        local myHum = myChar:FindFirstChildOfClass("Humanoid")
        if myHum and myHum.WalkSpeed == 0 then
            myHum.WalkSpeed = 16
        end
    end

    -- 3. INFINITE DASH LOGIC
    if Toggles.InfDash and myChar then
        -- Menghapus cooldown dash. FBG biasanya menggunakan objek bernama "DashCooldown" atau "Dashing"
        local dashCd = myChar:FindFirstChild("DashCooldown") or myChar:FindFirstChild("GeppoCooldown") or myChar:FindFirstChild("Dodging")
        if dashCd then
            dashCd:Destroy()
        end
    end
end)

-- Bersihkan ESP jika pemain keluar
Players.PlayerRemoving:Connect(removeEspGui)

-- ============================================================
--  INFINITE JUMP LOGIC
-- ============================================================
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfJump then
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

print("[CyRuZzz V2] Loaded Successfully!")
