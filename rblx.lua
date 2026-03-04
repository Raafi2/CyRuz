--[[
    CyRuZzz HUB
]]

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player            = Players.LocalPlayer
local camera            = workspace.CurrentCamera

-- ============================================================
-- CLEANUP
-- ============================================================
for _, ui in pairs(player.PlayerGui:GetChildren()) do
    if ui.Name == "CyRuZzz_Hub" then ui:Destroy() end
end
for _, h in pairs(workspace:GetChildren()) do
    if h.Name == "_CyESP" then h:Destroy() end
end

local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name         = "CyRuZzz_Hub"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ============================================================
-- UTIL
-- ============================================================
local function Lerp(a,b,t) return a+(b-a)*t end
local function Corner(p,r) local c=Instance.new("UICorner",p) c.CornerRadius=UDim.new(0,r or 8) return c end
local function Stroke(p,col,th) local s=Instance.new("UIStroke",p) s.Color=col or Color3.fromRGB(130,80,255) s.Thickness=th or 1.5 return s end
local function Tween(obj,t,props) TweenService:Create(obj,TweenInfo.new(t,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),props):Play() end

-- ============================================================
-- WARNA
-- ============================================================
local C = {
    BG      = Color3.fromRGB(10,10,18),
    Panel   = Color3.fromRGB(16,14,26),
    Card    = Color3.fromRGB(22,20,36),
    CardHov = Color3.fromRGB(34,30,54),
    Accent  = Color3.fromRGB(130,80,255),
    Accent2 = Color3.fromRGB(70,150,255),
    Green   = Color3.fromRGB(40,200,110),
    Red     = Color3.fromRGB(200,50,70),
    Orange  = Color3.fromRGB(255,150,40),
    Yellow  = Color3.fromRGB(255,215,40),
    Cyan    = Color3.fromRGB(40,220,210),
    Pink    = Color3.fromRGB(255,75,175),
    Lime    = Color3.fromRGB(120,255,80),
    Text    = Color3.fromRGB(228,222,255),
    Sub     = Color3.fromRGB(120,110,155),
    Input   = Color3.fromRGB(14,12,24),
    TabBG   = Color3.fromRGB(13,11,22),
}

-- ============================================================
-- STATE
-- ============================================================
local State = {
    speedOn    = false,
    flying     = false,
    ghost      = false,
    godmode    = false,
    espObj     = false,
    espAvatar  = false,
    targetLock = false,
    magnet     = false,
    offsetDist = 15,
    -- AUTO
    autoRebirth = false,
    autoSell    = false,
    autoCollect = false,
    autoBaseUp  = false,
    autoSlotUp  = false,
}

local originalWalkSpeed = 16

-- ============================================================
-- REMOTE HELPER — cari remote di Events atau root RS
-- ============================================================
local Ev = ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage

local function FindRemote(name)
    -- Cari di Events dulu, lalu ReplicatedStorage, lalu workspace
    local r = Ev:FindFirstChild(name)
              or ReplicatedStorage:FindFirstChild(name, true)
              or workspace:FindFirstChild(name, true)
    return r
end

-- ============================================================
-- MAIN WINDOW  (340 x 470)
-- ============================================================
local Main = Instance.new("Frame", sg)
Main.Name             = "Main"
Main.Size             = UDim2.new(0,340,0,470)
Main.Position         = UDim2.new(0.5,-170,0.5,-235)
Main.BackgroundColor3 = C.BG
Main.Active = true Main.Draggable = true Main.ClipsDescendants = true
Corner(Main,14)
local mainStroke = Stroke(Main,C.Accent,2)

local bgGrad = Instance.new("UIGradient",Main)
bgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(13,10,22)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(9,8,18))
}) bgGrad.Rotation = 135

-- Topbar
local Topbar = Instance.new("Frame",Main)
Topbar.Size = UDim2.new(1,0,0,44) Topbar.BackgroundColor3 = C.Panel Corner(Topbar,14)
local TopFix = Instance.new("Frame",Topbar)
TopFix.Size = UDim2.new(1,0,0,14) TopFix.Position = UDim2.new(0,0,1,-14)
TopFix.BackgroundColor3 = C.Panel TopFix.BorderSizePixel = 0

local Dot = Instance.new("Frame",Topbar)
Dot.Size = UDim2.new(0,7,0,7) Dot.Position = UDim2.new(0,12,0.5,-3.5)
Dot.BackgroundColor3 = C.Accent Corner(Dot,4)

local TitleLbl = Instance.new("TextLabel",Topbar)
TitleLbl.Size = UDim2.new(1,-100,1,0) TitleLbl.Position = UDim2.new(0,24,0,0)
TitleLbl.Text = "CyRuZzz Hub  v2.0" TitleLbl.TextColor3 = C.Text
TitleLbl.Font = Enum.Font.GothamBold TitleLbl.TextSize = 14
TitleLbl.BackgroundTransparency = 1 TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

local function TopBtn(txt,xOff,col)
    local b = Instance.new("TextButton",Topbar)
    b.Size = UDim2.new(0,26,0,26) b.Position = UDim2.new(1,xOff,0.5,-13)
    b.Text = txt b.BackgroundColor3 = col b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold b.TextSize = 12 b.BorderSizePixel = 0
    b.AutoButtonColor = false Corner(b,6) return b
end
local MinBtn   = TopBtn("−",-60,C.CardHov)
local CloseBtn = TopBtn("✕",-28,C.Red)

-- ============================================================
-- TAB BAR  (5 tab)
-- ============================================================
local TabBar = Instance.new("Frame",Main)
TabBar.Size = UDim2.new(1,-16,0,30) TabBar.Position = UDim2.new(0,8,0,48)
TabBar.BackgroundColor3 = C.TabBG Corner(TabBar,8)
local TabLayout = Instance.new("UIListLayout",TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder TabLayout.Padding = UDim.new(0,2)
local TabPad = Instance.new("UIPadding",TabBar)
TabPad.PaddingLeft=UDim.new(0,3) TabPad.PaddingRight=UDim.new(0,3)
TabPad.PaddingTop=UDim.new(0,3) TabPad.PaddingBottom=UDim.new(0,3)

local ContentArea = Instance.new("Frame",Main)
ContentArea.Size = UDim2.new(1,-16,1,-88) ContentArea.Position = UDim2.new(0,8,0,84)
ContentArea.BackgroundTransparency = 1

local pages   = {}
local tabBtns = {}

local tabDefs = {
    {name="MAIN",  icon="⚡", col=C.Accent},
    {name="ESP",   icon="👁",  col=C.Cyan},
    {name="SCAN",  icon="🔍", col=C.Accent2},
    {name="AUTO",  icon="🤖", col=C.Lime},
    {name="REMOT", icon="📡", col=C.Pink},
}

for i,def in ipairs(tabDefs) do
    local tb = Instance.new("TextButton",TabBar)
    tb.Size = UDim2.new(0.2,-2,1,0)
    tb.Text = def.icon.." "..def.name
    tb.Font = Enum.Font.GothamSemibold tb.TextSize = 9
    tb.BackgroundColor3 = C.Card tb.TextColor3 = C.Sub
    tb.AutoButtonColor = false tb.LayoutOrder = i Corner(tb,6)
    tabBtns[def.name] = {btn=tb,def=def}
    local page = Instance.new("Frame",ContentArea)
    page.Size = UDim2.new(1,0,1,0) page.BackgroundTransparency = 1 page.Visible = false
    pages[def.name] = page
end

local function SwitchTab(name)
    for n,p in pairs(pages) do p.Visible = n==name end
    for n,t in pairs(tabBtns) do
        local active = n==name
        Tween(t.btn,0.12,{
            BackgroundColor3 = active and t.def.col or C.Card,
            TextColor3       = active and Color3.new(1,1,1) or C.Sub
        })
    end
end
for name,t in pairs(tabBtns) do
    t.btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
end

-- ============================================================
-- HELPER BUILDERS
-- ============================================================
local function MkScroll(parent)
    local sf = Instance.new("ScrollingFrame",parent)
    sf.Size = UDim2.new(1,0,1,0) sf.BackgroundTransparency = 1 sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 3 sf.ScrollBarImageColor3 = C.Accent sf.CanvasSize = UDim2.new(0,0,0,0)
    local vl = Instance.new("UIListLayout",sf)
    vl.Padding = UDim.new(0,5) vl.SortOrder = Enum.SortOrder.LayoutOrder
    vl.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local pad = Instance.new("UIPadding",sf)
    pad.PaddingTop = UDim.new(0,4) pad.PaddingBottom = UDim.new(0,4)
    vl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0,0,0,vl.AbsoluteContentSize.Y+12)
    end)
    return sf
end

local function MkRow(parent,h,order)
    local f = Instance.new("Frame",parent)
    f.Size = UDim2.new(1,0,0,h) f.BackgroundColor3 = C.Card f.LayoutOrder = order or 0
    Corner(f,8) return f
end

local function SetToggle(btn,state,label,onCol,offCol)
    onCol = onCol or C.Green offCol = offCol or C.Red
    btn.Text = label..":  "..(state and "ON ✓" or "OFF")
    Tween(btn,0.15,{BackgroundColor3 = state and onCol or offCol})
end

local function MkToggleBtn(parent,label,col,offCol,order)
    local row = MkRow(parent,34,order)
    local btn = Instance.new("TextButton",row)
    btn.Size = UDim2.new(1,-10,1,-10) btn.Position = UDim2.new(0,5,0,5)
    btn.Text = label..":  OFF" btn.BackgroundColor3 = offCol or C.Red
    btn.TextColor3 = C.Text btn.Font = Enum.Font.GothamSemibold btn.TextSize = 12
    btn.AutoButtonColor = false Corner(btn,6)
    return btn, row
end

local function MkTextBtn(parent,txt,col,w,xPos,yPos,h)
    local b = Instance.new("TextButton",parent)
    b.Size = UDim2.new(w or 1,0,0,h or 28) b.Position = UDim2.new(xPos or 0,0,0,yPos or 0)
    b.Text = txt b.BackgroundColor3 = col b.TextColor3 = C.Text
    b.Font = Enum.Font.GothamSemibold b.TextSize = 11
    b.AutoButtonColor = false Corner(b,6) return b
end

-- ============================================================
-- PAGE: MAIN
-- ============================================================
local mainScroll = MkScroll(pages["MAIN"])

local speedRow = MkRow(mainScroll,36,1)
local SpeedInp = Instance.new("TextBox",speedRow)
SpeedInp.Size = UDim2.new(0,70,1,-10) SpeedInp.Position = UDim2.new(0,5,0,5)
SpeedInp.Text = "120" SpeedInp.PlaceholderText = "Speed"
SpeedInp.BackgroundColor3 = C.Input SpeedInp.TextColor3 = C.Text
SpeedInp.Font = Enum.Font.Gotham SpeedInp.TextSize = 12
SpeedInp.ClearTextOnFocus = false Corner(SpeedInp,6)

local SpeedToggle = Instance.new("TextButton",speedRow)
SpeedToggle.Size = UDim2.new(1,-84,1,-10) SpeedToggle.Position = UDim2.new(0,79,0,5)
SpeedToggle.Text = "SPEED:  OFF" SpeedToggle.BackgroundColor3 = C.Red
SpeedToggle.TextColor3 = C.Text SpeedToggle.Font = Enum.Font.GothamSemibold SpeedToggle.TextSize = 12
SpeedToggle.AutoButtonColor = false Corner(SpeedToggle,6)

local FlyToggle,   _ = MkToggleBtn(mainScroll,"✈  FLY",    C.Green,C.Red,2)
local GhostToggle, _ = MkToggleBtn(mainScroll,"👻 GHOST",   C.Green,C.Red,3)
local GodToggle,   _ = MkToggleBtn(mainScroll,"🛡  GODMODE",C.Green,C.Red,4)

local sliderRow = MkRow(mainScroll,50,5)
local SliderLbl = Instance.new("TextLabel",sliderRow)
SliderLbl.Size = UDim2.new(1,-10,0,18) SliderLbl.Position = UDim2.new(0,8,0,4)
SliderLbl.Text = "Offset Godmode: 15" SliderLbl.TextColor3 = C.Sub
SliderLbl.Font = Enum.Font.Gotham SliderLbl.TextSize = 11
SliderLbl.BackgroundTransparency = 1 SliderLbl.TextXAlignment = Enum.TextXAlignment.Left

local SliderTrack = Instance.new("Frame",sliderRow)
SliderTrack.Size = UDim2.new(1,-16,0,8) SliderTrack.Position = UDim2.new(0,8,0,30)
SliderTrack.BackgroundColor3 = C.Input Corner(SliderTrack,4)
local SliderFill = Instance.new("Frame",SliderTrack)
SliderFill.Size = UDim2.new(0.25,0,1,0) SliderFill.BackgroundColor3 = C.Accent
SliderFill.BorderSizePixel = 0 Corner(SliderFill,4)
local SliderKnob = Instance.new("TextButton",SliderTrack)
SliderKnob.Size = UDim2.new(0,16,0,16) SliderKnob.Position = UDim2.new(0.25,-8,0.5,-8)
SliderKnob.Text = "" SliderKnob.BackgroundColor3 = C.Accent SliderKnob.ZIndex = 5
SliderKnob.AutoButtonColor = false Corner(SliderKnob,8)

local statRow = MkRow(mainScroll,26,6)
statRow.BackgroundTransparency = 0.6
local StatLbl = Instance.new("TextLabel",statRow)
StatLbl.Size = UDim2.new(1,-10,1,0) StatLbl.Position = UDim2.new(0,8,0,0)
StatLbl.Text = "⚡ Ready" StatLbl.TextColor3 = C.Accent
StatLbl.Font = Enum.Font.Gotham StatLbl.TextSize = 11
StatLbl.BackgroundTransparency = 1 StatLbl.TextXAlignment = Enum.TextXAlignment.Left

-- ============================================================
-- PAGE: ESP
-- ============================================================
local espScroll = MkScroll(pages["ESP"])
local EspObjToggle,_ = MkToggleBtn(espScroll,"🔵 ESP OBJECT", C.Accent2,C.Red,1)
local EspAvaToggle,_ = MkToggleBtn(espScroll,"👤 ESP AVATAR",  C.Pink,  C.Red,2)
local LockToggle,_   = MkToggleBtn(espScroll,"🎯 TARGET LOCK", C.Orange,C.Red,3)

local hkRow = MkRow(espScroll,50,4) hkRow.BackgroundTransparency = 0.6
local hkLbl = Instance.new("TextLabel",hkRow)
hkLbl.Size = UDim2.new(1,-10,1,-8) hkLbl.Position = UDim2.new(0,8,0,4)
hkLbl.Text = "Hotkeys:\n  T = Toggle Lock Nearest\n  G = Ganti Target Berikutnya"
hkLbl.TextColor3 = C.Sub hkLbl.Font = Enum.Font.Gotham hkLbl.TextSize = 10
hkLbl.BackgroundTransparency = 1 hkLbl.TextXAlignment = Enum.TextXAlignment.Left

local espStatRow = MkRow(espScroll,26,5) espStatRow.BackgroundTransparency = 0.6
local EspStatLbl = Instance.new("TextLabel",espStatRow)
EspStatLbl.Size = UDim2.new(1,-10,1,0) EspStatLbl.Position = UDim2.new(0,8,0,0)
EspStatLbl.Text = "ESP: Standby" EspStatLbl.TextColor3 = C.Cyan
EspStatLbl.Font = Enum.Font.Gotham EspStatLbl.TextSize = 11
EspStatLbl.BackgroundTransparency = 1 EspStatLbl.TextXAlignment = Enum.TextXAlignment.Left

-- ============================================================
-- PAGE: SCAN
-- ============================================================
local scanPage = pages["SCAN"]

local SearchBox = Instance.new("TextBox",scanPage)
SearchBox.Size = UDim2.new(1,0,0,28) SearchBox.Position = UDim2.new(0,0,0,0)
SearchBox.PlaceholderText = "Cari nama objek..."
SearchBox.Text = "" SearchBox.BackgroundColor3 = C.Input SearchBox.TextColor3 = C.Text
SearchBox.Font = Enum.Font.Gotham SearchBox.TextSize = 11 SearchBox.ClearTextOnFocus = false
Corner(SearchBox,6)

local ScanRefBtn  = MkTextBtn(scanPage,"SCAN",    C.Accent2,1/3,  0,   32,26)
local ScanTeleBtn = MkTextBtn(scanPage,"TP",      C.Card,   1/3, 1/3,  32,26) ScanTeleBtn.TextColor3 = C.Sub
local ScanEspBtn  = MkTextBtn(scanPage,"ESP",     C.Card,   1/3, 2/3,  32,26) ScanEspBtn.TextColor3  = C.Sub

local FilterRow = Instance.new("Frame",scanPage)
FilterRow.Size = UDim2.new(1,0,0,22) FilterRow.Position = UDim2.new(0,0,0,62)
FilterRow.BackgroundTransparency = 1
local FRowLayout = Instance.new("UIListLayout",FilterRow)
FRowLayout.FillDirection = Enum.FillDirection.Horizontal FRowLayout.Padding = UDim.new(0,3)

local filterActive = "ALL"
local filterBtns   = {}
for i,label in ipairs({"ALL","Player","Model","Part","NPC"}) do
    local fb = Instance.new("TextButton",FilterRow)
    fb.Size = UDim2.new(0,i==1 and 32 or 50,1,0)
    fb.Text = label fb.Font = Enum.Font.GothamSemibold fb.TextSize = 9
    fb.BackgroundColor3 = i==1 and C.Accent or C.Card
    fb.TextColor3 = i==1 and Color3.new(1,1,1) or C.Sub
    fb.AutoButtonColor = false fb.LayoutOrder = i Corner(fb,5)
    filterBtns[label] = fb
end

local ScanStatus = Instance.new("TextLabel",scanPage)
ScanStatus.Size = UDim2.new(1,0,0,13) ScanStatus.Position = UDim2.new(0,0,0,87)
ScanStatus.Text = "Tekan SCAN untuk mulai" ScanStatus.TextColor3 = C.Sub
ScanStatus.Font = Enum.Font.Gotham ScanStatus.TextSize = 10
ScanStatus.BackgroundTransparency = 1 ScanStatus.TextXAlignment = Enum.TextXAlignment.Left

local ListFrame = Instance.new("ScrollingFrame",scanPage)
ListFrame.Size = UDim2.new(1,0,1,-103) ListFrame.Position = UDim2.new(0,0,0,103)
ListFrame.BackgroundColor3 = C.Input ListFrame.BorderSizePixel = 0
ListFrame.ScrollBarThickness = 3 ListFrame.ScrollBarImageColor3 = C.Accent
ListFrame.CanvasSize = UDim2.new(0,0,0,0) Corner(ListFrame,6)
local ListLayout = Instance.new("UIListLayout",ListFrame)
ListLayout.Padding = UDim.new(0,3) ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
local ListPad = Instance.new("UIPadding",ListFrame)
ListPad.PaddingTop = UDim.new(0,4) ListPad.PaddingLeft = UDim.new(0,4) ListPad.PaddingRight = UDim.new(0,4)

-- ============================================================
-- PAGE: AUTO  — remote name bisa diedit, PICK dari scan
-- ============================================================
local autoPage = pages["AUTO"]

-- Info banner
local autoInfo = Instance.new("TextLabel",autoPage)
autoInfo.Size = UDim2.new(1,0,0,22) autoInfo.Position = UDim2.new(0,0,0,0)
autoInfo.Text = "🤖  Auto Farm — edit nama remote sesuai game"
autoInfo.TextColor3 = C.Lime autoInfo.Font = Enum.Font.GothamSemibold autoInfo.TextSize = 10
autoInfo.BackgroundColor3 = Color3.fromRGB(18,38,18) autoInfo.BackgroundTransparency = 0.2
Corner(autoInfo,6)

-- Variabel untuk PICK: nama remote terakhir dari Remote Scanner
local lastPickedRemote = ""  -- diisi saat user klik item di RemList nanti

-- ── Helper: buat 1 auto row (tinggi 76px) ──────────────────
-- Setiap row punya:
--   Baris 1: icon+label | dot status
--   Baris 2: [TextBox nama remote]  [PICK]
--   Baris 3: [interval] detik  [ON/OFF toggle]
local autoRowList = {}  -- simpan semua row buat PICK broadcast

local function MkAutoRow(parent, icon, label, defaultRemote, remoteType, yPos, defaultInterval)
    local ROW_H = 82

    local row = Instance.new("Frame",parent)
    row.Size = UDim2.new(1,0,0,ROW_H) row.Position = UDim2.new(0,0,0,yPos)
    row.BackgroundColor3 = C.Card Corner(row,8)

    -- Baris 1: label + dot
    local lbl = Instance.new("TextLabel",row)
    lbl.Size = UDim2.new(1,-22,0,16) lbl.Position = UDim2.new(0,8,0,4)
    lbl.Text = icon.."  "..label
    lbl.TextColor3 = C.Text lbl.Font = Enum.Font.GothamSemibold lbl.TextSize = 11
    lbl.BackgroundTransparency = 1 lbl.TextXAlignment = Enum.TextXAlignment.Left

    local dot = Instance.new("Frame",row)
    dot.Size = UDim2.new(0,8,0,8) dot.Position = UDim2.new(1,-14,0,6)
    dot.BackgroundColor3 = C.Red Corner(dot,4)

    -- Baris 2: remote name TextBox + PICK
    local remBox = Instance.new("TextBox",row)
    remBox.Size = UDim2.new(1,-52,0,22) remBox.Position = UDim2.new(0,6,0,24)
    remBox.Text = defaultRemote remBox.PlaceholderText = "Nama remote..."
    remBox.BackgroundColor3 = C.Input remBox.TextColor3 = C.Cyan
    remBox.Font = Enum.Font.Code remBox.TextSize = 9
    remBox.ClearTextOnFocus = false Corner(remBox,5)
    local remBoxPad = Instance.new("UIPadding",remBox) remBoxPad.PaddingLeft = UDim.new(0,5)

    local pickBtn = Instance.new("TextButton",row)
    pickBtn.Size = UDim2.new(0,40,0,22) pickBtn.Position = UDim2.new(1,-46,0,24)
    pickBtn.Text = "PICK" pickBtn.BackgroundColor3 = C.Accent2
    pickBtn.TextColor3 = Color3.new(1,1,1) pickBtn.Font = Enum.Font.GothamSemibold pickBtn.TextSize = 9
    pickBtn.AutoButtonColor = false Corner(pickBtn,5)

    -- Baris 3: interval + toggle
    local intBox = Instance.new("TextBox",row)
    intBox.Size = UDim2.new(0,44,0,22) intBox.Position = UDim2.new(0,6,0,52)
    intBox.Text = tostring(defaultInterval or 1) intBox.PlaceholderText = "s"
    intBox.BackgroundColor3 = C.Input intBox.TextColor3 = C.Text
    intBox.Font = Enum.Font.Gotham intBox.TextSize = 10
    intBox.ClearTextOnFocus = false Corner(intBox,5)

    local intLbl = Instance.new("TextLabel",row)
    intLbl.Size = UDim2.new(0,20,0,22) intLbl.Position = UDim2.new(0,54,0,52)
    intLbl.Text = "dtk" intLbl.TextColor3 = C.Sub
    intLbl.Font = Enum.Font.Gotham intLbl.TextSize = 8 intLbl.BackgroundTransparency = 1

    local toggleBtn = Instance.new("TextButton",row)
    toggleBtn.Size = UDim2.new(1,-84,0,22) toggleBtn.Position = UDim2.new(0,80,0,52)
    toggleBtn.Text = "OFF" toggleBtn.BackgroundColor3 = C.Red
    toggleBtn.TextColor3 = C.Text toggleBtn.Font = Enum.Font.GothamSemibold toggleBtn.TextSize = 10
    toggleBtn.AutoButtonColor = false Corner(toggleBtn,5)

    -- PICK: isi remBox dengan remote yg terakhir dipilih dari scanner
    pickBtn.MouseButton1Click:Connect(function()
        if lastPickedRemote ~= "" then
            remBox.Text = lastPickedRemote
            Tween(pickBtn,0.12,{BackgroundColor3=C.Lime})
            task.delay(0.8,function() Tween(pickBtn,0.12,{BackgroundColor3=C.Accent2}) end)
        else
            -- Kalau belum pick, kasih hint
            remBox.PlaceholderText = "Scan remote dulu di tab REMOT!"
            Tween(pickBtn,0.12,{BackgroundColor3=C.Red})
            task.delay(1,function()
                remBox.PlaceholderText = "Nama remote..."
                Tween(pickBtn,0.12,{BackgroundColor3=C.Accent2})
            end)
        end
    end)

    -- Toggle ON/OFF loop
    local isOn = false
    toggleBtn.MouseButton1Click:Connect(function()
        isOn = not isOn
        if isOn then
            local remoteName = remBox.Text
            if remoteName == "" then
                isOn = false
                lbl.Text = icon.."  "..label.."  ⚠️ Isi nama remote!"
                lbl.TextColor3 = C.Red
                return
            end
            local remote = FindRemote(remoteName)
            if not remote then
                isOn = false
                lbl.Text = icon.."  "..label.."  ❌ '"..remoteName.."' not found"
                lbl.TextColor3 = C.Red
                Tween(toggleBtn,0.15,{BackgroundColor3=C.Red})
                return
            end
            lbl.Text = icon.."  "..label.."  ✓ "..remoteName
            lbl.TextColor3 = C.Lime
            toggleBtn.Text = "ON ✓"
            Tween(toggleBtn,0.15,{BackgroundColor3=C.Lime})
            Tween(dot,0.15,{BackgroundColor3=C.Lime})

            task.spawn(function()
                while isOn do
                    pcall(function()
                        if remoteType == "Event" then remote:FireServer()
                        elseif remoteType == "Function" then remote:InvokeServer() end
                    end)
                    local iv = tonumber(intBox.Text) or 1
                    task.wait(math.max(0.1, iv))
                end
            end)
        else
            isOn = false
            toggleBtn.Text = "OFF"
            Tween(toggleBtn,0.15,{BackgroundColor3=C.Red})
            Tween(dot,0.15,{BackgroundColor3=C.Red})
            lbl.Text = icon.."  "..label
            lbl.TextColor3 = C.Text
        end
    end)

    table.insert(autoRowList, {row=row, remBox=remBox})
    return row
end

-- 5 Auto features
local autoFeatures = {
    { icon="♻️",  label="Auto Rebirth",    remote="RequestRebirth",     type="Event", interval=3   },
    { icon="💰",  label="Auto Sell",        remote="RequestSell",        type="Event", interval=2   },
    { icon="🪙",  label="Auto Collect",     remote="PickupEvent",        type="Event", interval=0.5 },
    { icon="🏗️", label="Auto Base Up",     remote="RequestBaseUpgrade", type="Event", interval=5   },
    { icon="📦",  label="Auto Slot Up",     remote="RequestSlotUpgrade", type="Event", interval=5   },
}

for i, af in ipairs(autoFeatures) do
    MkAutoRow(autoPage, af.icon, af.label, af.remote, af.type, 28+(i-1)*88, af.interval)
end

local autoHint = Instance.new("TextLabel",autoPage)
autoHint.Size = UDim2.new(1,0,0,24) autoHint.Position = UDim2.new(0,0,0, 28+#autoFeatures*88+2)
autoHint.Text = "💡 PICK = ambil dari Remote Scanner\n    Edit langsung jika nama remote berbeda"
autoHint.TextColor3 = C.Sub autoHint.Font = Enum.Font.Gotham autoHint.TextSize = 8
autoHint.BackgroundTransparency = 1 autoHint.TextXAlignment = Enum.TextXAlignment.Left
autoHint.TextWrapped = true

-- ============================================================
-- PAGE: REMOT  (Magnet + Remote Scanner + Plugin Injector)
-- ============================================================
local remotePage = pages["REMOT"]
local remScroll  = MkScroll(remotePage)

-- == MAGNET SECTION ==
local magSection = MkRow(remScroll,130,1)

local magTitle = Instance.new("TextLabel",magSection)
magTitle.Size = UDim2.new(1,-10,0,16) magTitle.Position = UDim2.new(0,8,0,4)
magTitle.Text = "🧲  ITEM MAGNET" magTitle.TextColor3 = C.Pink
magTitle.Font = Enum.Font.GothamBold magTitle.TextSize = 12
magTitle.BackgroundTransparency = 1 magTitle.TextXAlignment = Enum.TextXAlignment.Left

local RemoteInp = Instance.new("TextBox",magSection)
RemoteInp.Size = UDim2.new(1,-16,0,24) RemoteInp.Position = UDim2.new(0,8,0,24)
RemoteInp.Text = "" RemoteInp.PlaceholderText = "Nama RemoteEvent (opsional)..."
RemoteInp.BackgroundColor3 = C.Input RemoteInp.TextColor3 = C.Text
RemoteInp.Font = Enum.Font.Gotham RemoteInp.TextSize = 10
RemoteInp.ClearTextOnFocus = false Corner(RemoteInp,6)

local ItemNameInp = Instance.new("TextBox",magSection)
ItemNameInp.Size = UDim2.new(1,-16,0,24) ItemNameInp.Position = UDim2.new(0,8,0,52)
ItemNameInp.Text = "" ItemNameInp.PlaceholderText = "Filter nama item/brainrot (kosong = semua)..."
ItemNameInp.BackgroundColor3 = C.Input ItemNameInp.TextColor3 = C.Text
ItemNameInp.Font = Enum.Font.Gotham ItemNameInp.TextSize = 10
ItemNameInp.ClearTextOnFocus = false Corner(ItemNameInp,6)

local RadiusInp = Instance.new("TextBox",magSection)
RadiusInp.Size = UDim2.new(0.4,-12,0,24) RadiusInp.Position = UDim2.new(0,8,0,80)
RadiusInp.Text = "50" RadiusInp.PlaceholderText = "Radius"
RadiusInp.BackgroundColor3 = C.Input RadiusInp.TextColor3 = C.Text
RadiusInp.Font = Enum.Font.Gotham RadiusInp.TextSize = 10
RadiusInp.ClearTextOnFocus = false Corner(RadiusInp,6)

local MagnetToggle = Instance.new("TextButton",magSection)
MagnetToggle.Size = UDim2.new(0.57,-4,0,24) MagnetToggle.Position = UDim2.new(0.43,0,0,80)
MagnetToggle.Text = "🧲 MAGNET: OFF" MagnetToggle.BackgroundColor3 = C.Red
MagnetToggle.TextColor3 = C.Text MagnetToggle.Font = Enum.Font.GothamSemibold MagnetToggle.TextSize = 10
MagnetToggle.AutoButtonColor = false Corner(MagnetToggle,6)

local MagStatusLbl = Instance.new("TextLabel",magSection)
MagStatusLbl.Size = UDim2.new(1,-16,0,12) MagStatusLbl.Position = UDim2.new(0,8,0,108)
MagStatusLbl.Text = "Isi remote lalu aktifkan" MagStatusLbl.TextColor3 = C.Sub
MagStatusLbl.Font = Enum.Font.Gotham MagStatusLbl.TextSize = 9
MagStatusLbl.BackgroundTransparency = 1 MagStatusLbl.TextXAlignment = Enum.TextXAlignment.Left

-- == REMOTE SCANNER SECTION ==
local remSection = MkRow(remScroll,140,2)

local remTitle = Instance.new("TextLabel",remSection)
remTitle.Size = UDim2.new(1,-10,0,16) remTitle.Position = UDim2.new(0,8,0,4)
remTitle.Text = "📡  REMOTE SCANNER" remTitle.TextColor3 = C.Accent
remTitle.Font = Enum.Font.GothamBold remTitle.TextSize = 12
remTitle.BackgroundTransparency = 1 remTitle.TextXAlignment = Enum.TextXAlignment.Left

local RemScanBtn = Instance.new("TextButton",remSection)
RemScanBtn.Size = UDim2.new(0.48,-4,0,24) RemScanBtn.Position = UDim2.new(0,8,0,24)
RemScanBtn.Text = "SCAN REMOTE" RemScanBtn.BackgroundColor3 = C.Accent
RemScanBtn.TextColor3 = Color3.new(1,1,1) RemScanBtn.Font = Enum.Font.GothamSemibold RemScanBtn.TextSize = 10
RemScanBtn.AutoButtonColor = false Corner(RemScanBtn,6)

local RemCopyBtn = Instance.new("TextButton",remSection)
RemCopyBtn.Size = UDim2.new(0.48,-4,0,24) RemCopyBtn.Position = UDim2.new(0.52,-4,0,24)
RemCopyBtn.Text = "COPY 📋" RemCopyBtn.BackgroundColor3 = C.Card
RemCopyBtn.TextColor3 = C.Sub RemCopyBtn.Font = Enum.Font.GothamSemibold RemCopyBtn.TextSize = 10
RemCopyBtn.AutoButtonColor = false Corner(RemCopyBtn,6)

local RemStatus = Instance.new("TextLabel",remSection)
RemStatus.Size = UDim2.new(1,-16,0,12) RemStatus.Position = UDim2.new(0,8,0,52)
RemStatus.Text = "Tekan SCAN REMOTE" RemStatus.TextColor3 = C.Sub
RemStatus.Font = Enum.Font.Gotham RemStatus.TextSize = 9
RemStatus.BackgroundTransparency = 1 RemStatus.TextXAlignment = Enum.TextXAlignment.Left

local RemList = Instance.new("ScrollingFrame",remSection)
RemList.Size = UDim2.new(1,-16,0,72) RemList.Position = UDim2.new(0,8,0,66)
RemList.BackgroundColor3 = C.Input RemList.BorderSizePixel = 0
RemList.ScrollBarThickness = 3 RemList.ScrollBarImageColor3 = C.Accent
RemList.CanvasSize = UDim2.new(0,0,0,0) Corner(RemList,6)
local RemListLayout = Instance.new("UIListLayout",RemList)
RemListLayout.Padding = UDim.new(0,2) RemListLayout.SortOrder = Enum.SortOrder.LayoutOrder
local RemListPad = Instance.new("UIPadding",RemList)
RemListPad.PaddingTop = UDim.new(0,3) RemListPad.PaddingLeft = UDim.new(0,4) RemListPad.PaddingRight = UDim.new(0,4)

-- ============================================================
-- PLUGIN LIBRARY + INJECTOR  (V2.2)
-- ============================================================

-- Storage plugin: simpan di _G supaya bertahan walau inject ulang hub
if not _G.CyPluginLib then _G.CyPluginLib = {} end
local PluginLib = _G.CyPluginLib  -- { [nama] = kode }

-- ── SECTION: PLUGIN LIBRARY ──────────────────────────────────
local libSection = MkRow(remScroll,190,3)

local libTitle = Instance.new("TextLabel",libSection)
libTitle.Size = UDim2.new(1,-10,0,16) libTitle.Position = UDim2.new(0,8,0,4)
libTitle.Text = "📚  PLUGIN LIBRARY" libTitle.TextColor3 = C.Yellow
libTitle.Font = Enum.Font.GothamBold libTitle.TextSize = 12
libTitle.BackgroundTransparency = 1 libTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Kotak nama plugin
local libNameBox = Instance.new("TextBox",libSection)
libNameBox.Size = UDim2.new(1,-16,0,24) libNameBox.Position = UDim2.new(0,8,0,24)
libNameBox.Text = "" libNameBox.PlaceholderText = "Nama plugin (cth: BrainrotHunter)"
libNameBox.BackgroundColor3 = C.Input libNameBox.TextColor3 = C.Yellow
libNameBox.Font = Enum.Font.GothamSemibold libNameBox.TextSize = 10
libNameBox.ClearTextOnFocus = false Corner(libNameBox,5)
local lnp = Instance.new("UIPadding",libNameBox) lnp.PaddingLeft = UDim.new(0,6)

-- Tombol SAVE + DELETE
local LibSaveBtn = Instance.new("TextButton",libSection)
LibSaveBtn.Size = UDim2.new(0.48,-4,0,22) LibSaveBtn.Position = UDim2.new(0,8,0,52)
LibSaveBtn.Text = "💾 SAVE" LibSaveBtn.BackgroundColor3 = Color3.fromRGB(30,80,30)
LibSaveBtn.TextColor3 = C.Lime LibSaveBtn.Font = Enum.Font.GothamSemibold LibSaveBtn.TextSize = 10
LibSaveBtn.AutoButtonColor = false Corner(LibSaveBtn,5)
Stroke(LibSaveBtn,C.Lime,1)

local LibDelBtn = Instance.new("TextButton",libSection)
LibDelBtn.Size = UDim2.new(0.48,-4,0,22) LibDelBtn.Position = UDim2.new(0.52,-4,0,52)
LibDelBtn.Text = "🗑 DELETE" LibDelBtn.BackgroundColor3 = C.Card
LibDelBtn.TextColor3 = C.Red LibDelBtn.Font = Enum.Font.GothamSemibold LibDelBtn.TextSize = 10
LibDelBtn.AutoButtonColor = false Corner(LibDelBtn,5)
Stroke(LibDelBtn,C.Red,1)

local LibStatus = Instance.new("TextLabel",libSection)
LibStatus.Size = UDim2.new(1,-16,0,12) LibStatus.Position = UDim2.new(0,8,0,78)
LibStatus.Text = "Simpan kode inject ke library" LibStatus.TextColor3 = C.Sub
LibStatus.Font = Enum.Font.Gotham LibStatus.TextSize = 9
LibStatus.BackgroundTransparency = 1 LibStatus.TextXAlignment = Enum.TextXAlignment.Left

-- List plugin tersimpan
local LibList = Instance.new("ScrollingFrame",libSection)
LibList.Size = UDim2.new(1,-16,0,90) LibList.Position = UDim2.new(0,8,0,94)
LibList.BackgroundColor3 = C.Input LibList.BorderSizePixel = 0
LibList.ScrollBarThickness = 3 LibList.ScrollBarImageColor3 = C.Yellow
LibList.CanvasSize = UDim2.new(0,0,0,0) Corner(LibList,6)
local LibLL = Instance.new("UIListLayout",LibList)
LibLL.Padding = UDim.new(0,2) LibLL.SortOrder = Enum.SortOrder.LayoutOrder
local LibPad = Instance.new("UIPadding",LibList)
LibPad.PaddingTop = UDim.new(0,3) LibPad.PaddingLeft = UDim.new(0,3) LibPad.PaddingRight = UDim.new(0,3)

-- Referensi ke InjectBox (didefinisikan setelah ini, forward declare)
local InjectBox  -- will be assigned below

-- Rebuild library list
local function RebuildLibList()
    for _,c in pairs(LibList:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end
    local count = 0
    for name,_ in pairs(PluginLib) do
        count += 1
        local item = Instance.new("Frame",LibList)
        item.Size = UDim2.new(1,0,0,26) item.BackgroundColor3 = C.Card
        item.BorderSizePixel = 0 item.LayoutOrder = count Corner(item,5)

        -- Icon + nama
        local nameLbl = Instance.new("TextLabel",item)
        nameLbl.Size = UDim2.new(1,-58,1,0) nameLbl.Position = UDim2.new(0,6,0,0)
        nameLbl.Text = "📌 "..name nameLbl.TextColor3 = C.Yellow
        nameLbl.Font = Enum.Font.GothamSemibold nameLbl.TextSize = 10
        nameLbl.BackgroundTransparency = 1 nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

        -- Tombol LOAD
        local loadBtn = Instance.new("TextButton",item)
        loadBtn.Size = UDim2.new(0,50,1,-6) loadBtn.Position = UDim2.new(1,-54,0,3)
        loadBtn.Text = "LOAD" loadBtn.BackgroundColor3 = C.Accent
        loadBtn.TextColor3 = Color3.new(1,1,1) loadBtn.Font = Enum.Font.GothamSemibold loadBtn.TextSize = 9
        loadBtn.AutoButtonColor = false Corner(loadBtn,4)

        local savedName = name  -- capture
        loadBtn.MouseButton1Click:Connect(function()
            -- Isi ke InjectBox dan isi nama
            if InjectBox then InjectBox.Text = PluginLib[savedName] or "" end
            libNameBox.Text = savedName
            LibStatus.Text = "✅ '"..savedName.."' dimuat ke injector"
            LibStatus.TextColor3 = C.Lime
            Tween(loadBtn,0.12,{BackgroundColor3=C.Lime})
            task.delay(0.8,function() Tween(loadBtn,0.12,{BackgroundColor3=C.Accent}) end)
        end)

        -- Long-press nama untuk preview kode di console
        nameLbl.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                print("=== Plugin: "..savedName.." ===")
                print(PluginLib[savedName])
            end
        end)
    end
    LibList.CanvasSize = UDim2.new(0,0,0,(count*28)+6)
    if count == 0 then
        LibStatus.Text = "Library kosong — simpan plugin dulu"
        LibStatus.TextColor3 = C.Sub
    else
        LibStatus.Text = count.." plugin tersimpan"
        LibStatus.TextColor3 = C.Sub
    end
end

-- SAVE: simpan kode dari InjectBox dengan nama dari libNameBox
LibSaveBtn.MouseButton1Click:Connect(function()
    local name = libNameBox.Text
    if name == "" then
        LibStatus.Text = "⚠️ Isi nama plugin dulu!"
        LibStatus.TextColor3 = C.Red return
    end
    local code = InjectBox and InjectBox.Text or ""
    if code == "" then
        LibStatus.Text = "⚠️ Kotak kode kosong!"
        LibStatus.TextColor3 = C.Red return
    end
    PluginLib[name] = code
    LibStatus.Text = "💾 '"..name.."' tersimpan!"
    LibStatus.TextColor3 = C.Lime
    Tween(LibSaveBtn,0.15,{BackgroundColor3=Color3.fromRGB(40,120,40)})
    task.delay(1,function() Tween(LibSaveBtn,0.15,{BackgroundColor3=Color3.fromRGB(30,80,30)}) end)
    RebuildLibList()
end)

-- DELETE: hapus plugin dengan nama di box
LibDelBtn.MouseButton1Click:Connect(function()
    local name = libNameBox.Text
    if name == "" then
        LibStatus.Text = "⚠️ Isi nama yang mau dihapus"
        LibStatus.TextColor3 = C.Red return
    end
    if PluginLib[name] then
        PluginLib[name] = nil
        LibStatus.Text = "🗑 '"..name.."' dihapus"
        LibStatus.TextColor3 = C.Orange
        libNameBox.Text = ""
        RebuildLibList()
    else
        LibStatus.Text = "⚠️ '"..name.."' tidak ada di library"
        LibStatus.TextColor3 = C.Red
    end
end)

-- Isi nama library dari contoh
local function AddBuiltins()
    -- Plugin bawaan: TP Manager (kode mini, tidak butuh paste manual)
    if not PluginLib["📍 TP Manager"] then
        PluginLib["📍 TP Manager"] = [[
-- CyRuZzz TP Plugin — paste lengkap CyTP_Plugin.lua di sini
print("Load CyTP_Plugin.lua dulu dari file!")
]]
    end
    RebuildLibList()
end
AddBuiltins()

-- ── SECTION: PLUGIN INJECTOR ─────────────────────────────────
local injectSection = MkRow(remScroll,168,4)

local injectTitle = Instance.new("TextLabel",injectSection)
injectTitle.Size = UDim2.new(1,-10,0,16) injectTitle.Position = UDim2.new(0,8,0,4)
injectTitle.Text = "🔌  PLUGIN INJECTOR" injectTitle.TextColor3 = C.Yellow
injectTitle.Font = Enum.Font.GothamBold injectTitle.TextSize = 12
injectTitle.BackgroundTransparency = 1 injectTitle.TextXAlignment = Enum.TextXAlignment.Left

local injectSubLbl = Instance.new("TextLabel",injectSection)
injectSubLbl.Size = UDim2.new(1,-16,0,14) injectSubLbl.Position = UDim2.new(0,8,0,22)
injectSubLbl.Text = "Paste kode → SAVE ke library → INJECT kapanpun"
injectSubLbl.TextColor3 = C.Sub injectSubLbl.Font = Enum.Font.Gotham injectSubLbl.TextSize = 9
injectSubLbl.BackgroundTransparency = 1 injectSubLbl.TextXAlignment = Enum.TextXAlignment.Left

-- Kotak kode
InjectBox = Instance.new("TextBox",injectSection)
InjectBox.Size = UDim2.new(1,-16,0,80) InjectBox.Position = UDim2.new(0,8,0,38)
InjectBox.Text = ""
InjectBox.PlaceholderText = "-- Paste kode plugin di sini\n-- Lalu SAVE ke library supaya tidak hilang\n-- Atau langsung INJECT"
InjectBox.BackgroundColor3 = C.Input InjectBox.TextColor3 = C.Text
InjectBox.Font = Enum.Font.Code InjectBox.TextSize = 9
InjectBox.ClearTextOnFocus = false InjectBox.MultiLine = true
InjectBox.TextXAlignment = Enum.TextXAlignment.Left InjectBox.TextYAlignment = Enum.TextYAlignment.Top
Corner(InjectBox,6)
local InjectPad = Instance.new("UIPadding",InjectBox)
InjectPad.PaddingTop = UDim.new(0,4) InjectPad.PaddingLeft = UDim.new(0,6)

-- Tombol baris: INJECT + CLEAR + COPY
local InjectBtn = Instance.new("TextButton",injectSection)
InjectBtn.Size = UDim2.new(0.45,-4,0,24) InjectBtn.Position = UDim2.new(0,8,0,122)
InjectBtn.Text = "⚡ INJECT" InjectBtn.BackgroundColor3 = C.Yellow
InjectBtn.TextColor3 = Color3.new(0,0,0) InjectBtn.Font = Enum.Font.GothamBold InjectBtn.TextSize = 11
InjectBtn.AutoButtonColor = false Corner(InjectBtn,6)

local InjectSaveShortBtn = Instance.new("TextButton",injectSection)
InjectSaveShortBtn.Size = UDim2.new(0.28,-4,0,24) InjectSaveShortBtn.Position = UDim2.new(0.47,0,0,122)
InjectSaveShortBtn.Text = "💾 SAVE" InjectSaveShortBtn.BackgroundColor3 = Color3.fromRGB(30,80,30)
InjectSaveShortBtn.TextColor3 = C.Lime InjectSaveShortBtn.Font = Enum.Font.GothamSemibold InjectSaveShortBtn.TextSize = 9
InjectSaveShortBtn.AutoButtonColor = false Corner(InjectSaveShortBtn,6)
Stroke(InjectSaveShortBtn,C.Lime,1)

local InjectClearBtn = Instance.new("TextButton",injectSection)
InjectClearBtn.Size = UDim2.new(0.22,-4,0,24) InjectClearBtn.Position = UDim2.new(0.78,0,0,122)
InjectClearBtn.Text = "🗑" InjectClearBtn.BackgroundColor3 = C.Card
InjectClearBtn.TextColor3 = C.Red InjectClearBtn.Font = Enum.Font.GothamSemibold InjectClearBtn.TextSize = 12
InjectClearBtn.AutoButtonColor = false Corner(InjectClearBtn,6)

local InjectStatus = Instance.new("TextLabel",injectSection)
InjectStatus.Size = UDim2.new(1,-16,0,12) InjectStatus.Position = UDim2.new(0,8,0,150)
InjectStatus.Text = "Paste kode lalu INJECT atau SAVE dulu" InjectStatus.TextColor3 = C.Sub
InjectStatus.Font = Enum.Font.Gotham InjectStatus.TextSize = 9
InjectStatus.BackgroundTransparency = 1 InjectStatus.TextXAlignment = Enum.TextXAlignment.Left

-- SAVE SHORTCUT dari injector (pakai nama dari libNameBox)
InjectSaveShortBtn.MouseButton1Click:Connect(function()
    local name = libNameBox.Text
    if name == "" then
        -- Auto nama dari timestamp
        name = "Plugin_"..os.date("%H%M%S")
        libNameBox.Text = name
    end
    local code = InjectBox.Text
    if code == "" then
        InjectStatus.Text = "⚠️ Kode kosong!" InjectStatus.TextColor3 = C.Red return
    end
    PluginLib[name] = code
    InjectStatus.Text = "💾 Disimpan sebagai '"..name.."'"
    InjectStatus.TextColor3 = C.Lime
    RebuildLibList()
    Tween(InjectSaveShortBtn,0.12,{BackgroundColor3=Color3.fromRGB(40,140,40)})
    task.delay(1,function() Tween(InjectSaveShortBtn,0.12,{BackgroundColor3=Color3.fromRGB(30,80,30)}) end)
end)

InjectClearBtn.MouseButton1Click:Connect(function()
    InjectBox.Text = ""
    InjectStatus.Text = "Paste kode lalu INJECT atau SAVE dulu"
    InjectStatus.TextColor3 = C.Sub
end)

-- INJECT handler  (FIX: tanpa setfenv, kompatibel semua executor)
InjectBtn.MouseButton1Click:Connect(function()
    local code = InjectBox.Text
    if code == "" then
        InjectStatus.Text = "⚠️ Kode kosong!"
        InjectStatus.TextColor3 = C.Red return
    end

    -- Tambahkan akses ke variabel hub lewat _G sementara
    local _prevState      = rawget(_G,"HubState")
    local _prevFindRemote = rawget(_G,"FindRemote")
    rawset(_G,"HubState",   State)
    rawset(_G,"FindRemote", FindRemote)

    local fn, parseErr = loadstring(code)
    if not fn then
        InjectStatus.Text = "❌ Parse error: "..(parseErr or "?")
        InjectStatus.TextColor3 = C.Red
        Tween(InjectBtn,0.15,{BackgroundColor3=C.Red, TextColor3=Color3.new(1,1,1)})
        task.delay(2,function()
            Tween(InjectBtn,0.15,{BackgroundColor3=C.Yellow, TextColor3=Color3.new(0,0,0)})
        end)
        rawset(_G,"HubState",   _prevState)
        rawset(_G,"FindRemote", _prevFindRemote)
        return
    end

    local ok, runErr = pcall(fn)

    -- Restore _G
    rawset(_G,"HubState",   _prevState)
    rawset(_G,"FindRemote", _prevFindRemote)

    if ok then
        InjectStatus.Text = "✅ Plugin berhasil dijalankan!"
        InjectStatus.TextColor3 = C.Lime
        Tween(InjectBtn,0.15,{BackgroundColor3=C.Lime, TextColor3=Color3.new(0,0,0)})
        task.delay(2,function()
            Tween(InjectBtn,0.15,{BackgroundColor3=C.Yellow, TextColor3=Color3.new(0,0,0)})
            InjectStatus.TextColor3 = C.Sub
        end)
    else
        -- Tampilkan error lebih singkat supaya muat
        local errMsg = tostring(runErr or "unknown error")
        errMsg = errMsg:gsub("^.*:%d+: ","") -- strip path prefix
        if #errMsg > 55 then errMsg = errMsg:sub(1,55).."…" end
        InjectStatus.Text = "❌ "..errMsg
        InjectStatus.TextColor3 = C.Red
        warn("[CyRuZzz Inject] "..tostring(runErr))
        Tween(InjectBtn,0.15,{BackgroundColor3=C.Red, TextColor3=Color3.new(1,1,1)})
        task.delay(2.5,function()
            Tween(InjectBtn,0.15,{BackgroundColor3=C.Yellow, TextColor3=Color3.new(0,0,0)})
        end)
    end
end)

InjectClearBtn.MouseButton1Click:Connect(function()
    InjectBox.Text = ""
    InjectStatus.Text = "Paste kode lalu klik INJECT"
    InjectStatus.TextColor3 = C.Sub
end)

-- ============================================================
-- ESP SYSTEM
-- ============================================================
local espObjects     = {}
local espAvatars     = {}
local scanEspObjects = {}
local selectedObj    = nil
local espContainer   = Instance.new("Folder",workspace)
espContainer.Name    = "_CyESP"

local function MakeSelectionBox(adornee,col)
    local sb = Instance.new("SelectionBox",espContainer)
    sb.Adornee = adornee sb.Color3 = col or C.Accent
    sb.LineThickness = 0.07 sb.SurfaceTransparency = 0.75 sb.SurfaceColor3 = col or C.Accent
    return sb
end

local function MakeBillboard(adornee,txt,col,yOff)
    local bb = Instance.new("BillboardGui",espContainer)
    bb.Adornee = adornee bb.Size = UDim2.new(0,120,0,34)
    bb.StudsOffset = Vector3.new(0,(yOff or 0)+3,0)
    bb.AlwaysOnTop = true bb.MaxDistance = 300
    local lbl = Instance.new("TextLabel",bb)
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundColor3 = Color3.fromRGB(0,0,0) lbl.BackgroundTransparency = 0.5
    lbl.TextColor3 = col or C.Accent lbl.Font = Enum.Font.GothamBold lbl.TextSize = 10
    lbl.Text = txt lbl.TextStrokeTransparency = 0.5 Corner(lbl,4)
    return bb,lbl
end

local function RemoveObjEsp(obj)
    if espObjects[obj] then
        pcall(function() if espObjects[obj].box then espObjects[obj].box:Destroy() end end)
        pcall(function() if espObjects[obj].billboard then espObjects[obj].billboard:Destroy() end end)
        espObjects[obj] = nil
    end
end

local function AddObjEsp(obj,col)
    RemoveObjEsp(obj) col = col or C.Accent
    local target = obj
    if obj:IsA("Model") then
        local r = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
        if r then target = r end
    end
    local box = MakeSelectionBox(obj,col)
    local bb,lbl = MakeBillboard(target,obj.Name.."\n["..obj.ClassName.."]",col)
    espObjects[obj] = {box=box,billboard=bb,label=lbl,part=target}
end

local function UpdateObjEspLabel(obj)
    local data = espObjects[obj]
    if not data or not data.label then return end
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local part = data.part
    if part and part.Parent and hrp then
        local ok,pos = pcall(function()
            if part:IsA("BasePart") then return part.Position
            elseif part:IsA("Model") then
                local r = part:FindFirstChild("HumanoidRootPart") or part:FindFirstChildWhichIsA("BasePart")
                return r and r.Position
            end
        end)
        if ok and pos then
            local dist = math.floor((pos-hrp.Position).Magnitude)
            data.label.Text = obj.Name.."\n📍 "..dist.." st"
        end
    end
end

local function RemoveAvaEsp(p)
    if espAvatars[p] then
        for _,v in pairs(espAvatars[p]) do pcall(function() v:Destroy() end) end
        espAvatars[p] = nil
    end
end

local function RefreshAvaEsp()
    for p,_ in pairs(espAvatars) do
        if not p or not p.Parent then RemoveAvaEsp(p) end
    end
    if not State.espAvatar then
        for p,_ in pairs(espAvatars) do RemoveAvaEsp(p) end return
    end
    for _,p in pairs(Players:GetPlayers()) do
        if p == player then continue end
        local char = p.Character
        if not char then RemoveAvaEsp(p) continue end
        local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
        if not root then RemoveAvaEsp(p) continue end
        if not espAvatars[p] then
            local box = MakeSelectionBox(char,C.Pink)
            local bb,_ = MakeBillboard(root,"👤 "..p.Name.."\n[PLAYER]",C.Pink,2)
            espAvatars[p] = {box,bb}
        end
    end
end

Players.PlayerRemoving:Connect(function(p) RemoveAvaEsp(p) end)

local currentHL = nil
local function SetHighlight(obj)
    if currentHL then currentHL:Destroy() currentHL = nil end
    if not obj then return end
    local h = Instance.new("SelectionBox",espContainer)
    h.Adornee = obj h.Color3 = C.Yellow
    h.LineThickness = 0.09 h.SurfaceTransparency = 0.7 h.SurfaceColor3 = C.Yellow
    currentHL = h
end

-- ============================================================
-- TARGET LOCK
-- ============================================================
local lockTarget = nil

local function GetAllTargets()
    local targets = {}
    for _,p in pairs(Players:GetPlayers()) do
        if p == player then continue end
        local char = p.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
        if root then table.insert(targets,{part=root,name=p.Name}) end
    end
    return targets
end

local function FindNearestTarget()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest,nearDist = nil,math.huge
    for _,t in pairs(GetAllTargets()) do
        local dist = (t.part.Position-hrp.Position).Magnitude
        if dist < nearDist then nearDist=dist nearest=t end
    end
    return nearest
end

-- ============================================================
-- SCANNER LOGIC
-- ============================================================
local allObjs = {}

local function GetObjCategory(obj)
    if obj:IsA("Model") then
        if Players:GetPlayerFromCharacter(obj) then return "Player" end
        if obj:FindFirstChildOfClass("Humanoid") then return "NPC" end
        return "Model"
    elseif obj:IsA("Tool") then return "Tool"
    elseif obj:IsA("BasePart") then return "Part"
    else return obj.ClassName end
end

local function GetObjPos(obj)
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local r = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
        if r then return r.Position end
        local ok,cf = pcall(function() return obj:GetModelCFrame() end)
        if ok then return cf.Position end
    end
    return nil
end

local function GetDist(pos)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not pos then return 9999 end
    return math.floor((hrp.Position-pos).Magnitude)
end

local function BuildList(filter)
    for _,c in pairs(ListFrame:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("Frame") then c:Destroy() end
    end
    local sorted = {}
    local icons = {Player="👤",NPC="🤖",Model="📦",Part="🔷",Tool="🔧"}
    for _,obj in ipairs(allObjs) do
        local cat = GetObjCategory(obj)
        if filterActive ~= "ALL" and cat ~= filterActive then continue end
        local name = obj.Name
        if filter and filter ~= "" then
            if not string.lower(name):find(string.lower(filter),1,true) then continue end
        end
        local pos = GetObjPos(obj)
        table.insert(sorted,{obj=obj,name=name,cat=cat,dist=GetDist(pos)})
    end
    table.sort(sorted,function(a,b) return a.dist < b.dist end)
    for i,data in ipairs(sorted) do
        local entry = Instance.new("TextButton",ListFrame)
        entry.Size = UDim2.new(1,0,0,32)
        entry.BackgroundColor3 = C.Card
        entry.TextColor3 = data.cat=="Player" and Color3.fromRGB(185,145,255) or C.Text
        entry.Font = Enum.Font.Gotham entry.TextSize = 10
        entry.TextXAlignment = Enum.TextXAlignment.Left
        entry.BorderSizePixel = 0 entry.LayoutOrder = i entry.AutoButtonColor = false
        entry.Text = "  "..(icons[data.cat] or "❔").."  "..data.name.."   ("..data.dist.."st)"
        Corner(entry,5)
        entry.MouseButton1Click:Connect(function()
            selectedObj = data.obj
            for _,e in pairs(ListFrame:GetChildren()) do
                if e:IsA("TextButton") then e.BackgroundColor3 = C.Card end
            end
            Tween(entry,0.1,{BackgroundColor3=Color3.fromRGB(38,26,80)})
            SetHighlight(data.obj)
            ScanStatus.Text = "✅ "..data.name
            Tween(ScanTeleBtn,0.15,{BackgroundColor3=C.Green,TextColor3=Color3.new(1,1,1)})
        end)
    end
    ListFrame.CanvasSize = UDim2.new(0,0,0,(#sorted*35)+8)
    ScanStatus.Text = "📋 "..(#sorted).." objek"
end

local function DoScan()
    allObjs = {}
    for _,obj in ipairs(workspace:GetChildren()) do
        if obj.Name == player.Name then continue end
        if obj.Name == "Terrain" then continue end
        if obj.Name == "_CyESP" then continue end
        table.insert(allObjs,obj)
    end
    local extras = {}
    for _,obj in ipairs(allObjs) do
        if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
            for _,child in ipairs(obj:GetChildren()) do
                if child:IsA("Model") or child:IsA("BasePart") then
                    table.insert(extras,child)
                end
            end
        end
    end
    for _,e in ipairs(extras) do table.insert(allObjs,e) end
    BuildList(SearchBox.Text)
end

for label,fb in pairs(filterBtns) do
    fb.MouseButton1Click:Connect(function()
        filterActive = label
        for l,btn in pairs(filterBtns) do
            Tween(btn,0.12,{
                BackgroundColor3 = l==label and C.Accent or C.Card,
                TextColor3       = l==label and Color3.new(1,1,1) or C.Sub
            })
        end
        BuildList(SearchBox.Text)
    end)
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function() BuildList(SearchBox.Text) end)
ScanRefBtn.MouseButton1Click:Connect(function()
    ScanStatus.Text = "🔄 Scanning..." task.wait(0.05) DoScan()
end)
ScanTeleBtn.MouseButton1Click:Connect(function()
    if not selectedObj then ScanStatus.Text = "⚠️ Pilih dulu!" return end
    local pos = GetObjPos(selectedObj)
    if not pos then ScanStatus.Text = "⚠️ No position" return end
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(pos+Vector3.new(0,5,0))
        ScanStatus.Text = "🚀 TP: "..selectedObj.Name
    end
end)
ScanEspBtn.MouseButton1Click:Connect(function()
    if not selectedObj then ScanStatus.Text = "⚠️ Pilih dulu!" return end
    if scanEspObjects[selectedObj] then
        RemoveObjEsp(selectedObj) scanEspObjects[selectedObj] = nil
        Tween(ScanEspBtn,0.15,{BackgroundColor3=C.Card,TextColor3=C.Sub})
        ScanEspBtn.Text = "ESP"
    else
        AddObjEsp(selectedObj,C.Yellow) scanEspObjects[selectedObj] = true
        Tween(ScanEspBtn,0.15,{BackgroundColor3=C.Green,TextColor3=Color3.new(1,1,1)})
        ScanEspBtn.Text = "ESP ✓"
    end
end)

-- ============================================================
-- REMOTE SCANNER LOGIC
-- ============================================================
local scannedRemotes = {}
local remoteOutput   = ""

local function DoRemoteScan()
    scannedRemotes = {} remoteOutput = ""
    local locations = {
        {game:GetService("ReplicatedStorage"),"ReplicatedStorage"},
        {game:GetService("ReplicatedFirst"),  "ReplicatedFirst"},
        {workspace,                           "Workspace"},
    }
    for _,loc in ipairs(locations) do
        pcall(function()
            for _,obj in ipairs(loc[1]:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")
                or obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
                    table.insert(scannedRemotes,{type=obj.ClassName,name=obj.Name,path=obj:GetFullName(),obj=obj})
                end
            end
        end)
    end
    local grouped = {RemoteEvent={},RemoteFunction={},BindableEvent={},BindableFunction={}}
    for _,r in ipairs(scannedRemotes) do
        if grouped[r.type] then table.insert(grouped[r.type],r) end
    end
    remoteOutput = "=== CyRuZzz Remote Scanner ===\nTotal: "..#scannedRemotes.."\n\n"
    for typeName,list in pairs(grouped) do
        if #list > 0 then
            remoteOutput = remoteOutput.."["..typeName.."] ("..#list..")\n"
            for _,r in ipairs(list) do remoteOutput = remoteOutput.."  "..r.path.."\n" end
            remoteOutput = remoteOutput.."\n"
        end
    end
    for _,c in pairs(RemList:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end
    local shortType = {RemoteEvent="RE",RemoteFunction="RF",BindableEvent="BE",BindableFunction="BF"}
    local typeCol   = {RemoteEvent=C.Accent,RemoteFunction=C.Accent2,BindableEvent=C.Cyan,BindableFunction=C.Pink}
    for i,r in ipairs(scannedRemotes) do
        local item = Instance.new("Frame",RemList)
        item.Size = UDim2.new(1,0,0,24) item.BackgroundColor3 = C.Card
        item.BorderSizePixel = 0 item.LayoutOrder = i Corner(item,5)
        local tag = Instance.new("TextLabel",item)
        tag.Size = UDim2.new(0,22,1,-4) tag.Position = UDim2.new(0,3,0,2)
        tag.Text = shortType[r.type] or "??"
        tag.BackgroundColor3 = typeCol[r.type] or C.Sub tag.BackgroundTransparency = 0.5
        tag.TextColor3 = typeCol[r.type] or C.Sub
        tag.Font = Enum.Font.GothamBold tag.TextSize = 7 tag.TextXAlignment = Enum.TextXAlignment.Center
        Corner(tag,3)
        local nameLbl = Instance.new("TextLabel",item)
        nameLbl.Size = UDim2.new(1,-28,1,0) nameLbl.Position = UDim2.new(0,28,0,0)
        nameLbl.Text = r.name nameLbl.TextColor3 = C.Text
        nameLbl.Font = Enum.Font.Gotham nameLbl.TextSize = 9
        nameLbl.BackgroundTransparency = 1 nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        item.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                RemoteInp.Text = r.name
                MagStatusLbl.Text = "✅ '"..r.name.."' → magnet & PICK siap"
                -- Set lastPickedRemote supaya tombol PICK di AUTO bisa pakai
                lastPickedRemote = r.name
                Tween(item,0.1,{BackgroundColor3=Color3.fromRGB(30,20,60)})
                task.delay(0.5,function() Tween(item,0.1,{BackgroundColor3=C.Card}) end)
            end
        end)
    end
    RemList.CanvasSize = UDim2.new(0,0,0,(#scannedRemotes*26)+8)
    RemStatus.Text = "📡 "..(#scannedRemotes).." remote ditemukan"
end

RemScanBtn.MouseButton1Click:Connect(function()
    RemStatus.Text = "🔄 Scanning..." task.wait(0.05) DoRemoteScan()
end)
RemCopyBtn.MouseButton1Click:Connect(function()
    if remoteOutput == "" then RemStatus.Text = "⚠️ Scan dulu!" return end
    if setclipboard then
        setclipboard(remoteOutput)
        Tween(RemCopyBtn,0.15,{BackgroundColor3=C.Green,TextColor3=Color3.new(1,1,1)})
        RemStatus.Text = "✅ Disalin!"
        task.delay(2,function() Tween(RemCopyBtn,0.15,{BackgroundColor3=C.Card,TextColor3=C.Sub}) end)
    else
        print(remoteOutput) RemStatus.Text = "📋 Cek console"
    end
end)

-- ============================================================
-- MAGNET LOGIC
-- ============================================================
local magnetConn = nil
local function ToggleMagnet()
    State.magnet = not State.magnet
    if State.magnet then
        Tween(MagnetToggle,0.15,{BackgroundColor3=C.Pink})
        MagnetToggle.Text = "🧲 MAGNET: ON"
        local remoteName = RemoteInp.Text
        local itemFilter = ItemNameInp.Text
        local radius     = tonumber(RadiusInp.Text) or 50
        local targetRemote = remoteName ~= "" and FindRemote(remoteName) or nil
        MagStatusLbl.Text = targetRemote and ("🧲 Remote: "..targetRemote.Name) or "Physical magnet aktif"
        magnetConn = RunService.Heartbeat:Connect(function()
            local char = player.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            for _,obj in ipairs(workspace:GetDescendants()) do
                if not obj or not obj.Parent then continue end
                if obj:IsA("Terrain") then continue end
                if obj.Parent == espContainer then continue end
                local name = obj.Name
                local match = itemFilter=="" or string.lower(name):find(string.lower(itemFilter),1,true)
                if not match then continue end
                local isChar = false
                for _,p in pairs(Players:GetPlayers()) do
                    if p.Character==obj or p.Character==obj.Parent then isChar=true break end
                end
                if isChar then continue end
                local pos = nil
                if obj:IsA("BasePart") then pos=obj.Position
                elseif obj:IsA("Model") then
                    local r = obj:FindFirstChildWhichIsA("BasePart")
                    if r then pos=r.Position end
                end
                if pos then
                    local dist = (pos-hrp.Position).Magnitude
                    if dist<=radius and dist>2 then
                        if targetRemote then
                            pcall(function()
                                if targetRemote:IsA("RemoteEvent") then targetRemote:FireServer(obj)
                                elseif targetRemote:IsA("RemoteFunction") then targetRemote:InvokeServer(obj) end
                            end)
                        else
                            if obj:IsA("BasePart") then
                                pcall(function()
                                    obj.CFrame = CFrame.new(hrp.Position+Vector3.new(math.random(-2,2),0,math.random(-2,2)))
                                end)
                            end
                        end
                    end
                end
            end
        end)
    else
        if magnetConn then magnetConn:Disconnect() magnetConn=nil end
        Tween(MagnetToggle,0.15,{BackgroundColor3=C.Red})
        MagnetToggle.Text = "🧲 MAGNET: OFF"
        MagStatusLbl.Text = "Isi remote lalu aktifkan"
    end
end
MagnetToggle.MouseButton1Click:Connect(ToggleMagnet)

-- ============================================================
-- GHOST
-- ============================================================
local function ApplyGhostVisuals(char,invisible)
    if not char then return end
    for _,v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            v.LocalTransparencyModifier = invisible and 1 or 0
            v.Transparency = invisible and 1 or 0
        elseif v:IsA("Decal") then v.Transparency = invisible and 1 or 0 end
    end
    for _,acc in pairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            local handle = acc:FindFirstChild("Handle")
            if handle then
                handle.LocalTransparencyModifier = invisible and 1 or 0
                handle.Transparency = invisible and 1 or 0
            end
        end
    end
end

local ghostCharConn = nil
local function ToggleGhost()
    State.ghost = not State.ghost
    SetToggle(GhostToggle,State.ghost,"👻 GHOST")
    ApplyGhostVisuals(player.Character,State.ghost)
    if State.ghost then
        ghostCharConn = player.CharacterAdded:Connect(function(newChar)
            task.wait(0.5)
            if State.ghost then ApplyGhostVisuals(newChar,true) end
        end)
        StatLbl.Text = "👻 Ghost aktif"
    else
        if ghostCharConn then ghostCharConn:Disconnect() ghostCharConn=nil end
        StatLbl.Text = "Ghost nonaktif"
    end
end
GhostToggle.MouseButton1Click:Connect(ToggleGhost)

-- ============================================================
-- GODMODE
-- ============================================================
local godRealChar=nil local godFakeChar=nil local currentOffset=15

local function ToggleGodmode()
    if State.godmode then
        State.godmode = false
        local savedPos = nil
        if godFakeChar then
            local fRoot = godFakeChar:FindFirstChild("HumanoidRootPart")
            if fRoot then savedPos = fRoot.CFrame end
        end
        if godRealChar then
            player.Character = godRealChar
            workspace.CurrentCamera.CameraSubject = godRealChar:FindFirstChild("Humanoid") or godRealChar
            for _,v in pairs(godRealChar:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide=true if v.Name~="HumanoidRootPart" then v.Transparency=0 end v.LocalTransparencyModifier=0
                elseif v:IsA("Decal") then v.Transparency=0 end
            end
            if savedPos then
                local rRoot = godRealChar:FindFirstChild("HumanoidRootPart")
                if rRoot then rRoot.CFrame=savedPos rRoot.Velocity=Vector3.new(0,0,0) end
            end
        end
        if godFakeChar then godFakeChar:Destroy() godFakeChar=nil end
        godRealChar=nil
    else
        godRealChar = player.Character
        if not godRealChar then return end
        godRealChar.Archivable = true
        State.godmode = true currentOffset = State.offsetDist
        godFakeChar = godRealChar:Clone()
        godFakeChar.Name = player.Name.."_Fake"
        godFakeChar.Parent = workspace
        for _,v in pairs(godFakeChar:GetDescendants()) do
            if (v:IsA("BasePart") or v:IsA("Decal")) and v.Name~="HumanoidRootPart" then v.Transparency=0.4 end
        end
        for _,v in pairs(godRealChar:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide=false end
        end
        player.Character = godFakeChar
        workspace.CurrentCamera.CameraSubject = godFakeChar:WaitForChild("Humanoid")
        local fHum = godFakeChar:FindFirstChild("Humanoid")
        if fHum then fHum.Died:Connect(function() if State.godmode then ToggleGodmode() end end) end
    end
    SetToggle(GodToggle,State.godmode,"🛡  GODMODE")
    mainStroke.Color = State.godmode and C.Orange or C.Accent
end
GodToggle.MouseButton1Click:Connect(ToggleGodmode)

-- ============================================================
-- SLIDER
-- ============================================================
local sliderDrag = false
SliderKnob.MouseButton1Down:Connect(function() sliderDrag=true end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then sliderDrag=false end
end)

-- ============================================================
-- FLY
-- ============================================================
local flyConn = nil
local function ToggleFly()
    State.flying = not State.flying
    SetToggle(FlyToggle,State.flying,"✈  FLY")
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChild("Humanoid")
    if State.flying and root and hum then
        hum.PlatformStand = true
        local bv = Instance.new("BodyVelocity",root)
        bv.Name="_FlyVel" bv.MaxForce=Vector3.new(9e9,9e9,9e9) bv.Velocity=Vector3.new(0,0,0)
        local bg = Instance.new("BodyGyro",root)
        bg.Name="_FlyGyro" bg.MaxTorque=Vector3.new(9e9,9e9,9e9) bg.P=9e4 bg.CFrame=root.CFrame
        flyConn = RunService.RenderStepped:Connect(function()
            if not State.flying then return end
            local spd = tonumber(SpeedInp.Text) or 60
            local cam = workspace.CurrentCamera.CFrame
            local dir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir+=cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir-=cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir-=cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir+=cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir-=Vector3.new(0,1,0) end
            bv.Velocity = dir.Magnitude>0 and dir.Unit*spd or Vector3.new(0,0,0)
            bg.CFrame = cam
        end)
    else
        if flyConn then flyConn:Disconnect() flyConn=nil end
        if hum then hum.PlatformStand=false end
        if root then
            local fv=root:FindFirstChild("_FlyVel") local fg=root:FindFirstChild("_FlyGyro")
            if fv then fv:Destroy() end if fg then fg:Destroy() end
        end
    end
end
FlyToggle.MouseButton1Click:Connect(ToggleFly)

-- ============================================================
-- SPEED
-- ============================================================
SpeedToggle.MouseButton1Click:Connect(function()
    local char = player.Character
    local hum  = char and char:FindFirstChild("Humanoid")
    if not State.speedOn then
        if hum then originalWalkSpeed = hum.WalkSpeed end
        State.speedOn = true
        SetToggle(SpeedToggle,true,"SPEED")
        StatLbl.Text = "⚡ Speed ON ("..SpeedInp.Text..")"
    else
        State.speedOn = false
        if hum then hum.WalkSpeed = originalWalkSpeed end
        SetToggle(SpeedToggle,false,"SPEED")
        StatLbl.Text = "Speed reset → "..originalWalkSpeed
    end
end)

-- ============================================================
-- ESP TOGGLES
-- ============================================================
EspObjToggle.MouseButton1Click:Connect(function()
    State.espObj = not State.espObj
    SetToggle(EspObjToggle,State.espObj,"🔵 ESP OBJECT",C.Accent2,C.Red)
    if not State.espObj then
        for obj,_ in pairs(espObjects) do
            if not scanEspObjects[obj] then RemoveObjEsp(obj) end
        end
    end
    EspStatLbl.Text = State.espObj and "🔵 ESP Object: ON" or "ESP: Standby"
end)

EspAvaToggle.MouseButton1Click:Connect(function()
    State.espAvatar = not State.espAvatar
    SetToggle(EspAvaToggle,State.espAvatar,"👤 ESP AVATAR",C.Pink,C.Red)
    if not State.espAvatar then for p,_ in pairs(espAvatars) do RemoveAvaEsp(p) end end
    EspStatLbl.Text = State.espAvatar and "👤 ESP Avatar: ON" or "ESP: Standby"
end)

LockToggle.MouseButton1Click:Connect(function()
    State.targetLock = not State.targetLock
    SetToggle(LockToggle,State.targetLock,"🎯 TARGET LOCK",C.Orange,C.Red)
    if State.targetLock then
        local t = FindNearestTarget()
        if t then lockTarget=t EspStatLbl.Text="🎯 Lock: "..t.name
        else
            State.targetLock=false
            SetToggle(LockToggle,false,"🎯 TARGET LOCK",C.Orange,C.Red)
            EspStatLbl.Text="⚠️ Tidak ada target"
        end
    else lockTarget=nil EspStatLbl.Text="ESP: Standby" end
end)

-- ============================================================
-- HOTKEYS
-- ============================================================
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.T then
        if lockTarget then
            lockTarget=nil State.targetLock=false
            SetToggle(LockToggle,false,"🎯 TARGET LOCK",C.Orange,C.Red)
            EspStatLbl.Text="🎯 Lock dilepas"
        else
            local t = FindNearestTarget()
            if t then
                lockTarget=t State.targetLock=true
                SetToggle(LockToggle,true,"🎯 TARGET LOCK",C.Orange,C.Red)
                EspStatLbl.Text="🎯 Lock: "..t.name
            end
        end
    end
    if input.KeyCode == Enum.KeyCode.G and State.targetLock then
        local targets = GetAllTargets()
        if #targets>1 and lockTarget then
            local idx=1
            for i,t in ipairs(targets) do if t.part==lockTarget.part then idx=i break end end
            local nxt = targets[(idx%#targets)+1]
            if nxt then lockTarget=nxt EspStatLbl.Text="🎯 Lock: "..nxt.name end
        end
    end
end)

-- ============================================================
-- MAIN LOOPS
-- ============================================================
RunService.Stepped:Connect(function()
    if State.godmode and godRealChar and godFakeChar then
        local rRoot=godRealChar:FindFirstChild("HumanoidRootPart")
        local fRoot=godFakeChar:FindFirstChild("HumanoidRootPart")
        if rRoot and fRoot then
            currentOffset = Lerp(currentOffset,State.offsetDist,0.1)
            rRoot.CFrame  = fRoot.CFrame*CFrame.new(0,-currentOffset,0)
            rRoot.Velocity = Vector3.new(0,0,0)
        end
    end
    if sliderDrag then
        local rel = UserInputService:GetMouseLocation().X - SliderTrack.AbsolutePosition.X
        local pct = math.clamp(rel/SliderTrack.AbsoluteSize.X,0,1)
        SliderKnob.Position = UDim2.new(pct,-8,0.5,-8)
        SliderFill.Size     = UDim2.new(pct,0,1,0)
        State.offsetDist    = math.floor(Lerp(5,50,pct))
        SliderLbl.Text      = "Offset Godmode: "..State.offsetDist
    end
end)

RunService.Heartbeat:Connect(function()
    if State.speedOn and not State.flying then
        local hum = player.Character and player.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = tonumber(SpeedInp.Text) or 120 end
    end
    if State.ghost then
        local char = player.Character
        if char then
            for _,v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.Name~="HumanoidRootPart" then
                    v.LocalTransparencyModifier = 1
                end
            end
        end
    end
    if State.espAvatar then RefreshAvaEsp() end
    for obj,_ in pairs(espObjects) do
        if not obj or not obj.Parent then RemoveObjEsp(obj)
        else UpdateObjEspLabel(obj) end
    end
end)

RunService.RenderStepped:Connect(function()
    if State.targetLock and lockTarget and lockTarget.part then
        local part = lockTarget.part
        if not part.Parent then
            local t = FindNearestTarget()
            if t then lockTarget=t EspStatLbl.Text="🎯 Auto: "..t.name
            else
                State.targetLock=false lockTarget=nil
                SetToggle(LockToggle,false,"🎯 TARGET LOCK",C.Orange,C.Red)
                EspStatLbl.Text="⚠️ Target hilang"
            end
            return
        end
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local targetPos = part.Position+Vector3.new(0,1,0)
            local fromPos   = camera.CFrame.Position
            local dir       = targetPos-fromPos
            if dir.Magnitude>0.5 then
                camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(fromPos,targetPos),0.12)
            end
            local dist = math.floor((part.Position-hrp.Position).Magnitude)
            EspStatLbl.Text = "🎯 "..lockTarget.name.." | "..dist.."st"
        end
    end
end)

-- ============================================================
-- MINIMIZE / CLOSE
-- ============================================================
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TabBar.Visible=false ContentArea.Visible=false
        Tween(Main,0.22,{Size=UDim2.new(0,340,0,44)}) MinBtn.Text="+"
    else
        TabBar.Visible=true ContentArea.Visible=true
        Tween(Main,0.22,{Size=UDim2.new(0,340,0,470)}) MinBtn.Text="−"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    if State.godmode then ToggleGodmode() end
    if magnetConn then magnetConn:Disconnect() end
    if currentHL then currentHL:Destroy() end
    if espContainer then espContainer:Destroy() end
    Tween(Main,0.18,{BackgroundTransparency=1})
    task.wait(0.2) sg:Destroy()
end)

RunService.Heartbeat:Connect(function()
    if sg and not sg.Parent then sg.Parent = player.PlayerGui end
end)

-- ============================================================
-- INIT
-- ============================================================
SwitchTab("MAIN")

print([[
╔════════════════════════════════════╗
║    CyRuZzz Hub Loaded              ║
║  MAIN | ESP | SCAN | AUTO | REMOT  ║
║  T=TargetLock   G=NextTarget       ║
║  AUTO: edit remote + PICK          ║
║  INJECT: Paste kode → langsung run ║
╚════════════════════════════════════╝
]])
