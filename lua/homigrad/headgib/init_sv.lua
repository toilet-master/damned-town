local net, hg, pairs, Vector, ents, IsValid, util = net, hg, pairs, Vector, ents, IsValid, util

local vecZero = Vector(0,0,0)
local vecInf = Vector(0,0,0) / 0

local function removeBone(rag, bone, phys_bone, nohuys)
	if !nohuys then rag:ManipulateBoneScale(bone, vecZero) end
	--rag:ManipulateBonePosition(bone,vecInf) -- Thanks Rama (only works on certain graphics cards!)

	if rag.gibRemove[phys_bone] then return end

	local phys_obj = rag:GetPhysicsObjectNum(phys_bone)
	phys_obj:EnableCollisions(false)
	phys_obj:SetMass(0.1)
	--rag:RemoveInternalConstraint(phys_bone)

	constraint.RemoveAll(phys_obj)
	rag.gibRemove[phys_bone] = phys_obj
end

local function recursive_bone(rag, bone, list)
	for i,bone in pairs(rag:GetChildBones(bone)) do
		if bone == 0 then continue end

		list[#list + 1] = bone

		recursive_bone(rag, bone, list)
	end
end

function Gib_RemoveBone(rag, bone, phys_bone, nohuys)
	rag.gibRemove = rag.gibRemove or {}

	removeBone(rag, bone, phys_bone, nohuys)

	local list = {}
	recursive_bone(rag, bone, list)
	for i, bone in pairs(list) do
		removeBone(rag, bone, rag:TranslateBoneToPhysBone(bone), nohuys)
	end
end

gib_ragdols = gib_ragdols or {}
local gib_ragdols = gib_ragdols

local VectorRand, ents_Create = VectorRand, ents.Create
local vector_up = Vector(0,0,1)
local function PhysCallback( ent, data )
	if data.DeltaTime < 0.2 then return end
	ent:EmitSound("physics/flesh/flesh_squishy_impact_hard"..math.random(4)..".wav")
	--print(ent:GetName()) mm cool thing to use for physics shit thank you meister грустный салат
	util.Decal("Normal.Blood24", data.HitPos - data.HitNormal * 1, data.HitPos + data.HitNormal * 1, ent)
end

local gamemod = engine.ActiveGamemode()
local gibRemoveTime = 60 --120
function SpawnMeatGore(mainent, pos, count, force, scale, models)
	force = force or Vector(0,0,0)
	if models then
		for i,v in pairs (models) do
			local ent = ents_Create("prop_physics")
			ent:SetModel(v)
			ent:SetPos(pos)
			ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			ent:SetAngles(AngleRand(-90,90))
			ent:Activate()
			ent:Spawn()
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(mainent:GetVelocity() + VectorRand(-65,65) + force / 10)
				phys:AddAngleVelocity(VectorRand(-65,65))

			end
			if zb.CROUND and zb.CROUND ~= "hmcd" or gamemod == "sandbox" then
				ent:DrawShadow(false)
				SafeRemoveEntityDelayed(ent, gibRemoveTime)
			end
			ent:AddCallback( "PhysicsCollide", PhysCallback )
		end
	else --shit code maybe?!? Idfk
		for i=1, (count or math.random(8, 10)) do
			local ent = ents_Create("prop_physics")
			ent:SetModel("models/mosi/fnv/props/gore/meatbit0"..math.random(1,3)..".mdl")
			ent:SetPos(pos)
			ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			ent:Activate()
			ent:Spawn()
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(mainent:GetVelocity() + VectorRand(-65,65) + force / 10)
				phys:AddAngleVelocity(VectorRand(-65,65))
			end
			if zb.CROUND and zb.CROUND ~= "hmcd" or gamemod == "sandbox" then
				ent:DrawShadow(false)
				ent:SetModelScale(0, gibRemoveTime)
				SafeRemoveEntityDelayed(ent, gibRemoveTime)
			end
			ent:AddCallback( "PhysicsCollide", PhysCallback )
		end
	end
end

local headpos_male, headpos_female, headang = Vector(0,0,5), Vector(-2,0,4), Angle(0,0,-0)

util.AddNetworkString("addfountain")

hg.fountains = hg.fountains or {}
local headboom_mdl = Model("models/gleb/zcity/headboom.mdl")
local sounds = {
	Sound("player/zombie_head_explode_01.wav"),
	Sound("player/zombie_head_explode_02.wav"),
	Sound("player/zombie_head_explode_03.wav"),
	Sound("player/zombie_head_explode_04.wav"),
	Sound("player/zombie_head_explode_05.wav"),
	Sound("player/zombie_head_explode_06.wav")
}
util.PrecacheModel(headboom_mdl)
for _, snd in ipairs(sounds) do
	util.PrecacheSound(snd)
end
local boomboom = {
	"models/mosi/fnv/props/gore/gorehead02.mdl",
	"models/mosi/fnv/props/gore/gorehead03.mdl",
	"models/mosi/fnv/props/gore/gorehead04.mdl",
	"models/mosi/fnv/props/gore/gorehead05.mdl",
	"models/mosi/fnv/props/gore/gorehead06.mdl"
}
function Gib_Input(rag, bone, force)
	if not IsValid(rag) then return end
	
	local gibRemove = rag.gibRemove

	if not gibRemove then
		rag.gibRemove = {}
		gibRemove = rag.gibRemove

		gib_ragdols[rag] = true
	end

	local phys_bone = rag:TranslateBoneToPhysBone(bone)
	local phys_obj = rag:GetPhysicsObjectNum(phys_bone)
	
	if (not gibRemove[phys_bone]) and (bone == rag:LookupBone("ValveBiped.Bip01_Head1")) then
		--sound.Emit(rag,"player/headshot" .. math.random(1, 2) .. ".wav")
		--sound.Emit(rag,"physics/flesh/flesh_squishy_impact_hard" .. math.random(2, 4) .. ".wav")
		--sound.Emit(rag,"physics/body/body_medium_break3.wav")
		--sound.Emit(rag,"physics/glass/glass_sheet_step" .. math.random(1,4) .. ".wav", 90, 50, 2)
		rag:EmitSound(sounds[math.random(#sounds)], 70, math.random(95, 105), 2)

		Gib_RemoveBone(rag, bone, phys_bone)
		
		--rag:ManipulateBoneScale(rag:LookupBone("ValveBiped.Bip01_Neck1"),vecZero)
		rag:ManipulateBonePosition(rag:LookupBone("ValveBiped.Bip01_Neck1"),Vector(-1,0,0))

		local ent = ents_Create("prop_dynamic")
		ent:SetModel(headboom_mdl)
		local att = rag:GetAttachment(3)
		local pos, ang = LocalToWorld(ThatPlyIsFemale(rag) and headpos_female or headpos_male, headang, att.Pos, att.Ang)
		ent:SetPos(pos)
		ent:SetAngles(ang)
		--ent:AddEffects(EF_FOLLOWBONE)
		ent:SetParent(rag, 3)--rag:LookupBone("ValveBiped.Bip01_Head1"))
		ent:Spawn()

		SpawnMeatGore(ent, pos, nil, force, 1, boomboom) --модельки поменять и будет эпик. Поменял братан

		local armors = rag:GetNetVar("Armor",{})

		if armors["head"] and !hg.armor["head"][armors["head"]].nodrop then
			local ent = hg.DropArmorForce(rag, armors["head"])
			ent:SetPos(phys_obj:GetPos())
		end
		
		if armors["face"] and !hg.armor["face"][armors["face"]].nodrop then
			local ent = hg.DropArmorForce(rag, armors["face"])
			ent:SetPos(phys_obj:GetPos())
		end

		rag.noHead = true
		rag:SetNWString("PlayerName", "Beheaded body")

		net.Start("addfountain")
		net.WriteEntity(rag)
		net.WriteVector(force or vector_origin)
		net.Broadcast()

		hg.fountains[rag] = {bone = rag:LookupBone("ValveBiped.Bip01_Neck1"), lpos = ThatPlyIsFemale(rag) and Vector(4,0,0) or Vector(5,0,0),lang = Angle(0,0,0)}

		rag:CallOnRemove("removefountain", function()
			hg.fountains[rag] = nil
			SetNetVar("fountains", hg.fountains)
		end)

		SetNetVar("fountains", hg.fountains)
	end
end
