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

function SWEP:VM()
    return self:GetOwner():GetViewModel()
end

function SWEP:GetAttackTables()
    local tables = { self.Primary, self.Secondary }
    if istable(self.AttackTables) then
        for _, data in ipairs(self.AttackTables) do
            table.insert(tables, data)
        end
    end

    return tables
end

function SWEP:GetOwnerSpeed(min, max)
    local ply = self:GetOwner()

    min = min or 0
    max = max or 0

    local vel = ply:GetVelocity()
    return math.Clamp(math.sqrt(vel:Length2DSqr()) / ply:GetRunSpeed(), min, max)
end