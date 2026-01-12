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

function SWEP:GiveAttachment(name, network)
    self:FireHook("GiveAttachment", name, network)

    if not istable(self.Attachments) or not istable(self.Attachments[name]) then
        error("Invalid attachment "..name)
        return
    end

    self:_AddAttachment(name)

    if network ~= false then
        net.Start("aerial.AddAttachment")
        net.WriteUInt(self:EntIndex(), 16)
        net.WriteString(name)
        net.Broadcast()
    end
end

function SWEP:TakeAttachment(name, network)
    self:FireHook("GiveAttachment", name, network)
    if not istable(self.Attachments) or not istable(self.Attachments[name]) then
        error("Invalid attachment "..name)
        return
    end

    self:_RemoveAttachment(name)
    if network ~= false then
        net.Start("aerial.RemoveAttachment")
        net.WriteUInt(self:EntIndex(), 16)
        net.WriteString(name)
        net.Broadcast()
    end
end