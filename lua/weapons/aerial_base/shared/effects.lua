--[[
    Aerial, a weapon base designed to ease the creation of realistic weapons within Garry's Mod.
    Copyright (C) 2026  aindrigo

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]--

function SWEP:AttackEffects(id, attackData)
    if self:FireHook("AttackEffects", id, attackData) then return end

    local data = self:GetAttackTable(id)

    local ply = attackData.Attacker
    ply:SetAnimation(PLAYER_ATTACK1)

    self:EmitSound(data.Sound, SNDLVL_GUNFIRE)

    local customRecoil = data.CustomRecoil or {}
    if (self:GetADS() and not data.ShootAnimationADS) or customRecoil.Always then
        if customRecoil.UseShootAnimation or customRecoil.Disabled then
            self:PlayAnimation(data.ShootAnimation)
            self:QueueIdle()
        end

        if not customRecoil.Disabled then
            self:SetCustomRecoilMode(aerial.enums.CUSTOM_RECOIL_MODE_KICKBACK)

            local force = customRecoil.Force or attackData.Damage / 6
            local yaw = util.SharedRandom("ARCRY", (customRecoil.MinYaw or -2), (customRecoil.MaxYaw or 2))

            self:SetCustomRecoilTargetPosition(Vector(-force, 0, 0))
            self:SetCustomRecoilTargetAngles(Angle(-force, 0, 0))
        end
    else
        self:PlayAnimation(data.ShootAnimation)
        self:QueueIdle()
    end


    for _, traceResult in ipairs(attackData.Traces) do
        -- Bullet hole
        if not traceResult.Hit or not (game.SinglePlayer() or IsFirstTimePredicted()) then continue end
        local impactEffect = EffectData()
        impactEffect:SetOrigin(traceResult.HitPos)
        impactEffect:SetStart(traceResult.StartPos)
        impactEffect:SetSurfaceProp(traceResult.SurfaceProps)
        impactEffect:SetEntity(traceResult.Entity)
        impactEffect:SetHitBox(traceResult.HitBoxBone or 0)
        impactEffect:SetDamageType(DMG_BULLET)

        util.Effect("Impact", impactEffect, true, false)
    end

    self:AttackEffectMuzzleFlash(id, attackData)
    self:AttackEffectRecoil(id, attackData)
end

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