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

hook.Add("PlayerButtonDown", "aerialButtonDown", function(ply, button)
    local code = ply:GetInfoNum("aerial_bind_firemode", 0)
    if code < 1 or button ~= code then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or not wep:IsWeapon() or not wep.Aerial then return end

    wep:ToggleFireMode()
end)

hook.Add("EntityRemoved", "aerialEntityRemoved", function(ent, fullUpdate)
    if not ent:IsWeapon() or not ent.Aerial or (CLIENT and fullUpdate) then return end

    local index = ent:EntIndex()
    aerial.Attachments.Data[index] = nil
end)