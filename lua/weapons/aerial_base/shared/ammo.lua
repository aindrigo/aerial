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

function SWEP:GetAttackMagazineCount(id)
    if id == "Primary" then
        return self:Clip1()
    elseif id == "Secondary" then
        return self:Clip2()
    end

    return self["Get"..id.."MagazineCount"](self)
end

function SWEP:SetAttackMagazineCount(id, value)
    if id == "Primary" then
        return self:SetClip1(value)
    elseif id == "Secondary" then
        return self:SetClip2(value)
    end

    return self["Set"..id.."MagazineCount"](self, value)
end
