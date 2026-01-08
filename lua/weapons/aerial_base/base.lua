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
SWEP.Primary.EmptyReloadAnimation = ACT_VM_RELOAD_EMPTY

SWEP.Primary.Ammo = "pistol"
SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 12
SWEP.Primary.MuzzleFlashColor = Color(201, 165, 112)

-- Fire modes
SWEP.Primary.FireModes = {
    [0] = aerial.enums.FIRE_MODE_AUTOMATIC, -- 0 is default
    [1] = aerial.enums.FIRE_MODE_SEMIAUTOMATIC
}

-- Secondary, disabled
SWEP.Secondary.ID = "Secondary"
SWEP.Secondary.EmptySound = Sound("Weapon_Pistol.Empty")
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.ShootAnimation = ACT_VM_SECONDARYATTACK

SWEP.Hooks = {}
SWEP.ADS = {}

SWEP.Bob = {}
SWEP.Sway = {}

function SWEP:Reset()
    self:FireHook("Reset")
    self:SetHoldType(self.HoldType or "revolver")

    self:SetIdleTime(0)
    self:SetReloadTime(0)
    self:SetADS(false)
    self:SetReloadFinished(false)
    self:SetReloadName("")
    self:SetRecoil(Vector(0, 0, 0))

    if CLIENT then
        self:ResetMuzzleAttachment()
        self.m_aLastEyeAng = nil
    end
end

function SWEP:Initialize()
    aerial.Attachments.Data[self:EntIndex()] = {}

    self:FireHook("Initialize")
    self:Reset()

    self:SetLastAttackName("Primary")
end

function SWEP:Deploy()
    self:FireHook("Deploy")
    self:Reset()

    self:PlayAnimation(ACT_VM_DEPLOY)
    self:QueueIdle()
end

function SWEP:OnReloaded()
    if CLIENT and istable(self.ADS) then
        self.ADS.MiddlePosition = nil
        self.ADS.MiddleAngles = nil
    end
end
function SWEP:SetupDataTables()
    self:FireHook("SetupDataTables")


    self:NetworkVar("Float", "IdleTime")
    self:NetworkVar("Float", "ReloadTime")
    self:NetworkVar("Int", "PrimaryFireMode")
    self:NetworkVar("Int", "SecondaryFireMode")
    self:NetworkVar("String", "ReloadName")
    self:NetworkVar("String", "LastAttackName")
    self:NetworkVar("Bool", "ADS")
    self:NetworkVar("Bool", "Reloading")
    self:NetworkVar("Bool", "ReloadFinished")
    self:NetworkVar("Vector", "Recoil")

    if istable(self.AttackTables) then
        for id, data in pairs(self.AttackTables) do
            self:NetworkVar("Float", "Next"..id.."Fire")
            self:NetworkVar("Int", id.."MagazineCount")
            self:NetworkVar("Int", id.."FireMode")
        end
    end
end