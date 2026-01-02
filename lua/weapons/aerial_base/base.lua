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

SWEP.Aerial = true
SWEP.PrintName = "Aerial Base"
SWEP.Category = "Aerial"
SWEP.DrawWeaponInfoBox = false

SWEP.SwayScale = 0
SWEP.BobScale = 0

SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.Primary.ID = "Primary"
SWEP.Primary.Sound = Sound("Weapon_Pistol.Single")
SWEP.Primary.EmptySound = Sound("Weapon_Pistol.Empty")
SWEP.Primary.Delay = 0.13
SWEP.Primary.ShootAnimation = ACT_VM_PRIMARYATTACK

SWEP.Primary.Recoil = {}
SWEP.Primary.Recoil.MinX = -1.35
SWEP.Primary.Recoil.MinX = 1.35
SWEP.Primary.Recoil.MinZ = 1.35
SWEP.Primary.Recoil.MaxZ = 2.7

SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 12

SWEP.Secondary.ID = "Secondary"
SWEP.Secondary.EmptySound = Sound("Weapon_Pistol.Empty")
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.ShootAnimation = ACT_VM_SECONDARYATTACK

SWEP.Primary.Spread = {}
SWEP.Primary.Spread.Min = 0
SWEP.Primary.Spread.Max = 0.005
SWEP.Primary.Spread.IronsightsMod = 1 -- multiply
SWEP.Primary.Spread.CrouchMod = 0.9 -- crouch effect (multiply)
SWEP.Primary.Spread.AirMod = 2 -- how does if the player is in the air effect spread (multiply)
SWEP.Primary.Spread.RecoilMod = 0.03 -- how does the recoil effect the spread (sustained fire) (additional)
SWEP.Primary.Spread.VelocityMod = 1.3 -- movement speed effect on spread (additonal)

SWEP.Hooks = SWEP.Hooks or {}

function SWEP:Reset()
    self:FireHook("Reset")
    self:SetHoldType(self.HoldType or "revolver")
    self:SetIdleTime(0)
    self:SetIronsights(false)
end

function SWEP:Initialize()
    self:FireHook("Initialize")
    self:Reset()
end

function SWEP:Deploy()
    self:FireHook("Deploy")
    self:Reset()

    self:PlayAnimation(ACT_VM_DEPLOY)
    self:QueueIdle()
end

function SWEP:SetupDataTables()
    self:FireHook("SetupDataTables")

    self:NetworkVar("Float", "IdleTime")
    self:NetworkVar("Float", "ReloadTime")
    self:NetworkVar("Bool", "Ironsights")

    if istable(self.AttackTables) then
        for _, data in ipairs(self.AttackTables) do
            local slot = self.DTSlotCounts["Float"]
            self:NetworkVar("Float", "Next"..data.ID.."Fire")
        end
    end
end