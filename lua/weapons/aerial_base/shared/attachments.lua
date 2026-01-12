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

function SWEP:HasAttachment(name)
    local id = self:EntIndex()
    if not istable(self.Attachments) or not istable(self.Attachments[name]) or not istable(aerial.Attachments.Data[id]) then
        return false
    end

    return istable(aerial.Attachments.Data[id][name])
end

function SWEP:AttachmentExists(name)
    return istable(self.Attachments) and istable(self.Attachments[name])
end

function SWEP:_AddAttachment(name)
    local id = self:EntIndex()
    aerial.Attachments.Data[id] = aerial.Attachments.Data[id] or {}
    aerial.Attachments.Data[id][name] = {}
end

function SWEP:_RemoveAttachment(name)
    local id = self:EntIndex()
    aerial.Attachments.Data[id] = aerial.Attachments.Data[id] or {}

    local data = aerial.Attachments.Data[id][name]
    aerial.Attachments.Data[id][name] = nil

    return data
end