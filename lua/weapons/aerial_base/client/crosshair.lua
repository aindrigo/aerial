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

function SWEP:GetCrosshairAlpha()
    if self:GetReloading() or self:GetADS() then return 0 end

    return 255
end

function SWEP:GetCrosshairGap()
    local attackData = self:GetLastAttackTable()
    local spreadData = attackData.Spread or {}

    local base = spreadData.Cone or 0.2
    base = base * self:_GetSpreadModifier(spreadData)

    return base * 128
end

function SWEP:DoDrawCrosshair(x, y)
    local ft = FrameTime()
    local length = 6
    local thickness = 2

    local gapTarget = self:GetCrosshairGap()
    local gap = aerial.math.Lerp(ft * 12, self.m_fCrosshairGap or gapTarget, gapTarget)
    self.m_fCrosshairGap = gap

    local alphaTarget = self:GetCrosshairAlpha()
    local alpha = aerial.math.Lerp(ft * 24, self.m_fCrosshairAlpha or alphaTarget, alphaTarget)
    self.m_fCrosshairAlpha = alpha

    draw.NoTexture()
    surface.SetDrawColor(ColorAlpha(color_white, alpha))

    aerial.ui.DrawLine(x + gap, y, x + gap + length, y, thickness)
    aerial.ui.DrawLine(x - gap, y, x - gap - length, y, thickness)

    aerial.ui.DrawLine(x, y + gap, x, y + gap + length, thickness)
    aerial.ui.DrawLine(x, y - gap, x, y - gap - length, thickness)

    surface.DrawRect(x - 1, y - 1, 2, 2)

    return true
end