SWEP.Primary.Recoil = {}
SWEP.Primary.Recoil.MultiplierX = 2
SWEP.Primary.Recoil.MultiplierY = 2

--[[ ?
local mx = math.ease.OutQuad(t)
local x = math.Clamp( math.sin(t * 8) * mx, -0.7, 0.7 )
local y = math.ease.OutQuint(t) * 3
y = y + math.cos(t * 8) * mx * 0.5
]]

function SWEP.Primary.Recoil:Function( t )
    local spd = math.ease.OutQuart(t) * 2
    local et = math.ease.OutQuad(t)

    local x = math.Clamp( math.sin(t * 9 + spd) * et, -0.8, 0.8 )
    local y = math.ease.OutQuint( math.Clamp( t - 0.1, 0, 1 ) ) * 3

    y = y + et * math.cos(t * 30) * 0.1

    return x, y
end

function SWEP:GetShotFrac( data )
    return math.Clamp( self:GetShot() / data.ClipSize + 0.05, 0, 1 )
end

function SWEP:AttackCalculateRecoil(id, attackData)
    local hookResult = self:FireHook("AttackCalculateRecoil", id, ply)
    if isvector(hookResult) then
        return hookResult
    end

    local data = self:GetAttackTable(id)

    local ply = attackData.Attacker
    local recoilData = data.Recoil or {}
    local globalRecoilData = self.Recoil or {}

    local x, y = recoilData:Function( self:GetShotFrac( data ) )

    return Vector( y * recoilData.MultiplierY, 0, x * recoilData.MultiplierX )
end

SWEP.Primary.Spread = {}
SWEP.Primary.Spread.Cone = 0.1
SWEP.Primary.Spread.Min = -math.huge
SWEP.Primary.Spread.Max = math.huge
SWEP.Primary.Spread.ProlongedFireMult = 1.2
SWEP.Primary.Spread.AimMult = 0.5
SWEP.Primary.Spread.CrouchMult = 0.8
SWEP.Primary.Spread.AirMult = 1.5
SWEP.Primary.Spread.VelocityMult = 1.5

function SWEP:_GetSpreadModifier(data, spreadData)
    local ply = self:GetOwner()
    local mod = 1
    if self:GetADS() then
        mod = mod * spreadData.ADSMod
    end

    if ply:Crouching() then
        mod = mod * spreadData.CrouchMod
    end

    if not ply:IsOnGround() then
        mod = mod * spreadData.AirMod
    end

    mod = mod * (self:GetShotFrac(data) * spreadData.ProlongedFireMult)
    mod = mod + (self:GetOwnerSpeed() * spreadData.VelocityMod)

    return mod
end

function SWEP:AttackCalculateSpread(id, attackData, index)
    local hookResult = self:FireHook("AttackCalculateSpread", id, attackData, index)
    if isvector(hookResult) then
        return hookResult
    end

    local data = self:GetAttackTable( id )
    local ply = attackData.Attacker
    local spreadData = data.Spread or {}

    local mod = self:_GetSpreadModifier(data, spreadData)
    local cone = Vector( spreadData.Cone, 0, spreadData.Cone )
    cone:Mul( mod )

    return Vector(
        math.Clamp(util.SharedRandom("ARSX"..tostring(index)..ply:SteamID(), -cone.x, cone.x), spreadData.Min, spreadData.Max),
        0,
        math.Clamp(util.SharedRandom("ARSZ"..tostring(index)..ply:SteamID(), -cone.z, cone.z), spreadData.Min, spreadData.Max)
    )
end


function SWEP:ThinkRecoil( attackID, attackData )
    if self:GetShot() > 0 then
        if CurTime() > ( self:LastShootTime() + attackData.Recoil.RestTime ) then
            self:SetShot( self:GetShot() - 1 )
        end
    end
end

function SWEP:ThinkCustomRecoil()
end

function SWEP:GetFinalShotPlacement( id, attackData, index )
    local
    pos = self:AttackCalculateRecoil( id, attackData )
    pos = pos + self:AttackCalculateSpread( id, attackData, index )

    return pos
end


SWEP.Primary.Punch = {}
SWEP.Primary.Punch.AmountX = 0
SWEP.Primary.Punch.AmountY = 1
SWEP.Primary.Punch.Smooth = false

function SWEP:AttackEffectRecoil(id, attackData)
    if self:FireHook("AttackEffectRecoil", id, attackData) then return end

    local data = self:GetAttackTable(id)
    local ply = self:GetOwner()

    local ang = Angle( -attackData.Punch.AmountY, attackData.Punch.AmountX, 0 )

    if attackData.Punch.Smooth then
        ply:SetViewPunchVelocity( ang )
    else
        ply:SetViewPunchAngles( ang )
    end
end
