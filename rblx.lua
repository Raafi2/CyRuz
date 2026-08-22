-- ============================================================
--  CyRuZzz Panel | Roblox LocalScript
--  [T] Fly  [C] Noclip  [Q] WalkSpeed  [H] TP1  [J] TP2
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
local espEnabled    = false
local tp1Pos        = nil
local tp2Pos        = nil
local flyConn       = nil
local noclipConn    = nil
local speedConn     = nil
local flySpeed      = 60
local walkSpeedVal  = 100
local selectedPlayer = nil

-- ESP variables
local espObjects          = {}
local espConn             = nil
local espPlayerAddedConn  = nil
local espPlayerRemoveConn = nil

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
Panel.Size                   = UDim2.new(0, 230, 0, 546) -- Diperpanjang untuk menu TP Player
Panel.Position               = UDim2.new(0, 16, 0.5, -273)
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

-- Top Bar
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

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,26,0,26); CloseBtn.Position = UDim2.new(1,-32,0.5,-13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(210,45,65); CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "x"; CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 12
CloseBtn.AutoButtonColor = false; CloseBtn.ZIndex = 13; CloseBtn.Parent = TB
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,7)
CloseBtn.MouseButton1Click:Connect(function() SG:Destroy() end)

-- Helpers
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

-- Toggle Rows
local function makeToggle(label, hotkey, posY, onCol)
    local row, rowStroke = makeRow(posY)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,8,0,8); dot.Position = UDim2.new(0,12,0.5,-4)
    dot.BackgroundColor3 = Color3.fromRGB(70,80,120); dot.BorderSizePixel = 0
    dot.ZIndex = 12; dot.Parent = row
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

    makeLabel(row, label,
        UDim2.new(1,-80,0,20), UDim2.new(0,26,0,5),
        Color3.fromRGB(205,215,255), Enum.Font.GothamSemibold, 12)

    local sub = makeLabel(row, "["..hotkey.."]  OFF",
        UDim2.new(1,-80,0,14), UDim2.new(0,26,0,24),
        Color3.fromRGB(85,100,150), Enum.Font.Gotham, 9)

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

-- TP Rows
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

    setBtn.MouseEnter:Connect(function() TweenService:Create(setBtn, TweenInfo.new(0.12), {BackgroundColor3 = hc}):Play() end)
    setBtn.MouseLeave:Connect(function() TweenService:Create(setBtn, TweenInfo.new(0.12), {BackgroundColor3 = ac}):Play() end)

    return setBtn, coord
end

-- Build Menus
local flyClick,    setFlyOn    = makeToggle("Fly Mode",       "T", 48,  Color3.fromRGB(55,195,95))
local noclipClick, setNoclipOn = makeToggle("Noclip",         "C", 100, Color3.fromRGB(175,75,250))
local speedClick,  setSpeedOn  = makeToggle("Walk Speed",     "Q", 152, Color3.fromRGB(255,150,50))
local espClick,    setEspOn    = makeToggle("ESP & Red Body", "-", 204, Color3.fromRGB(255,60,110))
local tp1Btn, tp1Lbl           = makeTpRow("Teleport 1",      "H", 256, 45, 105, 225)
local tp2Btn, tp2Lbl           = makeTpRow("Teleport 2",      "J", 308, 205, 55, 55)

-- ESP Refresh Button
local espRow = espClick.Parent
local espRefreshBtn = Instance.new("TextButton")
espRefreshBtn.Size = UDim2.new(0, 45, 0, 22)
espRefreshBtn.Position = UDim2.new(1, -95, 0.5, -11)
espRefreshBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 90)
espRefreshBtn.BorderSizePixel = 0
espRefreshBtn.Text = "RELOAD"
espRefreshBtn.TextColor3 = Color3.fromRGB(200, 210, 255)
espRefreshBtn.Font = Enum.Font.GothamBold
espRefreshBtn.TextSize = 9
espRefreshBtn.AutoButtonColor = false
espRefreshBtn.ZIndex = 15
espRefreshBtn.Parent = espRow
Instance.new("UICorner", espRefreshBtn).CornerRadius = UDim.new(0, 6)

-- ============================================================
--  TELEPORT TO PLAYER ROW
-- ============================================================
local tpPlrRow = makeRow(360)

local selectBtn = Instance.new("TextButton")
selectBtn.Size = UDim2.new(1, -75, 0, 28)
selectBtn.Position = UDim2.new(0, 10, 0.5, -14)
selectBtn.BackgroundColor3 = Color3.fromRGB(38, 45, 72)
selectBtn.BorderSizePixel = 0
selectBtn.Text = "Pilih Player..."
selectBtn.TextColor3 = Color3.fromRGB(180, 200, 255)
selectBtn.Font = Enum.Font.GothamSemibold
selectBtn.TextSize = 10
selectBtn.ZIndex = 12
selectBtn.Parent = tpPlrRow
Instance.new("UICorner", selectBtn).CornerRadius = UDim.new(0, 6)

local gotoBtn = Instance.new("TextButton")
gotoBtn.Size = UDim2.new(0, 48, 0, 28)
gotoBtn.Position = UDim2.new(1, -58, 0.5, -14)
gotoBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
gotoBtn.BorderSizePixel = 0
gotoBtn.Text = "TP"
gotoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
gotoBtn.Font = Enum.Font.GothamBold
gotoBtn.TextSize = 11
gotoBtn.ZIndex = 12
gotoBtn.Parent = tpPlrRow
Instance.new("UICorner", gotoBtn).CornerRadius = UDim.new(0, 6)

-- Dropdown Menu Frame
local dropFrame = Instance.new("ScrollingFrame")
dropFrame.Size = UDim2.new(1, -20, 0, 100)
dropFrame.Position = UDim2.new(0, 10, 0, 406)
dropFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
dropFrame.BorderSizePixel = 0
dropFrame.Visible = false
dropFrame.ZIndex = 20
dropFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
dropFrame.ScrollBarThickness = 4
dropFrame.Parent = Panel
Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0, 8)

local dropLayout = Instance.new("UIListLayout")
dropLayout.SortOrder = Enum.SortOrder.LayoutOrder
dropLayout.Parent = dropFrame

local function updatePlayerList()
    for _, child in ipairs(dropFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            count = count + 1
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, 0, 0, 24)
            pBtn.BackgroundColor3 = Color3.fromRGB(28, 32, 50)
            pBtn.BorderSizePixel = 0
            pBtn.Text = plr.Name
            pBtn.TextColor3 = Color3.fromRGB(200, 210, 255)
            pBtn.Font = Enum.Font.Gotham
            pBtn.TextSize = 10
            pBtn.ZIndex = 21
            pBtn.Parent = dropFrame
            
            pBtn.MouseButton1Click:Connect(function()
                selectedPlayer = plr
                selectBtn.Text = plr.Name
                dropFrame.Visible = false
            end)
        end
    end
    dropFrame.CanvasSize = UDim2.new(0, 0, 0, count * 24)
end

selectBtn.MouseButton1Click:Connect(function()
    dropFrame.Visible = not dropFrame.Visible
    if dropFrame.Visible then updatePlayerList() end
end)

gotoBtn.MouseButton1Click:Connect(function()
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myChar = LP.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myHrp then
            myHrp.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 3)
        end
    end
end)

-- Speed Controls
local function makeControlRow(title, posY, val, minV, maxV, onUpdate)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-20,0,44); row.Position = UDim2.new(0,10,0,posY)
    row.BackgroundColor3 = BASE_COL; row.BorderSizePixel = 0
    row.ZIndex = 11; row.Parent = Panel
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,10)
    do local s = Instance.new("UIStroke"); s.Color = STROKE_COL; s.Thickness = 1; s.Parent = row end

    makeLabel(row, title, UDim2.new(0.4,0,0,18), UDim2.new(0,12,0,4), Color3.fromRGB(205,215,255), Enum.Font.GothamSemibold, 11)
    local valLbl = makeLabel(row, tostring(val), UDim2.new(0.2,0,0,18), UDim2.new(0.4,0,0,4), Color3.fromRGB(130,175,255), Enum.Font.GothamBold, 12, Enum.TextXAlignment.Center)

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1,-24,0,4); barBg.Position = UDim2.new(0,12,1,-10)
    barBg.BackgroundColor3 = Color3.fromRGB(38,42,64); barBg.BorderSizePixel = 0; barBg.ZIndex = 12; barBg.Parent = row
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1,0)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new((val-minV)/(maxV-minV),0,1,0); barFill.BackgroundColor3 = Color3.fromRGB(80,130,255)
    barFill.BorderSizePixel = 0; barFill.ZIndex = 13; barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1,0)

    local function makeBtn(txt, posX, delta)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,28,0,22); b.Position = UDim2.new(1, posX, 0, 5)
        b.BackgroundColor3 = Color3.fromRGB(38,45,72); b.BorderSizePixel = 0
        b.Text = txt; b.TextColor3 = Color3.fromRGB(180,200,255)
        b.Font = Enum.Font.GothamBold; b.TextSize = 14; b.AutoButtonColor = false; b.ZIndex = 12; b.Parent = row
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,7)

        local function upd()
            val = math.clamp(val + delta, minV, maxV)
            valLbl.Text = tostring(val)
            barFill.Size = UDim2.new((val-minV)/(maxV-minV), 0, 1, 0)
            onUpdate(val)
        end
        b.MouseButton1Click:Connect(upd)
    end
    makeBtn("-", -62, -5)
    makeBtn("+", -30, 5)
end

makeControlRow("Fly Speed",  412, flySpeed,     10, 300, function(v) flySpeed = v end)
makeControlRow("Walk Speed", 464, walkSpeedVal, 16, 300, function(v) walkSpeedVal = v end)

-- Footer
local foot = Instance.new("TextLabel")
foot.Size = UDim2.new(1,0,0,16); foot.Position = UDim2.new(0,0,0,522)
foot.BackgroundTransparency = 1; foot.Text = "CyRuZzz  •  drag panel to move"
foot.TextColor3 = Color3.fromRGB(45,55,85); foot.Font = Enum.Font.Gotham
foot.TextSize = 9; foot.ZIndex = 11; foot.Parent = Panel

-- Logika Utama (Fly, Noclip, Speed, ESP)
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

local function enableSpeed()
    speedConn = RunService.RenderStepped:Connect(function()
        if not speedEnabled then return end
        local c = getChar()
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = walkSpeedVal end
    end)
end

local function disableSpeed()
    if speedConn then speedConn:Disconnect(); speedConn = nil end
    local c = getChar()
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16 end
end

local function createEspGui(plr)
    if plr == LP or espObjects[plr] then return end
    local espData = {}
    local espHolder = Instance.new("BillboardGui")
    espHolder.Name = "_CyESP_" .. plr.Name; espHolder.AlwaysOnTop = true
    espHolder.Size = UDim2.new(0, 100, 0, 40); espHolder.StudsOffset = Vector3.new(0, 2.5, 0)
    
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, 0, 1, 0); nameLbl.BackgroundTransparency = 1
    nameLbl.Text = plr.Name; nameLbl.TextColor3 = Color3.fromRGB(255, 60, 110)
    nameLbl.TextStrokeTransparency = 0.3; nameLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 11; nameLbl.Parent = espHolder
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "_CyChams_" .. plr.Name; highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0); highlight.FillTransparency = 0.5; highlight.OutlineTransparency = 0.1

    pcall(function() espHolder.Parent = game:GetService("CoreGui"); highlight.Parent = game:GetService("CoreGui") end)

    espData.Billboard = espHolder; espData.Highlight = highlight
    espObjects[plr] = espData
end

local function removeEspGui(plr)
    if espObjects[plr] then
        if espObjects[plr].Billboard then espObjects[plr].Billboard:Destroy() end
        if espObjects[plr].Highlight then espObjects[plr].Highlight:Destroy() end
        espObjects[plr] = nil
    end
end

local function enableEsp()
    for _, plr in ipairs(Players:GetPlayers()) do createEspGui(plr) end
    espPlayerAddedConn = Players.PlayerAdded:Connect(createEspGui)
    espPlayerRemoveConn = Players.PlayerRemoving:Connect(removeEspGui)
    
    espConn = RunService.RenderStepped:Connect(function()
        if not espEnabled then return end
        for plr, data in pairs(espObjects) do
            local char = plr.Character
            if char and char:FindFirstChild("Head") then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    data.Billboard.Adornee = char.Head; data.Billboard.Enabled = true
                    data.Highlight.Adornee = char; data.Highlight.Enabled = true
                else
                    data.Billboard.Enabled = false; data.Highlight.Enabled = false
                end
            else
                data.Billboard.Enabled = false; data.Highlight.Enabled = false
            end
        end
    end)
end

local function disableEsp()
    if espPlayerAddedConn then espPlayerAddedConn:Disconnect(); espPlayerAddedConn = nil end
    if espPlayerRemoveConn then espPlayerRemoveConn:Disconnect(); espPlayerRemoveConn = nil end
    if espConn then espConn:Disconnect(); espConn = nil end
    for plr, _ in pairs(espObjects) do removeEspGui(plr) end
    table.clear(espObjects)
end

espRefreshBtn.MouseButton1Click:Connect(function()
    if espEnabled then disableEsp(); task.wait(0.1); enableEsp() end
end)

local function setTp(slot)
    local c = getChar(); local h = c and c:FindFirstChild("HumanoidRootPart")
    if not h then return end
    local cf = h.CFrame
    if slot == 1 then
        tp1Pos = cf; tp1Lbl.Text = string.format("%.0f, %.0f, %.0f", cf.X, cf.Y, cf.Z); tp1Lbl.TextColor3 = Color3.fromRGB(90,210,130)
    else
        tp2Pos = cf; tp2Lbl.Text = string.format("%.0f, %.0f, %.0f", cf.X, cf.Y, cf.Z); tp2Lbl.TextColor3 = Color3.fromRGB(220,105,105)
    end
end

local function doTp(slot)
    local c = getChar(); local h = c and c:FindFirstChild("HumanoidRootPart")
    if not h then return end
    local pos = slot == 1 and tp1Pos or tp2Pos
    if pos then h.CFrame = pos end
end

-- Callbacks & Hotkeys
flyClick.MouseButton1Click:Connect(function() flyEnabled = not flyEnabled; setFlyOn(flyEnabled); if flyEnabled then enableFly() else disableFly() end end)
noclipClick.MouseButton1Click:Connect(function() noclipEnabled = not noclipEnabled; setNoclipOn(noclipEnabled); if noclipEnabled then enableNoclip() else disableNoclip() end end)
speedClick.MouseButton1Click:Connect(function() speedEnabled = not speedEnabled; setSpeedOn(speedEnabled); if speedEnabled then enableSpeed() else disableSpeed() end end)
espClick.MouseButton1Click:Connect(function() espEnabled = not espEnabled; setEspOn(espEnabled); if espEnabled then enableEsp() else disableEsp() end end)
tp1Btn.MouseButton1Click:Connect(function() setTp(1) end)
tp2Btn.MouseButton1Click:Connect(function() setTp(2) end)

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    local k = inp.KeyCode
    if k == Enum.KeyCode.T then flyEnabled = not flyEnabled; setFlyOn(flyEnabled); if flyEnabled then enableFly() else disableFly() end
    elseif k == Enum.KeyCode.C then noclipEnabled = not noclipEnabled; setNoclipOn(noclipEnabled); if noclipEnabled then enableNoclip() else disableNoclip() end
    elseif k == Enum.KeyCode.Q then speedEnabled = not speedEnabled; setSpeedOn(speedEnabled); if speedEnabled then enableSpeed() else disableSpeed() end
    elseif k == Enum.KeyCode.H then doTp(1)
    elseif k == Enum.KeyCode.J then doTp(2)
    end
end)

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if flyEnabled then enableFly() end
    if noclipEnabled then enableNoclip() end
    if speedEnabled then enableSpeed() end
end)

print("[CyRuZzz] Ready!")
