--[[ ?
local mx = math.ease.OutQuad(t)
local x = math.Clamp( math.sin(t * 8) * mx, -0.7, 0.7 )
local y = math.ease.OutQuint(t) * 3
y = y + math.cos(t * 8) * mx * 0.5
]]

function SWEP.Primary.Recoil:Function(t)
    local spd = math.ease.OutQuart(t) * 2
    local et = math.ease.OutQuad(t)

    local x = math.Clamp(math.sin(t * 9 + spd) * et, -0.8, 0.8)
    local y = math.ease.OutQuint(math.Clamp(t - 0.1, 0, 1)) * 3

    y = y + et * math.cos(t * 30) * 0.1

    return x, y
end

SWEP.Secondary.Recoil.Function = SWEP.Primary.Recoil.Function

function SWEP:GetShotFrac(data)
    return math.Clamp(self:GetShot() / data.ClipSize, 0, 1)
end

function SWEP:AttackCalculateRecoil(id, data, attackData)
    local hookResult = self:FireHook("AttackCalculateRecoil", id, data, attackData)
    if isvector(hookResult) then
        return hookResult
    end

    local recoilData = data.Recoil or {}

    local x, y = recoilData:Function(self:GetShotFrac(data))

    return Vector(y * recoilData.MultiplierY, 0, x * recoilData.MultiplierX)
end


--- @param attackData? table
function SWEP:AttackGetSpreadModifier(id, data, attackData)
    local v = self:FireHook("AttackGetSpreadModifier", id, data, attackData)
    if isnumber(v) then return v end

    local spreadData = data.Spread

    local ply = self:GetOwner()
    local mod = 1
    if self:GetAiming() and spreadData.AimMult > 0 then
        mod = mod * spreadData.AimMult
    end

    if ply:Crouching() and spreadData.CrouchMult > 0 then
        mod = mod * spreadData.CrouchMult
    end

    if not ply:IsOnGround() and spreadData.AirMult > 0 then
        mod = mod * spreadData.AirMult
    end

    local prolongedFireMult = self:GetShotFrac(data) * spreadData.ProlongedFireMult
    if prolongedFireMult > 0 then
        mod = mod * 1 + prolongedFireMult
    end

    mod = mod + (self:GetOwnerSpeed() * spreadData.VelocityMult)

    local hook = self:FireHook("AttackGetSpreadModifierAdditive", id, attackData)
    if isnumber(hook) then
        mod = mod * hook
    end

    return mod
end

function SWEP:AttackCalculateSpread(id, data, attackData, index)
    local hookResult = self:FireHook("AttackCalculateSpread", id, data, attackData, index)
    if isvector(hookResult) then
        return hookResult
    end

    local ply = attackData.Attacker
    local spreadData = data.Spread or {}

    local mod = self:AttackGetSpreadModifier(id, data, attackData)
    local cone = Vector(spreadData.Cone, 0, spreadData.Cone)
    cone:Mul(mod)

    return Vector(
        math.Clamp(util.SharedRandom("ARSX" .. tostring(index) .. ply:SteamID(), -cone.x, cone.x), spreadData.Min,
            spreadData.Max),
        0,
        math.Clamp(util.SharedRandom("ARSZ" .. tostring(index) .. ply:SteamID(), -cone.z, cone.z), spreadData.Min,
            spreadData.Max)
    )
end

function SWEP:ThinkRecoil(attackId, attackData)
    if self:GetShot() > 0 then
        if CurTime() > (self:LastShootTime() + attackData.Recoil.RestTime) then
            self:SetShot(self:GetShot() - 1)
        end
    end
end

function SWEP:AttackCalculateFinalShotPlacement(id, data, attackData, index)
    local pos = attackData.Recoil
    pos = pos + self:AttackCalculateSpread(id, data, attackData, index)

    return pos
end

function SWEP:AttackEffectRecoil(id, attackData)
    if self:FireHook("AttackEffectRecoil", id, attackData) then return end

    local data = self:GetAttackTable(id)
    local ply = self:GetOwner()

    local ang = Angle(-data.Punch.AmountY, data.Punch.AmountX, 0)

    if data.Punch.Smooth then
        ply:SetViewPunchVelocity(ang)
    else
        ply:SetViewPunchAngles(ang)
    end
end
