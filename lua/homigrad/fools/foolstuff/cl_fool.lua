
local PLUGIN = hg.Fools
local kills = {}
local lifetime = 2
local fadetime = 1
local mint,maxt = 60, 320
local rtime = CurTime() + math.random(mint,maxt)
local mat = Material("vgui/icons/kill_fools.png", "smooth NOCULL")
local function createkill()
    local tbl = {
        time = CurTime(),
        alpha = 255
    }
    table.insert(kills,tbl)
    if #kills > 6 then
        table.remove(kills,1)
    end
    
end
local imgs = {
    "opposinghorse.jpg",
    "calflife.jpg",
    "bluesheep.jpg",
    "jackjcharleshimself.png",
    "cat.jpg"
}
local panels = {}
local fevents = {
    ["bloat"] = function()
        local x,y = ScrW()/2, ScrH()/2
        local function createshi()
            if not table.IsEmpty(panels) then
                for i,v in pairs(panels) do
                    if ispanel(v) then
                        v:Remove()
                    end
                end
            end
            local pan = vgui.Create("DFrame")
            local key = #panels+1
            panels[key] = frame
            pan:Center()
            pan:SetSize(300,300)
            pan:MakePopup()
            pan:SetTitle("")
            pan:SetDraggable(false)
            local xrand,yrand = math.random(-125,125),math.random(-125,125)
            pan:SetPos(x+xrand,y+yrand)
            local img = Material(tostring("vgui/fools/"..imgs[math.random(#imgs)]))
            pan.Paint = function(self, w, h)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(img)
                surface.DrawTexturedRect(0, 0, w, h)
            end
            pan:SetKeyBoardInputEnabled(true)
            pan:SetMouseInputEnabled(true)
            pan.OnRemove = function()
                panels[key] = nil
            end
        end
        
        createshi()
        timer.Create("HORSEHALFLIFE",0.5,math.random(4,9),createshi)
    end,
}
PLUGIN.AddHook("Think",function()
    if rtime < CurTime() then
        if not LocalPlayer():Alive() then return end
        rtime = CurTime() + math.random(mint,maxt)
        table.Random(fevents)()
    end
end)

PLUGIN.AddHook("HUDPaint", function()
    if not IsValid(LocalPlayer()) or not LocalPlayer():Alive() then return end
    local x = ScrW() - 180  
    local width, height = UnitHud(128*1.5), UnitHud(128*1.5) 
    local th = (#kills * height) + ((#kills - 1) * 10)
    local y = (ScrH() / 2) - (th / 2)
    if not table.IsEmpty(kills) then
    for i = #kills, 1, -1 do
        local notif = kills[i]
        local time = CurTime() - notif.time
        if time > lifetime then
            local fade = (time - lifetime) / fadetime
            notif.alpha = math.Clamp(255 * (1 - fade), 0, 255)
        end
        if notif.alpha == 0 then
            table.remove(kills, i)
            continue 
        end
        surface.SetMaterial( mat )
        surface.SetDrawColor( 255, 255, 255, notif.alpha )
        local current = y + ((i - 1) * (height + 10))
        surface.DrawTexturedRect(x, current, width, height)
    end
    end
end)

--timer.Simple(10,createkill)
net.Receive("hg_kotikheadshot",createkill)