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

function SWEP:CanADS()
    if istable(self.ADS) and self.ADS.Enabled == false then
        return false
    end

    local ct = CurTime()
    return not self:GetReloading() and ct >= self:GetReloadTime()
end

function SWEP:OnADSChange(state)
    if self:FireHook("OnADSChange", state) == false then return end
    self:SetADS(state)

    local ply = self:GetOwner()

    if CLIENT and (IsFirstTimePredicted() or game.SinglePlayer()) then
        ply:EmitSound(state and "Aerial.ADSIn" or "Aerial.ADSOut")
    end
end
