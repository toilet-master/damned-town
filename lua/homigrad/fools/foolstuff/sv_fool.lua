local PLUGIN = hg.Fools

util.AddNetworkString("hg_kotikheadshot")
PLUGIN.AddHook("HomigradDamage",function(ply,dmg,hitgroup)
    if (dmg:IsDamageType(DMG_BULLET) or dmg:IsDamageType(DMG_BUCKSHOT)) and (IsValid(dmg:GetAttacker()) and dmg:GetAttacker():IsPlayer() and dmg:GetAttacker() ~= ply and hitgroup == HITGROUP_HEAD) then
        --print(dmg:GetAttacker():Name())
        net.Start("hg_kotikheadshot")
        net.Send(dmg:GetAttacker())
    end
end)
local function onragcollide(ragdoll,data)
    local hitEntity = data.HitEntity
    if hitEntity and hitEntity:IsWorld() then
        local owner = hg.RagdollOwner(ragdoll)
        if not owner then return end
        owner:PrintMessage(HUD_PRINTTALK, "Your atoms matched with the ground")
        ragdoll:SetNotSolid(true)
        local bones = ragdoll:GetPhysicsObjectCount()
         for i = 1, bones - 1 do
            local phys = ragdoll:GetPhysicsObjectNum(i)
            if phys then
                phys:EnableCollisions(false)
            end
        end
    end
end
PLUGIN.AddHook("Fake", function(ply, ragdoll)
    if math.random(1,15) == 15 then
        ragdoll:AddCallback("PhysicsCollide",onragcollide)
    end
end)
local function GetRandomNavMeshPos(centerPos, radius)
    local areas = navmesh.Find(centerPos, radius, 100, 100)
    if #areas == 0 then return nil end
    local randomArea = areas[math.random(#areas)]
    return randomArea:GetCenter()
end

local check = CurTime() + 100
local chance = 25
local nextbot = nil
local hasnavmesh = true
local mdl = "models/Humans/Group03m/male_06.mdl"
local function spawnbot(pos)
    if IsValid(nextbot) then return end
    nextbot = ents.Create("nb_example")
    nextbot:SetPos(pos)
    nextbot:Spawn()
    nextbot:SetModel(mdl)
end
PLUGIN.AddHook("Think", function()
    if not hasnavmesh then return end
    if IsValid(nextbot) then return end
    if CurTime() < check then return end
    if math.random(1, 100) <= chance then
        for i, ply in RandomPairs(player.GetAll()) do
            local spawnPos = GetRandomNavMeshPos(ply:GetPos(), 1000)
            if not spawnPos then hasnavmesh = false return end
            spawnbot(spawnPos)
            nextbot:SetModel(mdl)
        end
    end
end)
PLUGIN.AddHook("OnNPCKilled", function(npc)
    if npc == nextbot then
        nextbot = nil
        check = CurTime() + 100
    end
end)
PLUGIN.AddHook("PlayerSpawn",function(ply)
    timer.Simple(0.1, function()
    local Appearance = ply:GetNetVar("Accessories",{"none"})
	if istable(Appearance) then
		Appearance[1] = "dunce"
	else
		Appearance = "dunce"
	end
	ply:SetNetVar("Accessories", Appearance)
    end)
end)
local dsounds = {
    "die4.wav",
    "die2.wav",
    "Wilhelm_Scream.mp3"
}
PLUGIN.AddHook("PlayerDeath",function(ply,inf,att)
    if IsValid(ply.FakeRagdoll) then
        if ply:LastHitGroup() == HITGROUP_HEAD then return end
        timer.Simple(0.1,function()
            if ply.RagdollDeath.organism.spine3 >= 0.8 then return end
            if ply.RagdollDeath.organism.headamputated then return end
            local sndp = dsounds[math.random(#dsounds)]
            ply.RagdollDeath:EmitSound("fools/"..sndp)
        end)
    end
end)
--[[PLUGIN.AddHook("PlayerUse",function(ply,ent)
    if not IsValid(ent) and not hg.KeyDown(ply, IN_WALK) then
        local realply = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
        if IsValid(realply) then
            realply:EmitSound("fools/use.wav")
        end
    end
end)]]
