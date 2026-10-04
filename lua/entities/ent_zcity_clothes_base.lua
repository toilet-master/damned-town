-- meow

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ent_zcity_equipment_base"
ENT.PrintName = "Equipment base"
ENT.Category = "ZCity Equipment"
ENT.Spawnable = false
ENT.Model = "models/props_junk/cardboard_box003a.mdl"
ENT.IconOverride = ""

ENT.SlotOccupation = {
    --[ZC_CLOTHES_SLOT_TORSO] = true,
    --[ZC_CLOTHES_SLOT_PANTS] = true,
    --[ZC_CLOTHES_SLOT_BOOTS] = true,
}

ENT.Male = {}
ENT.Male.Model = ""
ENT.Male.HideSubMaterails = {}
ENT.Male.Skin = 0
ENT.Male.Bodygroups = "0000000000000"

ENT.FeMale = {}
ENT.FeMale.Model = ""
ENT.FeMale.HideSubMaterails = {}
ENT.FeMale.Skin = 0
ENT.FeMale.Bodygroups = "0000000000000"

ENT.PhysicsSounds = true

ENT.NamePos = Vector(12,1.5,4.6)
ENT.NameAng = Angle(0,-90,0)

--\\ Render Equipment
    local vec = Vector(1,1,1)
    function ENT:RenderOnBody(entDrawOn)
        local fem = ThatPlyIsFemale(entDrawOn)

        if !IsValid(self.renderModel) then
            local data = fem and self.FeMale or self.Male
            self.renderModel = ClientsideModel(data.Model, RENDERGROUP_BOTH)

            local model = self.renderModel
            model:SetNoDraw(true)
            model:SetSkin(data.Skin)
            model:SetBodyGroups(data.Bodygroups)
            model:SetParent(entDrawOn)
            model:AddEffects(EF_BONEMERGE)

            if data.ModelSubMaterials then
                for k,v in pairs(data.ModelSubMaterials) do
                    local id = isnumber(k) and k or model:GetSubMaterialIdByName(k)
                    if !id then continue end
                    model:SetSubMaterial(id, v)
                end
            end

            self:CallOnRemove("RemoveEquip",function()
                if IsValid(self.renderModel) then
                    model:Remove()
                    model = nil
                end
            end)
        end

        local model = self.renderModel

        local mdl = string.Split(string.sub(entDrawOn:GetModel(),1,-5),"/")[#string.Split(string.sub(entDrawOn:GetModel(),1,-5),"/")]
        if mdl and model:GetFlexIDByName(mdl) then
            model:SetFlexWeight(model:GetFlexIDByName(mdl),1)
        end

        if model:GetParent() != entDrawOn then model:SetParent(entDrawOn) end

        model:DrawModel()
    end
--//

--\\ Temperature system
    hook.Add("ZC_BodyTemperature", "EquipmentSaveTemp", function(ply, org, timeValue, changeRate, MaxWarmMul, warmLoseMul)
        local Equipment = ply:GetNetVar("zc_equipment", {})
        if #Equipment < 1 then return end

        for i = 1, #Equipment do
            local Equip = Entity(Equipment[i])
            if !IsValid(Equip) then continue end
            if !Equip.WarmSave then continue end
            MaxWarmMul = MaxWarmMul + (Equip.WarmSave / 1.5)
            changeRate = changeRate * math.max(1 - Equip.WarmSave, 0.1)
            --warmLoseMul = warmLoseMul * math.max(1 - Equip.WarmSave / 2.5, 0.1)
        end

        return changeRate, MaxWarmMul, warmLoseMul
    end)
--//

--\\ Clothes drop command
    if SERVER then
        concommand.Add("hg_drop_clothes", function(ply, cmd, args)
            if !IsValid(ply) then return end
            if !ply:Alive() or !ply.organism or ply.organism.otrub then return end
            if !args[1] or !tonumber(args[1]) then return end
            local Clothes = ply:GetNetVar("zc_clothes", {})

            for i = 1, #Clothes do
                local Cloth = Entity(Clothes[i])

                for slot, _ in pairs(Cloth.SlotOccupation) do
                    if isnumber(slot) and tonumber(args[1]) == slot then
                        Cloth:Unwear(ply)
                        return
                    end
                end
            end
        end)
    end

    hook.Add("radialOptions", "zc_clothes", function()
        local ply = LocalPlayer()
        local organism = ply.organism or {}

        if ply:Alive() and !organism.otrub and hg.GetCurrentCharacter(ply) == ply and ply:KeyDown(IN_WALK) then
            local Clothes = ply:GetNetVar("zc_clothes", {})
            if !Clothes or #Clothes < 1 then return end
            local tbl = {function()
                local commands = {}
                for i = 1, #Clothes do
                    local Cloth = Entity(Clothes[i])

                    for slot, _ in pairs(Cloth.SlotOccupation) do
                        commands[i] = {
                            [1] = function()
                                local id = next(Cloth.SlotOccupation)
                                RunConsoleCommand("hg_drop_clothes", id)
                                return 0
                            end,
                            [2] = "Drop:" .. " " .. Cloth.PrintName
                        }
                    end
                end
                hg.CreateRadialMenu(commands)
                return -1
            end, "Drop clothes"}
            hg.radialOptions[#hg.radialOptions + 1] = tbl
        end
    end)
--//