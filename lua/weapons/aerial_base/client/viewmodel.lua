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

local sin = math.sin
local cos = math.cos

function SWEP:GetViewModelPosition(eyePos, eyeAng)
    local ct = UnPredictedCurTime()
    local ft = FrameTime()

    local matrix = Matrix()
    matrix:Translate(eyePos)
    matrix:Rotate(eyeAng)

    local speed = self:GetOwnerSpeed()

    -- Bob, sway, etc
    self:VMViewBob(ct, ft, speed, matrix)

    return matrix:GetTranslation(), matrix:GetAngles()
end

function SWEP:VMViewBob(ct, ft, speed, matrix)
    local bobFrequency = 5
    local bobAmplitude = speed

    local calculatedPosition = Vector(
        0,
        sin(ct * bobFrequency) * 0.5 * bobAmplitude,
        cos(ct * 2 * bobFrequency) * 0.25 * bobAmplitude
    )

    local calculatedAngles = Angle(0, 0, 0)

    -- Lerp & move
    self._vmBobPosition = LerpVector(
        ft * 7,
        self._vmBobPosition or calculatedPosition,
        calculatedPosition
    )
    
    self._vmBobAngles = LerpAngle(
        ft * 7,
        self._vmBobAngles or calculatedAngles,
        calculatedAngles
    )

    matrix:Translate(self._vmBobPosition)
    matrix:Rotate(self._vmBobAngles)
end