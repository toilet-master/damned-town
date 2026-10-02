if not hg then return end
hg.hudcolor = hg.hudcolor or {}
local hudcl = hg.hudcolor:colorchange()
local font = "HomigradFontMedium"
local tex_gradient_r = Material("vgui/gradient-r")
local tex_gradient_l = Material("vgui/gradient-l")
local tex_gradient_d = Material("vgui/gradient-d")

local modetypes = {
    ["soe"] = { 
        Name = "States Of Emergency",
        Color = Color(10,0,155),
        colorb = Color(255,0,0),
        spawnfunc = function (pp)
        end,
    },
    ["std"] = { 
        Name = "Standard",
        Color = Color(10,0,155),
        colorb = Color(0,255,20),
        spawnfunc = function (pp)
        end,
    },
    ["gunner"] = { 
        Name = "Gunman/SOE",
        Color = Color(10,0,155),
        colorb = Color(235,0,255),
        spawnfunc = function (pp)
        end,
    },
}
local modetbl = {
    ["hmcd"] = { 
        Name = "Homicide",
        Color = Color(10,0,155),
        colorb = Color(0,132,255),
        spawnfunc = function (pp)
            if ValidPanel(pp.SubMenu) then pp.SubMenu:Remove() end
            local subc = vgui.Create("DPanel", pp)
            local scrw, scrh = ScrW(), ScrH()
            subc:Dock(FILL)
            subc:DockMargin(scrw/80, scrh/16, 0, 0)
            subc:SetPaintBackground(false)
            pp.SubMenu = subc
            local chosentype = modetypes["std"]
            local newscroll = vgui.Create("DHorizontalScroller", subc)
            newscroll:Dock(TOP)
            newscroll:SetHeight(scrh/16)
            newscroll:SetOverlap(-10)
            newscroll:SetSkin(hg.GetMainSkin())
            chosentype.spawnfunc(subc)
            for i,v in pairs(modetypes) do
                local btn = vgui.Create("DButton")
                btn:SetText(v.Name)
                btn:SetFont(font)
                btn:SetSize(scrw/8,scrh/16)
                newscroll:AddPanel(btn)
                btn.Paint = function (self, w, h)
                    draw.RoundedBox(0, 0, 0, w, h, v.Color or Color(255,0,0) )
                    draw.RoundedBox(0, 0, 25, w, h/2, v.colorb or Color(255,0,0) )
                    surface.SetDrawColor(Color(0,0,0,255))
                    surface.DrawOutlinedRect(0,0,w,h,4)
                end
                btn.DoClick = function ()
                    chosentype = modetypes[i] 
                    chosentype.spawnfunc(subc)
                    print(chosentype.Name)
                end
                
            end
            local cont = vgui.Create("DPanel", subc)
            --cont.Paint

        end,
    },
    ["cresp"] = { 
        Name = "Crisis Response", 
        Color = Color(155,0,0),
        colorb = Color(54,0,155),
        bgimg = Material("criresp/backgrnd.png"),
        bgcolor = Color(235,12,12),

        spawnfunc = function(pp)
            if ValidPanel(pp.SubMenu) then pp.SubMenu:Remove() end
            menumusicrn("sound/criresps/cri_mainmenu.mp3")
        end,
    },
}
function hg.DrawLoadoutMenu(pp)
    pp:SetAlpha(0)
    local chosen2 = nil
    local hscroll = vgui.Create("DScrollPanel", pp)
    local hscroll_height = pp:GetTall() - 50
    local scrw, scrh = ScrW(), ScrH()
    hscroll:SetWidth(scrw/8)
    hscroll:Dock(LEFT)
    hscroll:DockMargin(scrw/65, scrh/20, 0, scrh/20)
    hscroll:SetSkin(hg.GetMainSkin())
    for i,v in pairs(modetbl) do
        local btn = vgui.Create("DButton", hscroll)
        btn:SetText(v.Name)
        btn:SetFont(font)
        btn:Dock(TOP)
        btn:SetSize(scrw/2,scrh/16)
        btn:DockMargin(0, 10, 20, 0)
        btn.Paint = function (self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, v.Color or Color(255,0,0) )
            draw.RoundedBox(0, 0, 25, w, h/2, v.colorb or Color(255,0,0) )
            surface.SetDrawColor(Color(0,0,0,255))
            surface.DrawOutlinedRect(0,0,w,h,4)
        end
        btn.DoClick = function ()
            local chosengm = modetbl[i]
            chosengm.spawnfunc(pp)
            chosen2 = chosengm
            print(chosengm.Name)
        end
    end
    local chosengm = modetbl["hmcd"]
    chosengm.spawnfunc(pp)
    pp.Paint = function(self, w, h)
        if hg.DrawBlur then
            hg.DrawBlur(self, 5)
        end
        local clr1 = Color(hudcl.r,hudcl.g,hudcl.b,180)
        local clr2 = Color(hudcl.r,hudcl.g,hudcl.b,110)
        surface.DrawTexturedRect(0, 0, w, h)
        surface.SetDrawColor(chosen2 and chosen2.bgimg and Color(255,255,255) or clr1)
        surface.SetMaterial(chosen2 and chosen2.bgimg or tex_gradient_l)
        surface.DrawTexturedRect(0, 0, w, h)
        surface.SetDrawColor(chosen2 and chosen2.bgcolor or clr2)
        surface.SetMaterial(tex_gradient_d)
        surface.DrawTexturedRect(0, 0, w/5, h)
    end
    pp:AlphaTo(65, 0.5, 0)
end