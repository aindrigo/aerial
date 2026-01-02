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

AddCSLuaFile("base.lua")
include("base.lua")

for _, fileName in ipairs(file.Find("weapons/aerial_base/shared/*.lua", "LUA")) do
    local filePath = "shared/"..fileName
    AddCSLuaFile(filePath)
    include(filePath)
end

if SERVER then
    for _, fileName in ipairs(file.Find("weapons/aerial_base/server/*.lua", "LUA")) do
        local filePath = "server/"..fileName
        AddCSLuaFile(filePath)
        include(filePath)
    end
end

for _, fileName in ipairs(file.Find("weapons/aerial_base/client/*.lua", "LUA")) do
    local filePath = "client/"..fileName
    AddCSLuaFile(filePath)
    if CLIENT then
        include(filePath)
    end
end
