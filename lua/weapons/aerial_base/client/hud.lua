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

function SWEP:DrawAttachmentHUD(name, data)
    local attachment = self.Attachments[name]
    if not istable(attachment) then return end

    if istable(attachment.Cosmetic) and istable(attachment.Cosmetic.View) then
        local vm = self:VM()
        local cosmeticData = attachment.Cosmetic.View
        local model = data.m_eCSModelVM

        if IsValid(model) and istable(cosmeticData.RenderTarget) then
            self:VMDrawRenderTarget(name, data, vm, model, cosmeticData.RenderTarget)
        end
    end
end

function SWEP:DrawHUD()
    local attachments = aerial.Attachments.Data[self:EntIndex()]
    if istable(attachments) then
        for name, data in pairs(attachments) do
            self:DrawAttachmentHUD(name, data)
        end
    end
end