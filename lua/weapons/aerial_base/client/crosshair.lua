function SWEP:GetCrosshairAlpha()
    if self:GetReloading() or self:GetADS() then return 0 end

    return aerial.console.crosshair.colorAlpha:GetInt()
end

function SWEP:GetCrosshairGap(static)
    local attackData = self:GetLastAttackTable()
    local spreadData = attackData.Spread or {}

    local base = spreadData.Cone or 0.2
    if not static then
        base = base * self:_GetSpreadModifier(spreadData)
    end

    base = base - aerial.console.crosshair.gapAdditive:GetFloat()
    base = math.max(base, aerial.console.crosshair.gapMinimum:GetFloat())

    return base * aerial.console.crosshair.gap:GetFloat()
end

function SWEP:DoDrawCrosshair(x, y)
    local ft = FrameTime()
    local length = aerial.console.crosshair.length:GetFloat()
    local thickness = aerial.console.crosshair.thickness:GetFloat()

    local outline = aerial.console.crosshair.outline:GetFloat()

    local gapTarget = self:GetCrosshairGap(aerial.console.crosshair.static:GetBool())
    local gap = aerial.math.Lerp(ft * 12, self.m_fCrosshairGap or gapTarget, gapTarget)
    self.m_fCrosshairGap = gap

    local alphaTarget = self:GetCrosshairAlpha()
    local alpha = aerial.math.Lerp(ft * 24, self.m_fCrosshairAlpha or alphaTarget, alphaTarget)
    self.m_fCrosshairAlpha = alpha

    draw.NoTexture()

    if outline > 0 then
        outline = aerial.math.RoundToMultiple(outline, 2)
        local outlineThickness = thickness + outline

        surface.SetDrawColor(0, 0, 0, alpha)
        aerial.ui.DrawLine(x + gap, y, x + gap + length, y, outlineThickness)
        aerial.ui.DrawLine(x - gap, y, x - gap - length, y, outlineThickness)

        aerial.ui.DrawLine(x, y + gap, x, y + gap + length, outlineThickness)
        aerial.ui.DrawLine(x, y - gap, x, y - gap - length, outlineThickness)
    end

    local red, green, blue = aerial.console.crosshair.colorRed:GetInt(), aerial.console.crosshair.colorGreen:GetInt(), aerial.console.crosshair.colorBlue:GetInt()
    surface.SetDrawColor(red, green, blue, alpha)

    aerial.ui.DrawLine(x + gap, y, x + gap + length, y, thickness)
    aerial.ui.DrawLine(x - gap, y, x - gap - length, y, thickness)

    aerial.ui.DrawLine(x, y + gap, x, y + gap + length, thickness)
    aerial.ui.DrawLine(x, y - gap, x, y - gap - length, thickness)

    if aerial.console.crosshair.dotEnabled:GetBool() then
        local thicknessDot = aerial.math.RoundToMultiple(thickness, 2)

        if outline > 0 then
            local outlineThickness = thicknessDot + outline

            surface.SetDrawColor(0, 0, 0, alpha)
            surface.DrawRect(x - (thicknessDot + outline) / 2, y - (thicknessDot + outline) / 2, outlineThickness, outlineThickness)
            surface.SetDrawColor(red, green, blue, alpha)
        end

        
        surface.DrawRect(x - thicknessDot / 2, y - thicknessDot / 2, thicknessDot, thicknessDot)
    end

    

    return true
end