
local PLUGIN = hg.Fools
local kills = {}
local lifetime = 2
local fadetime = 1
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
PLUGIN.AddHook("HUDPaint", function()
    if not IsValid(LocalPlayer()) or not LocalPlayer():Alive() then return end
    local x = ScrW() - 180  
    local width, height = UnitHud(128*1.5), UnitHud(128*1.5) 
    local th = (#kills * height) + ((#kills - 1) * 10)
    local y = (ScrH() / 2) - (th / 2)
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
end)
--timer.Simple(10,createkill)
net.Receive("hg_kotikheadshot",createkill)