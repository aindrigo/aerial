local flashes = {
    "muzzleflash_1",
    "muzzleflash_3",
    "muzzleflash_4",
    "muzzleflash_5",
    "muzzleflash_6"
}

function SWEP:AttackEffectMuzzleFlash(id, attackData)
    if self:FireHook("AttackEffectMuzzleFlash", id, attackData) then return end
    if (game.SinglePlayer() or IsFirstTimePredicted()) then
        local data = self:GetAttackTable(id)
        local vm = self:VM()

        local ply = attackData.Attacker
        local muzzle = vm:LookupAttachment(
            data.MuzzleAttachment or self.MuzzleAttachment or "muzzle"
        )

        local flashEffect

        if isstring(data.MuzzleFlash) then
            flashEffect = data.MuzzleFlash
        elseif istable(data.MuzzleFlash) then
            flashEffect = data.MuzzleFlash[math.random(#data.MuzzleFlash)]
        else
            flashEffect = flashes[math.random(#flashes)]
        end

        ParticleEffectAttach(
            flashEffect,
            PATTACH_POINT_FOLLOW,
            vm,
            muzzle
        )

        if CLIENT then
            local light = DynamicLight(vm:EntIndex())
            if not light then return aerial.dprint("Dynamic light creation failed") end

            local color = data.MuzzleFlashColor or Color(201, 165, 112)

            light.pos = ply:GetShootPos()
            light.r = color.r
            light.g = color.g
            light.b = color.b
            light.brightness = 4
            light.decay = 4000
            light.dietime = CurTime() + 1
            light.size = 256
        end
    end 
end

function SWEP:AttackEffectRecoil(id, attackData)
    if self:FireHook("AttackEffectRecoil", id, attackData) then return end

    local data = self:GetAttackTable(id)
    local ply = attackData.Attacker

    -- View punch
    local recoil = attackData.Recoil
    local recoilData = data.Recoil or {}

    local xPunch = recoilData.PunchX or 0.15
    local zPunch = recoilData.PunchZ or 0.07

    local punch = Angle(
        util.SharedRandom("ARVPP", -recoil.z * zPunch, recoil.z * zPunch),
        util.SharedRandom("ARVPY", 0, -recoil.x * xPunch),
        0
    )

    ply:ViewPunch(punch)
    if IsFirstTimePredicted() or game.SinglePlayer() then
        ply:SetEyeAngles(ply:EyeAngles() + punch * 0.4)
    end
end