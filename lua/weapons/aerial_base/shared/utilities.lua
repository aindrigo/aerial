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

function SWEP:VM(index)
    return self:GetOwner():GetViewModel(index)
end

function SWEP:GetAttackTables()
    local tables = { ["Primary"] = self.Primary, ["Secondary"] = self.Secondary }
    if istable(self.AttackTables) then
        for id, data in pairs(self.AttackTables) do
            tables[id] = data
        end
    end

    return tables
end

function SWEP:GetAttackTable(id)
    if id == "Primary" then return self.Primary end
    if id == "Secondary" then return self.Secondary end

    return self.AttackTables[id]
end

function SWEP:GetAttackKey(idOrData)
    local data = idOrData
    if isstring(idOrData) then
        data = self:GetAttackTable(idOrData)
    end

    local key = data.Key
    if isnumber(key) then return key end

    if data.ID == "Primary" then
        return IN_ATTACK
    elseif data.ID == "Secondary" then
        return IN_ATTACK2
    end
end

function SWEP:GetLastAttackTable()
    return self:GetAttackTable(self:GetLastAttackName())
end

function SWEP:GetOwnerSpeed(min, max)
    local ply = self:GetOwner()

    min = min or 0
    max = max or 1

    local vel = ply:GetVelocity()
    return math.Clamp(vel:Length2D() / ply:GetRunSpeed(), min, max)
end

function SWEP:_GetSpreadModifier(spreadData)
    local ply = self:GetOwner()
    local mod = 1
    if isnumber(spreadData.ADSMod) and self:GetADS() then
        mod = mod * spreadData.ADSMod
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

    return mod
end