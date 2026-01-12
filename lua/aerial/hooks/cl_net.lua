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

net.Receive("aerial.SyncAttachments", function()
    local weaponCount = net.ReadUInt(16)
    for _ = 1, weaponCount do
        local index = net.ReadUInt(16)
        local weapon = Entity(index)
        if not IsValid(weapon) or not weapon:IsWeapon() or not weapon.Aerial then return end

        if istable(aerial.Attachments.Data[index]) then
            for name, _ in pairs(aerial.Attachments.Data[index]) do
                weapon:TakeAttachment(name)
            end
        end

        aerial.Attachments.Data[index] = {}
        local attachmentCount = net.ReadUInt(8)

        for _ = 1, attachmentCount do
            local id = net.ReadString()
            weapon:GiveAttachment(id)
        end
    end
end)

net.Receive("aerial.AddAttachment", function()
    local index = net.ReadUInt(16)
    local weapon = Entity(index)
    if not IsValid(weapon) or not weapon:IsWeapon() or not weapon.Aerial then return end

    weapon:GiveAttachment(net.ReadString())
end)

net.Receive("aerial.RemoveAttachment", function()
    local index = net.ReadUInt(16)
    local weapon = Entity(index)
    if not IsValid(weapon) or not weapon:IsWeapon() or not weapon.Aerial then return end

    weapon:TakeAttachment(net.ReadString())
end)