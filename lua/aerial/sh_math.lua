aerial.math = aerial.math or {}

--- Converts RPM to interval
--- @param rpm number
--- @return number Interval
function aerial.math.RPM(rpm)
    return 60 / rpm
end

--- Interpolates a value between two points
--- @param frac number between 0 and 1
--- @param p1 number Point 1
--- @param p2 number Point 2
function aerial.math.Lerp(frac, p1, p2)
    assert(type(p1) == type(p2), "type mismatch for p1 and p2")
    local minDist = 0.001
    local minDistSqr = 0.000001
    local minDistTri = 0.003

    if isvector(p1) then
        local dist = (p1 - p2):LengthSqr()
        if math.abs(dist) <= minDistSqr then
            return p2
        end

        return LerpVector(frac, p1, p2)
    elseif isangle(p1) then
        local dist = (p1 - p2)
        dist = dist.x + dist.y + dist.z
        -- idk

        if math.abs(dist) <= minDistTri then
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
        error("unsupported type" .. type(p1))
    end
end

--- Rounds number to the nearest multiple of another number
--- @param x number Number to round
--- @param y number Multiple
--- @return number
function aerial.math.RoundToMultiple(x, y)
    if math.fmod(x, y) == 0 then return x end

    return x + y - 1 - math.fmod(x + y - 1, y)
end


--- DeNANs a value, making it zero if NAN
--- @param x number|Vector|Angle
--- @return number|Vector|Angle x or 0 if nan
function aerial.math.DeNAN(x)
    --- @diagnostic disable
    if isvector(x) then
        x.x = aerial.math.DeNAN(x.x)
        x.y = aerial.math.DeNAN(x.y)
        x.z = aerial.math.DeNAN(x.z)
        return x
    elseif isangle(x) then
        x.p = aerial.math.DeNAN(x.p)
        x.y = aerial.math.DeNAN(x.y)
        x.r = aerial.math.DeNAN(x.r)
        return x
    end
    --- @diagnostic enable

    if x ~= x then return 0 end
    return x
end
