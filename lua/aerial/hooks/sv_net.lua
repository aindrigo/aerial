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

util.AddNetworkString("aerial.SyncAttachments")
util.AddNetworkString("aerial.AddAttachment")
util.AddNetworkString("aerial.RemoivAttachment")

net.Receive("aerial.SyncAttachments", function(_, ply)
    local ct = CurTime()
    ply.m_fNextAerialSync = ply.m_fNextAerialSync or 0

    if ply.m_fNextAerialSync > ct then return end
    ply.m_fNextAerialSync = ct + 180

    net.WriteUInt(#aerial.Attachments.Data, 16)
    for index, attachments in pairs(aerial.Attachments.Data) do
        net.WriteUInt(index, 16)
        net.WriteUInt(#attachments, 8)
        for _, name in ipairs(attachments) do
            net.WriteString(name)
        end
    end
end)