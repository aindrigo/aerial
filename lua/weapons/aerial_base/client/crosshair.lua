function SWEP:GetCrosshairAlpha()
    if self:GetReloading() or self:GetADS() then return 0 end

    return aerial.console.crosshair.colorAlpha:GetInt()
end

function SWEP:GetCrosshairGap(static)
    local attackData = self:GetLastAttackTable()
    local spreadData = attackData.Spread or {}

    local base = spreadData.Cone
    if not static then
        base = base * self:_GetSpreadModifier(attackData, spreadData)
    end

    base = base - aerial.console.crosshair.gapAdditive:GetFloat()
    base = math.max(base, aerial.console.crosshair.gapMinimum:GetFloat())

    return base * aerial.console.crosshair.gap:GetFloat()
end

local lastx = 0
local lasty = 0
function SWEP:GetCrosshairPos( x, y )
    local id = self:GetLastAttackName()
    local attackData = self:GetLastAttackTable()

    if not attackData.Recoil or not self:GetADS() then
        return x, y
    end

    local lerpSpeed = 16
    local recoil = self:AttackCalculateRecoil( id, attackData )
    if CurTime() > (self:LastShootTime() + attackData.Recoil.RestTime) then
        recoil.z = 0 -- reset
        recoil.x = 0
        lerpSpeed = 4
    else
        recoil.z = -recoil.z * 14 -- this seems to be the magic number
        recoil.x = -recoil.x * 14
    end

    recoil.z = Lerp( FrameTime() * lerpSpeed, lastx, recoil.z )
    recoil.x = Lerp( FrameTime() * lerpSpeed, lasty, recoil.x )
    lastx = recoil.z
    lasty = recoil.x

    return x + recoil.z, y + recoil.x
end

function SWEP:DoDrawCrosshair(x, y)
    x, y = self:GetCrosshairPos( x, y )

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
