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

function SWEP:AttackProjectile(id)
    local attackData = self:BuildAttackData(id)
    self:AttackProjectilePerform(id, attackData)
end

function SWEP:AttackProjectilePerform(id, attackData)
    if self:FireHook("AttackProjectilePerform", id, attackData) then return end

    local ply = attackData.Attacker
    local data = self:GetAttackTable(id)

    local magazineCount = self:GetAttackMagazineCount(id)
    attackData.Delay = attackData.Delay or data.Delay or 0.1

    local fireMode = self:GetAttackFireModeEnum(id)
    local nextAttack = CurTime() + attackData.Delay
    if fireMode == aerial.enums.FIRE_MODE_AUTOMATIC then
        self:SetCurrentAttackName(id)
        self:SetCurrentAttackTime(nextAttack)
    elseif fireMode == aerial.enums.FIRE_MODE_SEMIAUTOMATIC then
        self:SetNextAttack(nextAttack)
    end

    if magazineCount < 1 then
        if data.EmptyAnimation then
            self:PlayAnimation(data.EmptyAnimation)
            self:QueueIdle()
        end

        if data.EmptySound then
            self:EmitSound(data.EmptySound, SNDLVL_NORM)
        end

        return
    end
    
    self:SetAttackMagazineCount(id, magazineCount - 1)

    attackData.Delay = delay
    attackData.Damage = data.Damage
    attackData.Recoil = self:AttackCalculateRecoil(id, attackData)
    attackData.Traces = {}

    self:SetRecoil(attackData.Recoil)

    ply:LagCompensation(true)
    for i = 1, (data.ShotCount or 1) do
        local traceResult = self:AttackProjectileTrace(id, attackData, i)

        if traceResult.Hit and IsValid(traceResult.Entity) then
            self:AttackHitEntity(id, attackData, traceResult)
        end

        table.insert(attackData.Traces, traceResult)
    end
    ply:LagCompensation(false)

    self:AttackProjectileEffects(id, attackData)

    self.m_tLastAttacks = self.m_tLastAttacks or {}
    self.m_tLastAttacks[id] = attackData
end

function SWEP:AttackProjectileTrace(id, attackData, index)
    local hookResult = self:FireHook("AttackProjectileTrace", id, attackData, index)
    if istable(hookResult) then
        return hookResult
    end

    local ply = attackData.Attacker

    local data = self:GetAttackTable(id)
    local spread = self:AttackCalculateSpread(id, attackData, index)

    attackData.Spread = spread

    local direction = ply:GetAimVector()
    local angle = direction:Angle()

    angle:RotateAroundAxis(angle:Right(), spread.x)
    angle:RotateAroundAxis(angle:Up(), spread.z)
    
    direction = angle:Forward()

    local startPosition = ply:GetShootPos()
    local endPosition = startPosition + direction * (data.Distance or 8192)

    local traceData = {}
    traceData.start = startPosition
    traceData.endpos = endPosition
    traceData.filter = { self, ply }

    local traceResult = util.TraceLine(traceData)

    if CLIENT then
        debugoverlay.Line(traceData.start, traceResult.HitPos, 5, ColorRand(false), false)
    end

    return traceResult
end

function SWEP:AttackProjectileEffects(id, attackData)
    if self:FireHook("AttackProjectileEffects", id, attackData) then return end

    local data = self:GetAttackTable(id)

    local ply = attackData.Attacker
    ply:SetAnimation(PLAYER_ATTACK1)

    self:EmitSound(data.Sound, SNDLVL_GUNFIRE)

    local customRecoil = data.CustomRecoil or {}
    if (self:GetADS() and not data.ShootAnimationADS) or customRecoil.Always then
        if customRecoil.UseShootAnimation or customRecoil.Disabled then
            self:PlayAnimation(data.ShootAnimation or ACT_VM_PRIMARYATTACK)
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
        self:PlayAnimation(attackData.Animation or data.ShootAnimation or ACT_VM_PRIMARYATTACK)
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