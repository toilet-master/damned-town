hg.Fools = hg.Fools or {}
hg.Fools.Hooks = hg.Fools.Hooks or {}
hg.Fools.Active = false

local PLUGIN = hg.Fools

CreateConVar("zb_fools", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Toggle dumbass", 0, 1)

if SERVER then
    cvars.AddChangeCallback("zb_fools", function(name, old, new)
        PLUGIN.UpdateStatus()

        net.Start("UpdateFoolsStatus")
        net.Broadcast()
    end)

    util.AddNetworkString("UpdateFoolsStatus")
else
    net.Receive("UpdateFoolsStatus", function()
        PLUGIN.UpdateStatus()
    end)
end

hook.Add("InitPostEntity", "Zb_Foolsha", function()
    PLUGIN.UpdateStatus()
end)

function PLUGIN.UpdateStatus()
    local value = GetConVar("zb_fools"):GetBool()

    if value then
        PLUGIN.InitHooks()
        hg.Fools.Active = true
    else
        PLUGIN.DeInitHooks()
        hg.Fools.Active = false
    end
end

function PLUGIN.InitHooks()
    for k, v in pairs(PLUGIN.Hooks) do
        hook.Add(k, "FOOLS HOOK " .. k, v)
    end
end

function PLUGIN.DeInitHooks()
    for k, _ in pairs(PLUGIN.Hooks) do
        hook.Remove(k, "FOOLS HOOK " .. k)
    end
end

function PLUGIN.AddHook(name, func)
    PLUGIN.Hooks[name] = func
end

function PLUGIN.RemoveHook(name)
    hook.Remove(name, "FOOLS HOOK " .. name)
end