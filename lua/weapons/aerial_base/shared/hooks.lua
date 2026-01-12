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

function SWEP:FireHook(name, ...)
    local attachments = aerial.Attachments.Data[self:EntIndex()]
    if istable(attachments) then
        for attachmentName, _ in pairs(attachments) do
            local attachment = self.Attachments[attachmentName]
            if not istable(attachments) or not istable(attachments.Hooks) then continue end

            local func = attachments.Hooks[name]
            if not isfunction(func) then continue end

            local result = func(self, ...)
            if result ~= nil then
                return result
            end
        end
    end

    if not istable(self.Hooks) then return end

    local hookFunction = self.Hooks[name]
    if not isfunction(hookFunction) then return end

    return hookFunction(self, ...)
end