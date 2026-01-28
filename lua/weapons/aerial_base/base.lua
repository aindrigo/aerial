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

SWEP.Primary.Delay = 0.13
SWEP.Primary.ShootAnimation = ACT_VM_PRIMARYATTACK
SWEP.Primary.EmptyReloadAnimation = ACT_VM_RELOAD_EMPTY

SWEP.Primary.Ammo = "pistol"
SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 12
SWEP.Primary.MuzzleFlashColor = Color(201, 165, 112)

-- Fire modes
-- SWEP.Primary.FireModes = {
--     [0] = aerial.enums.FIRE_MODE_AUTOMATIC, -- 0 is default
--     [1] = aerial.enums.FIRE_MODE_SEMIAUTOMATIC
-- }

-- Secondary, disabled
SWEP.Secondary.ID = "Secondary"
SWEP.Secondary.AttackType = aerial.enums.ATTACK_TYPE_NONE
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

SWEP.VMSettings = {}
SWEP.WMSettings = {}


function SWEP:Reset()
    self:FireHook("Reset")
    self:SetHoldType(self.HoldType or "revolver")

    self:SetIdleTime(0)
    self:SetReloadTime(0)
    self:SetFireModeTime(0)
    self:SetCustomRecoilMode(aerial.enums.CUSTOM_RECOIL_MODE_COMPENSATING)
    self:SetADS(false)
    self:SetReloading(false)
    self:SetReloadFinished(false)
    self:SetReloadName("")
    self:SetCurrentAttackTime(0)
    self:SetCurrentAttackName("")

    local zeroVec = Vector()
    local zeroAng = Angle()
    self:SetRecoil(zeroVec)
    self:SetCustomRecoilPosition(zeroVec)
    self:SetCustomRecoilAngles(zeroAng)
    self:SetCustomRecoilTargetPosition(zeroVec)
    self:SetCustomRecoilTargetAngles(zeroAng)

    if CLIENT then
        self:ResetMuzzleAttachment()
        self.m_aLastEyeAng = nil
        self.m_vCurrentRecoilPosition = Vector()
        self.m_aCurrentRecoilAngles = Angle()
    end

    local attachments = aerial.Attachments.Data[self:EntIndex()]
    if istable(attachments) then
        for name, data in pairs(attachments) do
            self:_RefreshAttachmentOverrides(name)
        end
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

    self:PlayAnimation(self.DeployAnimation or ACT_VM_DRAW)
    self:QueueIdle()

    return true
end

function SWEP:Holster()
    self:FireHook("Holster")

    return true
end

function SWEP:OnReloaded()
    self:SetHoldType(self.HoldType)
    if CLIENT and istable(self.ADS) then
        self.ADS.MiddlePosition = nil
        self.ADS.MiddleAngles = nil
    end

    local attachments = aerial.Attachments.Data[self:EntIndex()]
    if istable(attachments) then
        for name, data in pairs(attachments) do
            self:_RefreshAttachmentOverrides(name)
        end
    end
end

function SWEP:SetupDataTables()
    self:FireHook("SetupDataTables")

    self:NetworkVar("Float", "IdleTime") -- Used to get next idle time
    self:NetworkVar("Float", "ReloadTime") -- Used to check reload end time/next bullet insert
    self:NetworkVar("Float", "ReloadStartTime") -- Used for reload camera
    self:NetworkVar("Float", "ReloadEndTime") -- Used for reload camera
    self:NetworkVar("Float", "FireModeTime") -- Used to delay attacks/reload after setting firemode
    self:NetworkVar("Float", "CurrentAttackTime") -- Used for delayed/automatic attacks
    self:NetworkVar("Int", "PrimaryFireMode") -- Firemode for primary
    self:NetworkVar("Int", "SecondaryFireMode") -- Firemode for secondary
    self:NetworkVar("Int", "CustomRecoilMode") -- Recoil mode, see aerial.enums.CUSTOM_RECOIL_MODE
    self:NetworkVar("String", "ReloadName") -- Name for attack table when finishing reload
    self:NetworkVar("String", "LastAttackName") -- Used for reloading, changing firemode, etc
    self:NetworkVar("String", "CurrentAttackName") -- See CurrentAttackTime
    self:NetworkVar("Bool", "ADS") -- ADS state
    self:NetworkVar("Bool", "Reloading") -- To check if reloading or not
    self:NetworkVar("Bool", "ReloadFinished") -- To check if reload has finished, used in bullet by bullet reload
    self:NetworkVar("Vector", "Recoil") -- Recoil value
    self:NetworkVar("Vector", "CustomRecoilPosition") -- Custom recoil values, used for firing when aiming downsights
    self:NetworkVar("Vector", "CustomRecoilTargetPosition") -- Self-explanatory
    self:NetworkVar("Angle", "CustomRecoilAngles") -- Self-explanatory
    self:NetworkVar("Angle", "CustomRecoilTargetAngles") -- Self-explanatory

    if istable(self.AttackTables) then
        for id, data in pairs(self.AttackTables) do
            self:NetworkVar("Float", "Next"..id.."Fire")
            self:NetworkVar("Int", id.."MagazineCount")
            self:NetworkVar("Int", id.."FireMode")
        end
    end
end