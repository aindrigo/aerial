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
    self:ThinkIdle()
    self:ThinkAttacks()
    self:ThinkADS()
    self:ThinkReload()
    self:ThinkRecoil()
    self:ThinkCustomRecoil()
    self:ThinkFireMode()
    self:ThinkFlags()
end

function SWEP:ThinkAttacks()
    local ply = self:GetOwner()

    self:ThinkAttack("Primary", self:GetAttackKey("Primary"))
    self:ThinkAttack("Secondary", self:GetAttackKey("Secondary"))
    self:ThinkCurrentAttack()
end

function SWEP:ThinkAttack(id, key)
    local ply = self:GetOwner()
    local data = self:GetAttackTable(id)

    local attackType = data.AttackType or aerial.enums.ATTACK_TYPE_BULLET
    if attackType == aerial.enums.ATTACK_TYPE_NONE then return end

    if istable(self.ADS) and self.ADS.Enabled ~= false and (self.ADS.Key or IN_ATTACK2) == key then
        aerial.dprint("Warning: conflicting keys for ironsights and attack "..id)
    end

    local chargeData = data.Charge
    local charge = istable(chargeData) and chargeData.Enabled ~= false

    local canAttack = self:CanAttack(id)

    if canAttack and ply:KeyPressed(key) and (self:GetCurrentAttackTime() < 1 or self:GetCurrentAttackName() == "") then
        self:Attack(id)
    elseif self:GetCurrentAttackName() == id and not canAttack then
        self:SetCurrentAttackTime(0)
        self:SetCurrentAttackName("") 
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

function SWEP:ThinkFireMode()
    local ct = CurTime()
    local nextFire = self:GetFireModeTime()

    if nextFire <= 0 or nextFire > ct then return end
    self:SetFireModeTime(0)
end

function SWEP:ThinkCurrentAttack()
    local attackTime = self:GetCurrentAttackTime()
    local attackName = self:GetCurrentAttackName()

    if attackName == "" then return end
    
    local data = self:GetAttackTable(attackName)

    local attackType = data.AttackType or aerial.enums.ATTACK_TYPE_BULLET

    local ct = CurTime()
    local ply = self:GetOwner()

    local chargeData = data.Charge
    local charge = istable(chargeData) and chargeData.Enabled ~= false

    if charge then
        if ply:KeyDown(self:GetAttackKey(data)) then return end
    else
        if attackTime > ct then return end
        self:SetCurrentAttackTime(0)
        self:SetCurrentAttackName("")
    end

    local attackData = self:BuildAttackData(attackName)
    if charge then
        attackData.Charge = {
            Start = self:GetCurrentAttackTime(),
            End = ct
        }
    end

    if attackType == aerial.enums.ATTACK_TYPE_MELEE then
        self:AttackMeleePerform(attackName, attackData)
    elseif attackType == aerial.enums.ATTACK_TYPE_BULLET then
        self:AttackBulletPerform(attackName, attackData)
    elseif attackType == aerial.enums.ATTACK_TYPE_PROJECTILE then
        self:AttackProjectilePerform(attackName, attackData)
    end
end

function SWEP:ThinkFlags()
    for name, data in pairs(self:GetAttackTables()) do
        if not isnumber(data.Flags) then continue end

        if SERVER and bit.band(data.Flags, aerial.enums.ATTACK_FLAGS_REMOVE_ON_ZERO_AMMO) == aerial.enums.ATTACK_FLAGS_REMOVE_ON_ZERO_AMMO then
            local ammoCount = self:GetAttackMagazineCount(name)
            if ammoCount < 1 then
                self:Remove()
            end            
        end
    end
end