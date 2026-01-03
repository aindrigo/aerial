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

function SWEP:GetNextAttack(data)
    local func = self["GetNext" .. data.ID .. "Fire"]
    return func(self)
end

function SWEP:SetNextAttack(data, value)
    local func = self["SetNext" .. data.ID .. "Fire"]
    return func(self, value)
end

function SWEP:PrimaryAttack()
    if self.Primary.Ammo == "none" then
        return
    end

    self:Attack(self.Primary)
end

function SWEP:SecondaryAttack()
    if self.Secondary.Ammo == "none" then
        return
    end

    self:Attack(self.Secondary)
end

function SWEP:CanAttack(data)
    if self:FireHook("CanAttack", data) == false then return false end

    local ct = CurTime()

    local nextFire = self:GetNextAttack(data)
    return ct > nextFire and ct > self:GetReloadTime()
end

function SWEP:Attack(data)
    if not self:CanAttack(data) then return end
    if self:FireHook("Attack", data) then return end

    local ply = self:GetOwner()
    local delay = data.Delay or 0.1
    self:SetNextAttack(data, CurTime() + delay)

    local attackData = {}
    attackData.Attacker = ply
    attackData.Delay = delay
    attackData.Recoil = self:AttackCalculateRecoil(data, attackData)
    attackData.Traces = {}

    for i = 1, (data.ShotCount or 1) do
        local traceResult = self:AttackTrace(data, attackData, i)

        if traceResult.Hit and IsValid(traceResult.Entity) then
            self:AttackHitEntity(data, attackData, traceResult)
        end

        table.insert(attackData.Traces, traceResult)
    end

    self:AttackEffects(data, attackData)
end

function SWEP:AttackHitEntity(data, attackData, traceResult)
    if self:FireHook("AttackHitEntity", data, attackData) then return end

    local dmgInfo = DamageInfo()
    dmgInfo:SetDamage(data.Damage)
    dmgInfo:SetAttacker(attackData.Attacker)
    dmgInfo:SetInflictor(self)
    dmgInfo:SetWeapon(self)

    dmgInfo:SetDamageType(data.DamageType or DMG_BULLET)
    dmgInfo:SetDamagePosition(traceResult.HitPos)
    dmgInfo:SetDamageForce(traceResult.Normal * (data.Force or 1))

    traceResult.Entity:DispatchTraceAttack(dmgInfo, traceResult)
end

function SWEP:AttackCalculateRecoil(data, attackData)
    local hookResult = self:FireHook("AttackCalculateRecoil", data, ply)
    if isvector(hookResult) then
        return hookResult
    end

    local ply = attackData.Attacker
    local recoilData = data.Recoil or {}

    local min = recoilData.Min or 0
    local max = recoilData.Max or 1

    local x = util.SharedRandom("ARRX"..ply:SteamID(), recoilData.MinX or min, recoilData.MaxX or max)
    local z = util.SharedRandom("ARRZ"..ply:SteamID(), recoilData.MinZ or min, recoilData.MaxZ or max)

    return Vector(x, 0, z)
end

function SWEP:AttackCalculateSpread(data, attackData, index)
    local hookResult = self:FireHook("AttackCalculateSpread", data, attackData, index)
    if isvector(hookResult) then
        return hookResult
    end

    local ply = attackData.Attacker
    local spreadData = data.Spread or {}

    local cone = Vector(spreadData.Cone, 0, spreadData.Cone)
    cone = cone * attackData.Recoil * (spreadData.RecoilMod or 1)

    local mod = 1
    if isnumber(spreadData.IronsightsMod) and self:GetIronsights() then
        mod = mod * spreadData.IronsightsMod
    end

    if isnumber(spreadData.CrouchMod) and ply:Crouching() then
        mod = mod * spreadData.CrouchMod
    end

    if isnumber(spreadData.AirMod) and not ply:IsOnGround() then
        mod = mod * spreadData.AirMod
    end

    if isnumber(spreadData.VelocityMod) then
        mod = mod + (self:GetOwnerSpeed() * spreadData.VelocityMod)
    end

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

function SWEP:AttackTrace(data, attackData, index)
    local ply = attackData.Attacker
    local hookResult = self:FireHook("AttackTrace", data, attackData, index)
    if istable(hookResult) then
        return hookResult
    end

    local spread = self:AttackCalculateSpread(data, attackData, index)

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