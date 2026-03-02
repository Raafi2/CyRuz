-- ╔══════════════════════════════════════╗
-- ║   CyRuz SSS Premium  |  v2.0        ║
-- ║   Optimized: <200 local vars        ║
-- ╚══════════════════════════════════════╝

-- ── SERVICES (combined, hemat 7 slot) ──────────────────────────────────────
local Players, RunService, UIS, TweenService, HttpService, RS, Lighting, TeleportSvc =
    game:GetService("Players"), game:GetService("RunService"),
    game:GetService("UserInputService"), game:GetService("TweenService"),
    game:GetService("HttpService"), game:GetService("ReplicatedStorage"),
    game:GetService("Lighting"), game:GetService("TeleportService")

-- ── MATH ALIASES (combined, hemat 11 slot) ─────────────────────────────────
local mfloor, mceil, mclamp, msin, mcos, mabs = math.floor, math.ceil, math.clamp, math.sin, math.cos, math.abs
local mmax, mmin, mrad, msqrt, matan2, mrandom = math.max, math.min, math.rad, math.sqrt, math.atan2, math.random

-- ── CONSTRUCTORS (combined, hemat 3 slot) ──────────────────────────────────
local V3, CF, CFA, CFla = Vector3.new, CFrame.new, CFrame.Angles, CFrame.lookAt
local UDim2n, C3, C3rgb = UDim2.new, Color3.new, Color3.fromRGB

-- ── CORE ────────────────────────────────────────────────────────────────────
local lp, cam = Players.LocalPlayer, workspace.CurrentCamera
local function Lerp(a, b, t) return a + (b - a) * t end
local RID       = tostring(mrandom(1e5, 9e5))
local GUI_NAME  = "_CYR_" .. RID
local ESP_NAME  = "_ESP_" .. RID
local CFG_DIR   = "CYRUZ_SSS"
local CFG_PATH  = CFG_DIR .. "/config.json"

-- ── MAID ────────────────────────────────────────────────────────────────────
local Maid = {}
Maid.__index = Maid
function Maid.new()   return setmetatable({ _t = {} }, Maid) end
function Maid:Add(x)  table.insert(self._t, x); return x end
function Maid:Remove(x)
    for i, v in ipairs(self._t) do
        if v == x then table.remove(self._t, i); return end
    end
end
function Maid:Destroy()
    for _, t in ipairs(self._t) do
        if typeof(t) == "RBXScriptConnection" then pcall(function() t:Disconnect() end)
        elseif typeof(t) == "Instance"          then pcall(function() t:Destroy() end)
        elseif type(t) == "function"            then pcall(t) end
    end
    self._t = {}
end
local M = Maid.new()

-- ── CONFIG ──────────────────────────────────────────────────────────────────
local Def = {
    speedVal=120, flySpd=120, godOff=15,
    fcSpd=60, fcSns=0.35, aimFov=120, aimSmo=12,
    farmR=60, delay=1.0, hbxScale=5, espMaxD=600, kaRadius=15,
}
local Cfg = {}
for k, v in pairs(Def) do Cfg[k] = v end

local function SaveCfg()
    pcall(function()
        if not isfolder then return end
        if not isfolder(CFG_DIR) then makefolder(CFG_DIR) end
        writefile(CFG_PATH, HttpService:JSONEncode(Cfg))
    end)
end
local function LoadCfg()
    pcall(function()
        if not (isfile and isfile(CFG_PATH)) then return end
        local ok, d = pcall(function() return HttpService:JSONDecode(readfile(CFG_PATH)) end)
        if ok and type(d) == "table" then
            for k, v in pairs(d) do if Def[k] ~= nil then Cfg[k] = v end end
        end
    end)
end
LoadCfg()

-- ── STATE ───────────────────────────────────────────────────────────────────
-- Semua state + UI references disatukan → hemat puluhan slot
local St = {
    speedOn=false, flyOn=false, ghostOn=false, godOn=false,
    ijOn=false, lgOn=false, nfOn=false, fcOn=false,
    hbxOn=false, avoidOn=false, afkOn=false,
    espAOn=false, chamOn=false, espOOn=false, aimOn=false,
    traceOn=false, fbOn=false, nfogOn=false,
    ieOn=false, acOn=false, kaOn=false, akOn=false,
    gReal=nil, gFake=nil, gSmooth=15, lockTgt=nil,
    fcCF=CF(0,10,0), fcRX=0, fcRY=0, fcPrev=nil,
    origGrav=workspace.Gravity,
    origAmb=Lighting.Ambient, origBri=Lighting.Brightness,
    origOut=Lighting.OutdoorAmbient, origFog=Lighting.FogEnd,
    espAvas={}, espObjs={}, chamParts={},
    scanObjs={}, scanSel=nil, scanHL=nil,
    discovered={}, claimList={},
    plrSel=nil, afkConn=nil, kaList={}, akHooked=false,
}

-- UI references table — menggantikan puluhan variabel lokal terpisah
local UI = {}

-- Toggle setter/getter table — dipanggil dari event handlers
local T = {}

-- Fungsi loop table
local AF = {}

-- ── CLEANUP STALE GUI ────────────────────────────────────────────────────────
for _, v in pairs(lp.PlayerGui:GetChildren()) do
    if v.Name:sub(1,5) == "_CYR_" then pcall(function() v:Destroy() end) end
end
for _, v in pairs(workspace:GetChildren()) do
    if v.Name:sub(1,5) == "_ESP_" then pcall(function() v:Destroy() end) end
end

-- ── COLORS ──────────────────────────────────────────────────────────────────
local C = {
    BG=C3rgb(8,8,13),    BG2=C3rgb(13,13,20),
    Panel=C3rgb(17,17,27), Card=C3rgb(22,22,34), Card2=C3rgb(28,28,42),
    Bord=C3rgb(40,40,62), Bord2=C3rgb(55,55,80),
    Acc=C3rgb(0,200,120), AccG=C3rgb(0,255,160), AccD=C3rgb(0,130,75),
    Red=C3rgb(205,45,45), RedL=C3rgb(240,60,60),
    Grn=C3rgb(30,170,70), Blu=C3rgb(45,110,240), BluL=C3rgb(70,140,255),
    Pur=C3rgb(135,55,225), PurL=C3rgb(165,90,255),
    Ora=C3rgb(240,148,0), OraL=C3rgb(255,175,30),
    Yel=C3rgb(230,195,30), Cya=C3rgb(0,205,225), CyaL=C3rgb(30,235,255),
    Pnk=C3rgb(215,75,160), PnkL=C3rgb(245,100,190),
    Txt=C3rgb(220,220,230), TxtD=C3rgb(115,115,140),
    TxtM=C3rgb(60,60,82), Inp=C3rgb(11,11,18), Inp2=C3rgb(16,16,26),
}
local TC = { C.Acc, C.Pur, C.Blu, C.Ora }

-- ── HELPERS ─────────────────────────────────────────────────────────────────
local function TW(obj, t, props, style, dir)
    if not obj or not obj.Parent then return end
    TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props):Play()
end
local function Cor(p, r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 8); return c end
local function Str(p,col,th) local s=Instance.new("UIStroke",p); s.Color=col or C.Bord; s.Thickness=th or 1; return s end
local function Pad(p,t,b,l,r) local u=Instance.new("UIPadding",p); u.PaddingTop=UDim.new(0,t or 6); u.PaddingBottom=UDim.new(0,b or 6); u.PaddingLeft=UDim.new(0,l or 8); u.PaddingRight=UDim.new(0,r or 8); return u end
local function LLay(p,dir,sp,ha,va) local l=Instance.new("UIListLayout",p); l.FillDirection=dir or Enum.FillDirection.Vertical; l.Padding=UDim.new(0,sp or 5); l.SortOrder=Enum.SortOrder.LayoutOrder; l.HorizontalAlignment=ha or Enum.HorizontalAlignment.Center; l.VerticalAlignment=va or Enum.VerticalAlignment.Top; return l end
local function Frm(par,sz,bg,ord) local f=Instance.new("Frame",par); f.Size=sz or UDim2n(1,0,0,40); f.BackgroundColor3=bg or C.Card; f.BorderSizePixel=0; if ord then f.LayoutOrder=ord end; return f end
local function Lbl(par,txt,sz,col,fnt,ts,xa) local l=Instance.new("TextLabel",par); l.Size=sz or UDim2n(1,0,0,16); l.Text=txt or ""; l.TextColor3=col or C.Txt; l.Font=fnt or Enum.Font.Gotham; l.TextSize=ts or 12; l.TextXAlignment=xa or Enum.TextXAlignment.Left; l.BackgroundTransparency=1; l.BorderSizePixel=0; return l end
local function Div(par,col,ord) local f=Frm(par,UDim2n(1,-12,0,1),col or C.Bord,ord); f.BackgroundTransparency=0.4; return f end

local function MkBtn(par,txt,bg,sz,ts,ord)
    bg=bg or C.Blu
    local b=Instance.new("TextButton",par)
    b.Size=sz or UDim2n(1,0,0,34); b.Text=txt or ""; b.BackgroundColor3=bg
    b.TextColor3=C.Txt; b.Font=Enum.Font.GothamSemibold; b.TextSize=ts or 12
    b.AutoButtonColor=false; b.BorderSizePixel=0
    if ord then b.LayoutOrder=ord end
    Cor(b,7)
    b.MouseEnter:Connect(function()   TW(b,.12,{BackgroundColor3=bg:Lerp(C3(1,1,1),.16)}) end)
    b.MouseLeave:Connect(function()   TW(b,.12,{BackgroundColor3=bg}) end)
    b.MouseButton1Down:Connect(function() TW(b,.06,{BackgroundColor3=bg:Lerp(C3(0,0,0),.22)}) end)
    b.MouseButton1Up:Connect(function()   TW(b,.1, {BackgroundColor3=bg}) end)
    return b
end

local function MkInp(par,hint,def,sz,ord)
    local w=Frm(par,sz or UDim2n(1,0,0,34),C.Inp,ord); Cor(w,7); Str(w,C.Bord,1)
    local tb=Instance.new("TextBox",w)
    tb.Size=UDim2n(1,-10,1,0); tb.Position=UDim2n(0,5,0,0); tb.Text=def or ""
    tb.PlaceholderText=hint or ""; tb.TextColor3=C.Txt; tb.PlaceholderColor3=C.TxtD
    tb.Font=Enum.Font.Gotham; tb.TextSize=12; tb.BackgroundTransparency=1
    tb.ClearTextOnFocus=false; tb.BorderSizePixel=0; tb.TextXAlignment=Enum.TextXAlignment.Left
    tb.FocusLost:Connect(function() TW(w,.12,{BackgroundColor3=C.Inp}) end)
    tb.Focused:Connect(function()   TW(w,.12,{BackgroundColor3=C.Inp2}) end)
    return tb, w
end

local function MkTog(par,lbl,onCol,sz,ord)
    onCol=onCol or C.Grn
    local b=Instance.new("TextButton",par)
    b.Size=sz or UDim2n(1,0,0,34); b.Text=lbl..":  OFF"; b.BackgroundColor3=C.Red
    b.TextColor3=C.Txt; b.Font=Enum.Font.GothamSemibold; b.TextSize=12
    b.AutoButtonColor=false; b.BorderSizePixel=0
    if ord then b.LayoutOrder=ord end
    Cor(b,7)
    local pill=Frm(b,UDim2n(0,32,0,14),C3rgb(55,55,78)); pill.Position=UDim2n(1,-38,0.5,-7); Cor(pill,7)
    local dot=Frm(pill,UDim2n(0,10,0,10),C.TxtD); dot.Position=UDim2n(0,2,0.5,-5); Cor(dot,5)
    local on=false
    local function Set(v)
        on=v; b.Text=lbl..":  "..(v and "ON" or "OFF")
        TW(b,.18,{BackgroundColor3=v and onCol or C.Red})
        TW(pill,.18,{BackgroundColor3=v and onCol or C3rgb(55,55,78)})
        TW(dot,.18,{Position=v and UDim2n(1,-12,0.5,-5) or UDim2n(0,2,0.5,-5), BackgroundColor3=v and C3(1,1,1) or C.TxtD})
    end
    local function Get() return on end
    b.MouseButton1Click:Connect(function() Set(not on) end)
    b.MouseEnter:Connect(function() TW(b,.1,{BackgroundColor3=(on and onCol or C.Red):Lerp(C3(1,1,1),.12)}) end)
    b.MouseLeave:Connect(function() TW(b,.1,{BackgroundColor3=on and onCol or C.Red}) end)
    return b, Set, Get
end

local function MkSldr(par,lbl,mn,mx,def,ord,ac)
    ac=ac or C.Acc
    local w=Frm(par,UDim2n(1,0,0,52),C.Card,ord); Cor(w,7); Str(w,C.Bord,1)
    local lb=Lbl(w,lbl..": "..def,UDim2n(1,-8,0,15),C.TxtD,nil,11); lb.Position=UDim2n(0,6,0,4)
    local tk=Frm(w,UDim2n(1,-14,0,7),C3rgb(20,20,32)); tk.Position=UDim2n(0,7,0,26); Cor(tk,4)
    local pct=(def-mn)/mmax(mx-mn,1)
    local fl=Frm(tk,UDim2n(pct,0,1,0),ac); Cor(fl,4)
    local kn=Instance.new("TextButton",tk)
    kn.Size=UDim2n(0,16,0,16); kn.Position=UDim2n(pct,-8,0.5,-8); kn.Text=""
    kn.BackgroundColor3=C3(1,1,1); kn.ZIndex=5; kn.AutoButtonColor=false; kn.BorderSizePixel=0
    Cor(kn,8); Str(kn,ac,1.5)
    local val=def; local drag=false; local onChange=nil
    kn.MouseButton1Down:Connect(function() drag=true end)
    M:Add(UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end))
    M:Add(RunService.RenderStepped:Connect(function()
        if not drag then return end
        local rel=UIS:GetMouseLocation().X-tk.AbsolutePosition.X
        local p=mclamp(rel/mmax(tk.AbsoluteSize.X,1),0,1)
        kn.Position=UDim2n(p,-8,0.5,-8); fl.Size=UDim2n(p,0,1,0)
        val=mfloor(mn+(mx-mn)*p); lb.Text=lbl..": "..val
        if onChange then onChange(val) end
    end))
    return w, function(cb) onChange=cb end, function() return val end
end

-- ── GUI ROOT ─────────────────────────────────────────────────────────────────
local W, H = 346, 545
local sg = Instance.new("ScreenGui")
sg.Name=GUI_NAME; sg.ResetOnSpawn=false; sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
sg.DisplayOrder=9999; sg.IgnoreGuiInset=true; sg.Parent=lp.PlayerGui
M:Add(sg)

local espF = Instance.new("Folder", workspace)
espF.Name=ESP_NAME; M:Add(espF)

local Main = Frm(sg, UDim2n(0,W,0,H), C.BG)
Main.Position=UDim2n(0.5,-W/2,0.5,-H/2); Main.Active=true; Main.Draggable=true
Main.ClipsDescendants=true; Cor(Main,12)

local mainStr = Str(Main, C.Acc, 1.5)
local gBar = Frm(Main, UDim2n(1,0,0,3), C.Acc); gBar.ZIndex=3; gBar.BackgroundTransparency=0.15
local gGrad = Instance.new("UIGradient", gBar)
gGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.AccG),ColorSequenceKeypoint.new(0.5,C.Acc),ColorSequenceKeypoint.new(1,C.AccG)})

local TB = Frm(Main, UDim2n(1,0,0,48), C.Panel); TB.Position=UDim2n(0,0,0,3); Cor(TB,10)
local tbFix = Frm(TB, UDim2n(1,0,0,10), C.Panel); tbFix.Position=UDim2n(0,0,1,-10)

do -- Header labels (scoped)
    local logoLbl = Lbl(TB,"CyRuz",UDim2n(0,130,0,24),C.Acc,Enum.Font.GothamBold,18)
    logoLbl.Position=UDim2n(0,14,0,5)
    local subLbl = Lbl(TB,"SSS PREMIUM  ‣  ALL GAMES",UDim2n(0,220,0,14),C.TxtM,Enum.Font.Gotham,9)
    subLbl.Position=UDim2n(0,14,0,30)
    local verBadge=Frm(TB,UDim2n(0,38,0,16),C.Acc:Lerp(C.BG,.6)); verBadge.Position=UDim2n(0,110,0,9); Cor(verBadge,4); Str(verBadge,C.Acc,1)
    local verLbl=Lbl(verBadge,"v2.0",UDim2n(1,0,1,0),C.AccG,Enum.Font.GothamBold,9,Enum.TextXAlignment.Center)
end

local function TopBtn(txt,xOff,bg)
    local b=Instance.new("TextButton",TB)
    b.Size=UDim2n(0,26,0,26); b.Position=UDim2n(1,xOff,0.5,-13); b.Text=txt
    b.BackgroundColor3=bg; b.TextColor3=C.Txt; b.Font=Enum.Font.GothamBold; b.TextSize=11
    b.AutoButtonColor=false; b.BorderSizePixel=0; b.ZIndex=5; Cor(b,6)
    b.MouseEnter:Connect(function() TW(b,.1,{BackgroundColor3=bg:Lerp(C3(1,1,1),.22)}) end)
    b.MouseLeave:Connect(function() TW(b,.1,{BackgroundColor3=bg}) end)
    return b
end
local BtnMin   = TopBtn("-",-58,C3rgb(45,45,68))
local BtnClose = TopBtn("X",-28,C.Red)

local TabBar = Frm(Main, UDim2n(1,0,0,38), C.BG2); TabBar.Position=UDim2n(0,0,0,51)
local tLine = Frm(TabBar, UDim2n(1,0,0,2), C.Bord); tLine.Position=UDim2n(0,0,1,-2)
local tInd  = Frm(tLine,  UDim2n(0.25,0,1,0), C.Acc)

local TN = {"MOVE","VISUAL","PLAYER","EXPLOIT"}
local TBs = {}
for i, n in ipairs(TN) do
    local b=Instance.new("TextButton",TabBar)
    b.Size=UDim2n(0.25,0,1,-2); b.Position=UDim2n((i-1)*0.25,0,0,0); b.Text=n
    b.Font=Enum.Font.GothamBold; b.TextSize=10
    b.BackgroundColor3=i==1 and TC[1]:Lerp(C.BG2,.82) or C.BG2
    b.TextColor3=i==1 and TC[1] or C.TxtD
    b.AutoButtonColor=false; b.BorderSizePixel=0
    TBs[i]=b
end

local PgArea = Frm(Main, UDim2n(1,0,1,-92), C.BG)
PgArea.Position=UDim2n(0,0,0,89); PgArea.BackgroundTransparency=1; PgArea.ClipsDescendants=true

local function MkPage()
    local sf=Instance.new("ScrollingFrame",PgArea)
    sf.Size=UDim2n(1,0,1,0); sf.BackgroundTransparency=1; sf.BorderSizePixel=0
    sf.ScrollBarThickness=3; sf.ScrollBarImageColor3=C.Bord
    sf.CanvasSize=UDim2n(0,0,0,0); sf.AutomaticCanvasSize=Enum.AutomaticSize.Y
    sf.Visible=false; sf.ScrollingDirection=Enum.ScrollingDirection.Y
    Pad(sf,6,12,5,5); LLay(sf,nil,4); return sf
end

local Pg = {}
for i=1,4 do Pg[i]=MkPage() end
Pg[1].Visible=true

local sBr = Frm(Main, UDim2n(1,-12,0,24), C3rgb(10,10,17))
sBr.Position=UDim2n(0,6,1,-30); sBr.ZIndex=3; Cor(sBr,5); Str(sBr,C.Bord,1)
local sLbl = Lbl(sBr,"Ready",UDim2n(1,-8,1,0),C.Acc,Enum.Font.Gotham,11)
sLbl.Position=UDim2n(0,6,0,0); sLbl.ZIndex=4; sLbl.TextTruncate=Enum.TextTruncate.AtEnd

local function SetSt(t, col) sLbl.Text=t; sLbl.TextColor3=col or C.Acc end

local curTab = 1
local secOrder = {}

local function MkSec(page, title, color, pageIdx)
    color=color or C.Acc
    if not secOrder[pageIdx] then secOrder[pageIdx]=0 end
    local base=secOrder[pageIdx]; secOrder[pageIdx]=base+30
    local hdr=Instance.new("TextButton",page)
    hdr.Size=UDim2n(1,0,0,28); hdr.Text="  ▾  "..title:upper()
    hdr.BackgroundColor3=C.Panel; hdr.TextColor3=color; hdr.Font=Enum.Font.GothamBold
    hdr.TextSize=10; hdr.TextXAlignment=Enum.TextXAlignment.Left
    hdr.AutoButtonColor=false; hdr.BorderSizePixel=0; hdr.LayoutOrder=base+1
    Cor(hdr,6); Str(hdr,color:Lerp(C.BG,.62),1)
    local strip=Frm(hdr,UDim2n(0,3,1,-8),color); strip.Position=UDim2n(0,0,0,4); strip.BackgroundTransparency=0.3
    local body=Frm(page,UDim2n(1,0,0,0),C3rgb(14,14,22),base+2)
    body.AutomaticSize=Enum.AutomaticSize.Y; body.BorderSizePixel=0; Cor(body,6)
    LLay(body,nil,5); Pad(body,7,9,7,7); Str(body,color:Lerp(C.BG,.78),1)
    local spc=Frm(page,UDim2n(1,0,0,4),C3(0,0,0),base+3); spc.BackgroundTransparency=1
    local open=true
    hdr.MouseButton1Click:Connect(function()
        open=not open; hdr.Text="  "..(open and "▾" or "▸").."  "..title:upper()
        body.Visible=open
        if open then body.AutomaticSize=Enum.AutomaticSize.Y
        else body.AutomaticSize=Enum.AutomaticSize.None; body.Size=UDim2n(1,0,0,0) end
        spc.Visible=open
    end)
    return body
end

local function SwTab(n)
    curTab=n
    for i, pg in ipairs(Pg) do pg.Visible=(i==n) end
    for i, b in ipairs(TBs) do TW(b,.15,{BackgroundColor3=i==n and TC[i]:Lerp(C.BG2,.82) or C.BG2, TextColor3=i==n and TC[i] or C.TxtD}) end
    TW(tInd,.2,{Position=UDim2n((n-1)*0.25,0,0,0), BackgroundColor3=TC[n]})
    mainStr.Color=TC[n]; TW(gBar,.2,{BackgroundColor3=TC[n]})
    gGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,TC[n]:Lerp(C3(1,1,1),.3)),ColorSequenceKeypoint.new(0.5,TC[n]),ColorSequenceKeypoint.new(1,TC[n]:Lerp(C3(1,1,1),.3))})
end
for i, b in ipairs(TBs) do b.MouseButton1Click:Connect(function() SwTab(i) end) end

-- ═══════════════════════════════════════════════════════════════════════════
-- PAGE 1 — MOVE  (wrapped in do...end → locals cleared after block)
-- ═══════════════════════════════════════════════════════════════════════════
do
    local bMove  = MkSec(Pg[1], "MOVEMENT",      C.Acc, 1)
    local bGod   = MkSec(Pg[1], "GODMODE",        C.Ora, 1)
    local bFC    = MkSec(Pg[1], "FREE CAM",        C.Cya, 1)
    local bMisc1 = MkSec(Pg[1], "MISC MOVEMENT",  C.Yel, 1)

    -- Speed row
    local spdRow=Frm(bMove,UDim2n(1,0,0,34),C3(0,0,0),1); spdRow.BackgroundTransparency=1
    LLay(spdRow,Enum.FillDirection.Horizontal,5,Enum.HorizontalAlignment.Left)
    UI.spdInp, UI.spdW = MkInp(spdRow,"Speed (studs/s)",tostring(Cfg.speedVal),UDim2n(0,90,0,34))
    UI.spdW.LayoutOrder=1; UI.spdW.Size=UDim2n(0,90,0,34)
    UI.spdTog, T.setSpdTog, T.getSpdTog = MkTog(spdRow,"SPEED",C.Grn,UDim2n(0,162,0,34),2)
    Div(bMove,nil,3)
    UI.flyTog,  T.setFly,  T.getFly  = MkTog(bMove,"FLY",            C.Cya, nil, 4)
    UI.ghoTog,  T.setGho,  T.getGho  = MkTog(bMove,"GHOST NOCLIP",   C.Pnk, nil, 5)
    UI.ijTog,   T.setIJ,   T.getIJ   = MkTog(bMove,"INFINITE JUMP",  C.Blu, nil, 6)
    UI.nfTog,   T.setNF,   T.getNF   = MkTog(bMove,"NO FALL DMG",    C.Grn, nil, 7)
    UI.lgTog,   T.setLG,   T.getLG   = MkTog(bMove,"LOW GRAVITY",    C.Cya, nil, 8)
    UI.hbxTog,  T.setHBX,  T.getHBX  = MkTog(bMove,"HITBOX EXPAND",  C.Ora, nil, 9)
    UI.avTog,   T.setAV,   T.getAV   = MkTog(bMove,"ANTI-VOID",      C.Red, nil,10)
    _, UI.hbxCb, UI.hbxGet = MkSldr(bMove,"HBX Scale",1,20,Cfg.hbxScale,11,C.Ora)
    UI.hbxCb(function(v) Cfg.hbxScale=v; SaveCfg() end)

    -- Godmode
    UI.godTog, T.setGod, T.getGod = MkTog(bGod,"GODMODE (CLONE)",C.Ora,nil,1)
    _, UI.godSlCb, UI.godSlGet = MkSldr(bGod,"Y Offset",3,80,Cfg.godOff,2,C.Ora)
    UI.godSlCb(function(v) Cfg.godOff=v; SaveCfg() end)
    Lbl(bGod,"Clone-desync method — real char sinks below fake",UDim2n(1,0,0,14),C.TxtD,nil,9).LayoutOrder=3

    -- FreeCam
    UI.fcTog, T.setFC, T.getFC = MkTog(bFC,"FREE CAM",C.Cya,nil,1)
    local fcInputRow=Frm(bFC,UDim2n(1,0,0,34),C3(0,0,0),2); fcInputRow.BackgroundTransparency=1
    LLay(fcInputRow,Enum.FillDirection.Horizontal,5,Enum.HorizontalAlignment.Left)
    UI.fcSpdInp, UI.fcSpdW = MkInp(fcInputRow,"Speed",tostring(Cfg.fcSpd),UDim2n(0,87,0,34))
    UI.fcSpdW.LayoutOrder=1; UI.fcSpdW.Size=UDim2n(0,87,0,34)
    UI.fcSnsInp, UI.fcSnsW = MkInp(fcInputRow,"Sens",tostring(Cfg.fcSns),UDim2n(0,87,0,34))
    UI.fcSnsW.LayoutOrder=2; UI.fcSnsW.Size=UDim2n(0,87,0,34)
    UI.fcTPBtn = MkBtn(bFC,"TP TO FREECAM POSITION",C.Cya,nil,12,3)
    UI.fcPLbl  = Lbl(bFC,"FC Pos: —",nil,C.TxtD,nil,10); UI.fcPLbl.LayoutOrder=4
    Lbl(bFC,"WASD+Q/E to move  •  Shift = fast  •  Esc to exit",UDim2n(1,0,0,14),C.TxtD,nil,9).LayoutOrder=5

    -- Misc
    UI.afkTog, T.setAFK, T.getAFK = MkTog(bMisc1,"ANTI-AFK",C.Grn,nil,1)
    Lbl(bMisc1,"Prevents kick by simulating movement every 55s",UDim2n(1,0,0,14),C.TxtD,nil,9).LayoutOrder=2
    Div(bMisc1,nil,3)
    UI.rejoinBtn  = MkBtn(bMisc1,"REJOIN SERVER",            C.Red,           nil,12,4)
    UI.servHopBtn = MkBtn(bMisc1,"SERVER HOP (new server)", C3rgb(140,45,45),nil,12,5)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- PAGE 2 — VISUAL
-- ═══════════════════════════════════════════════════════════════════════════
do
    local bEspP = MkSec(Pg[2],"ESP PLAYER", C.Pur, 2)
    local bEspO = MkSec(Pg[2],"ESP OBJECTS",C.Blu, 2)
    local bAim  = MkSec(Pg[2],"AIMBOT",     C.Ora, 2)
    local bLgt  = MkSec(Pg[2],"LIGHTING",   C.Yel, 2)

    UI.espATog,  T.setEspA,  T.getEspA  = MkTog(bEspP,"ESP PLAYER",  C.Pur, nil,1)
    UI.chamTog,  T.setCham,  T.getCham  = MkTog(bEspP,"CHAMS",        C.PurL,nil,2)
    UI.traceTog, T.setTrace, T.getTrace = MkTog(bEspP,"TRACERS",      C.Pnk, nil,3)
    _, UI.espDCb, UI.espDGet = MkSldr(bEspP,"Max Dist",50,1000,Cfg.espMaxD,4,C.Pur)
    UI.espDCb(function(v) Cfg.espMaxD=v; SaveCfg() end)
    Lbl(bEspP,"SelectionBox + BillboardGui + health + distance",UDim2n(1,0,0,14),C.TxtD,nil,9).LayoutOrder=5

    UI.espOTog, T.setEspO, T.getEspO = MkTog(bEspO,"ESP OBJECTS",C.Blu,nil,1)
    Lbl(bEspO,"SelectionBox + class label + distance",UDim2n(1,0,0,14),C.TxtD,nil,9).LayoutOrder=2

    UI.aimTog, T.setAim, T.getAim = MkTog(bAim,"AIMBOT (LOCK)",C.Ora,nil,1)
    Lbl(bAim,"T = Lock/Unlock  •  G = Cycle target",UDim2n(1,0,0,14),C.TxtD,nil,9).LayoutOrder=2
    Lbl(bAim,"Raycast wall-check + exponential cam smoothing",UDim2n(1,0,0,14),C.TxtD,nil,9).LayoutOrder=3
    UI.lockLbl = Lbl(bAim,"Target: —",UDim2n(1,0,0,15),C.Txt,Enum.Font.GothamBold,11); UI.lockLbl.LayoutOrder=4
    _, UI.aimFCb, UI.aimFGet = MkSldr(bAim,"FOV",30,360,Cfg.aimFov,5,C.Ora)
    _, UI.aimSCb, UI.aimSGet = MkSldr(bAim,"Smooth%",1,30,Cfg.aimSmo,6,C.Ora)
    UI.aimFCb(function(v) Cfg.aimFov=v; SaveCfg() end)
    UI.aimSCb(function(v) Cfg.aimSmo=v; SaveCfg() end)

    UI.fbBtn   = MkBtn(bLgt,"FULL BRIGHT", C.Yel, nil,12,1)
    UI.nfogBtn = MkBtn(bLgt,"REMOVE FOG",  C.Cya, nil,12,2)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- PAGE 3 — PLAYER
-- ═══════════════════════════════════════════════════════════════════════════
do
    local bScan  = MkSec(Pg[3],"SCANNER OBJEK",C.Blu, 3)
    local bPList = MkSec(Pg[3],"PLAYER LIST",  C.Pur, 3)

    UI.scanSrch, UI.scanSrchW = MkInp(bScan,"Cari nama...","",nil,1); UI.scanSrchW.LayoutOrder=1

    local fRow=Frm(bScan,UDim2n(1,0,0,26),C3(0,0,0),2); fRow.BackgroundTransparency=1
    LLay(fRow,Enum.FillDirection.Horizontal,3,Enum.HorizontalAlignment.Left)
    local FLTS={"ALL","Player","Model","Part","NPC","Tool"}
    UI.fAct="ALL"; UI.fBtns={}
    for i, f in ipairs(FLTS) do
        local fb=Instance.new("TextButton",fRow)
        fb.Size=UDim2n(0,i==1 and 34 or 46,1,0); fb.Text=f; fb.Font=Enum.Font.GothamBold; fb.TextSize=9
        fb.BackgroundColor3=i==1 and C.Acc or C.Card; fb.TextColor3=i==1 and C3(0,0,0) or C.TxtD
        fb.AutoButtonColor=false; fb.BorderSizePixel=0; fb.LayoutOrder=i; Cor(fb,5)
        UI.fBtns[f]=fb
    end

    local sBRow=Frm(bScan,UDim2n(1,0,0,30),C3(0,0,0),3); sBRow.BackgroundTransparency=1
    LLay(sBRow,Enum.FillDirection.Horizontal,5,Enum.HorizontalAlignment.Left)
    UI.sDoBtn=MkBtn(sBRow,"SCAN",    C.Blu,  UDim2n(0,66,1,0),11); UI.sDoBtn.LayoutOrder=1
    UI.sTpBtn=MkBtn(sBRow,"TELEPORT",C.Card, UDim2n(0,88,1,0),11); UI.sTpBtn.LayoutOrder=2; UI.sTpBtn.TextColor3=C.TxtD
    UI.sEBtn =MkBtn(sBRow,"ESP: OFF",C.Card, UDim2n(0,68,1,0),11); UI.sEBtn.LayoutOrder=3; UI.sEBtn.TextColor3=C.TxtD
    UI.sStatL=Lbl(bScan,"Tekan SCAN untuk mulai",nil,C.TxtD,nil,10); UI.sStatL.LayoutOrder=4

    UI.sList=Instance.new("ScrollingFrame",bScan)
    UI.sList.Size=UDim2n(1,0,0,185); UI.sList.BackgroundColor3=C.Inp; UI.sList.BorderSizePixel=0
    UI.sList.ScrollBarThickness=3; UI.sList.ScrollBarImageColor3=C.Acc
    UI.sList.CanvasSize=UDim2n(0,0,0,0); UI.sList.LayoutOrder=5; Cor(UI.sList,6)
    LLay(UI.sList,nil,3).HorizontalAlignment=Enum.HorizontalAlignment.Center; Pad(UI.sList,4,4,4,4)

    UI.plrRefBtn=MkBtn(bPList,"REFRESH PLAYER LIST",C.Pur,nil,12,1)
    UI.plrStatL=Lbl(bPList,"Tekan REFRESH",nil,C.TxtD,nil,10); UI.plrStatL.LayoutOrder=2

    UI.plrList=Instance.new("ScrollingFrame",bPList)
    UI.plrList.Size=UDim2n(1,0,0,185); UI.plrList.BackgroundColor3=C.Inp; UI.plrList.BorderSizePixel=0
    UI.plrList.ScrollBarThickness=3; UI.plrList.ScrollBarImageColor3=C.Pur
    UI.plrList.CanvasSize=UDim2n(0,0,0,0); UI.plrList.LayoutOrder=3; Cor(UI.plrList,6)
    LLay(UI.plrList,nil,3).HorizontalAlignment=Enum.HorizontalAlignment.Center; Pad(UI.plrList,4,4,4,4)

    local plrActRow=Frm(bPList,UDim2n(1,0,0,30),C3(0,0,0),4); plrActRow.BackgroundTransparency=1
    LLay(plrActRow,Enum.FillDirection.Horizontal,4,Enum.HorizontalAlignment.Left)
    UI.plrTpBtn   =MkBtn(plrActRow,"TP TO",    C.Pur,              UDim2n(0,74,1,0),10); UI.plrTpBtn.LayoutOrder=1;   UI.plrTpBtn.TextColor3=C.TxtD
    UI.plrBringBtn=MkBtn(plrActRow,"BRING",     C.Red:Lerp(C.Pur,.3),UDim2n(0,66,1,0),10); UI.plrBringBtn.LayoutOrder=2; UI.plrBringBtn.TextColor3=C.TxtD
    UI.plrSpecBtn =MkBtn(plrActRow,"SPECTATE",  C.Blu,              UDim2n(0,78,1,0),10); UI.plrSpecBtn.LayoutOrder=3;  UI.plrSpecBtn.TextColor3=C.TxtD
end

-- ═══════════════════════════════════════════════════════════════════════════
-- PAGE 4 — EXPLOIT
-- ═══════════════════════════════════════════════════════════════════════════
do
    local bRem = MkSec(Pg[4],"AUTO DISCOVER REMOTES",C.Ora, 4)
    local bIE  = MkSec(Pg[4],"INSTANT INTERACT",      C.Grn, 4)
    local bKA  = MkSec(Pg[4],"KILL AURA",             C.Red, 4)
    local bRT  = MkSec(Pg[4],"REMOTE TESTER",         C.RedL,4)
    local bAK  = MkSec(Pg[4],"ANTI-KICK",             C.Yel, 4)

    Lbl(bRem,"Scan SEMUA remote. Oranye = keyword match (claim/reward/etc).",UDim2n(1,0,0,22),C.TxtD,nil,9).LayoutOrder=1
    UI.rScanBtn=MkBtn(bRem,"SCAN SEMUA REMOTE",C.Ora,nil,12,2)
    UI.rAutoTog, T.setRATog, T.getRATog = MkTog(bRem,"AUTO CLAIM LOOP",C.Ora,nil,3)

    local rDelRow=Frm(bRem,UDim2n(1,0,0,34),C3(0,0,0),4); rDelRow.BackgroundTransparency=1
    LLay(rDelRow,Enum.FillDirection.Horizontal,5,Enum.HorizontalAlignment.Left)
    UI.rDelInp, UI.rDelW = MkInp(rDelRow,"Delay (s)",tostring(Cfg.delay),UDim2n(0,90,0,34))
    UI.rDelW.LayoutOrder=1; UI.rDelW.Size=UDim2n(0,90,0,34)
    UI.rClrBtn=MkBtn(rDelRow,"CLEAR LIST",C.Red:Lerp(C.Card,.4),UDim2n(0,90,0,34),10)
    UI.rClrBtn.LayoutOrder=2; UI.rClrBtn.TextColor3=C.TxtD

    UI.rStatL=Lbl(bRem,"Tekan SCAN dulu",nil,C.TxtD,nil,10); UI.rStatL.LayoutOrder=5

    UI.rList=Instance.new("ScrollingFrame",bRem)
    UI.rList.Size=UDim2n(1,0,0,170); UI.rList.BackgroundColor3=C.Inp; UI.rList.BorderSizePixel=0
    UI.rList.ScrollBarThickness=3; UI.rList.ScrollBarImageColor3=C.Acc
    UI.rList.CanvasSize=UDim2n(0,0,0,0); UI.rList.LayoutOrder=6; Cor(UI.rList,6)
    LLay(UI.rList,nil,3).HorizontalAlignment=Enum.HorizontalAlignment.Center; Pad(UI.rList,4,4,4,4)

    UI.ieTog, T.setIE, T.getIE = MkTog(bIE,"INSTANT INTERACT (E)",C.Grn,nil,1)
    Lbl(bIE,"Set HoldDuration=0, RequiresLOS=false on all prompts",UDim2n(1,0,0,14),C.TxtD,nil,9).LayoutOrder=2
    local ieRadW2=Frm(bIE,UDim2n(1,0,0,32),C.Inp,3); Cor(ieRadW2,7); Str(ieRadW2,C.Bord,1)
    UI.ieRInp=Instance.new("TextBox",ieRadW2)
    UI.ieRInp.Size=UDim2n(1,-10,1,0); UI.ieRInp.Position=UDim2n(0,5,0,0); UI.ieRInp.Text=tostring(Cfg.farmR)
    UI.ieRInp.PlaceholderText="Radius (studs)"; UI.ieRInp.BackgroundTransparency=1
    UI.ieRInp.TextColor3=C.Txt; UI.ieRInp.Font=Enum.Font.Gotham; UI.ieRInp.TextSize=12
    UI.ieRInp.ClearTextOnFocus=false; UI.ieRInp.BorderSizePixel=0
    UI.ieFireBtn=MkBtn(bIE,"FIRE ALL PROMPTS IN RADIUS",C.Grn,nil,12,4)

    UI.kaTog, T.setKA, T.getKA = MkTog(bKA,"KILL AURA",C.Red,nil,1)
    Lbl(bKA,"Attempts tool hit on nearby players every frame",UDim2n(1,0,0,14),C.TxtD,nil,9).LayoutOrder=2
    _, UI.kaRCb, UI.kaRGet = MkSldr(bKA,"Radius",5,60,Cfg.kaRadius,3,C.Red)
    UI.kaRCb(function(v) Cfg.kaRadius=v; SaveCfg() end)
    UI.kaStatL=Lbl(bKA,"Targets: 0",nil,C.TxtD,nil,10); UI.kaStatL.LayoutOrder=4

    Lbl(bRT,"Path e.g.: RS.RemoteEvents.Collect",UDim2n(1,0,0,14),C.TxtD,nil,9).LayoutOrder=0
    UI.rtPathInp, UI.rtP = MkInp(bRT,"Remote path...","",nil,1); UI.rtP.LayoutOrder=1
    UI.rtArgInp,  UI.rtA = MkInp(bRT,'Args JSON: null or [1,"abc"]',"null",nil,2); UI.rtA.LayoutOrder=2
    local rtActRow=Frm(bRT,UDim2n(1,0,0,30),C3(0,0,0),3); rtActRow.BackgroundTransparency=1
    LLay(rtActRow,Enum.FillDirection.Horizontal,5,Enum.HorizontalAlignment.Left)
    UI.rtFire=MkBtn(rtActRow,"FIRE/INVOKE",C.Red,              UDim2n(0,104,1,0),11); UI.rtFire.LayoutOrder=1
    UI.rtSpam=MkBtn(rtActRow,"SPAM x10",  C.Red:Lerp(C.Ora,.5),UDim2n(0,80,1,0),11); UI.rtSpam.LayoutOrder=2
    UI.rtResL=Lbl(bRT,"Result: —",UDim2n(1,0,0,28),C.TxtD,nil,10); UI.rtResL.LayoutOrder=4; UI.rtResL.TextWrapped=true

    UI.akTog, T.setAK, T.getAK = MkTog(bAK,"ANTI-KICK HOOK",C.Yel,nil,1)
    Lbl(bAK,"Hooks kick events — effectiveness varies by game",UDim2n(1,0,0,14),C.TxtD,nil,9).LayoutOrder=2
    UI.akStatL=Lbl(bAK,"Status: Inactive",nil,C.TxtD,nil,10); UI.akStatL.LayoutOrder=3
end

-- ═══════════════════════════════════════════════════════════════════════════
-- UTILITY SHORTCUTS
-- ═══════════════════════════════════════════════════════════════════════════
local function GH()   local c=lp.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function GM()   local c=lp.Character; return c and c:FindFirstChildOfClass("Humanoid")  end

-- ═══════════════════════════════════════════════════════════════════════════
-- LOGIC — MOVEMENT
-- ═══════════════════════════════════════════════════════════════════════════
UI.spdTog.MouseButton1Click:Connect(function()
    St.speedOn = T.getSpdTog()
    if not St.speedOn then local hrp=GH(); if hrp then hrp.AssemblyLinearVelocity=V3(0,0,0) end end
    SetSt(St.speedOn and ("Speed ON: "..UI.spdInp.Text.." s/s") or "Speed OFF")
    Cfg.speedVal=tonumber(UI.spdInp.Text) or Def.speedVal; SaveCfg()
end)
AF.speed = function()
    if not St.speedOn then return end
    local hrp=GH(); local hum=GM(); if not hrp or not hum then return end
    if hum.MoveDirection.Magnitude < 0.01 then return end
    local spd=tonumber(UI.spdInp.Text) or 120
    local dir=hum.MoveDirection.Unit; local cur=hrp.AssemblyLinearVelocity
    hrp.AssemblyLinearVelocity=V3(dir.X*spd*0.65+cur.X*0.35, cur.Y, dir.Z*spd*0.65+cur.Z*0.35)
end

local function ClrFly()
    local c=lp.Character; if not c then return end
    local r=c:FindFirstChild("HumanoidRootPart")
    if r then local bv=r:FindFirstChild("_CFV"); if bv then bv:Destroy() end
              local bg=r:FindFirstChild("_CFG"); if bg then bg:Destroy() end end
    local h=c:FindFirstChildOfClass("Humanoid"); if h then h.PlatformStand=false end
end

UI.flyTog.MouseButton1Click:Connect(function()
    St.flyOn=T.getFly()
    if St.flyOn then
        local c=lp.Character; if not c then T.setFly(false); St.flyOn=false; return end
        local r=c:FindFirstChild("HumanoidRootPart"); local h=c:FindFirstChildOfClass("Humanoid")
        if not r or not h then T.setFly(false); St.flyOn=false; return end
        h.PlatformStand=true
        for _, v in pairs(r:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
        end
        local bv=Instance.new("BodyVelocity",r); bv.Name="_CFV"; bv.MaxForce=V3(9e9,9e9,9e9); bv.Velocity=V3(0,0,0)
        local bg=Instance.new("BodyGyro",r);     bg.Name="_CFG"; bg.MaxTorque=V3(9e9,9e9,9e9); bg.P=9e4; bg.CFrame=r.CFrame
        SetSt("Fly ON — WASD + Space/Ctrl")
    else ClrFly(); SetSt("Fly OFF") end
end)
AF.fly = function()
    if not St.flyOn then return end
    local r=GH(); if not r then return end
    local bv=r:FindFirstChild("_CFV"); local bg=r:FindFirstChild("_CFG"); if not bv or not bg then return end
    local spd=tonumber(UI.spdInp.Text) or 120
    local cf=cam.CFrame; local d=V3(0,0,0)
    if UIS:IsKeyDown(Enum.KeyCode.W)           then d=d+cf.LookVector  end
    if UIS:IsKeyDown(Enum.KeyCode.S)           then d=d-cf.LookVector  end
    if UIS:IsKeyDown(Enum.KeyCode.A)           then d=d-cf.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D)           then d=d+cf.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space)       then d=d+V3(0,1,0)      end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d=d-V3(0,1,0)      end
    if UIS:IsKeyDown(Enum.KeyCode.LeftShift)   then spd=spd*2.5        end
    bv.Velocity=d.Magnitude>0 and d.Unit*spd or V3(0,0,0); bg.CFrame=cf
end

UI.ghoTog.MouseButton1Click:Connect(function()
    St.ghostOn=T.getGho()
    if not St.ghostOn then
        local c=lp.Character; if not c then return end
        for _, v in pairs(c:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide=true; if v.Name~="HumanoidRootPart" then v.Transparency=0 end end
        end
    end
    SetSt(St.ghostOn and "Ghost Noclip ON" or "Ghost OFF")
end)
M:Add(RunService.Stepped:Connect(function()
    if not St.ghostOn then return end
    local c=lp.Character; if not c then return end
    for _, v in pairs(c:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide=false; if v.Name~="HumanoidRootPart" then v.Transparency=0.55 end end
    end
end))

-- Godmode
local function GodOff()
    St.godOn=false
    local saved=nil
    if St.gFake then local fr=St.gFake:FindFirstChild("HumanoidRootPart"); if fr then saved=fr.CFrame end end
    if St.gReal then
        pcall(function()
            lp.Character=St.gReal; task.wait(0.05)
            cam.CameraType=Enum.CameraType.Custom
            local rh=St.gReal:FindFirstChildOfClass("Humanoid"); if rh then cam.CameraSubject=rh end
            for _, v in pairs(St.gReal:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide=true; if v.Name~="HumanoidRootPart" then v.Transparency=0 end
                    v.LocalTransparencyModifier=0
                elseif v:IsA("Decal") then v.Transparency=0 end
            end
            if saved then local rr=St.gReal:FindFirstChild("HumanoidRootPart"); if rr then rr.CFrame=saved; rr.Velocity=V3(0,0,0) end end
            local rh2=St.gReal:FindFirstChildOfClass("Humanoid"); if rh2 then rh2.PlatformStand=false end
        end)
    end
    if St.gFake then pcall(function() St.gFake:Destroy() end); St.gFake=nil end
    St.gReal=nil; T.setGod(false); SetSt("Godmode OFF")
end
local function GodOn()
    local c=lp.Character; if not c then T.setGod(false); return end
    St.gReal=c; St.godOn=true
    pcall(function()
        c.Archivable=true; local f=c:Clone(); f.Name=lp.Name.."_GC"; f.Parent=workspace; St.gFake=f
        for _, v in pairs(f:GetDescendants()) do
            if v:IsA("BasePart") and v.Name~="HumanoidRootPart" then v.Transparency=0.35
            elseif v:IsA("Script") or v:IsA("LocalScript") then v:Destroy() end
        end
        for _, v in pairs(c:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end
        lp.Character=f; task.wait(0.05)
        local fh=f:FindFirstChildOfClass("Humanoid")
        if fh then cam.CameraSubject=fh; cam.CameraType=Enum.CameraType.Custom
            fh.Died:Connect(function() if St.godOn then GodOff() end end) end
    end)
    SetSt("Godmode ON — clone desync active")
end
UI.godTog.MouseButton1Click:Connect(function() if St.godOn then GodOff() else GodOn() end end)
AF.godmode = function()
    if not St.godOn or not St.gReal or not St.gFake then return end
    local rr=St.gReal:FindFirstChild("HumanoidRootPart"); local fr=St.gFake:FindFirstChild("HumanoidRootPart")
    if not rr or not fr then return end
    for _, v in pairs(St.gReal:GetChildren()) do if v:IsA("BasePart") then v.CanCollide=false end end
    local off=UI.godSlGet(); St.gSmooth=St.gSmooth+(off-St.gSmooth)*0.1
    rr.CFrame=fr.CFrame*CF(0,-St.gSmooth,0); rr.Velocity=V3(0,0,0)
end

UI.ijTog.MouseButton1Click:Connect(function() St.ijOn=T.getIJ(); SetSt(St.ijOn and "Infinite Jump ON" or "Infinite Jump OFF") end)
M:Add(UIS.JumpRequest:Connect(function() if not St.ijOn then return end; local h=GM(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end))

UI.nfTog.MouseButton1Click:Connect(function() St.nfOn=T.getNF(); SetSt(St.nfOn and "No Fall Damage ON" or "No Fall Damage OFF") end)
AF.nofall = function() if not St.nfOn then return end; local h=GM(); if h then h:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false) end end

UI.lgTog.MouseButton1Click:Connect(function() St.lgOn=T.getLG(); workspace.Gravity=St.lgOn and 32 or St.origGrav; SetSt(St.lgOn and "Low Gravity ON (32)" or "Gravity restored") end)

UI.hbxTog.MouseButton1Click:Connect(function() St.hbxOn=T.getHBX(); SetSt(St.hbxOn and "Hitbox Expand ON" or "Hitbox Expand OFF") end)
AF.hitbox = function()
    if not St.hbxOn then return end
    local scale=UI.hbxGet()
    for _, p in pairs(Players:GetPlayers()) do
        if p==lp then continue end
        local c=p.Character; if not c then continue end
        local hrp=c:FindFirstChild("HumanoidRootPart"); if hrp and hrp:IsA("BasePart") then hrp.Size=V3(scale,scale,scale) end
    end
end

UI.avTog.MouseButton1Click:Connect(function() St.avoidOn=T.getAV(); SetSt(St.avoidOn and "Anti-Void ON" or "Anti-Void OFF") end)
AF.antivoid = function()
    if not St.avoidOn then return end
    local hrp=GH(); if not hrp then return end
    if hrp.Position.Y < -200 then hrp.CFrame=CF(0,100,0); SetSt("Anti-Void: Rescued!",C.Yel) end
end

UI.afkTog.MouseButton1Click:Connect(function()
    St.afkOn=T.getAFK()
    if St.afkOn then
        if St.afkConn then St.afkConn:Disconnect(); St.afkConn=nil end
        local lastTick=os.clock()
        St.afkConn=M:Add(RunService.Heartbeat:Connect(function()
            if os.clock()-lastTick < 55 then return end
            lastTick=os.clock()
            pcall(function()
                local h=GM(); if h then
                    local prev=h.AutoRotate; h.AutoRotate=false
                    local hrp=GH(); if hrp then hrp.CFrame=hrp.CFrame*CF(0,0,-0.01); task.wait(0.05); hrp.CFrame=hrp.CFrame*CF(0,0,0.01) end
                    h.AutoRotate=prev
                end
            end)
        end))
        SetSt("Anti-AFK ON")
    else
        if St.afkConn then pcall(function() St.afkConn:Disconnect() end); St.afkConn=nil end
        SetSt("Anti-AFK OFF")
    end
end)

UI.rejoinBtn.MouseButton1Click:Connect(function()
    SetSt("Rejoining...",C.Yel)
    task.delay(0.5,function() pcall(function() TeleportSvc:Teleport(game.PlaceId,lp) end) end)
end)
UI.servHopBtn.MouseButton1Click:Connect(function()
    SetSt("Server hopping...",C.Ora)
    task.delay(0.5,function()
        pcall(function()
            local ok,servers=pcall(function() return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=10")) end)
            if ok and servers and servers.data then
                for _, s in ipairs(servers.data) do
                    if s.id~=game.JobId then TeleportSvc:TeleportToPlaceInstance(game.PlaceId,s.id,lp); return end
                end
            end
            TeleportSvc:Teleport(game.PlaceId,lp)
        end)
    end)
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- LOGIC — FREE CAM
-- ═══════════════════════════════════════════════════════════════════════════
local function StopFC()
    St.fcOn=false
    if St.fcPrev then pcall(function() cam.CameraType=St.fcPrev.ct; cam.CameraSubject=St.fcPrev.cs end); St.fcPrev=nil end
    UIS.MouseBehavior=Enum.MouseBehavior.Default; UI.fcPLbl.Text="FC Pos: —"
end
local function StartFC()
    local hrp=GH(); if not hrp then return end
    St.fcOn=true; St.fcPrev={ct=cam.CameraType,cs=cam.CameraSubject}
    St.fcCF=cam.CFrame; cam.CameraType=Enum.CameraType.Scriptable; UIS.MouseBehavior=Enum.MouseBehavior.LockCenter
    local lv=St.fcCF.LookVector; St.fcRX=matan2(lv.Y,V3(lv.X,0,lv.Z).Magnitude); St.fcRY=matan2(-lv.X,-lv.Z)
end
UI.fcTog.MouseButton1Click:Connect(function() if T.getFC() then StartFC() else StopFC() end end)
UI.fcTPBtn.MouseButton1Click:Connect(function()
    if not St.fcOn then SetSt("Aktifkan FreeCam dulu!"); return end
    local hrp=GH(); if hrp then hrp.CFrame=CF(St.fcCF.Position+V3(0,3,0)) end
end)
M:Add(UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.Escape and St.fcOn then StopFC(); T.setFC(false) end
end))
AF.freecam = function(dt)
    if not St.fcOn then return end
    local spd=tonumber(UI.fcSpdInp.Text) or 60; local sns=tonumber(UI.fcSnsInp.Text) or 0.35
    local md=UIS:GetMouseDelta()
    St.fcRY=St.fcRY-md.X*sns*0.01; St.fcRX=mclamp(St.fcRX-md.Y*sns*0.01,-math.pi/2+0.05,math.pi/2-0.05)
    local rot=CFA(0,St.fcRY,0)*CFA(St.fcRX,0,0); local pos=St.fcCF.Position; local d=V3(0,0,0)
    if UIS:IsKeyDown(Enum.KeyCode.W)           then d=d+rot.LookVector  end
    if UIS:IsKeyDown(Enum.KeyCode.S)           then d=d-rot.LookVector  end
    if UIS:IsKeyDown(Enum.KeyCode.A)           then d=d-rot.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D)           then d=d+rot.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.E) or UIS:IsKeyDown(Enum.KeyCode.Space)       then d=d+V3(0,1,0) end
    if UIS:IsKeyDown(Enum.KeyCode.Q) or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d=d-V3(0,1,0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then spd=spd*3 end
    if d.Magnitude>0 then pos=pos+d.Unit*spd*dt end
    St.fcCF=CF(pos)*rot; cam.CFrame=St.fcCF
    local p=St.fcCF.Position; UI.fcPLbl.Text=("FC: %.0f, %.0f, %.0f"):format(p.X,p.Y,p.Z)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- LOGIC — AIMBOT
-- ═══════════════════════════════════════════════════════════════════════════
local function HasLOS(from,to)
    local rp=RaycastParams.new(); rp.FilterDescendantsInstances={lp.Character,espF}; rp.FilterType=Enum.RaycastFilterType.Exclude
    return workspace:Raycast(from,to-from,rp)==nil
end
local function FindNrst()
    local hrp=GH(); if not hrp then return nil end
    local fovR=mrad(UI.aimFGet()); local best,bd=nil,math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p==lp then continue end
        local c=p.Character; if not c then continue end
        local r=c:FindFirstChild("HumanoidRootPart") or c:FindFirstChildWhichIsA("BasePart"); if not r then continue end
        local dir=(r.Position-cam.CFrame.Position).Unit; local dot=dir:Dot(cam.CFrame.LookVector)
        if math.acos(mclamp(dot,-1,1))>fovR/2 then continue end
        local d=(r.Position-hrp.Position).Magnitude; if d<bd then bd=d; best={part=r,name=p.Name} end
    end
    return best
end
UI.aimTog.MouseButton1Click:Connect(function()
    St.aimOn=T.getAim()
    if St.aimOn then
        local t=FindNrst()
        if t then St.lockTgt=t; UI.lockLbl.Text="Target: "..t.name; SetSt("Aimbot → "..t.name)
        else T.setAim(false); St.aimOn=false; St.lockTgt=nil; UI.lockLbl.Text="Tidak ada target" end
    else St.lockTgt=nil; UI.lockLbl.Text="Target: —"; SetSt("Aimbot OFF") end
end)
M:Add(UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.T then
        if St.lockTgt then St.lockTgt=nil; St.aimOn=false; T.setAim(false); UI.lockLbl.Text="Target: —"
        else local t=FindNrst(); if t then St.lockTgt=t; St.aimOn=true; T.setAim(true); UI.lockLbl.Text="Target: "..t.name end end
    end
    if i.KeyCode==Enum.KeyCode.G and St.aimOn then
        local ts={}
        for _, p in pairs(Players:GetPlayers()) do
            if p==lp then continue end
            local c=p.Character; if not c then continue end
            local r=c:FindFirstChild("HumanoidRootPart") or c:FindFirstChildWhichIsA("BasePart")
            if r then table.insert(ts,{part=r,name=p.Name}) end
        end
        if #ts>1 and St.lockTgt then
            local idx=1; for i2,t in ipairs(ts) do if t.part==St.lockTgt.part then idx=i2; break end end
            local nx=ts[(idx%#ts)+1]; if nx then St.lockTgt=nx; UI.lockLbl.Text="Target: "..nx.name; SetSt("Ganti: "..nx.name) end
        end
    end
end))
AF.aimbot = function()
    if not St.aimOn or not St.lockTgt then return end
    local part=St.lockTgt.part
    if not part or not part.Parent then
        local t=FindNrst()
        if t then St.lockTgt=t; UI.lockLbl.Text="Target: "..t.name
        else St.lockTgt=nil; St.aimOn=false; T.setAim(false); UI.lockLbl.Text="Target: —" end
        return
    end
    local camPos=cam.CFrame.Position; local tPos=part.Position+V3(0,1.5,0)
    if not HasLOS(camPos,tPos) then UI.lockLbl.TextColor3=C.Red; return end
    UI.lockLbl.TextColor3=C.Txt
    local smo=mclamp(UI.aimSGet()/100,0.01,0.5)
    cam.CFrame=cam.CFrame:Lerp(CFla(camPos,tPos),smo)
    local hrp=GH(); if hrp then UI.lockLbl.Text=("Target: %s  |  %.0fs"):format(St.lockTgt.name,(part.Position-hrp.Position).Magnitude) end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- LOGIC — ESP
-- ═══════════════════════════════════════════════════════════════════════════
local function MkSB(ad,col) local sb=Instance.new("SelectionBox",espF); sb.Adornee=ad; sb.Color3=col; sb.LineThickness=0.055; sb.SurfaceTransparency=0.82; sb.SurfaceColor3=col; return sb end
local function MkBB(ad,txt,col)
    local bb=Instance.new("BillboardGui",espF); bb.Adornee=ad; bb.Size=UDim2n(0,130,0,38)
    bb.StudsOffset=V3(0,3.5,0); bb.AlwaysOnTop=true; bb.MaxDistance=UI.espDGet()
    local bg2=Instance.new("Frame",bb); bg2.Size=UDim2n(1,0,1,0); bg2.BackgroundColor3=C3(0,0,0); bg2.BackgroundTransparency=0.45; Cor(bg2,4)
    local l=Lbl(bg2,txt,UDim2n(1,0,0.65,0),col,Enum.Font.GothamBold,11,Enum.TextXAlignment.Center)
    l.Position=UDim2n(0,0,0,0); l.TextStrokeTransparency=0.4; l.TextStrokeColor3=C3(0,0,0)
    local hbg=Frm(bg2,UDim2n(1,-8,0,4),C3rgb(40,40,40)); hbg.Position=UDim2n(0,4,1,-6); Cor(hbg,2)
    local hfl=Frm(hbg,UDim2n(1,0,1,0),C.Grn); Cor(hfl,2)
    return bb,l,hfl
end
local function RmEspA(p) if St.espAvas[p] then for _,v in pairs(St.espAvas[p]) do pcall(function() v:Destroy() end) end; St.espAvas[p]=nil end end
local function RmEspO(obj) if St.espObjs[obj] then pcall(function() St.espObjs[obj].box:Destroy() end); pcall(function() St.espObjs[obj].bb:Destroy() end); St.espObjs[obj]=nil end end
local function AddEspO(obj,col)
    RmEspO(obj); col=col or C.Acc
    local tgt=obj
    if obj:IsA("Model") then local r=obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart"); if r then tgt=r end end
    local box=MkSB(obj,col); local bb,lbl2=MkBB(tgt,obj.Name.."\n["..obj.ClassName.."]",col)
    St.espObjs[obj]={box=box,bb=bb,lbl=lbl2,part=tgt}
end

UI.espATog.MouseButton1Click:Connect(function() St.espAOn=T.getEspA(); if not St.espAOn then for p,_ in pairs(St.espAvas) do RmEspA(p) end end; SetSt(St.espAOn and "ESP Player ON" or "ESP Player OFF") end)
UI.espOTog.MouseButton1Click:Connect(function() St.espOOn=T.getEspO(); if not St.espOOn then for obj,_ in pairs(St.espObjs) do RmEspO(obj) end end; SetSt(St.espOOn and "ESP Objects ON" or "ESP Objects OFF") end)

local chamHighlights={}
UI.chamTog.MouseButton1Click:Connect(function()
    St.chamOn=T.getCham()
    if not St.chamOn then for _,h in pairs(chamHighlights) do pcall(function() h:Destroy() end) end; chamHighlights={} end
    SetSt(St.chamOn and "Chams ON" or "Chams OFF")
end)

local espFrm=0
AF.esp = function()
    espFrm=espFrm+1; if espFrm%24~=0 then return end
    local hrp=GH()
    if St.espAOn then
        for p,_ in pairs(St.espAvas) do if not p or not p.Parent then RmEspA(p) end end
        for _,p in pairs(Players:GetPlayers()) do
            if p==lp then continue end
            local c=p.Character; if not c then RmEspA(p); continue end
            local rt=c:FindFirstChild("HumanoidRootPart") or c:FindFirstChildWhichIsA("BasePart"); if not rt then RmEspA(p); continue end
            local hum=c:FindFirstChildOfClass("Humanoid"); local hp=hum and (hum.Health/mmax(hum.MaxHealth,1)) or 1
            if not St.espAvas[p] then
                local box=MkSB(c,C.Pur); local bb,lbl2,hfl=MkBB(rt,p.Name,C.Pur); St.espAvas[p]={box,bb,lbl2,hfl}
            else
                local lbl2=St.espAvas[p][3]; local hfl=St.espAvas[p][4]
                if lbl2 and hrp then lbl2.Text=p.Name.."\n"..mfloor((rt.Position-hrp.Position).Magnitude).."s" end
                if hfl then local hp2=mclamp(hp,0,1); hfl.Size=UDim2n(hp2,0,1,0); hfl.BackgroundColor3=hp2>0.5 and C.Grn:Lerp(C.Yel,1-(hp2-0.5)*2) or C.Yel:Lerp(C.Red,1-hp2*2) end
            end
        end
    end
    if St.chamOn then
        for _,p in pairs(Players:GetPlayers()) do
            if p==lp then continue end
            if not chamHighlights[p] then
                local c=p.Character; if not c then continue end
                local ok,h=pcall(function() local hl=Instance.new("Highlight",espF); hl.Adornee=c; hl.FillColor=C.PurL; hl.OutlineColor=C.Pur; hl.FillTransparency=0.55; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; return hl end)
                if ok then chamHighlights[p]=h end
            end
        end
        for p,h in pairs(chamHighlights) do if not p.Character then pcall(function() h:Destroy() end); chamHighlights[p]=nil end end
    end
    if St.espOOn then
        for obj,d in pairs(St.espObjs) do
            if not obj or not obj.Parent then RmEspO(obj); continue end
            if hrp and d.lbl and d.part and d.part.Parent then
                local ok,pos=pcall(function() return d.part:IsA("BasePart") and d.part.Position end)
                if ok and pos then d.lbl.Text=obj.Name.."\n"..mfloor((pos-hrp.Position).Magnitude).."s" end
            end
        end
    end
end
M:Add(Players.PlayerRemoving:Connect(function(p)
    RmEspA(p)
    if chamHighlights[p] then pcall(function() chamHighlights[p]:Destroy() end); chamHighlights[p]=nil end
end))

-- Tracers
local tracerDrawings={}
UI.traceTog.MouseButton1Click:Connect(function()
    St.traceOn=T.getTrace()
    if not St.traceOn then for _,d in pairs(tracerDrawings) do pcall(function() d:Remove() end) end; tracerDrawings={} end
    SetSt(St.traceOn and "Tracers ON" or "Tracers OFF")
end)
AF.tracers = function()
    if not St.traceOn then return end
    for p,d in pairs(tracerDrawings) do if not p.Character then pcall(function() d:Remove() end); tracerDrawings[p]=nil end end
    local vp=cam.ViewportSize
    for _,p in pairs(Players:GetPlayers()) do
        if p==lp then continue end
        local c=p.Character; if not c then continue end
        local rt=c:FindFirstChild("HumanoidRootPart"); if not rt then continue end
        local sp,vis=cam:WorldToViewportPoint(rt.Position)
        if not vis then if tracerDrawings[p] then tracerDrawings[p].Visible=false end; continue end
        if not tracerDrawings[p] then
            local ok,line=pcall(function() local l=Drawing.new("Line"); l.Color=Color3.fromRGB(180,60,255); l.Thickness=1.5; l.Transparency=0.4; l.ZIndex=1; return l end)
            if ok then tracerDrawings[p]=line end
        end
        if tracerDrawings[p] then tracerDrawings[p].From=Vector2.new(vp.X/2,vp.Y); tracerDrawings[p].To=Vector2.new(sp.X,sp.Y); tracerDrawings[p].Visible=true end
    end
end

-- Lighting
UI.fbBtn.MouseButton1Click:Connect(function()
    St.fbOn=not St.fbOn
    if St.fbOn then Lighting.Ambient=C3(1,1,1); Lighting.Brightness=2; Lighting.OutdoorAmbient=C3(1,1,1); Lighting.FogEnd=9e9; SetSt("Full Bright ON")
    else Lighting.Ambient=St.origAmb; Lighting.Brightness=St.origBri; Lighting.OutdoorAmbient=St.origOut; Lighting.FogEnd=St.origFog; SetSt("Full Bright OFF") end
    UI.fbBtn.Text=St.fbOn and "FULL BRIGHT (ON)" or "FULL BRIGHT"
end)
UI.nfogBtn.MouseButton1Click:Connect(function()
    St.nfogOn=not St.nfogOn
    Lighting.FogEnd=St.nfogOn and 9e9 or St.origFog; Lighting.FogStart=St.nfogOn and 9e9 or 0
    UI.nfogBtn.Text=St.nfogOn and "REMOVE FOG (ON)" or "REMOVE FOG"; SetSt(St.nfogOn and "No Fog ON" or "Fog restored")
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- LOGIC — SCANNER
-- ═══════════════════════════════════════════════════════════════════════════
local scanEspAct={}
local scanHLBox=nil
local function SetSHL(obj)
    if scanHLBox then pcall(function() scanHLBox:Destroy() end); scanHLBox=nil end
    if not obj then return end
    local h=Instance.new("SelectionBox",espF); h.Adornee=obj; h.Color3=C.Yel; h.LineThickness=0.09; h.SurfaceTransparency=0.75; h.SurfaceColor3=C.Yel; scanHLBox=h
end
local function GCat(obj)
    if obj:IsA("Model") then
        if Players:GetPlayerFromCharacter(obj) then return "Player" end
        if obj:FindFirstChildOfClass("Humanoid") then return "NPC" end
        return "Model"
    elseif obj:IsA("Tool") then return "Tool"
    elseif obj:IsA("BasePart") then return "Part"
    else return obj.ClassName end
end
local function GPos(obj)
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local r=obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart"); if r then return r.Position end
        local ok,cf=pcall(function() return obj:GetModelCFrame() end); if ok then return cf.Position end
    end
end
local cCol={Player=C.Pur,NPC=C.Red,Model=C.Blu,Part=C.Cya,Tool=C.Yel}

local function BuildSList(flt)
    for _,ch in pairs(UI.sList:GetChildren()) do if ch:IsA("TextButton") or ch:IsA("Frame") then ch:Destroy() end end
    local hrp=GH(); local sorted={}
    for _,obj in ipairs(St.scanObjs) do
        local cat=GCat(obj)
        if UI.fAct~="ALL" and cat~=UI.fAct then continue end
        local nm=obj.Name
        if flt and flt~="" and not nm:lower():find(flt:lower(),1,true) then continue end
        local pos=GPos(obj); local d=9999
        if hrp and pos then d=mfloor((hrp.Position-pos).Magnitude) end
        table.insert(sorted,{obj=obj,name=nm,cat=cat,dist=d})
    end
    table.sort(sorted,function(a,b) return a.dist<b.dist end)
    for idx,data in ipairs(sorted) do
        local e=Instance.new("TextButton",UI.sList)
        e.Size=UDim2n(1,0,0,32); e.BackgroundColor3=C.Card; e.TextColor3=cCol[data.cat] or C.Txt
        e.Font=Enum.Font.Gotham; e.TextSize=10; e.TextXAlignment=Enum.TextXAlignment.Left
        e.BorderSizePixel=0; e.AutoButtonColor=false; e.LayoutOrder=idx
        e.Text="  ["..data.cat.."]  "..data.name.."  |  "..data.dist.."s"; e.TextTruncate=Enum.TextTruncate.AtEnd; Cor(e,5)
        e.MouseButton1Click:Connect(function()
            St.scanSel=data.obj; SetSHL(data.obj)
            for _,c2 in pairs(UI.sList:GetChildren()) do if c2:IsA("TextButton") then c2.BackgroundColor3=C.Card end end
            TW(e,.1,{BackgroundColor3=C3rgb(28,50,95)}); UI.sStatL.Text="Dipilih: "..data.name
            TW(UI.sTpBtn,.15,{BackgroundColor3=C.Grn}); UI.sTpBtn.TextColor3=C.Txt
        end)
    end
    UI.sList.CanvasSize=UDim2n(0,0,0,#sorted*35+8)
    UI.sStatL.Text=#sorted.." obj  (total "..#St.scanObjs..")"
end
local function DoScan()
    St.scanObjs={}
    for _,obj in ipairs(workspace:GetChildren()) do
        if obj.Name==ESP_NAME or obj.Name=="Terrain" or obj==cam then continue end
        table.insert(St.scanObjs,obj)
        if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
            for _,ch in ipairs(obj:GetChildren()) do
                if ch:IsA("Model") or ch:IsA("BasePart") or ch:IsA("Tool") then table.insert(St.scanObjs,ch) end
            end
        end
    end
    BuildSList(UI.scanSrch.Text)
end

for lbl2,fb in pairs(UI.fBtns) do
    fb.MouseButton1Click:Connect(function()
        UI.fAct=lbl2
        for l2,b2 in pairs(UI.fBtns) do TW(b2,.12,{BackgroundColor3=l2==lbl2 and C.Acc or C.Card, TextColor3=l2==lbl2 and C3(0,0,0) or C.TxtD}) end
        BuildSList(UI.scanSrch.Text)
    end)
end
UI.scanSrch:GetPropertyChangedSignal("Text"):Connect(function() BuildSList(UI.scanSrch.Text) end)
UI.sDoBtn.MouseButton1Click:Connect(function() UI.sStatL.Text="Scanning..."; task.wait(0.05); DoScan() end)
UI.sTpBtn.MouseButton1Click:Connect(function()
    if not St.scanSel then UI.sStatL.Text="Pilih dulu!"; return end
    local pos=GPos(St.scanSel); if not pos then UI.sStatL.Text="No position!"; return end
    local hrp=GH(); if hrp then hrp.CFrame=CF(pos+V3(0,4,0)) end
end)
UI.sEBtn.MouseButton1Click:Connect(function()
    if not St.scanSel then UI.sStatL.Text="Pilih dulu!"; return end
    local obj=St.scanSel
    if scanEspAct[obj] then
        RmEspO(obj); scanEspAct[obj]=nil
        TW(UI.sEBtn,.15,{BackgroundColor3=C.Card}); UI.sEBtn.TextColor3=C.TxtD; UI.sEBtn.Text="ESP: OFF"
    else
        AddEspO(obj,C.Yel); scanEspAct[obj]=true
        TW(UI.sEBtn,.15,{BackgroundColor3=C.Blu}); UI.sEBtn.TextColor3=C.Txt; UI.sEBtn.Text="ESP: ON"
    end
end)

-- Player List
local function BuildPlrList()
    for _,ch in pairs(UI.plrList:GetChildren()) do if ch:IsA("Frame") or ch:IsA("TextButton") then ch:Destroy() end end
    local ps=Players:GetPlayers(); UI.plrStatL.Text=#ps.." player online"; St.plrSel=nil
    for i,p in ipairs(ps) do
        if p==lp then continue end
        local e=Frm(UI.plrList,UDim2n(1,0,0,34),C.Card,i); Cor(e,5)
        local nameLbl=Lbl(e,p.Name,UDim2n(0.65,0,1,0),C.Txt,Enum.Font.GothamSemibold,11); nameLbl.Position=UDim2n(0,8,0,0)
        local selBtn=Instance.new("TextButton",e); selBtn.Size=UDim2n(1,0,1,0); selBtn.Text=""; selBtn.BackgroundTransparency=1; selBtn.ZIndex=2; selBtn.AutoButtonColor=false
        selBtn.MouseButton1Click:Connect(function()
            St.plrSel=p
            for _,c2 in pairs(UI.plrList:GetChildren()) do if c2:IsA("Frame") then c2.BackgroundColor3=C.Card end end
            TW(e,.12,{BackgroundColor3=C3rgb(28,50,95)}); UI.plrStatL.Text="Dipilih: "..p.Name
            TW(UI.plrTpBtn,.15,{BackgroundColor3=C.Pur});   UI.plrTpBtn.TextColor3=C.Txt
            TW(UI.plrBringBtn,.15,{BackgroundColor3=C.Red}); UI.plrBringBtn.TextColor3=C.Txt
            TW(UI.plrSpecBtn,.15,{BackgroundColor3=C.Blu});  UI.plrSpecBtn.TextColor3=C.Txt
        end)
    end
    UI.plrList.CanvasSize=UDim2n(0,0,0,#ps*37+8)
end
UI.plrRefBtn.MouseButton1Click:Connect(BuildPlrList)
UI.plrTpBtn.MouseButton1Click:Connect(function()
    local p=St.plrSel; if not p then UI.plrStatL.Text="Pilih player dulu!"; return end
    local c=p.Character; if not c then return end; local r=c:FindFirstChild("HumanoidRootPart"); if not r then return end
    local hrp=GH(); if hrp then hrp.CFrame=r.CFrame*CF(0,0,-3) end; SetSt("TP → "..p.Name)
end)
UI.plrBringBtn.MouseButton1Click:Connect(function()
    local p=St.plrSel; if not p then UI.plrStatL.Text="Pilih player dulu!"; return end
    local c=p.Character; if not c then return end; local r=c:FindFirstChild("HumanoidRootPart"); if not r then return end
    local hrp=GH(); if not hrp then return end; pcall(function() r.CFrame=hrp.CFrame*CF(0,0,-3) end); SetSt("Bring: "..p.Name)
end)
UI.plrSpecBtn.MouseButton1Click:Connect(function()
    local p=St.plrSel; if not p then UI.plrStatL.Text="Pilih player dulu!"; return end
    local c=p.Character; if not c then return end
    local hum=c:FindFirstChildOfClass("Humanoid"); if hum then cam.CameraType=Enum.CameraType.Custom; cam.CameraSubject=hum; SetSt("Spectating: "..p.Name) end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- LOGIC — REMOTE SCANNER / AUTO CLAIM
-- ═══════════════════════════════════════════════════════════════════════════
local KW={"claim","free","reward","spin","daily","bonus","redeem","collect","money","coin","gem","cash","item","gift","prize","buy","purchase","sell","upgrade","rebirth","reset","interact","use","open","take","loot","drop","pickup","grab","earn","score","point","exp","level"}
local function IsKW(nm) local l=nm:lower(); for _,k in ipairs(KW) do if l:find(k,1,true) then return true end end end
local function ScanRem()
    local out={}
    local function Rec(par,path,dep)
        if dep>5 then return end
        for _,ch in ipairs(par:GetChildren()) do
            local np=path.."."..ch.Name
            if ch:IsA("RemoteFunction") or ch:IsA("RemoteEvent") then table.insert(out,{name=ch.Name,path=np,inst=ch,type=ch.ClassName}) end
            pcall(Rec,ch,np,dep+1)
        end
    end
    pcall(Rec,RS,"RS",0)
    pcall(function() for _,ch in pairs(workspace:GetChildren()) do if ch:IsA("RemoteFunction") or ch:IsA("RemoteEvent") then table.insert(out,{name=ch.Name,path="WS."..ch.Name,inst=ch,type=ch.ClassName}) end end end)
    return out
end
local function AddREntry(d)
    local hl=IsKW(d.name)
    local e=Frm(UI.rList,UDim2n(1,0,0,36),C.Card,#St.discovered+1); Cor(e,5)
    if hl then Str(e,C.Ora,1.5) end
    local typeLbl=Lbl(e,d.type=="RemoteFunction" and "RF" or "RE",UDim2n(0,28,0,16),d.type=="RemoteFunction" and C.Blu or C.Cya,Enum.Font.GothamBold,8,Enum.TextXAlignment.Center)
    typeLbl.Position=UDim2n(0,4,0.5,-8); typeLbl.BackgroundColor3=C3rgb(14,18,36); Cor(typeLbl,3)
    local nameLbl2=Lbl(e,d.name,UDim2n(0.48,0,1,0),hl and C.Ora or C.Txt,Enum.Font.GothamSemibold,10)
    nameLbl2.Position=UDim2n(0,36,0,0); nameLbl2.TextTruncate=Enum.TextTruncate.AtEnd
    local tryB=MkBtn(e,"TRY",C.Ora,UDim2n(0,38,0,24),10); tryB.Position=UDim2n(1,-82,0.5,-12)
    local addB=MkBtn(e,"+AUTO",C.AccD,UDim2n(0,40,0,24),9); addB.Position=UDim2n(1,-38,0.5,-12)
    tryB.MouseButton1Click:Connect(function()
        UI.rStatL.Text="Firing "..d.name.."..."; UI.rStatL.TextColor3=C.TxtD
        task.spawn(function()
            local ok,res=pcall(function() return d.inst:IsA("RemoteFunction") and d.inst:InvokeServer() or (d.inst:FireServer() or "fired") end)
            UI.rStatL.Text=(ok and "OK: " or "ERR: ")..tostring(res):sub(1,55); UI.rStatL.TextColor3=ok and C.Acc or C.Red
        end)
    end)
    addB.MouseButton1Click:Connect(function()
        for _,x in ipairs(St.claimList) do if x.inst==d.inst then UI.rStatL.Text=d.name.." sudah di claim list!"; return end end
        table.insert(St.claimList,d); TW(addB,.15,{BackgroundColor3=C.Acc}); UI.rStatL.Text="+ "..d.name.." → Auto Claim list"
    end)
    table.insert(St.discovered,d)
end
UI.rScanBtn.MouseButton1Click:Connect(function()
    for _,ch in pairs(UI.rList:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
    St.discovered={}; St.claimList={}; UI.rStatL.Text="Scanning remotes..."; UI.rStatL.TextColor3=C.TxtD
    task.spawn(function()
        local all=ScanRem()
        table.sort(all,function(a,b) local am,bm=IsKW(a.name),IsKW(b.name); if am~=bm then return am end; return a.name<b.name end)
        for _,d in ipairs(all) do AddREntry(d) end
        UI.rList.CanvasSize=UDim2n(0,0,0,#St.discovered*39+8)
        local kw=0; for _,d in ipairs(St.discovered) do if IsKW(d.name) then kw=kw+1 end end
        UI.rStatL.Text=#St.discovered.." remote  |  "..kw.." potensial claim"; UI.rStatL.TextColor3=C.Acc
    end)
end)
UI.rClrBtn.MouseButton1Click:Connect(function() St.claimList={}; UI.rStatL.Text="Claim list cleared"; UI.rStatL.TextColor3=C.TxtD end)

local acRun=false
UI.rAutoTog.MouseButton1Click:Connect(function()
    St.acOn=T.getRATog(); acRun=St.acOn
    if St.acOn then
        if #St.claimList==0 then UI.rStatL.Text="Tambah remote (+AUTO) dulu!"; T.setRATog(false); St.acOn=false; acRun=false; return end
        task.spawn(function()
            while acRun and St.acOn do
                for _,d in ipairs(St.claimList) do
                    if not acRun then break end
                    pcall(function() if d.inst:IsA("RemoteFunction") then d.inst:InvokeServer() else d.inst:FireServer() end end)
                    task.wait(0.08)
                end
                task.wait(math.max(0.1,tonumber(UI.rDelInp.Text) or 1))
            end
        end)
        SetSt("Auto Claim ON — "..#St.claimList.." remotes")
    else acRun=false; SetSt("Auto Claim OFF") end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- LOGIC — INSTANT INTERACT / KILL AURA / REMOTE TESTER / ANTI-KICK
-- ═══════════════════════════════════════════════════════════════════════════
UI.ieTog.MouseButton1Click:Connect(function()
    St.ieOn=T.getIE()
    if St.ieOn then
        for _,pp in pairs(workspace:GetDescendants()) do if pp:IsA("ProximityPrompt") then pp.HoldDuration=0; pp.RequiresLineOfSight=false end end
        workspace.DescendantAdded:Connect(function(d) if St.ieOn and d:IsA("ProximityPrompt") then d.HoldDuration=0; d.RequiresLineOfSight=false end end)
    end
    SetSt(St.ieOn and "Instant Interact ON" or "Instant Interact OFF")
end)
UI.ieFireBtn.MouseButton1Click:Connect(function()
    local radius=tonumber(UI.ieRInp.Text) or 60; local hrp=GH(); if not hrp then return end
    local fired=0
    for _,pp in pairs(workspace:GetDescendants()) do
        if pp:IsA("ProximityPrompt") then
            local pt=pp.Parent
            if pt and pt:IsA("BasePart") and (pt.Position-hrp.Position).Magnitude<=radius then
                pp.HoldDuration=0; pcall(function() fireproximityprompt(pp) end); fired=fired+1
            end
        end
    end
    SetSt("Fired "..fired.." prompts (r="..radius.."s)")
end)

UI.kaTog.MouseButton1Click:Connect(function() St.kaOn=T.getKA(); SetSt(St.kaOn and "Kill Aura ON" or "Kill Aura OFF") end)
local kaFrame=0
AF.killaura = function()
    if not St.kaOn then return end
    kaFrame=kaFrame+1; if kaFrame%3~=0 then return end
    local hrp=GH(); if not hrp then return end
    local radius=UI.kaRGet(); local count=0
    for _,p in pairs(Players:GetPlayers()) do
        if p==lp then continue end
        local c=p.Character; if not c then continue end
        local r=c:FindFirstChild("HumanoidRootPart"); if not r then continue end
        if (r.Position-hrp.Position).Magnitude<=radius then
            count=count+1
            local char=lp.Character; if not char then continue end
            local tool=char:FindFirstChildOfClass("Tool")
            if tool then local h=c:FindFirstChild("Humanoid"); if h then pcall(function() h:TakeDamage(10) end) end end
        end
    end
    UI.kaStatL.Text="Targets in radius: "..count
end

local function ResolvePath(path)
    if not path or path=="" then return nil end
    local parts=path:split("."); local root,si=RS,1
    if parts[1]=="WS" or parts[1]=="Workspace" then root=workspace; si=2
    elseif parts[1]=="RS" or parts[1]=="ReplicatedStorage" then si=2 end
    local cur=root
    for i=si,#parts do
        local pname=parts[i]; local found=cur:FindFirstChild(pname)
        if not found then for _,ch in pairs(cur:GetChildren()) do if ch.Name:lower()==pname:lower() then found=ch; break end end end
        if not found then return nil end; cur=found
    end
    return cur
end
local function ParseArgs(s)
    if not s or s=="" or s=="null" or s=="nil" then return {} end
    local ok,r=pcall(function() return HttpService:JSONDecode(s) end)
    if ok and type(r)=="table" then return r end; return {}
end

UI.rtFire.MouseButton1Click:Connect(function()
    local pth=UI.rtPathInp.Text; if pth=="" then UI.rtResL.Text="Masukkan path remote!"; return end
    local rem=ResolvePath(pth)
    if not rem then UI.rtResL.Text="Tidak ditemukan: "..pth; UI.rtResL.TextColor3=C.Red; return end
    local args=ParseArgs(UI.rtArgInp.Text)
    task.spawn(function()
        local ok,res=pcall(function() return rem:IsA("RemoteFunction") and rem:InvokeServer(table.unpack(args)) or (rem:IsA("RemoteEvent") and (rem:FireServer(table.unpack(args)) or "fired")) end)
        UI.rtResL.Text=(ok and "OK: " or "ERR: ")..tostring(res):sub(1,80); UI.rtResL.TextColor3=ok and C.Acc or C.Red
    end)
end)
UI.rtSpam.MouseButton1Click:Connect(function()
    local pth=UI.rtPathInp.Text; if pth=="" then return end
    local rem=ResolvePath(pth); if not rem then UI.rtResL.Text="Tidak ditemukan!"; return end
    local args=ParseArgs(UI.rtArgInp.Text); local success=0
    UI.rtResL.Text="Spamming x10..."; UI.rtResL.TextColor3=C.Yel
    task.spawn(function()
        for _=1,10 do
            local ok=pcall(function() if rem:IsA("RemoteFunction") then rem:InvokeServer(table.unpack(args)) else rem:FireServer(table.unpack(args)) end end)
            if ok then success=success+1 end; task.wait(0.06)
        end
        UI.rtResL.Text="Spam x10: "..success.."/10 OK"; UI.rtResL.TextColor3=C.Acc
    end)
end)

UI.akTog.MouseButton1Click:Connect(function()
    St.akOn=T.getAK()
    if St.akOn and not St.akHooked then
        St.akHooked=true
        local mt=getrawmetatable and getrawmetatable(game)
        if mt then
            local oldNC=mt.__namecall
            pcall(function()
                if setreadonly then setreadonly(mt,false) end
                mt.__namecall=newcclosure and newcclosure(function(self,...)
                    local method=getnamecallmethod and getnamecallmethod()
                    if method=="Kick" and self==lp then UI.akStatL.Text="Kick blocked!"; return end
                    return oldNC(self,...)
                end) or mt.__namecall
                if setreadonly then setreadonly(mt,true) end
            end)
        end
        UI.akStatL.Text="Anti-Kick: Hooked"; UI.akStatL.TextColor3=C.Grn; SetSt("Anti-Kick ON")
    elseif not St.akOn then
        UI.akStatL.Text="Anti-Kick: Inactive"; UI.akStatL.TextColor3=C.TxtD; SetSt("Anti-Kick OFF")
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- MAIN LOOPS
-- ═══════════════════════════════════════════════════════════════════════════
M:Add(RunService.Heartbeat:Connect(function(dt)
    for _,fn in pairs({AF.speed,AF.nofall,AF.godmode,AF.antivoid,AF.hitbox,AF.esp,AF.killaura}) do
        pcall(fn,dt)
    end
end))
M:Add(RunService.RenderStepped:Connect(function(dt)
    pcall(AF.fly); pcall(AF.freecam,dt); pcall(AF.aimbot); pcall(AF.tracers)
end))

-- ═══════════════════════════════════════════════════════════════════════════
-- WINDOW CONTROLS
-- ═══════════════════════════════════════════════════════════════════════════
local mini=false
BtnMin.MouseButton1Click:Connect(function()
    mini=not mini; BtnMin.Text=mini and "+" or "-"
    if mini then TabBar.Visible=false; PgArea.Visible=false; sBr.Visible=false; TW(Main,.22,{Size=UDim2n(0,W,0,54)})
    else TabBar.Visible=true; PgArea.Visible=true; sBr.Visible=true; TW(Main,.22,{Size=UDim2n(0,W,0,H)}) end
end)

BtnClose.MouseButton1Click:Connect(function()
    if St.godOn   then GodOff() end
    if St.flyOn   then ClrFly() end
    if St.fcOn    then StopFC() end
    if St.ghostOn then
        local c=lp.Character; if c then for _,v in pairs(c:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=true; v.Transparency=0 end end end
    end
    if St.hbxOn then
        for _,p in pairs(Players:GetPlayers()) do if p==lp then continue end; local c=p.Character; if not c then continue end
            local hrp=c:FindFirstChild("HumanoidRootPart"); if hrp then hrp.Size=V3(2,2,1) end end
    end
    if St.fbOn or St.nfogOn then Lighting.Ambient=St.origAmb; Lighting.Brightness=St.origBri; Lighting.OutdoorAmbient=St.origOut; Lighting.FogEnd=St.origFog; Lighting.FogStart=0 end
    if St.lgOn then workspace.Gravity=St.origGrav end
    local hrp=GH(); if hrp then hrp.AssemblyLinearVelocity=V3(0,0,0) end
    if scanHLBox then pcall(function() scanHLBox:Destroy() end) end
    for _,h in pairs(chamHighlights) do pcall(function() h:Destroy() end) end
    for _,d in pairs(tracerDrawings) do pcall(function() d:Remove() end) end
    SaveCfg()
    TW(Main,.2,{BackgroundTransparency=1,Size=UDim2n(0,W,0,8)})
    task.delay(.25,function() M:Destroy() end)
end)

M:Add(lp.CharacterAdded:Connect(function()
    task.wait(1.5)
    if St.godOn  then St.godOn=false; St.gReal=nil; St.gFake=nil; T.setGod(false) end
    if St.flyOn  then St.flyOn=false; T.setFly(false); ClrFly() end
    if St.fcOn   then StopFC(); T.setFC(false) end
    for p,_ in pairs(St.espAvas) do RmEspA(p) end
    for p,h in pairs(chamHighlights) do pcall(function() h:Destroy() end); chamHighlights[p]=nil end
    SetSt("Respawn detected — state auto-adjusted")
end))

-- Glow pulse
local glowT=0
M:Add(RunService.RenderStepped:Connect(function(dt)
    glowT=glowT+dt
    local pulse=0.1+math.abs(math.sin(glowT*1.8))*0.12
    if gBar and gBar.Parent then gBar.BackgroundTransparency=mclamp(0.22-pulse,0,0.95) end
end))

SetSt("CyRuz SSS Premium — Ready", C.Acc)
