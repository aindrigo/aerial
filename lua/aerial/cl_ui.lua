aerial.ui = aerial.ui or {}

surface.CreateFont("aerial24", {
    font = "Roboto",
    size = 24,
    weight = 300,
    antialias = true
})

surface.CreateFont("aerial32", {
    font = "Roboto",
    size = 32,
    weight = 300,
    antialias = true
})

surface.CreateFont("aerial48", {
    font = "Roboto",
    size = 48,
    weight = 300,
    antialias = true
})
--- Draws a line. Similar to surface.DrawLine but with thickness
-- @realm client
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