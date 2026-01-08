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

    local ply = self:GetOwner()
    local vm = self:VM()

    -- Find muzzle
    local muzzleAttachment = self:GetMuzzleAttachment()

    -- Other data
    local matrix = Matrix()
    matrix:Translate(eyePos)
    matrix:Rotate(eyeAng)

    local moveSpeed = self:GetOwnerSpeed()

    -- Viewbob, etc
    self:VMViewBob(ct, ft, moveSpeed, matrix)

    -- Sway LAST
    self:VMViewSway(ct, ft, matrix, muzzleAttachment)

    eyePos, eyeAng = matrix:GetTranslation(), matrix:GetAngles()
    return eyePos, eyeAng
end

function SWEP:VMViewBob(ct, ft, moveSpeed, matrix)
    local speed = self.m_fBobLastSpeed or moveSpeed
    local time = self.m_fBobTime or 0

    local bobFrequency = 0.96
    local bobAmplitude = speed * 0.6

    local calculatedPosition = Vector(0, 0, 0)

    local t = 0.01 * (-time * 210)

    calculatedPosition.y = calculatedPosition.y + sin(time * bobFrequency)
    calculatedPosition.y = calculatedPosition.y + sin(time * bobFrequency * 2.1 + t) * 0.4
    calculatedPosition.y = calculatedPosition.y + sin(time * bobFrequency * 2.2 + t) * 0.2
    calculatedPosition.y = calculatedPosition.y * bobAmplitude * 1.2

    calculatedPosition.z = calculatedPosition.z + cos(time * bobFrequency * 2) * -0.3
    calculatedPosition.z = calculatedPosition.z + cos(time * bobFrequency * 2.4) * -0.09
    calculatedPosition.z = calculatedPosition.z * bobAmplitude * 1.1

    calculatedPosition.z = calculatedPosition.z - speed * 0.4
    calculatedPosition.x = -speed * 1
    local calculatedAngles = Angle(0, 0, 0)

    -- Increase time
    time = time + ft * math.min(speed, 0.64) * 3
    self.m_fBobTime = time

    -- Lerp
    self.m_fBobLastSpeed = Lerp(ft * 5, speed, moveSpeed)

    -- Translate
    matrix:Translate(calculatedPosition)
    matrix:Rotate(calculatedAngles)
end

function SWEP:VMViewSway(ct, ft, matrix, muzzle)
    local eyeAng = matrix:GetAngles()

    self.m_aLastEyeAng = self.m_aLastEyeAng or eyeAng
    local difference = eyeAng - self.m_aLastEyeAng
    self.m_aLastEyeAng = LerpAngle(ft * 1, self.m_aLastEyeAng, eyeAng)

    if difference.y >= 180 then
        difference.y = difference.y - 360
    elseif difference.y <= -180 then
        difference.y = difference.y + 360
    end

    local range = 50


    local rot = Angle(difference.p, difference.y, 0)
    rot.p = math.Clamp(rot.p * 0.3, -range, range)
    rot.y = math.Clamp(rot.y * 0.3, -range, range)
    
    if rot.y >= 180 then
        rot.y = rot.y - 360
    elseif rot.y <= -180 then
        rot.y = rot.y + 360
    end

    local swayOrigin = muzzle.Pos
    if istable(self.Sway) and isvector(self.Sway.Origin) then
        swayOrigin = self.Sway.Origin
    end

    matrix:Translate(swayOrigin)
    matrix:Rotate(rot)
    matrix:Translate(-swayOrigin)
end