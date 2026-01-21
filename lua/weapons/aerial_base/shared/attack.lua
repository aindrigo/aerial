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

function SWEP:GetNextAttack(id)
    local func = self["GetNext"..id.."Fire"]
    return func(self)
end

function SWEP:SetNextAttack(id, value)
    local func = self["SetNext"..id.."Fire"]
    return func(self, value)
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:CanAttack(id)
    if self:FireHook("CanAttack", id) == false then return false end

    local ct = CurTime()
    return ct >= self:GetNextAttack(id) and ct >= self:GetReloadTime() and ct >= self:GetFireModeTime()
end

function SWEP:Attack(id)
    if self:FireHook("Attack", id) or not self:CanAttack(id) then return end

    local data = self:GetAttackTable(id)
    local ply = self:GetOwner()

    local magazineCount = self:GetAttackMagazineCount(id)
    local delay = data.Delay or 0.1

    self:SetNextAttack(id, CurTime() + delay)
    self:SetLastAttackName(id)

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

    local attackData = {}
    attackData.Attacker = ply
    attackData.Delay = delay
    attackData.Damage = data.Damage
    attackData.Recoil = self:AttackCalculateRecoil(id, attackData)
    attackData.Traces = {}


    self:SetRecoil(attackData.Recoil)
    for i = 1, (data.ShotCount or 1) do
        local traceResult = self:AttackTrace(id, attackData, i)

        if traceResult.Hit and IsValid(traceResult.Entity) then
            self:AttackHitEntity(id, attackData, traceResult)
        end

        table.insert(attackData.Traces, traceResult)
    end

    self:AttackEffects(id, attackData)

    self.m_tLastAttacks = self.m_tLastAttacks or {}
    self.m_tLastAttacks[id] = attackData
end

function SWEP:AttackHitEntity(id, attackData, traceResult)
    if self:FireHook("AttackHitEntity", id, attackData) then return end

    local data = self:GetAttackTable(id)
    local dmgInfo = DamageInfo()
    dmgInfo:SetDamage(attackData.Damage)
    dmgInfo:SetAttacker(attackData.Attacker)
    dmgInfo:SetInflictor(self)
    dmgInfo:SetWeapon(self)

    dmgInfo:SetDamageType(data.DamageType or DMG_BULLET)
    dmgInfo:SetDamagePosition(traceResult.HitPos)
    dmgInfo:SetDamageForce(traceResult.Normal * (data.Force or 1))

    traceResult.Entity:DispatchTraceAttack(dmgInfo, traceResult)
end

function SWEP:AttackCalculateRecoil(id, attackData)
    local hookResult = self:FireHook("AttackCalculateRecoil", id, ply)
    if isvector(hookResult) then
        return hookResult
    end

    local data = self:GetAttackTable(id)

    local ply = attackData.Attacker
    local recoilData = data.Recoil or {}
    local globalRecoilData = self.Recoil or {}

    local compensation = 1 / (globalRecoilData.Compensation or 1)

    local min = recoilData.Min or 0
    local max = recoilData.Max or 1

    local x = util.SharedRandom("ARRX"..ply:SteamID(), recoilData.MinX or min, recoilData.MaxX or max)
    local z = util.SharedRandom("ARRZ"..ply:SteamID(), recoilData.MinZ or min, recoilData.MaxZ or max)

    local currentRecoil = self:GetRecoil() * compensation
    return currentRecoil + Vector(x, 0, z)
end

function SWEP:AttackCalculateSpread(id, attackData, index)
    local hookResult = self:FireHook("AttackCalculateSpread", id, attackData, index)
    if isvector(hookResult) then
        return hookResult
    end

    local data = self:GetAttackTable(id)

    local ply = attackData.Attacker
    local spreadData = data.Spread or {}

    local cone = Vector(spreadData.Cone, 0, spreadData.Cone)
    cone = cone * attackData.Recoil * (spreadData.RecoilMod or 1)

    local mod = self:_GetSpreadModifier(spreadData)
    cone:Mul(mod)
    cone = cone / 2

    local min = spreadData.Min or -math.huge
    local max = spreadData.Max or math.huge

    return Vector(
        math.Clamp(util.SharedRandom("ARSX"..tostring(index)..ply:SteamID(), -cone.x, cone.x), spreadData.MinX or min, spreadData.MaxX or max),
        0,
        math.Clamp(util.SharedRandom("ARSZ"..tostring(index)..ply:SteamID(), -cone.z, cone.z), spreadData.MinZ or min, spreadData.MaxZ or max)
    )
end

function SWEP:AttackTrace(id, attackData, index)
    local hookResult = self:FireHook("AttackTrace", id, attackData, index)
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

    ply:LagCompensation(true)
    local traceResult = util.TraceLine(traceData)
    ply:LagCompensation(false)

    if CLIENT then
        debugoverlay.Line(traceData.start, traceResult.HitPos, 5, ColorRand(false), false)
    end

    return traceResult
end