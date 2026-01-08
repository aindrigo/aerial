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
    -- We have to use our own time-delta calculation because (Real)FrameTime seems to just not work properly in this hook
    local ct = UnPredictedCurTime()
    self.m_fLastCurTime = self.m_fLastCurTime or ct

    local ft = ct - self.m_fLastCurTime

    local ply = self:GetOwner()
    local vm = self:VM()

    -- Find muzzle
    local muzzleAttachment = self:GetMuzzleAttachment()

    -- Other data
    local matrix = Matrix()
    matrix:SetTranslation(eyePos)
    matrix:SetAngles(eyeAng)

    local moveSpeed = self:GetOwnerSpeed()

    -- Calculations
    self:VMADS(ct, ft, matrix)
    self:VMViewSway(ct, ft, muzzleAttachment, matrix)
    self:VMViewBob(ct, ft, moveSpeed, muzzleAttachment, matrix)


    eyePos, eyeAng = matrix:GetTranslation(), matrix:GetAngles()
    self.m_fLastCurTime = ct

    return eyePos, eyeAng
end

function SWEP:VMViewBob(ct, ft, moveSpeed, muzzle, matrix)
    local bobTable = self.Bob or {}

    local speed = self.m_fBobLastSpeed or moveSpeed
    local time = self.m_fBobTime or 0

    local bobFrequency = 1
    local bobAmplitude = speed * 2

    if isnumber(bobTable.AmplitudeMultiplier) then
        bobAmplitude = bobAmplitude * bobTable.AmplitudeMultiplier
    end

    if isnumber(bobTable.FrequencyMultiplier) then
        bobAmplitude = bobAmplitude * bobTable.FrequencyMultiplier
    end

    local calculatedPosition = Vector(0, 0, 0)
    calculatedPosition.x = -speed * 1.5
    calculatedPosition.z = -speed * 0.75

    local calculatedAngles = Angle(0, 0, 0)
    local t = time * -2.1

    calculatedAngles.y = calculatedAngles.y + sin(time * bobFrequency)
    calculatedAngles.y = calculatedAngles.y + sin(time * bobFrequency * 2.1 + t) * 0.4
    calculatedAngles.y = calculatedAngles.y + sin(time * bobFrequency * 2.4 + t) * 0.2
    calculatedAngles.y = calculatedAngles.y * bobAmplitude * 1.1

    calculatedAngles.p = calculatedAngles.p + cos(time * bobFrequency * 2) * -0.3
    calculatedAngles.p = calculatedAngles.p + cos(time * bobFrequency * 2.4) * -0.09
    calculatedAngles.p = calculatedAngles.p * bobAmplitude

    -- Increase time
    local delta = ft * math.min(speed, 0.61) * 17

    time = time + delta
    self.m_fBobTime = time

    -- Lerp
    self.m_fBobLastSpeed = Lerp(ft * 8, speed, moveSpeed)

    -- Translate
    matrix:Translate(calculatedPosition)

    -- Rotate
    local bobOrigin = muzzle.Pos
    local forwardMultiplier = 4

    if isnumber(bobTable.ForwardMultiplier) then
        forwardMultiplier = bobTable.ForwardMultiplier
    end

    if isvector(bobTable.Origin) then
        bobOrigin = bobTable.Origin
    else
        bobOrigin = bobOrigin + muzzle.Ang:Forward() * forwardMultiplier
    end

    matrix:Translate(bobOrigin)
    matrix:Rotate(calculatedAngles)
    matrix:Translate(-bobOrigin)
end

function SWEP:VMViewSway(ct, ft, muzzle, matrix)
    local swayTable = self.Sway or {}
    local eyeAng = matrix:GetAngles()

    self.m_aLastEyeAng = self.m_aLastEyeAng or eyeAng
    local difference = eyeAng - self.m_aLastEyeAng

    local speed = self.Sway.Speed or 5
    if self:GetADS() then
        if istable(self.ADS) and isnumber(self.ADS.SwaySpeed) then
            speed = self.ADS.SwaySpeed
        end

        speed = speed * 2
    end

    self.m_aLastEyeAng = LerpAngle(ft * speed, self.m_aLastEyeAng, eyeAng)

    if difference.y >= 180 then
        difference.y = difference.y - 360
    elseif difference.y <= -180 then
        difference.y = difference.y + 360
    end

    local range = 30
    local multiplier = swayTable.Multiplier or 1

    local rot = Angle(difference.p, difference.y, 0)
    rot.p = math.Clamp(rot.p * 0.3 * multiplier, -range, range)
    rot.y = math.Clamp(rot.y * 0.3 * multiplier, -range, range)
    
    if rot.y >= 180 then
        rot.y = rot.y - 360
    elseif rot.y <= -180 then
        rot.y = rot.y + 360
    end

    local swayOrigin = nil
    local forwardMultiplier = swayTable.ForwardMultiplier or -4

    if isvector(swayTable.Origin) then
        swayOrigin = swayTable.Origin
    else
        swayOrigin = muzzle.Pos + muzzle.Ang:Forward() * forwardMultiplier
    end

    if swayTable.Invert then
        rot = -rot
    end

    matrix:Translate(swayOrigin)
    matrix:Rotate(rot)
    matrix:Translate(-swayOrigin)
end

function SWEP:VMADS(ct, ft, matrix)
    if not istable(self.ADS) or not isvector(self.ADS.Position) or not isangle(self.ADS.Angles) then return end
    local adsData = self.ADS

    local position = adsData.Position
    local angles = adsData.Angles

    if not isvector(adsData.MiddlePosition) then
        adsData.MiddlePosition = position + angles:Up() * -4
    end

    if not isangle(adsData.MiddleAngles) then
        adsData.MiddleAngles = angles / 2
    end

    local targetFraction = self:GetADS() and 1 or 0
    if targetFraction == 1 and self.m_fADSFraction == 1 then
        matrix:Rotate(angles)
        matrix:Translate(position)
        return
    end

    self.m_fADSFraction = Lerp(ft * (adsData.Speed or 8), self.m_fADSFraction or 0, targetFraction)
    matrix:Rotate(math.QuadraticBezier(self.m_fADSFraction, Angle(), adsData.MiddleAngles, angles))
    matrix:Translate(math.QuadraticBezier(self.m_fADSFraction, Vector(), adsData.MiddlePosition, position))
end