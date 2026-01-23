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


AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

AccessorFunc(ENT, "m_tAttackData", "AttackData")
AccessorFunc(ENT, "m_tProjectileData", "ProjectileData")
AccessorFunc(ENT, "m_iProjectileType", "ProjectileType", FORCE_NUMBER)
AccessorFunc(ENT, "m_iProjectileHealth", "ProjectileHealth", FORCE_NUMBER)
AccessorFunc(ENT, "m_fProjectileTime", "ProjectileTime", FORCE_NUMBER)

function ENT:Initialize()
    local projectileData = self:GetProjectileData()
    assert(istable(projectileData))

    local attackData = self:GetAttackData()
    assert(istable(attackData))

    -- Position
    local trace = {}
    trace.start = attackData.Position
    trace.endpos = trace.start + attackData.Direction * (projectileData.InitialDistance or 50)
    trace.filter = attackData.Attacker

    local traceResult = util.TraceLine(trace)
    self:SetPos(traceResult.HitPos)

    -- Angles
    local angles = attackData.Direction:Angle()
    if isangle(projectileData.AnglesOffset) then
        angles = angles + projectileData.AnglesOffset
    end

    self:SetAngles(angles)

    -- Other
    self:SetModel(projectileData.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local projectileType = projectileData.Type or aerial.enums.PROJECTILE_TYPE_COLLISION
    self:SetProjectileType(projectileType)

    if projectileType == aerial.enums.PROJECTILE_TYPE_COLLISION then
        self:SetProjectileHealth(projectileData.Health or 100)
    elseif projectileType == aerial.enums.PROJECTILE_TYPE_TIMER then
        self:SetProjectileTime(CurTime() + projectileData.Time)
    end

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:ApplyForceCenter(attackData.Force * phys:GetMass())
    end
end

function ENT:PhysicsCollide(collisionData, collider)
    if self:GetProjectileType() ~= aerial.enums.PROJECTILE_TYPE_COLLISION then return end
    local projectileData = self:GetProjectileData()

    local health = self:GetProjectileHealth()
    if health < 1 then return end

    local penalty = (collisionData.Speed / 20) * (projectileData.HitPenalty or 1)
    health = math.max(health - penalty, 0)
    self:SetProjectileHealth(health)

    if health < 1 then
        self:ExecuteProjectile()
    end
end

function ENT:Think()
    if self:GetProjectileType() ~= aerial.enums.PROJECTILE_TYPE_TIMER then return end

    local time = self:GetProjectileTime()
    if time < 1 then return end

    if CurTime() > ct then
        self:SetProjectileTime(0)
        self:ExecuteProjectile()
    end
end

function ENT:FireHook(name, ...)
    local projectileData = self:GetProjectileData()
    if not istable(projectileData.Hooks) then return end

    local func = projectileData.Hooks[name]
    if not isfunction(func) then return end

    return func(self, name, ...)
end

function ENT:ExecuteProjectile()
    self:FireHook("ExecuteProjectile")
end