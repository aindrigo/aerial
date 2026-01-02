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

function SWEP:CanReload()
    local canReloadHook = self:FireHook("CanReload")
    if canReloadHook == false then return false end

    local ct = CurTime()

    for _, data in ipairs(self:GetAttackTables()) do
        local nextFire = self:GetNextAttack(data)
        if nextFire >= ct then
            return false
        end
    end

    local reloadTime = self:GetReloadTime()
    return ct > reloadTime
end

function SWEP:Reload()
    if not self:CanReload() then
        return
    end

    self:FireHook("Reload")
end