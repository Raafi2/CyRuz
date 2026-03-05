local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")
local HttpService=game:GetService("HttpService")
local ContextActionService=game:GetService("ContextActionService")
local player=Players.LocalPlayer
local camera=workspace.CurrentCamera
local mouse=nil
pcall(function() mouse=player:GetMouse() end)

for _,ui in pairs(player.PlayerGui:GetChildren()) do
    if ui.Name=="CyRuZzz_Hub" then ui:Destroy() end
end
for _,h in pairs(workspace:GetChildren()) do
    if h.Name=="_CyESP" then h:Destroy() end
end
if _G.CyHz then
    for _,c in pairs(_G.CyHz) do pcall(function() c:Disconnect() end) end
end
_G.CyHz={}
if not _G.CyPluginLib then _G.CyPluginLib={} end
if not _G.CyBH then _G.CyBH={skipList={}} end

local sg=Instance.new("ScreenGui")
sg.Name="CyRuZzz_Hub"
sg.ResetOnSpawn=false
sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset=true
sg.Parent=player.PlayerGui
local function MountGui()
    if not sg.Parent then sg.Parent=player.PlayerGui end
end

local C={
    BG=Color3.fromRGB(7,6,14),
    Panel=Color3.fromRGB(12,10,22),
    Card=Color3.fromRGB(18,16,32),
    CardH=Color3.fromRGB(28,24,50),
    Acc=Color3.fromRGB(120,70,255),
    Acc2=Color3.fromRGB(60,140,255),
    Green=Color3.fromRGB(35,195,100),
    Red=Color3.fromRGB(210,45,65),
    Orange=Color3.fromRGB(255,145,35),
    Yellow=Color3.fromRGB(255,210,35),
    Cyan=Color3.fromRGB(35,215,205),
    Pink=Color3.fromRGB(255,65,170),
    Lime=Color3.fromRGB(110,250,75),
    Gold=Color3.fromRGB(255,185,25),
    Teal=Color3.fromRGB(0,200,175),
    Purple=Color3.fromRGB(180,80,255),
    Blue=Color3.fromRGB(40,130,255),
    Text=Color3.fromRGB(225,218,255),
    Sub=Color3.fromRGB(110,100,148),
    Input=Color3.fromRGB(11,9,20),
    Dark=Color3.fromRGB(6,5,12),
    Border=Color3.fromRGB(35,28,65),
}

local State={
    speedOn=false,flying=false,noclip=false,ghost=false,godmode=false,
    freecam=false,clickTP=false,infJump=false,fullbright=false,
    espObj=false,espPlayers=false,targetLock=false,
    aimbot=false,magnet=false,follow=false,hitch=false,
    instantE=false,
    speedVal=120,offsetDist=15,magnetRadius=50,
    followTarget=nil,hitchTarget=nil,lockTarget=nil,
    originalWalkSpeed=16,originalFOV=70,
    originalAmbient=nil,originalOutdoor=nil,originalBrightness=nil,
    freecamActive=false,
}

local Conns={}
local function AddConn(c) table.insert(Conns,c) table.insert(_G.CyHz,c) return c end

local function Tw(o,t,p,es,ed)
    TweenService:Create(o,TweenInfo.new(t,es or Enum.EasingStyle.Quart,ed or Enum.EasingDirection.Out),p):Play()
end
local function Cr(p,r) local c=Instance.new("UICorner",p) c.CornerRadius=UDim.new(0,r or 8) return c end
local function Sk(p,col,th) local s=Instance.new("UIStroke",p) s.Color=col or C.Acc s.Thickness=th or 1.5 return s end
local function Pad(p,l,r,t,b)
    local pd=Instance.new("UIPadding",p)
    pd.PaddingLeft=UDim.new(0,l or 0) pd.PaddingRight=UDim.new(0,r or 0)
    pd.PaddingTop=UDim.new(0,t or 0) pd.PaddingBottom=UDim.new(0,b or 0)
    return pd
end
local function HRP() local c=player.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function HUM() local c=player.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function ObjPos(obj)
    if not obj or not obj.Parent then return nil end
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local r=obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
        if r then return r.Position end
        local ok,cf=pcall(function() return obj:GetModelCFrame() end)
        if ok and cf then return cf.Position end
    end
    return nil
end
local function Lerp(a,b,t) return a+(b-a)*t end

local Main=Instance.new("Frame",sg)
Main.Name="Main"
Main.Size=UDim2.new(0,360,0,510)
Main.Position=UDim2.new(0.5,-180,0.5,-255)
Main.BackgroundColor3=C.BG
Main.Active=true Main.Draggable=true Main.ClipsDescendants=true
Cr(Main,14)
local mainStroke=Sk(Main,C.Acc,2)
local mainGrad=Instance.new("UIGradient",Main)
mainGrad.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(10,7,20)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(5,5,12))
}) mainGrad.Rotation=145

local TopGlow=Instance.new("Frame",Main)
TopGlow.Size=UDim2.new(1,0,0,2)
TopGlow.BackgroundColor3=C.Acc
TopGlow.BorderSizePixel=0
local TopGlowG=Instance.new("UIGradient",TopGlow)
TopGlowG.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.2,C.Acc),
    ColorSequenceKeypoint.new(0.5,C.Purple),
    ColorSequenceKeypoint.new(0.8,C.Acc2),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0)),
})

local Topbar=Instance.new("Frame",Main)
Topbar.Size=UDim2.new(1,0,0,46)
Topbar.Position=UDim2.new(0,0,0,2)
Topbar.BackgroundColor3=C.Panel
Topbar.BorderSizePixel=0
Cr(Topbar,14)
local TopFix=Instance.new("Frame",Topbar)
TopFix.Size=UDim2.new(1,0,0,14) TopFix.Position=UDim2.new(0,0,1,-14)
TopFix.BackgroundColor3=C.Panel TopFix.BorderSizePixel=0

local LogoDot=Instance.new("Frame",Topbar)
LogoDot.Size=UDim2.new(0,8,0,8) LogoDot.Position=UDim2.new(0,14,0.5,-4)
LogoDot.BackgroundColor3=C.Acc Cr(LogoDot,4)
local LogoDotInner=Instance.new("Frame",LogoDot)
LogoDotInner.Size=UDim2.new(0,4,0,4) LogoDotInner.Position=UDim2.new(0.5,-2,0.5,-2)
LogoDotInner.BackgroundColor3=C.Purple Cr(LogoDotInner,2)

local TitleLbl=Instance.new("TextLabel",Topbar)
TitleLbl.Size=UDim2.new(1,-110,1,0) TitleLbl.Position=UDim2.new(0,26,0,0)
TitleLbl.Text="CyRuZzZ Hub" TitleLbl.TextColor3=C.Text
TitleLbl.Font=Enum.Font.GothamBold TitleLbl.TextSize=15
TitleLbl.BackgroundTransparency=1 TitleLbl.TextXAlignment=Enum.TextXAlignment.Left

local VerLbl=Instance.new("TextLabel",Topbar)
VerLbl.Size=UDim2.new(0,50,0,14) VerLbl.Position=UDim2.new(0,26,1,-18)
VerLbl.Text="v3.0 FINAL" VerLbl.TextColor3=C.Acc
VerLbl.Font=Enum.Font.GothamSemibold VerLbl.TextSize=8
VerLbl.BackgroundTransparency=1 VerLbl.TextXAlignment=Enum.TextXAlignment.Left

local function MkTopBtn(txt,xOff,col,tcol)
    local b=Instance.new("TextButton",Topbar)
    b.Size=UDim2.new(0,26,0,26) b.Position=UDim2.new(1,xOff,0.5,-13)
    b.Text=txt b.BackgroundColor3=col b.TextColor3=tcol or Color3.new(1,1,1)
    b.Font=Enum.Font.GothamBold b.TextSize=12 b.BorderSizePixel=0
    b.AutoButtonColor=false Cr(b,6) return b
end
local MinBtn=MkTopBtn("−",-62,C.CardH,C.Sub)
local CloseBtn=MkTopBtn("✕",-30,C.Red)

local TabBar=Instance.new("Frame",Main)
TabBar.Size=UDim2.new(1,-14,0,30) TabBar.Position=UDim2.new(0,7,0,52)
TabBar.BackgroundColor3=C.Dark Cr(TabBar,8)
Sk(TabBar,C.Border,1)
local TabLayout=Instance.new("UIListLayout",TabBar)
TabLayout.FillDirection=Enum.FillDirection.Horizontal
TabLayout.SortOrder=Enum.SortOrder.LayoutOrder TabLayout.Padding=UDim.new(0,2)
Pad(TabBar,3,3,3,3)

local ContentArea=Instance.new("Frame",Main)
ContentArea.Size=UDim2.new(1,-14,1,-90)
ContentArea.Position=UDim2.new(0,7,0,86)
ContentArea.BackgroundTransparency=1

local pages={}
local tabBtns={}
local tabDefs={
    {name="MAIN", icon="⚡",col=C.Acc},
    {name="MOVE", icon="🧭",col=C.Cyan},
    {name="ESP",  icon="👁", col=C.Pink},
    {name="SCAN", icon="🔍",col=C.Acc2},
    {name="SOCIAL",icon="👥",col=C.Gold},
    {name="INJECT",icon="🔌",col=C.Yellow},
}
for i,def in ipairs(tabDefs) do
    local tb=Instance.new("TextButton",TabBar)
    tb.Size=UDim2.new(1/6,-2,1,0)
    tb.Text=def.icon
    tb.Font=Enum.Font.GothamBold tb.TextSize=13
    tb.BackgroundColor3=C.Card tb.TextColor3=C.Sub
    tb.AutoButtonColor=false tb.LayoutOrder=i Cr(tb,5)
    tabBtns[def.name]={btn=tb,def=def}
    local page=Instance.new("Frame",ContentArea)
    page.Size=UDim2.new(1,0,1,0) page.BackgroundTransparency=1 page.Visible=false
    pages[def.name]=page
end

local activeTab=""
local function SwitchTab(name)
    if activeTab==name then return end
    activeTab=name
    for n,p in pairs(pages) do p.Visible=n==name end
    for n,t in pairs(tabBtns) do
        local on=n==name
        Tw(t.btn,0.14,{BackgroundColor3=on and t.def.col or C.Card,TextColor3=on and Color3.new(1,1,1) or C.Sub})
    end
    mainStroke.Color=tabBtns[name] and tabBtns[name].def.col or C.Acc
end
for name,t in pairs(tabBtns) do
    t.btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
end

local function MkScroll(parent)
    local sf=Instance.new("ScrollingFrame",parent)
    sf.Size=UDim2.new(1,0,1,0) sf.BackgroundTransparency=1 sf.BorderSizePixel=0
    sf.ScrollBarThickness=2 sf.ScrollBarImageColor3=C.Acc sf.CanvasSize=UDim2.new(0,0,0,0)
    local vl=Instance.new("UIListLayout",sf)
    vl.Padding=UDim.new(0,5) vl.SortOrder=Enum.SortOrder.LayoutOrder
    vl.HorizontalAlignment=Enum.HorizontalAlignment.Center
    Pad(sf,0,0,4,4)
    vl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize=UDim2.new(0,0,0,vl.AbsoluteContentSize.Y+12)
    end)
    return sf,vl
end

local function MkCard(parent,h,order)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,-2,0,h) f.BackgroundColor3=C.Card
    f.LayoutOrder=order or 0 f.BorderSizePixel=0
    Cr(f,8) return f
end

local function MkToggle(parent,label,icon,onCol,order)
    local card=MkCard(parent,38,order)
    local btn=Instance.new("TextButton",card)
    btn.Size=UDim2.new(1,-10,1,-10) btn.Position=UDim2.new(0,5,0,5)
    btn.Text=icon.."  "..label..":  OFF"
    btn.BackgroundColor3=C.Red btn.TextColor3=C.Text
    btn.Font=Enum.Font.GothamSemibold btn.TextSize=12
    btn.AutoButtonColor=false Cr(btn,6)
    local function Set(on)
        btn.Text=icon.."  "..label..":  "..(on and "ON ✓" or "OFF")
        Tw(btn,0.15,{BackgroundColor3=on and (onCol or C.Green) or C.Red})
    end
    return btn,Set
end

local function MkStat(parent,order)
    local card=MkCard(parent,22,order) card.BackgroundTransparency=0.7
    local lbl=Instance.new("TextLabel",card)
    lbl.Size=UDim2.new(1,-10,1,0) lbl.Position=UDim2.new(0,8,0,0)
    lbl.Text="Ready" lbl.TextColor3=C.Acc
    lbl.Font=Enum.Font.Gotham lbl.TextSize=10
    lbl.BackgroundTransparency=1 lbl.TextXAlignment=Enum.TextXAlignment.Left
    return lbl
end

local function MkInputRow(parent,placeholder,defaultVal,order)
    local card=MkCard(parent,34,order)
    local inp=Instance.new("TextBox",card)
    inp.Size=UDim2.new(1,-10,1,-10) inp.Position=UDim2.new(0,5,0,5)
    inp.PlaceholderText=placeholder inp.Text=defaultVal or ""
    inp.BackgroundColor3=C.Input inp.TextColor3=C.Cyan
    inp.Font=Enum.Font.Code inp.TextSize=11
    inp.ClearTextOnFocus=false Cr(inp,6)
    Pad(inp,8,8,0,0)
    return inp
end

local function MkBtn(parent,txt,col,order,h)
    local card=MkCard(parent,h or 34,order)
    local btn=Instance.new("TextButton",card)
    btn.Size=UDim2.new(1,-10,1,-10) btn.Position=UDim2.new(0,5,0,5)
    btn.Text=txt btn.BackgroundColor3=col btn.TextColor3=C.Text
    btn.Font=Enum.Font.GothamSemibold btn.TextSize=11
    btn.AutoButtonColor=false Cr(btn,6)
    return btn
end

local function MkDualBtn(parent,t1,c1,t2,c2,order)
    local card=MkCard(parent,38,order)
    local b1=Instance.new("TextButton",card)
    b1.Size=UDim2.new(0.5,-8,1,-10) b1.Position=UDim2.new(0,5,0,5)
    b1.Text=t1 b1.BackgroundColor3=c1 b1.TextColor3=C.Text
    b1.Font=Enum.Font.GothamSemibold b1.TextSize=11 b1.AutoButtonColor=false Cr(b1,6)
    local b2=Instance.new("TextButton",card)
    b2.Size=UDim2.new(0.5,-8,1,-10) b2.Position=UDim2.new(0.5,3,0,5)
    b2.Text=t2 b2.BackgroundColor3=c2 b2.TextColor3=C.Text
    b2.Font=Enum.Font.GothamSemibold b2.TextSize=11 b2.AutoButtonColor=false Cr(b2,6)
    return b1,b2
end

local function MkSliderRow(parent,label,min,max,default,order)
    local card=MkCard(parent,52,order)
    local lbl=Instance.new("TextLabel",card)
    lbl.Size=UDim2.new(1,-10,0,18) lbl.Position=UDim2.new(0,8,0,4)
    lbl.Text=label..": "..default lbl.TextColor3=C.Sub
    lbl.Font=Enum.Font.Gotham lbl.TextSize=10
    lbl.BackgroundTransparency=1 lbl.TextXAlignment=Enum.TextXAlignment.Left
    local track=Instance.new("Frame",card)
    track.Size=UDim2.new(1,-16,0,8) track.Position=UDim2.new(0,8,0,32)
    track.BackgroundColor3=C.Input Cr(track,4)
    local fill=Instance.new("Frame",track)
    local pct=(default-min)/(max-min)
    fill.Size=UDim2.new(pct,0,1,0) fill.BackgroundColor3=C.Acc
    fill.BorderSizePixel=0 Cr(fill,4)
    local knob=Instance.new("TextButton",track)
    knob.Size=UDim2.new(0,16,0,16) knob.Position=UDim2.new(pct,-8,0.5,-8)
    knob.Text="" knob.BackgroundColor3=C.Acc knob.ZIndex=5
    knob.AutoButtonColor=false Cr(knob,8)
    local dragging=false
    local val=default
    knob.MouseButton1Down:Connect(function() dragging=true end)
    AddConn(UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end))
    AddConn(RunService.Heartbeat:Connect(function()
        if dragging then
            local rel=UserInputService:GetMouseLocation().X-track.AbsolutePosition.X
            local p2=math.clamp(rel/track.AbsoluteSize.X,0,1)
            val=math.floor(Lerp(min,max,p2))
            knob.Position=UDim2.new(p2,-8,0.5,-8)
            fill.Size=UDim2.new(p2,0,1,0)
            lbl.Text=label..": "..val
        end
    end))
    return card,lbl,fill,knob,function() return val end
end

local function MkSectionHeader(parent,txt,col,order)
    local card=MkCard(parent,22,order)
    card.BackgroundTransparency=0.5
    local lbl=Instance.new("TextLabel",card)
    lbl.Size=UDim2.new(1,-10,1,0) lbl.Position=UDim2.new(0,8,0,0)
    lbl.Text=txt lbl.TextColor3=col or C.Acc
    lbl.Font=Enum.Font.GothamBold lbl.TextSize=10
    lbl.BackgroundTransparency=1 lbl.TextXAlignment=Enum.TextXAlignment.Left
    return card
end
local mainScroll,_=MkScroll(pages["MAIN"])
MkSectionHeader(mainScroll,"⚡  MOVEMENT",C.Acc,1)

local speedCard=MkCard(mainScroll,38,2)
local speedInp=Instance.new("TextBox",speedCard)
speedInp.Size=UDim2.new(0,72,1,-10) speedInp.Position=UDim2.new(0,5,0,5)
speedInp.Text="120" speedInp.PlaceholderText="Speed"
speedInp.BackgroundColor3=C.Input speedInp.TextColor3=C.Cyan
speedInp.Font=Enum.Font.GothamBold speedInp.TextSize=13
speedInp.ClearTextOnFocus=false Cr(speedInp,6)
Pad(speedInp,6,0,0,0)
local speedToggle=Instance.new("TextButton",speedCard)
speedToggle.Size=UDim2.new(1,-86,1,-10) speedToggle.Position=UDim2.new(0,81,0,5)
speedToggle.Text="⚡ SPEED:  OFF" speedToggle.BackgroundColor3=C.Red
speedToggle.TextColor3=C.Text speedToggle.Font=Enum.Font.GothamSemibold speedToggle.TextSize=12
speedToggle.AutoButtonColor=false Cr(speedToggle,6)

local flyBtn,setFly=MkToggle(mainScroll,"FLY","✈",C.Green,3)
local noclipBtn,setNoclip=MkToggle(mainScroll,"NOCLIP","👻",Color3.fromRGB(100,60,220),4)
local infJumpBtn,setInfJump=MkToggle(mainScroll,"INFINITE JUMP","🦘",Color3.fromRGB(255,140,0),5)

MkSectionHeader(mainScroll,"🛡  COMBAT / STEALTH",C.Purple,6)
local godBtn,setGod=MkToggle(mainScroll,"GODMODE","🛡",C.Orange,7)
local ghostBtn,setGhost=MkToggle(mainScroll,"GHOST (Full Invis)","🌫",Color3.fromRGB(80,200,200),8)
local aimbotBtn,setAimbot=MkToggle(mainScroll,"AIMBOT LOCK","🎯",C.Pink,9)

MkSectionHeader(mainScroll,"🌟  VISUAL",C.Cyan,10)
local fullbrightBtn,setFullbright=MkToggle(mainScroll,"FULL BRIGHT","💡",C.Yellow,11)
local freecamBtn,setFreecam=MkToggle(mainScroll,"FREECAM","📷",C.Teal,12)
local clickTPBtn,setClickTP=MkToggle(mainScroll,"CLICK TP","🖱",C.Acc2,13)
local instantEBtn,setInstantE=MkToggle(mainScroll,"INSTANT INTERACT (E)","⚡",C.Lime,14)
local mainStat=MkStat(mainScroll,16)

local moveScroll,_=MkScroll(pages["MOVE"])
MkSectionHeader(moveScroll,"📍  CURRENT POSITION",C.Cyan,1)
local posDisplay=MkInputRow(moveScroll,"x, y, z","Belum diambil",2)
local getPosBtn,copyPosBtn=MkDualBtn(moveScroll,"📍 GET POS",C.Cyan,"📋 COPY",C.Card,3)

MkSectionHeader(moveScroll,"📌  TELEPORT 1",C.Acc,4)
local tp1Inp=MkInputRow(moveScroll,"x, y, z  (ketik atau SET)","",5)
local tp1SetBtn,tp1GoBtn=MkDualBtn(moveScroll,"📍 SET",C.Card,"🚀 TP 1",C.Acc,6)

MkSectionHeader(moveScroll,"📌  TELEPORT 2",C.Pink,7)
local tp2Inp=MkInputRow(moveScroll,"x, y, z","",8)
local tp2SetBtn,tp2GoBtn=MkDualBtn(moveScroll,"📍 SET",C.Card,"🚀 TP 2",C.Pink,9)

MkSectionHeader(moveScroll,"↩️  BACK / HISTORY",C.Gold,10)
local backBtn=MkBtn(moveScroll,"↩️  BACK  (kembali ke posisi sebelum TP)",C.Card,11)
backBtn.TextColor3=C.Gold
Sk(backBtn.Parent,C.Gold,1)
local moveStat=MkStat(moveScroll,12)
local originPos=nil
local backPos=nil

local function ParseCoord(str)
    if not str or str=="" then return nil end
    local s=str:gsub(","," ")
    local t={}
    for v in s:gmatch("[%-%.%d]+") do table.insert(t,v) end
    return tonumber(t[1]),tonumber(t[2]),tonumber(t[3])
end
local function GetCurrentPos()
    local hrp=HRP()
    if not hrp then return nil end
    return hrp.Position
end
local function PosToStr(p)
    if not p then return "" end
    return string.format("%.1f, %.1f, %.1f",p.X,p.Y,p.Z)
end
local function DoTP(x,y,z)
    local hrp=HRP()
    if not hrp then return false end
    if not x or not y or not z then return false end
    backPos=hrp.Position
    hrp.CFrame=CFrame.new(x,y+2,z)
    return true
end

getPosBtn.MouseButton1Click:Connect(function()
    local p=GetCurrentPos()
    if p then
        posDisplay.Text=PosToStr(p)
        moveStat.Text="✅ Posisi diambil" moveStat.TextColor3=C.Lime
        Tw(getPosBtn,0.12,{BackgroundColor3=C.Lime,TextColor3=Color3.new(0,0,0)})
        task.delay(1,function() Tw(getPosBtn,0.12,{BackgroundColor3=C.Cyan,TextColor3=C.Text}) end)
    end
end)
copyPosBtn.MouseButton1Click:Connect(function()
    if posDisplay.Text=="" or posDisplay.Text=="Belum diambil" then
        moveStat.Text="⚠️ GET dulu!" moveStat.TextColor3=C.Red return
    end
    if setclipboard then setclipboard(posDisplay.Text) end
    moveStat.Text="📋 Disalin!" moveStat.TextColor3=C.Lime
    Tw(copyPosBtn,0.12,{BackgroundColor3=C.Green,TextColor3=Color3.new(1,1,1)})
    task.delay(1.5,function() Tw(copyPosBtn,0.12,{BackgroundColor3=C.Card,TextColor3=C.Sub}) end)
end)
tp1SetBtn.MouseButton1Click:Connect(function()
    local p=GetCurrentPos()
    if p then tp1Inp.Text=PosToStr(p) moveStat.Text="✅ TP1 di-set" moveStat.TextColor3=C.Lime end
end)
tp2SetBtn.MouseButton1Click:Connect(function()
    local p=GetCurrentPos()
    if p then tp2Inp.Text=PosToStr(p) moveStat.Text="✅ TP2 di-set" moveStat.TextColor3=C.Lime end
end)
tp1GoBtn.MouseButton1Click:Connect(function()
    local x,y,z=ParseCoord(tp1Inp.Text)
    if DoTP(x,y,z) then moveStat.Text="🚀 TP1 berhasil" moveStat.TextColor3=C.Lime
    else moveStat.Text="⚠️ Koordinat tidak valid" moveStat.TextColor3=C.Red end
end)
tp2GoBtn.MouseButton1Click:Connect(function()
    local x,y,z=ParseCoord(tp2Inp.Text)
    if DoTP(x,y,z) then moveStat.Text="🚀 TP2 berhasil" moveStat.TextColor3=C.Lime
    else moveStat.Text="⚠️ Koordinat tidak valid" moveStat.TextColor3=C.Red end
end)
backBtn.MouseButton1Click:Connect(function()
    if backPos then
        local hrp=HRP()
        if hrp then
            local curr=hrp.Position
            hrp.CFrame=CFrame.new(backPos+Vector3.new(0,2,0))
            backPos=curr
            moveStat.Text="↩️ Kembali!" moveStat.TextColor3=C.Gold
            Tw(backBtn,0.12,{BackgroundColor3=C.Gold,TextColor3=Color3.new(0,0,0)})
            task.delay(1,function() Tw(backBtn,0.12,{BackgroundColor3=C.Card,TextColor3=C.Gold}) end)
        end
    else
        moveStat.Text="⚠️ Belum ada posisi back" moveStat.TextColor3=C.Red
    end
end)

local espScroll,_=MkScroll(pages["ESP"])
MkSectionHeader(espScroll,"👁  ESP VISUALS",C.Pink,1)
local espObjBtn,setEspObj=MkToggle(espScroll,"ESP OBJECTS","🔵",C.Acc2,2)
local espPlayersBtn,setEspPlayers=MkToggle(espScroll,"ESP PLAYERS","👤",C.Pink,3)
local lockBtn,setLock=MkToggle(espScroll,"TARGET LOCK CAM","🎯",C.Orange,4)

local hkCard=MkCard(espScroll,46,5) hkCard.BackgroundTransparency=0.6
local hkLbl=Instance.new("TextLabel",hkCard)
hkLbl.Size=UDim2.new(1,-10,1,0) hkLbl.Position=UDim2.new(0,8,0,0)
hkLbl.Text="T = Toggle Lock Nearest   G = Next Target\nAimbot di tab MAIN" hkLbl.TextColor3=C.Sub
hkLbl.Font=Enum.Font.Gotham hkLbl.TextSize=9 hkLbl.BackgroundTransparency=1
hkLbl.TextXAlignment=Enum.TextXAlignment.Left hkLbl.TextWrapped=true

local espStat=MkStat(espScroll,6)

local espContainer=Instance.new("Folder",workspace) espContainer.Name="_CyESP"
local espObjects={} local espPlayers={} local scanEspMap={}
local currentHL=nil
local lockTarget=nil

local function MkSelBox(adornee,col)
    local sb=Instance.new("SelectionBox",espContainer)
    sb.Adornee=adornee sb.Color3=col or C.Acc
    sb.LineThickness=0.06 sb.SurfaceTransparency=0.78 sb.SurfaceColor3=col or C.Acc
    return sb
end
local function MkBill(adornee,txt,col,yOff)
    local bb=Instance.new("BillboardGui",espContainer)
    bb.Adornee=adornee bb.Size=UDim2.new(0,130,0,32)
    bb.StudsOffset=Vector3.new(0,(yOff or 0)+3,0)
    bb.AlwaysOnTop=true bb.MaxDistance=350
    local lbl=Instance.new("TextLabel",bb)
    lbl.Size=UDim2.new(1,0,1,0)
    lbl.BackgroundColor3=Color3.new(0,0,0) lbl.BackgroundTransparency=0.55
    lbl.TextColor3=col or C.Acc lbl.Font=Enum.Font.GothamBold lbl.TextSize=9
    lbl.Text=txt lbl.TextStrokeTransparency=0.5 Cr(lbl,4)
    return bb,lbl
end
local function RemObjEsp(obj)
    if espObjects[obj] then
        pcall(function() if espObjects[obj].box then espObjects[obj].box:Destroy() end end)
        pcall(function() if espObjects[obj].bill then espObjects[obj].bill:Destroy() end end)
        espObjects[obj]=nil
    end
end
local function AddObjEsp(obj,col)
    RemObjEsp(obj) col=col or C.Acc
    local target=obj
    if obj:IsA("Model") then
        local r=obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
        if r then target=r end
    end
    local box=MkSelBox(obj,col)
    local bb,lbl=MkBill(target,obj.Name,col)
    espObjects[obj]={box=box,bill=bb,lbl=lbl,part=target}
end
local function UpdateEspLabel(obj)
    local d=espObjects[obj] if not d or not d.lbl then return end
    local hrp=HRP() local part=d.part
    if part and part.Parent and hrp then
        local ok,pos=pcall(function()
            if part:IsA("BasePart") then return part.Position end
        end)
        if ok and pos then
            local dist=math.floor((pos-hrp.Position).Magnitude)
            d.lbl.Text=obj.Name.."\n📍 "..dist.."st"
        end
    end
end
local function RemPlayerEsp(p)
    if espPlayers[p] then
        for _,v in pairs(espPlayers[p]) do pcall(function() v:Destroy() end) end
        espPlayers[p]=nil
    end
end
local function RefreshPlayerEsp()
    for p,_ in pairs(espPlayers) do if not p or not p.Parent then RemPlayerEsp(p) end end
    if not State.espPlayers then
        for p,_ in pairs(espPlayers) do RemPlayerEsp(p) end return
    end
    for _,p in pairs(Players:GetPlayers()) do
        if p==player then continue end
        local char=p.Character
        if not char then RemPlayerEsp(p) continue end
        local root=char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
        if not root then RemPlayerEsp(p) continue end
        if not espPlayers[p] then
            local box=MkSelBox(char,C.Pink)
            local bb,lbl=MkBill(root,"👤 "..p.Name,C.Pink,2)
            espPlayers[p]={box,bb}
        end
    end
end
Players.PlayerRemoving:Connect(function(p) RemPlayerEsp(p) end)
local function SetHL(obj)
    if currentHL then currentHL:Destroy() currentHL=nil end
    if not obj then return end
    local h=Instance.new("SelectionBox",espContainer)
    h.Adornee=obj h.Color3=C.Yellow
    h.LineThickness=0.1 h.SurfaceTransparency=0.7 h.SurfaceColor3=C.Yellow
    currentHL=h
end
local function GetAllTargets()
    local tgts={}
    for _,p in pairs(Players:GetPlayers()) do
        if p==player then continue end
        local char=p.Character
        if not char then continue end
        local root=char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
        if root then table.insert(tgts,{part=root,name=p.Name,player=p}) end
    end
    return tgts
end
local function FindNearest()
    local hrp=HRP() if not hrp then return nil end
    local near,nearD=nil,math.huge
    for _,t in pairs(GetAllTargets()) do
        local d=(t.part.Position-hrp.Position).Magnitude
        if d<nearD then nearD=d near=t end
    end
    return near
end
local scanPage=pages["SCAN"]
local searchBox=Instance.new("TextBox",scanPage)
searchBox.Size=UDim2.new(1,0,0,28) searchBox.PlaceholderText="🔍  Cari nama objek..."
searchBox.Text="" searchBox.BackgroundColor3=C.Input searchBox.TextColor3=C.Text
searchBox.Font=Enum.Font.Gotham searchBox.TextSize=11 searchBox.ClearTextOnFocus=false
Cr(searchBox,7) Pad(searchBox,8,0,0,0)

local scanBtnRow=Instance.new("Frame",scanPage)
scanBtnRow.Size=UDim2.new(1,0,0,28) scanBtnRow.Position=UDim2.new(0,0,0,32)
scanBtnRow.BackgroundTransparency=1
local sRefBtn=Instance.new("TextButton",scanBtnRow)
sRefBtn.Size=UDim2.new(1/3,-2,1,0) sRefBtn.Text="SCAN" sRefBtn.BackgroundColor3=C.Acc2
sRefBtn.TextColor3=Color3.new(1,1,1) sRefBtn.Font=Enum.Font.GothamBold sRefBtn.TextSize=11
sRefBtn.AutoButtonColor=false Cr(sRefBtn,6)
local sTpBtn=Instance.new("TextButton",scanBtnRow)
sTpBtn.Size=UDim2.new(1/3,-2,1,0) sTpBtn.Position=UDim2.new(1/3,2,0,0)
sTpBtn.Text="TP" sTpBtn.BackgroundColor3=C.Card sTpBtn.TextColor3=C.Sub
sTpBtn.Font=Enum.Font.GothamBold sTpBtn.TextSize=11 sTpBtn.AutoButtonColor=false Cr(sTpBtn,6)
local sEspBtn=Instance.new("TextButton",scanBtnRow)
sEspBtn.Size=UDim2.new(1/3,-2,1,0) sEspBtn.Position=UDim2.new(2/3,4,0,0)
sEspBtn.Text="ESP" sEspBtn.BackgroundColor3=C.Card sEspBtn.TextColor3=C.Sub
sEspBtn.Font=Enum.Font.GothamBold sEspBtn.TextSize=11 sEspBtn.AutoButtonColor=false Cr(sEspBtn,6)

local filterRow=Instance.new("Frame",scanPage)
filterRow.Size=UDim2.new(1,0,0,22) filterRow.Position=UDim2.new(0,0,0,64)
filterRow.BackgroundTransparency=1
local fLayout=Instance.new("UIListLayout",filterRow)
fLayout.FillDirection=Enum.FillDirection.Horizontal fLayout.Padding=UDim.new(0,3)
local filterActive="ALL" local filterBtns={}
for i,lbl in ipairs({"ALL","Player","Model","Part","NPC"}) do
    local fb=Instance.new("TextButton",filterRow)
    fb.Size=UDim2.new(0,i==1 and 32 or 50,1,0)
    fb.Text=lbl fb.Font=Enum.Font.GothamSemibold fb.TextSize=9
    fb.BackgroundColor3=i==1 and C.Acc or C.Card
    fb.TextColor3=i==1 and Color3.new(1,1,1) or C.Sub
    fb.AutoButtonColor=false fb.LayoutOrder=i Cr(fb,5)
    filterBtns[lbl]=fb
end
local scanStat=Instance.new("TextLabel",scanPage)
scanStat.Size=UDim2.new(1,0,0,13) scanStat.Position=UDim2.new(0,0,0,90)
scanStat.Text="Tekan SCAN" scanStat.TextColor3=C.Sub
scanStat.Font=Enum.Font.Gotham scanStat.TextSize=9
scanStat.BackgroundTransparency=1 scanStat.TextXAlignment=Enum.TextXAlignment.Left
local listFrame=Instance.new("ScrollingFrame",scanPage)
listFrame.Size=UDim2.new(1,0,1,-106) listFrame.Position=UDim2.new(0,0,0,106)
listFrame.BackgroundColor3=C.Input listFrame.BorderSizePixel=0
listFrame.ScrollBarThickness=2 listFrame.ScrollBarImageColor3=C.Acc
listFrame.CanvasSize=UDim2.new(0,0,0,0) Cr(listFrame,6)
local listLayout=Instance.new("UIListLayout",listFrame)
listLayout.Padding=UDim.new(0,2) listLayout.SortOrder=Enum.SortOrder.LayoutOrder
Pad(listFrame,3,3,3,3)
local allObjs={} local selectedObj=nil

local function GetCat(obj)
    if obj:IsA("Model") then
        if Players:GetPlayerFromCharacter(obj) then return "Player" end
        if obj:FindFirstChildOfClass("Humanoid") then return "NPC" end
        return "Model"
    elseif obj:IsA("BasePart") then return "Part"
    else return obj.ClassName end
end
local function GetObjDist(obj)
    local hrp=HRP() local pos=ObjPos(obj)
    if not hrp or not pos then return 9999 end
    return math.floor((hrp.Position-pos).Magnitude)
end
local function BuildScanList(filter)
    for _,c in pairs(listFrame:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("Frame") then c:Destroy() end
    end
    local sorted={}
    local icons={Player="👤",NPC="🤖",Model="📦",Part="🔷"}
    for _,obj in ipairs(allObjs) do
        local cat=GetCat(obj)
        if filterActive~="ALL" and cat~=filterActive then continue end
        local name=obj.Name
        if filter and filter~="" then
            if not string.lower(name):find(string.lower(filter),1,true) then continue end
        end
        table.insert(sorted,{obj=obj,name=name,cat=cat,dist=GetObjDist(obj)})
    end
    table.sort(sorted,function(a,b) return a.dist<b.dist end)
    for i,data in ipairs(sorted) do
        local entry=Instance.new("TextButton",listFrame)
        entry.Size=UDim2.new(1,0,0,30)
        entry.BackgroundColor3=C.Card
        entry.TextColor3=data.cat=="Player" and Color3.fromRGB(185,145,255) or C.Text
        entry.Font=Enum.Font.Gotham entry.TextSize=9
        entry.TextXAlignment=Enum.TextXAlignment.Left
        entry.BorderSizePixel=0 entry.LayoutOrder=i entry.AutoButtonColor=false
        entry.Text="  "..(icons[data.cat] or "❔").."  "..data.name.."   ("..data.dist.."st)"
        entry.TextTruncate=Enum.TextTruncate.AtEnd
        Cr(entry,5)
        entry.MouseButton1Click:Connect(function()
            selectedObj=data.obj
            for _,e in pairs(listFrame:GetChildren()) do
                if e:IsA("TextButton") then e.BackgroundColor3=C.Card end
            end
            Tw(entry,0.1,{BackgroundColor3=Color3.fromRGB(35,24,70)})
            SetHL(data.obj)
            scanStat.Text="✅ "..data.name
            Tw(sTpBtn,0.15,{BackgroundColor3=C.Green,TextColor3=Color3.new(1,1,1)})
        end)
    end
    listFrame.CanvasSize=UDim2.new(0,0,0,(#sorted*32)+8)
    scanStat.Text="📋 "..(#sorted).." objek ditemukan"
end
local function DoScan()
    allObjs={}
    local function addDeep(parent,depth)
        if depth<=0 then return end
        pcall(function()
            for _,obj in ipairs(parent:GetChildren()) do
                if obj==player.Character then continue end
                if obj.Name=="_CyESP" then continue end
                if obj.Name=="Terrain" then continue end
                table.insert(allObjs,obj)
                if obj:IsA("Model") or obj:IsA("Folder") then
                    addDeep(obj,depth-1)
                end
            end
        end)
    end
    for _,obj in ipairs(workspace:GetChildren()) do
        if obj.Name==player.Name then continue end
        if obj.Name=="Terrain" then continue end
        if obj.Name=="_CyESP" then continue end
        table.insert(allObjs,obj)
        -- Deep scan known brainrot containers
        local lname=obj.Name:lower()
        if lname:find("brainrot") or lname:find("active") or lname:find("item")
        or lname:find("drop") or lname:find("spawn") or lname:find("collect")
        or lname:find("map") or lname:find("zone") or lname:find("holder") then
            addDeep(obj,3)
        elseif obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
            for _,child in ipairs(obj:GetChildren()) do
                if child:IsA("Model") or child:IsA("BasePart") then
                    table.insert(allObjs,child)
                end
            end
        end
    end
    BuildScanList(searchBox.Text)
end
for lbl,fb in pairs(filterBtns) do
    fb.MouseButton1Click:Connect(function()
        filterActive=lbl
        for l,btn in pairs(filterBtns) do
            Tw(btn,0.12,{BackgroundColor3=l==lbl and C.Acc or C.Card,TextColor3=l==lbl and Color3.new(1,1,1) or C.Sub})
        end
        BuildScanList(searchBox.Text)
    end)
end
searchBox:GetPropertyChangedSignal("Text"):Connect(function() BuildScanList(searchBox.Text) end)
sRefBtn.MouseButton1Click:Connect(function()
    scanStat.Text="🔄 Scanning..." task.wait(0.05) DoScan()
end)
sTpBtn.MouseButton1Click:Connect(function()
    if not selectedObj then scanStat.Text="⚠️ Pilih dulu!" return end
    local pos=ObjPos(selectedObj)
    if not pos then scanStat.Text="⚠️ No position" return end
    local hrp=HRP()
    if hrp then
        backPos=hrp.Position
        hrp.CFrame=CFrame.new(pos+Vector3.new(0,5,0))
        scanStat.Text="🚀 TP: "..selectedObj.Name
    end
end)
sEspBtn.MouseButton1Click:Connect(function()
    if not selectedObj then scanStat.Text="⚠️ Pilih dulu!" return end
    if scanEspMap[selectedObj] then
        RemObjEsp(selectedObj) scanEspMap[selectedObj]=nil
        Tw(sEspBtn,0.15,{BackgroundColor3=C.Card,TextColor3=C.Sub})
        sEspBtn.Text="ESP"
    else
        AddObjEsp(selectedObj,C.Yellow) scanEspMap[selectedObj]=true
        Tw(sEspBtn,0.15,{BackgroundColor3=C.Green,TextColor3=Color3.new(1,1,1)})
        sEspBtn.Text="ESP ✓"
    end
end)

local remSection=MkCard(scanPage,0,99)
remSection.Size=UDim2.new(1,0,0,0)
remSection.BackgroundTransparency=1
local socialScroll,_=MkScroll(pages["SOCIAL"])

MkSectionHeader(socialScroll,"🎮  SERVER / JOB ID",C.Gold,1)
local jobIdCard=MkCard(socialScroll,34,2)
local jobIdLbl=Instance.new("TextLabel",jobIdCard)
jobIdLbl.Size=UDim2.new(1,-90,1,-8) jobIdLbl.Position=UDim2.new(0,8,0,4)
local jid=game.JobId
jobIdLbl.Text=jid~="" and jid:sub(1,22).."..." or "Private Server"
jobIdLbl.TextColor3=C.Gold jobIdLbl.Font=Enum.Font.Code jobIdLbl.TextSize=9
jobIdLbl.BackgroundTransparency=1 jobIdLbl.TextXAlignment=Enum.TextXAlignment.Left
local copyJobBtn=Instance.new("TextButton",jobIdCard)
copyJobBtn.Size=UDim2.new(0,80,1,-8) copyJobBtn.Position=UDim2.new(1,-84,0,4)
copyJobBtn.Text="📋 COPY ID" copyJobBtn.BackgroundColor3=C.Gold
copyJobBtn.TextColor3=Color3.new(0,0,0) copyJobBtn.Font=Enum.Font.GothamBold copyJobBtn.TextSize=9
copyJobBtn.AutoButtonColor=false Cr(copyJobBtn,5)
copyJobBtn.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard(game.JobId) end
    copyJobBtn.Text="✅ Copied!" Tw(copyJobBtn,0.12,{BackgroundColor3=C.Lime})
    task.delay(1.5,function() copyJobBtn.Text="📋 COPY ID" Tw(copyJobBtn,0.12,{BackgroundColor3=C.Gold}) end)
end)

MkSectionHeader(socialScroll,"🔗  JOIN VIA JOB ID",C.Teal,3)
local joinInp=MkInputRow(socialScroll,"Paste Job ID di sini...","",4)
local joinBtn=MkBtn(socialScroll,"🔗  JOIN SERVER INI",C.Teal,5,34)
joinBtn.TextColor3=Color3.new(0,0,0) joinBtn.Font=Enum.Font.GothamBold
joinBtn.MouseButton1Click:Connect(function()
    local id=joinInp.Text
    if id=="" then return end
    local TeleportService=game:GetService("TeleportService")
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId,id,player)
    end)
end)

MkSectionHeader(socialScroll,"👥  PLAYERS",C.Pink,6)
local playerListFrame=Instance.new("ScrollingFrame",MkCard(socialScroll,180,7))
playerListFrame.Size=UDim2.new(1,-10,1,-10) playerListFrame.Position=UDim2.new(0,5,0,5)
playerListFrame.BackgroundColor3=C.Input playerListFrame.BorderSizePixel=0
playerListFrame.ScrollBarThickness=2 playerListFrame.ScrollBarImageColor3=C.Pink
playerListFrame.CanvasSize=UDim2.new(0,0,0,0) Cr(playerListFrame,6)
local plLayout=Instance.new("UIListLayout",playerListFrame)
plLayout.Padding=UDim.new(0,2) plLayout.SortOrder=Enum.SortOrder.LayoutOrder
Pad(playerListFrame,3,3,3,3)

local socialStat=MkStat(socialScroll,8)
local selectedPlayerName=""
local playerLastPos={}

local function BuildPlayerList()
    for _,c in pairs(playerListFrame:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end
    local plist=Players:GetPlayers()
    for i,p in ipairs(plist) do
        if p==player then continue end
        local row=Instance.new("Frame",playerListFrame)
        row.Size=UDim2.new(1,0,0,36) row.BackgroundColor3=C.Card
        row.BorderSizePixel=0 row.LayoutOrder=i Cr(row,5)

        local ava=Instance.new("TextLabel",row)
        ava.Size=UDim2.new(0,30,0,30) ava.Position=UDim2.new(0,4,0,3)
        ava.Text="👤" ava.TextSize=18 ava.BackgroundColor3=C.CardH
        ava.TextColor3=C.Pink ava.BackgroundTransparency=0 Cr(ava,6)
        ava.Font=Enum.Font.GothamBold

        local nameLbl=Instance.new("TextLabel",row)
        nameLbl.Size=UDim2.new(1,-130,0,18) nameLbl.Position=UDim2.new(0,38,0,3)
        nameLbl.Text=p.Name nameLbl.TextColor3=C.Text
        nameLbl.Font=Enum.Font.GothamSemibold nameLbl.TextSize=10
        nameLbl.BackgroundTransparency=1 nameLbl.TextXAlignment=Enum.TextXAlignment.Left
        nameLbl.TextTruncate=Enum.TextTruncate.AtEnd

        local hrp2=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        local dist="?"
        local myHrp=HRP()
        if hrp2 and myHrp then
            dist=math.floor((hrp2.Position-myHrp.Position).Magnitude).."st"
        end
        local distLbl=Instance.new("TextLabel",row)
        distLbl.Size=UDim2.new(1,-130,0,12) distLbl.Position=UDim2.new(0,38,0,20)
        distLbl.Text="📍 "..dist nameLbl.TextColor3=C.Sub
        distLbl.TextColor3=C.Sub distLbl.Font=Enum.Font.Gotham distLbl.TextSize=8
        distLbl.BackgroundTransparency=1 distLbl.TextXAlignment=Enum.TextXAlignment.Left

        local tpPBtn=Instance.new("TextButton",row)
        tpPBtn.Size=UDim2.new(0,28,0,28) tpPBtn.Position=UDim2.new(1,-94,0,4)
        tpPBtn.Text="🚀" tpPBtn.BackgroundColor3=Color3.fromRGB(30,20,70)
        tpPBtn.TextColor3=C.Acc tpPBtn.Font=Enum.Font.GothamBold tpPBtn.TextSize=13
        tpPBtn.AutoButtonColor=false Cr(tpPBtn,6)

        local followPBtn=Instance.new("TextButton",row)
        followPBtn.Size=UDim2.new(0,28,0,28) followPBtn.Position=UDim2.new(1,-62,0,4)
        followPBtn.Text="🔗" followPBtn.BackgroundColor3=Color3.fromRGB(20,40,70)
        followPBtn.TextColor3=C.Cyan followPBtn.Font=Enum.Font.GothamBold followPBtn.TextSize=13
        followPBtn.AutoButtonColor=false Cr(followPBtn,6)

        local hitchPBtn=Instance.new("TextButton",row)
        hitchPBtn.Size=UDim2.new(0,28,0,28) hitchPBtn.Position=UDim2.new(1,-30,0,4)
        hitchPBtn.Text="🧲" hitchPBtn.BackgroundColor3=Color3.fromRGB(40,20,60)
        hitchPBtn.TextColor3=C.Purple hitchPBtn.Font=Enum.Font.GothamBold hitchPBtn.TextSize=13
        hitchPBtn.AutoButtonColor=false Cr(hitchPBtn,6)

        local cap=p
        tpPBtn.MouseButton1Click:Connect(function()
            local char2=cap.Character
            local root2=char2 and (char2:FindFirstChild("HumanoidRootPart") or char2:FindFirstChildWhichIsA("BasePart"))
            if root2 then
                local hrp=HRP()
                if hrp then
                    backPos=hrp.Position
                    playerLastPos[cap.Name]=root2.Position
                    hrp.CFrame=CFrame.new(root2.Position+Vector3.new(0,3,0))
                    socialStat.Text="🚀 TP ke "..cap.Name
                    socialStat.TextColor3=C.Lime
                end
            else
                socialStat.Text="⚠️ "..cap.Name.." tidak punya karakter"
                socialStat.TextColor3=C.Red
            end
        end)
        followPBtn.MouseButton1Click:Connect(function()
            if State.followTarget==cap.Name then
                State.follow=false State.followTarget=nil
                socialStat.Text="🔗 Follow OFF" socialStat.TextColor3=C.Sub
                Tw(followPBtn,0.12,{BackgroundColor3=Color3.fromRGB(20,40,70),TextColor3=C.Cyan})
            else
                State.follow=true State.followTarget=cap.Name
                socialStat.Text="🔗 Follow: "..cap.Name socialStat.TextColor3=C.Cyan
                Tw(followPBtn,0.12,{BackgroundColor3=C.Cyan,TextColor3=Color3.new(0,0,0)})
            end
        end)
        hitchPBtn.MouseButton1Click:Connect(function()
            if State.hitchTarget==cap.Name then
                State.hitch=false State.hitchTarget=nil
                socialStat.Text="🧲 Hitch OFF" socialStat.TextColor3=C.Sub
                Tw(hitchPBtn,0.12,{BackgroundColor3=Color3.fromRGB(40,20,60),TextColor3=C.Purple})
            else
                State.hitch=true State.hitchTarget=cap.Name
                socialStat.Text="🧲 Nempel ke "..cap.Name socialStat.TextColor3=C.Purple
                Tw(hitchPBtn,0.12,{BackgroundColor3=C.Purple,TextColor3=Color3.new(1,1,1)})
            end
        end)
    end
    plLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        playerListFrame.CanvasSize=UDim2.new(0,0,0,plLayout.AbsoluteContentSize.Y+8)
    end)
end

local refreshPlBtn=MkBtn(socialScroll,"🔄  Refresh Player List",C.Card,9,28)
refreshPlBtn.TextColor3=C.Sub refreshPlBtn.TextSize=10
refreshPlBtn.MouseButton1Click:Connect(function()
    BuildPlayerList()
    socialStat.Text="✅ Player list diperbarui" socialStat.TextColor3=C.Lime
end)

MkSectionHeader(socialScroll,"🧲  ITEM MAGNET",C.Purple,10)
local magnetCard=MkCard(socialScroll,110,11)
local magRemInp=Instance.new("TextBox",magnetCard)
magRemInp.Size=UDim2.new(1,-16,0,24) magRemInp.Position=UDim2.new(0,8,0,6)
magRemInp.PlaceholderText="Nama RemoteEvent (opsional)" magRemInp.Text=""
magRemInp.BackgroundColor3=C.Input magRemInp.TextColor3=C.Text
magRemInp.Font=Enum.Font.Gotham magRemInp.TextSize=10
magRemInp.ClearTextOnFocus=false Cr(magRemInp,5) Pad(magRemInp,6,0,0,0)
local magItemInp=Instance.new("TextBox",magnetCard)
magItemInp.Size=UDim2.new(1,-16,0,24) magItemInp.Position=UDim2.new(0,8,0,34)
magItemInp.PlaceholderText="Filter nama item (kosong = semua)" magItemInp.Text=""
magItemInp.BackgroundColor3=C.Input magItemInp.TextColor3=C.Text
magItemInp.Font=Enum.Font.Gotham magItemInp.TextSize=10
magItemInp.ClearTextOnFocus=false Cr(magItemInp,5) Pad(magItemInp,6,0,0,0)
local magRadInp=Instance.new("TextBox",magnetCard)
magRadInp.Size=UDim2.new(0.45,-10,0,24) magRadInp.Position=UDim2.new(0,8,0,62)
magRadInp.Text="80" magRadInp.PlaceholderText="Radius"
magRadInp.BackgroundColor3=C.Input magRadInp.TextColor3=C.Text
magRadInp.Font=Enum.Font.Gotham magRadInp.TextSize=10
magRadInp.ClearTextOnFocus=false Cr(magRadInp,5) Pad(magRadInp,6,0,0,0)
local magToggle=Instance.new("TextButton",magnetCard)
magToggle.Size=UDim2.new(0.5,-6,0,24) magToggle.Position=UDim2.new(0.5,0,0,62)
magToggle.Text="🧲 MAGNET: OFF" magToggle.BackgroundColor3=C.Red
magToggle.TextColor3=C.Text magToggle.Font=Enum.Font.GothamSemibold magToggle.TextSize=10
magToggle.AutoButtonColor=false Cr(magToggle,5)
local magStat=Instance.new("TextLabel",magnetCard)
magStat.Size=UDim2.new(1,-16,0,12) magStat.Position=UDim2.new(0,8,0,90)
magStat.Text="Isi remote/filter lalu aktifkan" magStat.TextColor3=C.Sub
magStat.Font=Enum.Font.Gotham magStat.TextSize=9
magStat.BackgroundTransparency=1 magStat.TextXAlignment=Enum.TextXAlignment.Left

local magnetConn=nil
local function FindRemote(name)
    local Ev2=ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage
    return Ev2:FindFirstChild(name)
        or ReplicatedStorage:FindFirstChild(name,true)
        or workspace:FindFirstChild(name,true)
end
local function ToggleMagnet()
    State.magnet=not State.magnet
    if State.magnet then
        Tw(magToggle,0.15,{BackgroundColor3=C.Purple})
        magToggle.Text="🧲 MAGNET: ON"
        local remName=magRemInp.Text
        local itemFilter=magItemInp.Text
        local radius=tonumber(magRadInp.Text) or 80
        local targetRemote=remName~="" and FindRemote(remName) or nil
        magStat.Text=targetRemote and ("🧲 "..targetRemote.Name) or "Physical magnet aktif"
        magnetConn=RunService.Heartbeat:Connect(function()
            local char=player.Character local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            for _,obj in ipairs(workspace:GetDescendants()) do
                if not obj or not obj.Parent then continue end
                if obj:IsA("Terrain") then continue end
                if obj.Parent==espContainer then continue end
                local name=obj.Name
                local match=itemFilter=="" or string.lower(name):find(string.lower(itemFilter),1,true)
                if not match then continue end
                local isChar=false
                for _,p2 in pairs(Players:GetPlayers()) do
                    if p2.Character==obj or p2.Character==obj.Parent then isChar=true break end
                end
                if isChar then continue end
                local pos2=nil
                if obj:IsA("BasePart") then pos2=obj.Position
                elseif obj:IsA("Model") then
                    local r2=obj:FindFirstChildWhichIsA("BasePart")
                    if r2 then pos2=r2.Position end
                end
                if pos2 then
                    local dist=(pos2-hrp.Position).Magnitude
                    if dist<=radius and dist>2 then
                        if targetRemote then
                            pcall(function()
                                if targetRemote:IsA("RemoteEvent") then targetRemote:FireServer(obj)
                                elseif targetRemote:IsA("RemoteFunction") then targetRemote:InvokeServer(obj) end
                            end)
                        else
                            pcall(function()
                                if obj:IsA("BasePart") then
                                    obj.CFrame=CFrame.new(hrp.Position+Vector3.new(math.random(-2,2),0,math.random(-2,2)))
                                end
                            end)
                        end
                    end
                end
            end
        end)
    else
        if magnetConn then magnetConn:Disconnect() magnetConn=nil end
        Tw(magToggle,0.15,{BackgroundColor3=C.Red})
        magToggle.Text="🧲 MAGNET: OFF"
        magStat.Text="Isi remote/filter lalu aktifkan"
    end
end
magToggle.MouseButton1Click:Connect(ToggleMagnet)
BuildPlayerList()
local PluginLib=_G.CyPluginLib
local DB=_G.CyBH
local injectScroll,_=MkScroll(pages["INJECT"])

MkSectionHeader(injectScroll,"📚  PLUGIN LIBRARY",C.Yellow,1)
local libCard=MkCard(injectScroll,200,2)

local libNameBox=Instance.new("TextBox",libCard)
libNameBox.Size=UDim2.new(1,-16,0,24) libNameBox.Position=UDim2.new(0,8,0,6)
libNameBox.PlaceholderText="Nama plugin (cth: BrainrotHunter)"
libNameBox.Text="" libNameBox.BackgroundColor3=C.Input libNameBox.TextColor3=C.Yellow
libNameBox.Font=Enum.Font.GothamSemibold libNameBox.TextSize=10
libNameBox.ClearTextOnFocus=false Cr(libNameBox,5) Pad(libNameBox,6,0,0,0)

local libSaveBtn=Instance.new("TextButton",libCard)
libSaveBtn.Size=UDim2.new(0.48,-6,0,22) libSaveBtn.Position=UDim2.new(0,8,0,34)
libSaveBtn.Text="💾 SAVE" libSaveBtn.BackgroundColor3=Color3.fromRGB(25,70,25)
libSaveBtn.TextColor3=C.Lime libSaveBtn.Font=Enum.Font.GothamSemibold libSaveBtn.TextSize=10
libSaveBtn.AutoButtonColor=false Cr(libSaveBtn,5) Sk(libSaveBtn,C.Lime,1)

local libDelBtn=Instance.new("TextButton",libCard)
libDelBtn.Size=UDim2.new(0.48,-6,0,22) libDelBtn.Position=UDim2.new(0.52,-2,0,34)
libDelBtn.Text="🗑 DELETE" libDelBtn.BackgroundColor3=C.Card
libDelBtn.TextColor3=C.Red libDelBtn.Font=Enum.Font.GothamSemibold libDelBtn.TextSize=10
libDelBtn.AutoButtonColor=false Cr(libDelBtn,5) Sk(libDelBtn,C.Red,1)

local libStat=Instance.new("TextLabel",libCard)
libStat.Size=UDim2.new(1,-16,0,12) libStat.Position=UDim2.new(0,8,0,60)
libStat.Text="Simpan plugin dari injector ke sini" libStat.TextColor3=C.Sub
libStat.Font=Enum.Font.Gotham libStat.TextSize=9
libStat.BackgroundTransparency=1 libStat.TextXAlignment=Enum.TextXAlignment.Left

local libList=Instance.new("ScrollingFrame",libCard)
libList.Size=UDim2.new(1,-16,0,118) libList.Position=UDim2.new(0,8,0,76)
libList.BackgroundColor3=C.Input libList.BorderSizePixel=0
libList.ScrollBarThickness=2 libList.ScrollBarImageColor3=C.Yellow
libList.CanvasSize=UDim2.new(0,0,0,0) Cr(libList,6)
local libLL=Instance.new("UIListLayout",libList)
libLL.Padding=UDim.new(0,2) libLL.SortOrder=Enum.SortOrder.LayoutOrder
Pad(libList,3,3,3,3)

local InjectBox
local function RebuildLibList()
    for _,c in pairs(libList:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end
    local count=0
    for name,_ in pairs(PluginLib) do
        count=count+1
        local item=Instance.new("Frame",libList)
        item.Size=UDim2.new(1,0,0,26) item.BackgroundColor3=C.Card
        item.BorderSizePixel=0 item.LayoutOrder=count Cr(item,5)
        local nLbl=Instance.new("TextLabel",item)
        nLbl.Size=UDim2.new(1,-58,1,0) nLbl.Position=UDim2.new(0,6,0,0)
        nLbl.Text="📌 "..name nLbl.TextColor3=C.Yellow
        nLbl.Font=Enum.Font.GothamSemibold nLbl.TextSize=9
        nLbl.BackgroundTransparency=1 nLbl.TextXAlignment=Enum.TextXAlignment.Left
        nLbl.TextTruncate=Enum.TextTruncate.AtEnd
        local lBtn=Instance.new("TextButton",item)
        lBtn.Size=UDim2.new(0,50,1,-6) lBtn.Position=UDim2.new(1,-54,0,3)
        lBtn.Text="LOAD" lBtn.BackgroundColor3=C.Acc
        lBtn.TextColor3=Color3.new(1,1,1) lBtn.Font=Enum.Font.GothamBold lBtn.TextSize=9
        lBtn.AutoButtonColor=false Cr(lBtn,4)
        local sn=name
        lBtn.MouseButton1Click:Connect(function()
            if InjectBox then InjectBox.Text=PluginLib[sn] or "" end
            libNameBox.Text=sn
            libStat.Text="✅ '"..sn.."' dimuat" libStat.TextColor3=C.Lime
            Tw(lBtn,0.12,{BackgroundColor3=C.Lime})
            task.delay(0.8,function() Tw(lBtn,0.12,{BackgroundColor3=C.Acc}) end)
        end)
    end
    libList.CanvasSize=UDim2.new(0,0,0,(count*28)+6)
    libStat.Text=count>0 and count.." plugin tersimpan" or "Library kosong"
    libStat.TextColor3=C.Sub
end

MkSectionHeader(injectScroll,"🔌  PLUGIN INJECTOR",C.Yellow,3)
local injectCard=MkCard(injectScroll,180,4)

InjectBox=Instance.new("TextBox",injectCard)
InjectBox.Size=UDim2.new(1,-16,0,96) InjectBox.Position=UDim2.new(0,8,0,6)
InjectBox.Text="" InjectBox.PlaceholderText="-- Paste kode plugin di sini\n-- Lalu SAVE ke library atau langsung INJECT"
InjectBox.BackgroundColor3=C.Input InjectBox.TextColor3=C.Text
InjectBox.Font=Enum.Font.Code InjectBox.TextSize=9
InjectBox.ClearTextOnFocus=false InjectBox.MultiLine=true
InjectBox.TextXAlignment=Enum.TextXAlignment.Left InjectBox.TextYAlignment=Enum.TextYAlignment.Top
Cr(InjectBox,6) Pad(InjectBox,6,6,4,4)

local injectBtn=Instance.new("TextButton",injectCard)
injectBtn.Size=UDim2.new(0.44,-6,0,24) injectBtn.Position=UDim2.new(0,8,0,106)
injectBtn.Text="⚡ INJECT" injectBtn.BackgroundColor3=C.Yellow
injectBtn.TextColor3=Color3.new(0,0,0) injectBtn.Font=Enum.Font.GothamBold injectBtn.TextSize=11
injectBtn.AutoButtonColor=false Cr(injectBtn,6)

local injectSaveBtn=Instance.new("TextButton",injectCard)
injectSaveBtn.Size=UDim2.new(0.3,-4,0,24) injectSaveBtn.Position=UDim2.new(0.46,0,0,106)
injectSaveBtn.Text="💾 SAVE" injectSaveBtn.BackgroundColor3=Color3.fromRGB(25,70,25)
injectSaveBtn.TextColor3=C.Lime injectSaveBtn.Font=Enum.Font.GothamSemibold injectSaveBtn.TextSize=9
injectSaveBtn.AutoButtonColor=false Cr(injectSaveBtn,6) Sk(injectSaveBtn,C.Lime,1)

local injectClrBtn=Instance.new("TextButton",injectCard)
injectClrBtn.Size=UDim2.new(0.22,-4,0,24) injectClrBtn.Position=UDim2.new(0.78,0,0,106)
injectClrBtn.Text="🗑" injectClrBtn.BackgroundColor3=C.Card
injectClrBtn.TextColor3=C.Red injectClrBtn.Font=Enum.Font.GothamBold injectClrBtn.TextSize=14
injectClrBtn.AutoButtonColor=false Cr(injectClrBtn,6)

local injectStat=Instance.new("TextLabel",injectCard)
injectStat.Size=UDim2.new(1,-16,0,12) injectStat.Position=UDim2.new(0,8,0,134)
injectStat.Text="Paste kode lalu INJECT atau SAVE dulu"
injectStat.TextColor3=C.Sub injectStat.Font=Enum.Font.Gotham injectStat.TextSize=9
injectStat.BackgroundTransparency=1 injectStat.TextXAlignment=Enum.TextXAlignment.Left

local hintLbl=Instance.new("TextLabel",injectCard)
hintLbl.Size=UDim2.new(1,-16,0,28) hintLbl.Position=UDim2.new(0,8,0,148)
hintLbl.Text="HubState = akses State hub\nFindRemote(name) = cari remote otomatis"
hintLbl.TextColor3=C.Sub hintLbl.Font=Enum.Font.Code hintLbl.TextSize=8
hintLbl.BackgroundTransparency=1 hintLbl.TextXAlignment=Enum.TextXAlignment.Left
hintLbl.TextWrapped=true

libSaveBtn.MouseButton1Click:Connect(function()
    local name=libNameBox.Text
    if name=="" then libStat.Text="⚠️ Isi nama!" libStat.TextColor3=C.Red return end
    local code=InjectBox and InjectBox.Text or ""
    if code=="" then libStat.Text="⚠️ Kode kosong!" libStat.TextColor3=C.Red return end
    PluginLib[name]=code
    libStat.Text="💾 '"..name.."' tersimpan!" libStat.TextColor3=C.Lime
    RebuildLibList()
    Tw(libSaveBtn,0.12,{BackgroundColor3=Color3.fromRGB(40,130,40)})
    task.delay(1,function() Tw(libSaveBtn,0.12,{BackgroundColor3=Color3.fromRGB(25,70,25)}) end)
end)
libDelBtn.MouseButton1Click:Connect(function()
    local name=libNameBox.Text
    if name=="" then libStat.Text="⚠️ Isi nama!" libStat.TextColor3=C.Red return end
    if PluginLib[name] then
        PluginLib[name]=nil
        libStat.Text="🗑 '"..name.."' dihapus" libStat.TextColor3=C.Orange
        libNameBox.Text="" RebuildLibList()
    else
        libStat.Text="⚠️ '"..name.."' tidak ada" libStat.TextColor3=C.Red
    end
end)
injectSaveBtn.MouseButton1Click:Connect(function()
    local name=libNameBox.Text
    if name=="" then name="Plugin_"..os.date("%H%M%S") libNameBox.Text=name end
    local code=InjectBox.Text
    if code=="" then injectStat.Text="⚠️ Kode kosong!" injectStat.TextColor3=C.Red return end
    PluginLib[name]=code
    injectStat.Text="💾 Disimpan: '"..name.."'" injectStat.TextColor3=C.Lime
    RebuildLibList()
end)
injectClrBtn.MouseButton1Click:Connect(function()
    InjectBox.Text=""
    injectStat.Text="Paste kode lalu INJECT atau SAVE dulu"
    injectStat.TextColor3=C.Sub
end)
injectBtn.MouseButton1Click:Connect(function()
    local code=InjectBox.Text
    if code=="" then injectStat.Text="⚠️ Kode kosong!" injectStat.TextColor3=C.Red return end
    local prev1=rawget(_G,"HubState")
    local prev2=rawget(_G,"FindRemote")
    rawset(_G,"HubState",State)
    rawset(_G,"FindRemote",FindRemote)
    local fn,pe=loadstring(code)
    if not fn then
        injectStat.Text="❌ "..((pe or "parse error"):gsub("^.*:%d+: ",""):sub(1,50))
        injectStat.TextColor3=C.Red
        Tw(injectBtn,0.15,{BackgroundColor3=C.Red,TextColor3=Color3.new(1,1,1)})
        task.delay(2,function() Tw(injectBtn,0.15,{BackgroundColor3=C.Yellow,TextColor3=Color3.new(0,0,0)}) end)
        rawset(_G,"HubState",prev1) rawset(_G,"FindRemote",prev2) return
    end
    local ok,re=pcall(fn)
    rawset(_G,"HubState",prev1) rawset(_G,"FindRemote",prev2)
    if ok then
        injectStat.Text="✅ Plugin berhasil dijalankan!" injectStat.TextColor3=C.Lime
        Tw(injectBtn,0.15,{BackgroundColor3=C.Lime,TextColor3=Color3.new(0,0,0)})
        task.delay(2,function() Tw(injectBtn,0.15,{BackgroundColor3=C.Yellow,TextColor3=Color3.new(0,0,0)}) injectStat.TextColor3=C.Sub end)
    else
        local em=tostring(re or ""):gsub("^.*:%d+: ",""):sub(1,55)
        injectStat.Text="❌ "..em injectStat.TextColor3=C.Red
        warn("[CyRuZzZ Inject] "..tostring(re))
        Tw(injectBtn,0.15,{BackgroundColor3=C.Red,TextColor3=Color3.new(1,1,1)})
        task.delay(2.5,function() Tw(injectBtn,0.15,{BackgroundColor3=C.Yellow,TextColor3=Color3.new(0,0,0)}) end)
    end
end)
RebuildLibList()
local flyConn=nil
local function ToggleFly()
    State.flying=not State.flying
    setFly(State.flying)
    local char=player.Character
    if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart")
    local hum=char:FindFirstChildOfClass("Humanoid")
    if State.flying and root and hum then
        hum.PlatformStand=true
        local bv=Instance.new("BodyVelocity",root)
        bv.Name="_CyFlyVel" bv.MaxForce=Vector3.new(9e9,9e9,9e9) bv.Velocity=Vector3.new(0,0,0)
        local bg=Instance.new("BodyGyro",root)
        bg.Name="_CyFlyGyro" bg.MaxTorque=Vector3.new(9e9,9e9,9e9) bg.P=9e4 bg.CFrame=root.CFrame
        flyConn=RunService.RenderStepped:Connect(function()
            if not State.flying then return end
            local spd=tonumber(speedInp.Text) or 60
            local cam2=workspace.CurrentCamera.CFrame
            local dir=Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir=dir+cam2.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir=dir-cam2.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir=dir-cam2.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir=dir+cam2.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir=dir-Vector3.new(0,1,0) end
            bv.Velocity=dir.Magnitude>0 and dir.Unit*spd or Vector3.new(0,0,0)
            bg.CFrame=cam2
        end)
        mainStat.Text="✈ Fly ON" mainStat.TextColor3=C.Green
    else
        if flyConn then flyConn:Disconnect() flyConn=nil end
        if hum then hum.PlatformStand=false end
        if root then
            local fv=root:FindFirstChild("_CyFlyVel") local fg=root:FindFirstChild("_CyFlyGyro")
            if fv then fv:Destroy() end if fg then fg:Destroy() end
        end
        mainStat.Text="✈ Fly OFF" mainStat.TextColor3=C.Sub
    end
end
flyBtn.MouseButton1Click:Connect(ToggleFly)

local noclipConn=nil
local function ToggleNoclip()
    State.noclip=not State.noclip
    setNoclip(State.noclip)
    if State.noclip then
        noclipConn=RunService.Stepped:Connect(function()
            local char=player.Character if not char then return end
            for _,p2 in pairs(char:GetDescendants()) do
                if p2:IsA("BasePart") then p2.CanCollide=false end
            end
        end)
        mainStat.Text="👻 Noclip ON" mainStat.TextColor3=Color3.fromRGB(100,60,220)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn=nil end
        local char=player.Character
        if char then
            for _,p2 in pairs(char:GetDescendants()) do
                if p2:IsA("BasePart") then p2.CanCollide=true end
            end
        end
        mainStat.Text="👻 Noclip OFF" mainStat.TextColor3=C.Sub
    end
end
noclipBtn.MouseButton1Click:Connect(ToggleNoclip)

local infJumpConn=nil
local function ToggleInfJump()
    State.infJump=not State.infJump
    setInfJump(State.infJump)
    if State.infJump then
        infJumpConn=AddConn(UserInputService.JumpRequest:Connect(function()
            local hum=HUM()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end))
        mainStat.Text="🦘 Infinite Jump ON" mainStat.TextColor3=C.Orange
    else
        if infJumpConn then infJumpConn:Disconnect() infJumpConn=nil end
        mainStat.Text="🦘 Infinite Jump OFF" mainStat.TextColor3=C.Sub
    end
end
infJumpBtn.MouseButton1Click:Connect(ToggleInfJump)

local origAmbient=Lighting.Ambient
local origOutdoor=Lighting.OutdoorAmbient
local origBright=Lighting.Brightness
local function ToggleFullbright()
    State.fullbright=not State.fullbright
    setFullbright(State.fullbright)
    if State.fullbright then
        Lighting.Ambient=Color3.new(1,1,1)
        Lighting.OutdoorAmbient=Color3.new(1,1,1)
        Lighting.Brightness=2
        for _,v in pairs(Lighting:GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
                v.Enabled=false
            end
        end
        mainStat.Text="💡 Full Bright ON" mainStat.TextColor3=C.Yellow
    else
        Lighting.Ambient=origAmbient
        Lighting.OutdoorAmbient=origOutdoor
        Lighting.Brightness=origBright
        for _,v in pairs(Lighting:GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
                v.Enabled=true
            end
        end
        mainStat.Text="💡 Full Bright OFF" mainStat.TextColor3=C.Sub
    end
end
fullbrightBtn.MouseButton1Click:Connect(ToggleFullbright)

local freecamPart=nil local freecamConn=nil
local function ToggleFreecam()
    State.freecam=not State.freecam
    setFreecam(State.freecam)
    if State.freecam then
        State.origFOV=camera.FieldOfView
        freecamPart=Instance.new("Part",workspace)
        freecamPart.Name="_CyFreecam" freecamPart.Size=Vector3.new(1,1,1)
        freecamPart.Anchored=true freecamPart.CanCollide=false freecamPart.Transparency=1
        local hrp=HRP()
        if hrp then freecamPart.CFrame=hrp.CFrame+Vector3.new(0,3,0)
        else freecamPart.CFrame=CFrame.new(0,10,0) end
        camera.CameraType=Enum.CameraType.Scriptable
        camera.CFrame=freecamPart.CFrame
        freecamConn=RunService.RenderStepped:Connect(function()
            if not State.freecam then return end
            local spd2=(tonumber(speedInp.Text) or 60)*0.5
            local camCF=camera.CFrame
            local moveDir=Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir=moveDir+camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir=moveDir-camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir=moveDir-camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir=moveDir+camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir=moveDir+Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir=moveDir-Vector3.new(0,1,0) end
            if moveDir.Magnitude>0 then
                freecamPart.CFrame=freecamPart.CFrame+moveDir.Unit*(spd2*0.016)
                camera.CFrame=CFrame.new(freecamPart.CFrame.Position,freecamPart.CFrame.Position+camCF.LookVector)
            end
        end)
        mainStat.Text="📷 Freecam ON" mainStat.TextColor3=C.Teal
    else
        if freecamConn then freecamConn:Disconnect() freecamConn=nil end
        if freecamPart then freecamPart:Destroy() freecamPart=nil end
        camera.CameraType=Enum.CameraType.Custom
        if State.origFOV then camera.FieldOfView=State.origFOV end
        mainStat.Text="📷 Freecam OFF" mainStat.TextColor3=C.Sub
    end
end
freecamBtn.MouseButton1Click:Connect(ToggleFreecam)

local clickTPConn=nil
local function ToggleClickTP()
    State.clickTP=not State.clickTP
    setClickTP(State.clickTP)
    if State.clickTP then
        if mouse then
            clickTPConn=mouse.Button1Down:Connect(function()
                if not State.clickTP then return end
                local hit2=mouse.Hit
                if hit2 then
                    local hrp=HRP()
                    if hrp then
                        backPos=hrp.Position
                        hrp.CFrame=CFrame.new(hit2.Position+Vector3.new(0,3,0))
                    end
                end
            end)
            mainStat.Text="🖱 Click TP ON" mainStat.TextColor3=C.Acc2
        else
            State.clickTP=false setClickTP(false)
            mainStat.Text="⚠️ Mouse API tidak tersedia" mainStat.TextColor3=C.Red
        end
    else
        if clickTPConn then clickTPConn:Disconnect() clickTPConn=nil end
        mainStat.Text="🖱 Click TP OFF" mainStat.TextColor3=C.Sub
    end
end
clickTPBtn.MouseButton1Click:Connect(ToggleClickTP)

local instantEConn=nil
local function ToggleInstantE()
    State.instantE=not State.instantE
    setInstantE(State.instantE)
    if State.instantE then
        instantEConn=RunService.Heartbeat:Connect(function()
            if not State.instantE then return end
            local hrp=HRP() if not hrp then return end
            for _,obj in pairs(workspace:GetDescendants()) do
                if not obj or not obj.Parent then continue end
                if obj:IsA("ProximityPrompt") then
                    local pp=obj
                    local ppPart=pp.Parent
                    if ppPart and ppPart:IsA("BasePart") then
                        local dist2=(ppPart.Position-hrp.Position).Magnitude
                        if dist2<=(pp.MaxActivationDistance or 10)+5 then
                            pcall(function() if typeof(fireproximityprompt)=="function" then fireproximityprompt(pp) end end)
                        end
                    end
                end
                if obj:IsA("ClickDetector") then
                    local cdPart=obj.Parent
                    if cdPart and cdPart:IsA("BasePart") then
                        local dist3=(cdPart.Position-hrp.Position).Magnitude
                        if dist3<=(obj.MaxActivationDistance or 32) then
                            pcall(function() if typeof(fireclickdetector)=="function" then fireclickdetector(obj) end end)
                        end
                    end
                end
            end
        end)
        mainStat.Text="⚡ Instant E ON" mainStat.TextColor3=C.Lime
    else
        if instantEConn then instantEConn:Disconnect() instantEConn=nil end
        mainStat.Text="⚡ Instant E OFF" mainStat.TextColor3=C.Sub
    end
end
instantEBtn.MouseButton1Click:Connect(ToggleInstantE)

speedToggle.MouseButton1Click:Connect(function()
    local hum=HUM()
    if not State.speedOn then
        if hum then State.originalWalkSpeed=hum.WalkSpeed end
        State.speedOn=true
        speedToggle.Text="⚡ SPEED: ON ✓"
        Tw(speedToggle,0.15,{BackgroundColor3=C.Green})
        mainStat.Text="⚡ Speed ON ("..speedInp.Text..")" mainStat.TextColor3=C.Green
    else
        State.speedOn=false
        if hum then hum.WalkSpeed=State.originalWalkSpeed end
        speedToggle.Text="⚡ SPEED: OFF"
        Tw(speedToggle,0.15,{BackgroundColor3=C.Red})
        mainStat.Text="Speed reset → "..State.originalWalkSpeed mainStat.TextColor3=C.Sub
    end
end)

local ghostCharConn=nil
local function ApplyGhost(char,on)
    if not char then return end
    for _,v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") and v.Name~="HumanoidRootPart" then
            v.LocalTransparencyModifier=on and 1 or 0
            v.Transparency=on and 1 or 0
        elseif v:IsA("Decal") then v.Transparency=on and 1 or 0 end
    end
    for _,acc in pairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            local handle=acc:FindFirstChild("Handle")
            if handle then
                handle.LocalTransparencyModifier=on and 1 or 0
                handle.Transparency=on and 1 or 0
            end
        end
    end
end
local function ToggleGhost()
    State.ghost=not State.ghost
    setGhost(State.ghost)
    ApplyGhost(player.Character,State.ghost)
    if State.ghost then
        ghostCharConn=player.CharacterAdded:Connect(function(nc)
            task.wait(0.5)
            if State.ghost then ApplyGhost(nc,true) end
        end)
        mainStat.Text="🌫 Ghost ON" mainStat.TextColor3=C.Cyan
    else
        if ghostCharConn then ghostCharConn:Disconnect() ghostCharConn=nil end
        mainStat.Text="🌫 Ghost OFF" mainStat.TextColor3=C.Sub
    end
end
ghostBtn.MouseButton1Click:Connect(ToggleGhost)

local godRealChar=nil local godFakeChar=nil
local function ToggleGodmode()
    if State.godmode then
        State.godmode=false
        local savedPos=nil
        if godFakeChar then
            local fr=godFakeChar:FindFirstChild("HumanoidRootPart")
            if fr then savedPos=fr.CFrame end
        end
        if godRealChar then
            player.Character=godRealChar
            workspace.CurrentCamera.CameraSubject=godRealChar:FindFirstChildOfClass("Humanoid") or godRealChar
            for _,v in pairs(godRealChar:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide=true if v.Name~="HumanoidRootPart" then v.Transparency=0 end v.LocalTransparencyModifier=0
                elseif v:IsA("Decal") then v.Transparency=0 end
            end
            if savedPos then
                local rr=godRealChar:FindFirstChild("HumanoidRootPart")
                if rr then rr.CFrame=savedPos rr.Velocity=Vector3.new(0,0,0) end
            end
        end
        if godFakeChar then godFakeChar:Destroy() godFakeChar=nil end
        godRealChar=nil
        setGod(false)
        mainStroke.Color=C.Acc
        mainStat.Text="🛡 Godmode OFF" mainStat.TextColor3=C.Sub
    else
        godRealChar=player.Character
        if not godRealChar then return end
        godRealChar.Archivable=true
        State.godmode=true
        godFakeChar=godRealChar:Clone()
        godFakeChar.Name=player.Name.."_Fake"
        godFakeChar.Parent=workspace
        for _,v in pairs(godFakeChar:GetDescendants()) do
            if (v:IsA("BasePart") or v:IsA("Decal")) and v.Name~="HumanoidRootPart" then
                v.Transparency=0.35
            end
        end
        for _,v in pairs(godRealChar:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide=false end
        end
        player.Character=godFakeChar
        workspace.CurrentCamera.CameraSubject=godFakeChar:WaitForChild("Humanoid")
        local fHum=godFakeChar:FindFirstChildOfClass("Humanoid")
        if fHum then fHum.Died:Connect(function() if State.godmode then ToggleGodmode() end end) end
        setGod(true)
        mainStroke.Color=C.Orange
        mainStat.Text="🛡 Godmode ON" mainStat.TextColor3=C.Orange
    end
end
godBtn.MouseButton1Click:Connect(ToggleGodmode)

local aimbotConn=nil
local function ToggleAimbot()
    State.aimbot=not State.aimbot
    setAimbot(State.aimbot)
    if State.aimbot then
        if not lockTarget then lockTarget=FindNearest() end
        mainStat.Text="🎯 Aimbot ON" mainStat.TextColor3=C.Pink
    else
        mainStat.Text="🎯 Aimbot OFF" mainStat.TextColor3=C.Sub
    end
end
aimbotBtn.MouseButton1Click:Connect(ToggleAimbot)

espObjBtn.MouseButton1Click:Connect(function()
    State.espObj=not State.espObj
    setEspObj(State.espObj)
    if not State.espObj then
        for obj,_ in pairs(espObjects) do if not scanEspMap[obj] then RemObjEsp(obj) end end
    end
    espStat.Text=State.espObj and "🔵 ESP Object: ON" or "ESP: Standby"
    espStat.TextColor3=State.espObj and C.Acc2 or C.Sub
end)
espPlayersBtn.MouseButton1Click:Connect(function()
    State.espPlayers=not State.espPlayers
    setEspPlayers(State.espPlayers)
    if not State.espPlayers then for p,_ in pairs(espPlayers) do RemPlayerEsp(p) end end
    espStat.Text=State.espPlayers and "👤 ESP Players: ON" or "ESP: Standby"
    espStat.TextColor3=State.espPlayers and C.Pink or C.Sub
end)
lockBtn.MouseButton1Click:Connect(function()
    State.targetLock=not State.targetLock
    setLock(State.targetLock)
    if State.targetLock then
        lockTarget=FindNearest()
        if lockTarget then espStat.Text="🎯 Lock: "..lockTarget.name espStat.TextColor3=C.Orange
        else State.targetLock=false setLock(false) espStat.Text="⚠️ Tidak ada target" espStat.TextColor3=C.Red end
    else lockTarget=nil espStat.Text="ESP: Standby" espStat.TextColor3=C.Sub end
end)
local sliderDragging=false
local godOffsetCard,godOffLbl,godOffFill,godOffKnob,getGodOff=MkSliderRow(mainScroll,"Godmode Offset",5,60,15,15)

AddConn(RunService.Stepped:Connect(function()
    if State.godmode and godRealChar and godFakeChar then
        local rr=godRealChar:FindFirstChild("HumanoidRootPart")
        local fr=godFakeChar:FindFirstChild("HumanoidRootPart")
        if rr and fr then
            local off=getGodOff()
            rr.CFrame=fr.CFrame*CFrame.new(0,-off,0)
            rr.Velocity=Vector3.new(0,0,0)
        end
    end
    if State.noclip then
        local char=player.Character if not char then return end
        for _,p2 in pairs(char:GetDescendants()) do
            if p2:IsA("BasePart") then p2.CanCollide=false end
        end
    end
end))

AddConn(RunService.Heartbeat:Connect(function()
    if State.speedOn and not State.flying then
        local hum=HUM()
        if hum then hum.WalkSpeed=tonumber(speedInp.Text) or 120 end
    end
    if State.ghost then
        local char=player.Character
        if char then
            for _,v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.Name~="HumanoidRootPart" then
                    v.LocalTransparencyModifier=1
                end
            end
        end
    end
    if State.espPlayers then RefreshPlayerEsp() end
    for obj,_ in pairs(espObjects) do
        if not obj or not obj.Parent then RemObjEsp(obj)
        else UpdateEspLabel(obj) end
    end
    if State.follow and State.followTarget then
        local tp=Players:FindFirstChild(State.followTarget)
        if tp and tp.Character then
            local tr=tp.Character:FindFirstChild("HumanoidRootPart")
            local myHrp=HRP()
            if tr and myHrp then
                local dist=(tr.Position-myHrp.Position).Magnitude
                if dist>8 then
                    myHrp.CFrame=CFrame.new(tr.Position+Vector3.new(math.random(-3,3),2,math.random(-3,3)))
                end
            end
        end
    end
    if State.hitch and State.hitchTarget then
        local tp=Players:FindFirstChild(State.hitchTarget)
        if tp and tp.Character then
            local tr=tp.Character:FindFirstChild("HumanoidRootPart")
            local myHrp=HRP()
            if tr and myHrp then
                myHrp.CFrame=CFrame.new(tr.Position+Vector3.new(1.5,0,0))
                myHrp.Velocity=Vector3.new(0,0,0)
            end
        end
    end
end))

AddConn(RunService.RenderStepped:Connect(function()
    if (State.targetLock or State.aimbot) and lockTarget and lockTarget.part then
        local part=lockTarget.part
        if not part.Parent then
            lockTarget=FindNearest()
            if not lockTarget then
                if State.targetLock then State.targetLock=false setLock(false) espStat.Text="⚠️ Target hilang" espStat.TextColor3=C.Red end
                if State.aimbot then State.aimbot=false setAimbot(false) end
            end
            return
        end
        local hrp=HRP()
        if hrp then
            local tpos=part.Position+Vector3.new(0,1,0)
            local from=camera.CFrame.Position
            local dir=tpos-from
            if dir.Magnitude>0.5 then
                if State.aimbot then
                    camera.CFrame=CFrame.lookAt(from,tpos)
                else
                    camera.CFrame=camera.CFrame:Lerp(CFrame.lookAt(from,tpos),0.1)
                end
            end
            local dist=(part.Position-hrp.Position).Magnitude
            espStat.Text=(State.aimbot and "🎯 AIMBOT: " or "🎯 Lock: ")..lockTarget.name.."  |  "..math.floor(dist).."st"
            espStat.TextColor3=C.Orange
        end
    end
end))

AddConn(UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode==Enum.KeyCode.T then
        if lockTarget then lockTarget=nil State.targetLock=false setLock(false) espStat.Text="🎯 Lock OFF" espStat.TextColor3=C.Sub
        else
            lockTarget=FindNearest()
            if lockTarget then State.targetLock=true setLock(true) espStat.Text="🎯 Lock: "..lockTarget.name espStat.TextColor3=C.Orange end
        end
    end
    if input.KeyCode==Enum.KeyCode.G and (State.targetLock or State.aimbot) then
        local tgts=GetAllTargets()
        if #tgts>1 and lockTarget then
            local idx=1
            for i2,t2 in ipairs(tgts) do if t2.part==lockTarget.part then idx=i2 break end end
            local nxt=tgts[(idx%#tgts)+1]
            if nxt then lockTarget=nxt espStat.Text="🎯 → "..nxt.name espStat.TextColor3=C.Orange end
        end
    end
    if input.KeyCode==Enum.KeyCode.F5 then
        DoScan()
    end
    if input.KeyCode==Enum.KeyCode.B then
        if backPos then
            local hrp=HRP()
            if hrp then
                local curr=hrp.Position
                hrp.CFrame=CFrame.new(backPos+Vector3.new(0,2,0))
                backPos=curr
                mainStat.Text="↩️ Back!" mainStat.TextColor3=C.Gold
            end
        end
    end
end))

Players.PlayerRemoving:Connect(function(p)
    RemPlayerEsp(p)
    if State.followTarget==p.Name then State.follow=false State.followTarget=nil end
    if State.hitchTarget==p.Name then State.hitch=false State.hitchTarget=nil end
end)

local minimized=false
MinBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    if minimized then
        TabBar.Visible=false ContentArea.Visible=false
        Tw(Main,0.22,{Size=UDim2.new(0,360,0,50)}) MinBtn.Text="+"
    else
        TabBar.Visible=true ContentArea.Visible=true
        Tw(Main,0.22,{Size=UDim2.new(0,360,0,510)}) MinBtn.Text="−"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    if State.godmode then ToggleGodmode() end
    if magnetConn then magnetConn:Disconnect() end
    if flyConn then flyConn:Disconnect() end
    if noclipConn then noclipConn:Disconnect() end
    if instantEConn then instantEConn:Disconnect() end
    if freecamConn then freecamConn:Disconnect() end
    if freecamPart then freecamPart:Destroy() end
    if currentHL then currentHL:Destroy() end
    if espContainer then espContainer:Destroy() end
    camera.CameraType=Enum.CameraType.Custom
    for _,c in pairs(Conns) do pcall(function() c:Disconnect() end) end
    Tw(Main,0.18,{BackgroundTransparency=1,Size=UDim2.new(0,360,0,0)})
    task.wait(0.22) sg:Destroy()
end)

AddConn(RunService.Heartbeat:Connect(function()
    if sg and not sg.Parent then sg.Parent=player.PlayerGui end
end))

SwitchTab("MAIN")
BuildPlayerList()
print("CyRuZzZ Hub v3.0 Loaded | T=Lock | G=NextTarget | B=Back | F5=Scan")
