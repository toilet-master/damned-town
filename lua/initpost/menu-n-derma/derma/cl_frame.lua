--

----
local PANEL = {}
hg.hudcolor = hg.hudcolor or {}
--[[
hg.VGUI.SecondaryColor = Color(155,0,0,240)
hg.VGUI.BackgroundColor = Color(25,25,35,220)]]
local color_blacky = Color(25,25,30,220)

function PANEL:Init()
    self.Itensens = {}
    self:SetAlpha( 0 )
    self:SetTitle( "" )

    self.DrawBorder = true
    local chcl = hg.hudcolor:colorchange()
    local hmm = Color(
    chcl.r - 125,
	chcl.g - 125,
	chcl.b - 125, 200)
    self.ColorBG = Color(hmm:Unpack())
    self.ColorBR = Color(hg.hudcolor:colorchange():Unpack())
    self.BlurStrengh = 2

    timer.Simple(0,function()
        if self.First then
            self:First()
        end
    end)
end
local conv = ConVarExists("hg_bars") and GetConVar("hg_bars") or CreateClientConVar("hg_bars", "0", true, false, "Toggle bars in hud", 0, 1)
function PANEL:Paint(w,h)
    draw.RoundedBox(0,0,0,w,h,self.ColorBG)
    hg.DrawBlur(self, self.BlurStrengh)

    if self.DrawBorder then
        surface.SetDrawColor(self.ColorBR)
        surface.DrawOutlinedRect(0,0,w,h,1.5)
    end
    surface.SetDrawColor(107, 107, 107,20)
    if conv:GetBool() == true then
        for i = 1, (ybars + 1) do
            surface.DrawRect((sw / ybars) * i - (CurTime() * 10 % (sw / ybars)), 0, ScreenScale(0.5), sh)
        end

        for i = 1, (xbars + 1) do
            surface.DrawRect(0, (sh / xbars) * (i - 1) + (CurTime() * 10 % (sh / xbars)), sw, ScreenScale(0.5))
        end
    end
end

function PANEL:SetBorder( bDraw )
    self.DrawBorder = bDraw
end

function PANEL:SetColorBG( cColor )
    self.ColorBG = cColor
end

function PANEL:SetColorBR( cColor )
    self.ColorBR = cColor
end

function PANEL:SetBlurStrengh( floatVal )
    self.BlurStrengh = floatVal
end

function PANEL:First( ply )
    self:SetY(self:GetY() + self:GetTall())
    self:MoveTo(self:GetX(), self:GetY() - self:GetTall(), 0.4, 0, 0.2, function() end)
    self:AlphaTo( 255, 0.2, 0.1, nil )

    if self.PostInit then
        self:PostInit()
    end
end

function PANEL:Close()
    if self.Closing then return end
    self.Closing = true
    self:MoveTo(self:GetX(), ScrH() / 2 + self:GetTall(), 5, 0, 0.3, function()
    end)
    self:AlphaTo( 0, 0.2, 0, function() 
        if self.OnClose then self:OnClose() end 
        self:Remove() 
    end)
    self:SetKeyboardInputEnabled(false)
    self:SetMouseInputEnabled(false)
end

vgui.Register( "ZFrame", PANEL, "DFrame")

