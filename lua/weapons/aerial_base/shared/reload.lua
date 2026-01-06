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

    for id, _ in ipairs(self:GetAttackTables()) do
        local nextFire = self:GetNextAttack(id)
        if nextFire >= ct then
            return false
        end
    end

    local reloadTime = self:GetReloadTime()
    return ct > reloadTime
end

function SWEP:Reload()
    if not self:CanReload() or self:FireHook("Reload") then return end
    self:ReloadAttack("Primary")
end

function SWEP:CanAttackReload(id)
    if self:FireHook("CanAttackReload", id) == false then return false end

    local data = self:GetAttackTable(id)

    local capacity = data.ClipSize
    local currentMagazine = self:GetAttackMagazineCount(id)

    local ammo = self:GetOwner():GetAmmoCount(data.Ammo)

    return ammo > 0 and (data.CanChamberBullet and currentMagazine <= capacity or currentMagazine < capacity)
end

function SWEP:ReloadAttack(id)
    if not self:CanAttackReload(id) or self:FireHook("AttackReload", id) then return end
    local data = self:GetAttackTable(id)

    local capacity = data.ClipSize
    local currentMagazine = self:GetAttackMagazineCount(id)

    local normalReloadAnimation = data.ReloadAnimation or ACT_VM_RELOAD
    local reloadAnimation = normalReloadAnimation

    if currentMagazine <= 0 then
        reloadAnimation = data.EmptyReloadAnimation or normalReloadAnimation
    end

    local duration = self:PlayAnimation(reloadAnimation)
    self:QueueIdle()

    self:SetReloadName(id)
    self:SetReloadTime(CurTime() + duration)
end

function SWEP:ReloadAttackFinish(id)
    if not self:CanAttackReload(id) or self:FireHook("AttackReload", id) then return end
    local data = self:GetAttackTable(id)
    local ply = self:GetOwner()

    local capacity = data.ClipSize
    local currentMagazine = self:GetAttackMagazineCount(id)

    local target = math.min(math.max(capacity, ply:GetAmmoCount(data.Ammo)), data.ClipSize)

    if target == capacity and currentMagazine == capacity and data.CanChamberBullet then
        target = target + 1
    end

    self:SetAttackMagazineCount(id, target)
end