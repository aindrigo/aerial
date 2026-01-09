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

function SWEP:AddAttachment(name)
    if not istable(self.Attachments) or not istable(self.Attachments[id]) then
        error("Invalid attachment "..name)
        return
    end

    local id = self:EntIndex()

    aerial.Attachments.Data[id] = aerial.Attachments.Data[id] or {}
    table.insert(aerial.Attachments.Data[id], name)

    net.Start("aerial.AddAttachment")
    net.WriteUInt(self:EntIndex(), 32)
    net.WriteString(name)
    net.Broadcast()
end

function SWEP:RemoveAttachment(name)
    if not istable(self.Attachments) or not istable(self.Attachments[id]) then
        error("Invalid attachment "..name)
        return
    end

    local id = self:EntIndex()
    local attachmentIndex

    for i, attachmentName in ipairs(aerial.Attachments.Data[id] or {}) do
        if attachmentName == name then
            attachmentIndex = i
        end
    end

    if attachmentIndex == nil then return end
    table.remove(aerial.Attachments.Data[id], attachmentIndex)
end