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
AccessorFunc(ENT, "m_iProjectileHealth", "ProjectileHealth", FORCE_NUMBER)
AccessorFunc(ENT, "m_fProjectileTime", "ProjectileTime", FORCE_NUMBER)
AccessorFunc(ENT, "m_bExecuted", "Executed", FORCE_BOOL)

function ENT:Initialize()
    local projectileData = self:GetProjectileData()
    assert(istable(projectileData))

    local attackData = self:GetAttackData()
    assert(istable(attackData))

    local trace = {}
    trace.start = attackData.Position
    trace.endpos = trace.start + attackData.Direction * (projectileData.InitialDistance or 50)
    trace.filter = attackData.Attacker

    local traceResult = util.TraceLine(trace)

    -- Transform
    local position = traceResult.HitPos
    local angles = attackData.Direction:Angle()

    if istable(projectileData.ThrowOffset) then
        if isvector(projectileData.ThrowOffset.Position) then
            position = position + projectileData.ThrowOffset.Position
        end

        if isangle(projectileData.ThrowOffset.Angles) then
            angles = angles + projectileData.ThrowOffset.Angles
        end
    end

    self:SetPos(position)
    self:SetAngles(angles)

    -- Other
    self:SetModel(projectileData.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    self:SetExecuted(false)

    if istable(projectileData.Health) then
        self:SetProjectileHealth(projectileData.Health.Maximum or 100)
    else
        self:SetProjectileHealth(0)
    end

    if isnumber(projectileData.Time) then
        self:SetProjectileTime(CurTime() + projectileData.Time)
    else
        self:SetProjectileTime(0)
    end

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:ApplyForceCenter(attackData.Force * phys:GetMass())
    end
end

function ENT:PhysicsCollide(collisionData, collider)
    if self:GetExecuted() then return end
    local projectileData = self:GetProjectileData()

    if projectileData.CollideSound then
        self:EmitSound(projectileData.CollideSound)
    end

    local time = self:GetProjectileTime()
    if istable(projectileData.Health) then
        local health = self:GetProjectileHealth()
        local penalty = (collisionData.Speed / 20) * (projectileData.Health.CollidePenalty or 1)
        health = math.max(health - penalty, 0)

        self:SetProjectileHealth(health)

        if health < 1 then
            self:ExecuteProjectile()
            return
        end
    end


    if self:GetProjectileTime() > 0 then
        local ct = CurTime()
        local newTime = ct + (projectileData.Time or 5)
        local maxTime = projectileData.MaxTime or 0

        self:SetProjectileTime(math.min(maxTime, newTime))
    end

end

function ENT:Think()
    if self:GetExecuted() then return end

    local time = self:GetProjectileTime()
    if time < 1 then return end

    if CurTime() > ct then
        self:SetProjectileTime(0)
        self:ExecuteProjectile()
    end
end

function ENT:ExecuteProjectile()
    local projectileData = self:GetProjectileData()
    if isfunction(projectileData.Execute) then
        projectileData.Execute(self)
    end

    self:SetExecuted(true)
end