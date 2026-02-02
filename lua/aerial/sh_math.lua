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

--- Rounds number to the nearest multiple of another number
-- @realm shared
-- @number x Number to round
-- @number y Multiple
-- @treturn number Result
function aerial.math.RoundToMultiple(x, y)
    if math.fmod(x, y) == 0 then return x end

    return x + y - 1 - math.fmod(x + y - 1, y)
end