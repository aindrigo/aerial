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

function SWEP:CalcView(ply, position, angles, fov)
    if not self:GetReloading() then return end
    local muzzleOrigin = self:GetMuzzleAttachment()
    local realMuzzle = self:GetRealMuzzleAttachment()

    local ct = CurTime()
    local startTime = self:GetReloadStartTime()
    local endTime = self:GetReloadTime()

    local fraction = math.TimeFraction(startTime, endTime, ct)

    local muzzleDifference = realMuzzle.Pos - muzzleOrigin.Pos
    muzzleDifference:Mul(math.sin(math.pi * fraction))

    angles:RotateAroundAxis(angles:Up(), muzzleDifference.y)
    angles:RotateAroundAxis(angles:Right(), -muzzleDifference.z)

    return position, angles, fov
end