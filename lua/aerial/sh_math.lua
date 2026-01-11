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

aerial.math = aerial.math or {}

--- Converts RPM to interval
-- @realm shared
-- @number rpm Rate per minute value
-- @treturn number Interval
function aerial.math.RPM(rpm)
    return 60 / rpm
end

--- Interpolates a value between two points
-- @realm shared
-- @number frac Fraction, between 0 and 1
-- @any p1 Point 1
-- @any p2 Point 2
function aerial.math.Lerp(frac, p1, p2)
    assert(type(p1) == type(p2), "Type mismatch for p1 and p2")
    local minDist = 0.001

    if isvector(p1) then
        local dist = (p1 - p2):LengthSqr()
        if math.abs(dist) <= minDist ^ 2 then
            return p2
        end

        return LerpVector(frac, p1, p2)
    elseif isangle(p1) then
        local dist = (p1 - p2)
        dist = dist.x + dist.y + dist.z
        -- idk

        if math.abs(dist) <= minDist * 3 then
            return p2
        end

        return LerpAngle(frac, p1, p2)
    elseif isnumber(p1) then
        local dist = p1 - p2
        if math.abs(dist) < minDist then
            return p2
        end

        return Lerp(frac, p1, p2)
    else
        error("Unsupported type")
    end
end