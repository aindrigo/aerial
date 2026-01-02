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

function SWEP:AttackEffects(data, traceResult)
    self:FireHook("AttackEffects", data)

    self:EmitSound(data.Sound, SNDLVL_GUNFIRE)
    self:PlayAnimation(data.ShootAnimation)
    self:QueueIdle()

    -- Bullet hole
    if traceResult.Hit and IsFirstTimePredicted() then
        local impactEffect = EffectData()
        impactEffect:SetOrigin(traceResult.HitPos)
        impactEffect:SetStart(traceResult.StartPos)
        impactEffect:SetSurfaceProp(traceResult.SurfaceProps)
        impactEffect:SetEntity(traceResult.Entity)
        impactEffect:SetHitBox(traceResult.HitBoxBone or 0)
        impactEffect:SetDamageType(DMG_BULLET)

        util.Effect("Impact", impactEffect, true, false)
    end
end