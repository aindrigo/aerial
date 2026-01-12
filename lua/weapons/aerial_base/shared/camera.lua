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

function SWEP:CalculateFOV()
    local hookResult = self:FireHook("CalculateFOV")

    local mod = 1
    if hookResult ~= nil then
        mod = mod * hookResult
    end

    if istable(self.ADS) and isnumber(self.ADS.FOV) and self:GetADS() then
        mod = mod * self.ADS.FOV
    end

    return mod
end

function SWEP:TranslateFOV(fov)
    local multiplier = self:CalculateFOV()
    self.m_fFOVMultiplier = Lerp(FrameTime() * 8, self.m_fFOVMultiplier or multiplier, multiplier)

    return fov * self.m_fFOVMultiplier
end