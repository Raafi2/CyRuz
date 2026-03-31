-- ============================================================
--  CyRuZzz Panel | Roblox LocalScript
--  [T] Fly  [C] Noclip  [Q] Speed  [H] TP1  [J] TP2
-- ============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local flyEnabled    = false
local noclipEnabled = false
local speedEnabled  = false
local tp1Pos        = nil
local tp2Pos        = nil
local flyConn       = nil
local noclipConn    = nil
local speedConn     = nil
local flySpeed      = 60
local walkSpeedVal  = 100

-- ============================================================
--  GUI
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name           = "CyRuZzz"
SG.ResetOnSpawn   = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder   = 999
SG.Parent         = LP:WaitForChild("PlayerGui")

local Panel = Instance.new("Frame")
Panel.Name                   = "Panel"
Panel.Size                   = UDim2.new(0, 230, 0, 412) -- Diperpanjang untuk muat menu Speed
Panel.Position               = UDim2.new(0, 16, 0.5, -206)
Panel.BackgroundColor3       = Color3.fromRGB(18, 20, 32)
Panel.BackgroundTransparency = 0
Panel.BorderSizePixel        = 0
Panel.Active                 = true
Panel.Draggable              = true
Panel.ZIndex                 = 10
Panel.Parent                 = SG

do
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,14); c.Parent = Panel
    local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(60,100,255); s.Thickness = 1.5; s.Parent = Panel
end

-- top bar
local TB = Instance.new("Frame")
TB.Size = UDim2.new(1,0,0,38); TB.BackgroundColor3 = Color3.fromRGB(80,50,230)
TB.BorderSizePixel = 0; TB.ZIndex = 11; TB.Parent = Panel
do
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100,60,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,160,255)),
    })
    g.Parent = TB
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,14); c.Parent = TB
    -- patch straight bottom edge
    local p = Instance.new("Frame")
    p.Size = UDim2.new(1,0,0,14); p.Position = UDim2.new(0,0,1,-14)
    p.BackgroundColor3 = Color3.fromRGB(80,50,230); p.BorderSizePixel = 0; p.ZIndex = 11; p.Parent = TB
    local g2 = Instance.new("UIGradient"); g2.Color = g.Color; g2.Parent = p
end

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1,-46,1,0); TitleLbl.Position = UDim2.new(0,12,0,0)
TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = "✦  CYRUZZZ PANEL"
TitleLbl.TextColor3 = Color3.fromRGB(230,240,255); TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 13; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex = 12; TitleLbl.Parent = TB

-- close (TextButton with explicit TextColor3 = no nil)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,26,0,26); CloseBtn.Position = UDim2.new(1,-32,0.5,-13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(210,45,65); CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "x"; CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 12
CloseBtn.AutoButtonColor = false; CloseBtn.ZIndex = 13; CloseBtn.Parent = TB
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,7)
CloseBtn.MouseButton1Click:Connect(function() SG:Destroy() end)

-- ============================================================
--  Row helpers
-- ============================================================
local BASE_COL   = Color3.fromRGB(28,32,50)
local STROKE_COL = Color3.fromRGB(50,60,100)

local function makeRow(posY)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-20,0,44); f.Position = UDim2.new(0,10,0,posY)
    f.BackgroundColor3 = BASE_COL; f.BorderSizePixel = 0; f.ZIndex = 11; f.Parent = Panel
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)
    local s = Instance.new("UIStroke"); s.Color = STROKE_COL; s.Thickness = 1; s.Parent = f
    return f, s
end

local function makeLabel(parent, text, size, pos, col, font, tsize, align)
    local l = Instance.new("TextLabel")
    l.Size = size; l.Position = pos; l.BackgroundTransparency = 1
    l.Text = text; l.TextColor3 = col; l.Font = font; l.TextSize = tsize
    l.TextXAlignment = align or Enum.TextXAlignment.Left
    l.ZIndex = 12; l.Parent = parent
    return l
end

-- ============================================================
--  TOGGLE ROWS
-- ============================================================
local function makeToggle(label, hotkey, posY, onCol)
    local row, rowStroke = makeRow(posY)

    -- dot indicator
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,8,0,8); dot.Position = UDim2.new(0,12,0.5,-4)
    dot.BackgroundColor3 = Color3.fromRGB(70,80,120); dot.BorderSizePixel = 0
    dot.ZIndex = 12; dot.Parent = row
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

    -- main label
    makeLabel(row, label,
        UDim2.new(1,-80,0,20), UDim2.new(0,26,0,5),
        Color3.fromRGB(205,215,255), Enum.Font.GothamSemibold, 12)

    -- sub label (status)
    local sub = makeLabel(row, "["..hotkey.."]  OFF",
        UDim2.new(1,-80,0,14), UDim2.new(0,26,0,24),
        Color3.fromRGB(85,100,150), Enum.Font.Gotham, 9)

    -- pill toggle
    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0,38,0,20); pill.Position = UDim2.new(1,-46,0.5,-10)
    pill.BackgroundColor3 = Color3.fromRGB(45,50,75); pill.BorderSizePixel = 0
    pill.ZIndex = 12; pill.Parent = row
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,14,0,14); knob.Position = UDim2.new(0,3,0.5,-7)
    knob.BackgroundColor3 = Color3.fromRGB(130,140,170); knob.BorderSizePixel = 0
    knob.ZIndex = 13; knob.Parent = pill
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    -- invisible click catcher
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1
    btn.Text = ""; btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.AutoButtonColor = false; btn.ZIndex = 14; btn.Parent = row

    local tw = TweenInfo.new(0.18, Enum.EasingStyle.Quad)
    local function setOn(v)
        if v then
            TweenService:Create(pill,  tw, {BackgroundColor3 = onCol}):Play()
            TweenService:Create(knob,  tw, {Position = UDim2.new(0,21,0.5,-7), BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
            TweenService:Create(dot,   tw, {BackgroundColor3 = onCol}):Play()
            TweenService:Create(row,   tw, {BackgroundColor3 = Color3.fromRGB(20,32,22)}):Play()
            TweenService:Create(rowStroke, tw, {Color = onCol}):Play()
            sub.Text = "["..hotkey.."]  ON"; sub.TextColor3 = Color3.fromRGB(100,220,120)
        else
            TweenService:Create(pill,  tw, {BackgroundColor3 = Color3.fromRGB(45,50,75)}):Play()
            TweenService:Create(knob,  tw, {Position = UDim2.new(0,3,0.5,-7), BackgroundColor3 = Color3.fromRGB(130,140,170)}):Play()
            TweenService:Create(dot,   tw, {BackgroundColor3 = Color3.fromRGB(70,80,120)}):Play()
            TweenService:Create(row,   tw, {BackgroundColor3 = BASE_COL}):Play()
            TweenService:Create(rowStroke, tw, {Color = STROKE_COL}):Play()
            sub.Text = "["..hotkey.."]  OFF"; sub.TextColor3 = Color3.fromRGB(85,100,150)
        end
    end
    return btn, setOn
end

-- ============================================================
--  TP ROWS
-- ============================================================
local function makeTpRow(label, hotkey, posY, r, g, b)
    local ac = Color3.fromRGB(r, g, b)
    local hc = Color3.fromRGB(math.min(r+40,255), math.min(g+40,255), math.min(b+40,255))

    local row, _ = makeRow(posY)

    makeLabel(row, label.."  ["..hotkey.."]",
        UDim2.new(0.58,0,0,20), UDim2.new(0,12,0,5),
        Color3.fromRGB(205,215,255), Enum.Font.GothamSemibold, 12)

    local coord = makeLabel(row, "Not set",
        UDim2.new(1,-20,0,14), UDim2.new(0,12,1,-18),
        Color3.fromRGB(80,95,140), Enum.Font.Gotham, 9)

    local setBtn = Instance.new("TextButton")
    setBtn.Size = UDim2.new(0,50,0,28); setBtn.Position = UDim2.new(1,-58,0.5,-14)
    setBtn.BackgroundColor3 = ac; setBtn.BorderSizePixel = 0
    setBtn.Text = "SET"; setBtn.TextColor3 = Color3.fromRGB(255,255,255)
    setBtn.Font = Enum.Font.GothamBold; setBtn.TextSize = 11
    setBtn.AutoButtonColor = false; setBtn.ZIndex = 12; setBtn.Parent = row
    Instance.new("UICorner", setBtn).CornerRadius = UDim.new(0,8)

    setBtn.MouseEnter:Connect(function()
        TweenService:Create(setBtn, TweenInfo.new(0.12), {BackgroundColor3 = hc}):Play()
    end)
    setBtn.MouseLeave:Connect(function()
        TweenService:Create(setBtn, TweenInfo.new(0.12), {BackgroundColor3 = ac}):Play()
    end)

    return setBtn, coord
end

-- ============================================================
--  BUILD ROWS
-- ============================================================
local flyClick,    setFlyOn    = makeToggle("Fly Mode",   "T", 48,  Color3.fromRGB(55,195,95))
local noclipClick, setNoclipOn = makeToggle("Noclip",     "C", 100, Color3.fromRGB(175,75,250))
local speedClick,  setSpeedOn  = makeToggle("Walk Speed", "Q", 152, Color3.fromRGB(255,150,50))
local tp1Btn, tp1Lbl           = makeTpRow("Teleport 1",  "H", 204, 45, 105, 225)
local tp2Btn, tp2Lbl           = makeTpRow("Teleport 2",  "J", 256, 205, 55, 55)

-- ============================================================
--  FLY SPEED CONTROL
-- ============================================================
local speedRow = Instance.new("Frame")
speedRow.Size = UDim2.new(1,-20,0,44); speedRow.Position = UDim2.new(0,10,0,308)
speedRow.BackgroundColor3 = BASE_COL; speedRow.BorderSizePixel = 0
speedRow.ZIndex = 11; speedRow.Parent = Panel
Instance.new("UICorner", speedRow).CornerRadius = UDim.new(0,10)
do local s = Instance.new("UIStroke"); s.Color = STROKE_COL; s.Thickness = 1; s.Parent = speedRow end

makeLabel(speedRow, "Fly Speed",
    UDim2.new(0.4,0,0,18), UDim2.new(0,12,0,4),
    Color3.fromRGB(205,215,255), Enum.Font.GothamSemibold, 11)

local speedVal = makeLabel(speedRow, tostring(flySpeed),
    UDim2.new(0.2,0,0,18), UDim2.new(0.4,0,0,4),
    Color3.fromRGB(130,175,255), Enum.Font.GothamBold, 12, Enum.TextXAlignment.Center)

-- bar visual
local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(1,-24,0,4); barBg.Position = UDim2.new(0,12,1,-10)
barBg.BackgroundColor3 = Color3.fromRGB(38,42,64); barBg.BorderSizePixel = 0
barBg.ZIndex = 12; barBg.Parent = speedRow
Instance.new("UICorner", barBg).CornerRadius = UDim.new(1,0)

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new((flySpeed-10)/190,0,1,0)
barFill.BackgroundColor3 = Color3.fromRGB(80,130,255)
barFill.BorderSizePixel = 0; barFill.ZIndex = 13; barFill.Parent = barBg
Instance.new("UICorner", barFill).CornerRadius = UDim.new(1,0)

local function makeSpeedBtn(txt, posX, delta)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,28,0,22); b.Position = UDim2.new(1, posX, 0, 5)
    b.BackgroundColor3 = Color3.fromRGB(38,45,72); b.BorderSizePixel = 0
    b.Text = txt; b.TextColor3 = Color3.fromRGB(180,200,255)
    b.Font = Enum.Font.GothamBold; b.TextSize = 14
    b.AutoButtonColor = false; b.ZIndex = 12; b.Parent = speedRow
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,7)

    local function upd()
        flySpeed = math.clamp(flySpeed + delta, 10, 200)
        speedVal.Text = tostring(flySpeed)
        barFill.Size  = UDim2.new((flySpeed-10)/190, 0, 1, 0)
    end
    b.MouseButton1Click:Connect(upd)
    
    local held = false
    b.MouseButton1Down:Connect(function()
        held = true
        task.spawn(function()
            task.wait(0.4)
            while held do upd(); task.wait(0.08) end
        end)
    end)
    b.MouseButton1Up:Connect(function() held = false end)
    b.MouseLeave:Connect(function() held = false end)
    return b
end

makeSpeedBtn("-", -62, -5)
makeSpeedBtn("+", -30, 5)

-- ============================================================
--  FOOTER
-- ============================================================
local foot = Instance.new("TextLabel")
foot.Size = UDim2.new(1,0,0,16); foot.Position = UDim2.new(0,0,0,390)
foot.BackgroundTransparency = 1; foot.Text = "CyRuZzz  •  drag panel to move"
foot.TextColor3 = Color3.fromRGB(45,55,85); foot.Font = Enum.Font.Gotham
foot.TextSize = 9; foot.ZIndex = 11; foot.Parent = Panel

-- ============================================================
--  FLY
-- ============================================================
local function getChar() return LP.Character end

local function enableFly()
    local c = getChar(); if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand = true

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    bv.Name = "_CyBV"; bv.Parent = hrp

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5,1e5,1e5); bg.D = 100; bg.P = 1e4
    bg.CFrame = hrp.CFrame; bg.Name = "_CyBG"; bg.Parent = hrp

    flyConn = RunService.RenderStepped:Connect(function()
        if not flyEnabled then return end
        local c2 = getChar(); if not c2 then return end
        local h2 = c2:FindFirstChild("HumanoidRootPart"); if not h2 then return end
        local bv2 = h2:FindFirstChild("_CyBV"); local bg2 = h2:FindFirstChild("_CyBG")
        if not bv2 or not bg2 then return end
        
        local cf = Camera.CFrame; local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W)         then dir += cf.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)         then dir -= cf.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)         then dir -= cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)         then dir += cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
        
        bv2.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
        bg2.CFrame = CFrame.lookAt(h2.Position, h2.Position + cf.LookVector)
    end)
end

local function disableFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    local c = getChar(); if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if hum then hum.PlatformStand = false end
    if hrp then
        local bv = hrp:FindFirstChild("_CyBV"); local bg = hrp:FindFirstChild("_CyBG")
        if bv then bv:Destroy() end; if bg then bg:Destroy() end
    end
end

-- ============================================================
--  NOCLIP
-- ============================================================
local function enableNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        if not noclipEnabled then return end
        local c = getChar(); if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end

local function disableNoclip()
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
end

-- ============================================================
--  WALK SPEED
-- ============================================================
local function enableSpeed()
    -- Pakai loop supaya kecepatan nggak kereset sama script game bawaan
    speedConn = RunService.RenderStepped:Connect(function()
        if not speedEnabled then return end
        local c = getChar()
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = walkSpeedVal
        end
    end)
end

local function disableSpeed()
    if speedConn then speedConn:Disconnect(); speedConn = nil end
    local c = getChar()
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16 end -- Kembali ke kecepatan normal (16)
end

-- ============================================================
--  TELEPORT
-- ============================================================
local function setTp(slot)
    local c = getChar(); local h = c and c:FindFirstChild("HumanoidRootPart")
    if not h then return end
    local cf = h.CFrame
    if slot == 1 then
        tp1Pos = cf; tp1Lbl.Text = string.format("%.0f, %.0f, %.0f", cf.X, cf.Y, cf.Z)
        tp1Lbl.TextColor3 = Color3.fromRGB(90,210,130)
    else
        tp2Pos = cf; tp2Lbl.Text = string.format("%.0f, %.0f, %.0f", cf.X, cf.Y, cf.Z)
        tp2Lbl.TextColor3 = Color3.fromRGB(220,105,105)
    end
end

local function doTp(slot)
    local c = getChar(); local h = c and c:FindFirstChild("HumanoidRootPart")
    if not h then return end
    local pos = slot == 1 and tp1Pos or tp2Pos
    if pos then h.CFrame = pos end
end

-- ============================================================
--  CALLBACKS
-- ============================================================
flyClick.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled; setFlyOn(flyEnabled)
    if flyEnabled then enableFly() else disableFly() end
end)

noclipClick.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled; setNoclipOn(noclipEnabled)
    if noclipEnabled then enableNoclip() else disableNoclip() end
end)

speedClick.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled; setSpeedOn(speedEnabled)
    if speedEnabled then enableSpeed() else disableSpeed() end
end)

tp1Btn.MouseButton1Click:Connect(function() setTp(1) end)
tp2Btn.MouseButton1Click:Connect(function() setTp(2) end)

-- ============================================================
--  HOTKEYS
-- ============================================================
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    local k = inp.KeyCode
    if k == Enum.KeyCode.T then
        flyEnabled = not flyEnabled; setFlyOn(flyEnabled)
        if flyEnabled then enableFly() else disableFly() end
    elseif k == Enum.KeyCode.C then
        noclipEnabled = not noclipEnabled; setNoclipOn(noclipEnabled)
        if noclipEnabled then enableNoclip() else disableNoclip() end
    elseif k == Enum.KeyCode.Q then
        speedEnabled = not speedEnabled; setSpeedOn(speedEnabled)
        if speedEnabled then enableSpeed() else disableSpeed() end
    elseif k == Enum.KeyCode.H then doTp(1)
    elseif k == Enum.KeyCode.J then doTp(2)
    end
end)

-- ============================================================
--  RESPAWN
-- ============================================================
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if flyEnabled    then enableFly()    end
    if noclipEnabled then enableNoclip() end
    if speedEnabled  then enableSpeed()  end
end)

print("[CyRuZzz] Ready! T=Fly | C=Noclip | Q=Speed | H=TP1 | J=TP2")
