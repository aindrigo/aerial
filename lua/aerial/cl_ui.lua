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

aerial.ui = aerial.ui or {}


--- Draws a line. Similar to surface.DrawLine but with thickness
-- @number xStart X start position
-- @number yStart X end position
-- @number xEnd Y start position
-- @number yEnd Y end position
-- @number[opt=1] thickness Thickness value
function aerial.ui.DrawLine(xStart, yStart, xEnd, yEnd, thickness)
    thickness = thickness or 1

    if xEnd < xStart then
        local originalXStart = xStart
        xStart = xEnd
        xEnd = originalXStart
    end

    if yEnd < yStart then
        local originalYStart = yStart
        yStart = yEnd
        yEnd = originalYStart
    end

    local halfThickness = thickness / 2

    local v0 = { x = xStart - halfThickness, y = yStart - halfThickness }
    local v1 = { x = xEnd + halfThickness, y = yStart - halfThickness }
    local v2 = { x = xEnd + halfThickness, y = yEnd + halfThickness }
    local v3 = { x = xStart - halfThickness, y = yEnd + halfThickness }

    surface.DrawPoly({ v0, v1, v2, v3 })
end