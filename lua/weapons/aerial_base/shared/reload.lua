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

function SWEP:CanReload()
    local canReloadHook = self:FireHook("CanReload")
    if canReloadHook == false then return false end

    local ct = CurTime()

    for id, _ in pairs(self:GetAttackTables()) do
        local nextFire = self:GetNextAttack(id)
        if nextFire >= ct then
            return false
        end
    end

    local reloadTime = self:GetReloadTime()
    return ct >= reloadTime
end

function SWEP:Reload()
    if self:FireHook("Reload") or not self:CanReload() then return end
    self:ReloadAttack("Primary")
end

function SWEP:CanReloadAttack(id)
    if self:FireHook("CanReloadAttack", id) == false then return false end

    local data = self:GetAttackTable(id)

    local capacity = data.ClipSize
    local currentMagazine = self:GetAttackMagazineCount(id)

    local ammo = self:GetOwner():GetAmmoCount(data.Ammo)

    return ammo > 0 and (data.CanChamberBullet and currentMagazine <= capacity or currentMagazine < capacity)
end

function SWEP:ReloadAttack(id)
    if self:FireHook("ReloadAttack", id) or not self:CanReloadAttack(id) then return end
    local data = self:GetAttackTable(id)

    local capacity = data.ClipSize
    local currentMagazine = self:GetAttackMagazineCount(id)

    local reloadMode = data.ReloadMode or aerial.enums.RELOAD_MODE_NORMAL
    local reloadAnimation = nil

    self:SetReloadName(id)

    if reloadMode == aerial.enums.RELOAD_MODE_NORMAL then
        local normalReloadAnimation = data.ReloadAnimation or ACT_VM_RELOAD
        local reloadAnimation = normalReloadAnimation
        if currentMagazine <= 0 then
            reloadAnimation = data.EmptyReloadAnimation or normalReloadAnimation
        end

        self:SetReloadTime(CurTime() + self:PlayAnimation(reloadAnimation))
        self:QueueIdle()
    elseif reloadMode == aerial.enums.RELOAD_MODE_BULLET_BY_BULLET then
        self:SetReloadTime(CurTime() + self:PlayAnimation(data.StartReloadAnimation or ACT_SHOTGUN_RELOAD_START))
        self:QueueIdle()
    end
end

function SWEP:ReloadAttackTimer(id)
    if self:FireHook("AttackReloadTimer", id) then return end

    local data = self:GetAttackTable(id)
    local mode = data.ReloadMode or aerial.enums.RELOAD_MODE_NORMAL

    local ply = self:GetOwner()

    local capacity = data.ClipSize
    local currentMagazine = self:GetAttackMagazineCount(id)
    local reserve = ply:GetAmmoCount(data.Ammo)

    if mode == aerial.enums.RELOAD_MODE_NORMAL then
        local target = math.min(math.max(capacity, reserve), capacity)

        local isChambering = data.CanChamberBullet and target == capacity and currentMagazine > 0
        if isChambering then
            target = target + 1
        end

        local difference = target - math.min(self:GetAttackMagazineCount(id), isChambering and capacity + 1 or capacity)
        ply:SetAmmo(reserve - difference, data.Ammo)

        self:SetAttackMagazineCount(id, target)
        self:SetReloadTime(0)
        self:SetReloadName("")
    elseif aerial.enums.RELOAD_MODE_BULLET_BY_BULLET then
        local ct = CurTime()

        if currentMagazine == capacity or reserve == 0 then
            if self:GetReloadFinished() then
                self:SetReloadTime(0)
                self:SetReloadName("")
                self:SetReloadFinished(false)
                return
            end

            self:SetReloadTime(ct + self:PlayAnimation(data.FinishReloadAnimation or ACT_SHOTGUN_RELOAD_FINISH))
            self:QueueIdle()
            self:SetReloadFinished(true)
            return
        end

        local bulletsToAdd = 1
        local target = math.min(currentMagazine + bulletsToAdd, reserve)
        ply:SetAmmo(reserve - bulletsToAdd, data.Ammo)

        self:SetAttackMagazineCount(id, target)
        self:SetReloadTime(ct + self:PlayAnimation(data.InsertBulletAnimation or ACT_VM_RELOAD))
        self:QueueIdle()
    end
    
end