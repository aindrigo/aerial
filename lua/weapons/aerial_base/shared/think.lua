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

function SWEP:Think()
    self:ThinkAttacks()
    self:ThinkADS()
    self:ThinkIdle()
    self:ThinkReload()
    self:ThinkRecoil()
    self:ThinkCustomRecoil()
end

function SWEP:ThinkAttacks()
    local ply = self:GetOwner()

    self:ThinkAttack("Primary", IN_ATTACK)
    self:ThinkAttack("Secondary", IN_ATTACK2)
end

function SWEP:ThinkAttack(id, key)
    if not self:CanAttack(id) then return end

    local ply = self:GetOwner()
    local data = self:GetAttackTable(id)

    if data.Ammo == "none" then return end
    if istable(self.ADS) and (self.ADS.Key or IN_ATTACK2) == key then
        aerial.dprint("Warning: conflicting keys for ironsights and attack "..id)
    end
    
    local magazineCount = self:GetAttackMagazineCount(id)
    local fireMode = self:GetAttackFireModeEnum(id)

    if magazineCount > 0 and fireMode == aerial.enums.FIRE_MODE_AUTOMATIC then
        if ply:KeyDown(key) then
            self:Attack(id)
        end
    elseif magazineCount < 1 or fireMode == aerial.enums.FIRE_MODE_SEMIAUTOMATIC then
        if ply:KeyPressed(key) then
            self:Attack(id)
        end
    end
end

function SWEP:ThinkADS()
    if not istable(self.ADS) or self.ADS.Enabled == false then return end

    local canAds = self:CanADS()

    local ply = self:GetOwner()
    local key = self.ADS.Key or IN_ATTACK2

    local down = ply:KeyDown(key)
    local state = self:GetADS()

    if down and not state and canAds then
        self:OnADSChange(true)
    elseif (not down or not canAds) and state then
        self:OnADSChange(false)
    end
end

function SWEP:ThinkIdle()
    local idleTime = self:GetIdleTime()
    if idleTime <= 0 then return end

    local ct = CurTime()
    if ct > idleTime then
        self:SetIdleTime(0)
        self:PlayAnimation(self.IdleAnimation or ACT_VM_IDLE)
    end
end

function SWEP:ThinkReload()
    local reloadTime = self:GetReloadTime()
    if reloadTime <= 0 then return end

    local id = self:GetReloadName()
    local ct = CurTime()

    if ct >= reloadTime and id ~= "" then
        self:ReloadAttackTimer(id)
    end
end

function SWEP:ThinkRecoil()
    local ft = FrameTime()

    local recoil = self:GetRecoil()
    if recoil.x == 0 and recoil.z == 0 then return end
    local recoilData = self.Recoil or {}
    local compensation = recoilData.Compensation or 1

    self:SetRecoil(aerial.math.Lerp(ft * 4 * compensation, recoil, vector_origin))
end

function SWEP:ThinkCustomRecoil()
    local ft = FrameTime()
    
    local targetPosition = self:GetCustomRecoilTargetPosition()
    local targetAngles = self:GetCustomRecoilTargetAngles()

    local currentPosition = self:GetCustomRecoilPosition()
    local currentAngles = self:GetCustomRecoilAngles()

    local mode = self:GetCustomRecoilMode()

    if currentPosition == targetPosition and currentAngles == targetAngles then
        if mode == aerial.enums.CUSTOM_RECOIL_MODE_COMPENSATING then
            return
        end

        mode = aerial.enums.CUSTOM_RECOIL_MODE_COMPENSATING
        targetPosition = Vector()
        targetAngles = Angle()

        self:SetCustomRecoilMode(mode)
        self:SetCustomRecoilTargetPosition(targetPosition)
        self:SetCustomRecoilTargetAngles(targetAngles)
    end

    local speed = mode == aerial.enums.CUSTOM_RECOIL_MODE_COMPENSATING and 8 or 48

    speed = ft * speed
    currentPosition = aerial.math.Lerp(speed, currentPosition, targetPosition)
    currentAngles = aerial.math.Lerp(speed, currentAngles, targetAngles)

    self:SetCustomRecoilPosition(currentPosition)
    self:SetCustomRecoilAngles(currentAngles)
end