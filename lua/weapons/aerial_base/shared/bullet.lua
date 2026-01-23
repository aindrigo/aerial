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

function SWEP:AttackBullet(id)
    if self:FireHook("AttackBullet", id) then return end
    local data = self:GetAttackTable(id)

    self:AttackBulletPreEffects(id)

    if not isnumber(data.StartDelay) or data.StartDelay <= 0 then
        local attackData = self:BuildAttackData(id)
        self:AttackBulletPerform(id, attackData)
        return
    end

    local ct = CurTime()
    self:SetCurrentAttackTime(ct + data.StartDelay)
    self:SetCurrentAttackName(id)
end

function SWEP:AttackBulletPerform(id, attackData)
    if self:FireHook("AttackBulletPerform", id, attackData) then return end

    local ply = attackData.Attacker
    local data = self:GetAttackTable(id)

    local magazineCount = self:GetAttackMagazineCount(id)
    attackData.Delay = attackData.Delay or data.Delay or 0.1
    
    local fireMode = self:GetAttackFireModeEnum(id)
    local chargeData = data.Charge

    local attackTime = CurTime()
    attackTime = attackTime + attackData.Delay

    local key = self:GetAttackKey(data)
    local keyDown = ply:KeyDown(key)

    if not istable(chargeData) or chargeData.Enabled == false then
        if fireMode == aerial.enums.FIRE_MODE_AUTOMATIC and keyDown then
            self:SetCurrentAttackName(id)
            self:SetCurrentAttackTime(attackTime)
        elseif fireMode == aerial.enums.FIRE_MODE_SEMIAUTOMATIC then
            self:SetNextAttack(id, attackTime)
        end
    else
        if fireMode == aerial.enums.FIRE_MODE_AUTOMATIC and keyDown then
            self:SetCurrentAttackName(id)
            self:SetCurrentAttackTime(attackTime)
        elseif fireMode == aerial.enums.FIRE_MODE_SEMIAUTOMATIC then
            self:SetCurrentAttackName("")
            self:SetCurrentAttackTime(0)
        end
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
    
    self:AttackTakeAmmo(id, 1)
   
    attackData.Delay = delay
    attackData.Damage = data.Damage
    attackData.DamageType = attackData.DamageType or data.DamageType or DMG_BULLET
    attackData.Recoil = self:AttackCalculateRecoil(id, attackData)
    attackData.Traces = {}

    self:SetRecoil(attackData.Recoil)

    ply:LagCompensation(true)
    for i = 1, (data.ShotCount or 1) do
        local traceResult = self:AttackBulletTrace(id, attackData, i)

        if traceResult.Hit and IsValid(traceResult.Entity) then
            self:AttackHitEntity(id, attackData, traceResult)
        end

        table.insert(attackData.Traces, traceResult)
    end
    ply:LagCompensation(false)

    self:AttackBulletEffects(id, attackData)

    self.m_tLastAttacks = self.m_tLastAttacks or {}
    self.m_tLastAttacks[id] = attackData
end

function SWEP:AttackBulletTrace(id, attackData, index)
    local hookResult = self:FireHook("AttackBulletTrace", id, attackData, index)
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

function SWEP:AttackBulletPreEffects(id)
    if self:FireHook("AttackBulletPreEffects", id, attackData) then return end

    local data = self:GetAttackTable(id)
    if isstring(data.StartSound) then
        self:EmitSound(data.StartSound)
    end
end

function SWEP:AttackBulletEffects(id, attackData)
    if self:FireHook("AttackBulletEffects", id, attackData) then return end

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
            local force = customRecoil.Force or attackData.Damage / 6
            local yaw = attackData.Recoil.x * 0.2
            
            if isnumber(customRecoil.YawMultiplier) then
                yaw = yaw * customRecoil.YawMultiplier
            end

            local pitch = -force

            self:SetCustomRecoilMode(aerial.enums.CUSTOM_RECOIL_MODE_KICKBACK)
            self:SetCustomRecoilTargetPosition(Vector(pitch, 0, 0))
            self:SetCustomRecoilTargetAngles(Angle(pitch, yaw, 0))
        end
    else
        self:PlayAnimation(attackData.Animation or data.ShootAnimation or ACT_VM_PRIMARYATTACK)
        self:QueueIdle()
    end


    for _, traceResult in ipairs(attackData.Traces) do
        if not traceResult.Hit or not (game.SinglePlayer() or IsFirstTimePredicted()) then continue end
        local impactEffect = EffectData()
        impactEffect:SetOrigin(traceResult.HitPos)
        impactEffect:SetStart(traceResult.StartPos)
        impactEffect:SetSurfaceProp(traceResult.SurfaceProps)
        impactEffect:SetEntity(traceResult.Entity)
        impactEffect:SetHitBox(traceResult.HitBoxBone or 0)
        impactEffect:SetDamageType(attackData.DamageType)

        util.Effect("Impact", impactEffect, true, false)
    end

    self:AttackEffectMuzzleFlash(id, attackData)
    self:AttackEffectRecoil(id, attackData)
end