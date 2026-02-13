function SWEP:Think()
    self:ThinkIdle()
    self:ThinkAttacks()
    self:ThinkADS()
    self:ThinkReload()
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

    local canAttack = self:CanAttack(id)

    local chargeData = data.Charge
    if istable(chargeData) then
        local chargeType = chargeData.Type or aerial.enums.CHARGE_TYPE_RELEASE
        if chargeType ~= aerial.enums.CHARGE_TYPE_RELEASE then
            canAttack = canAttack and ply:KeyDown(key)
        end
    end

    if canAttack and ply:KeyPressed(key) and (self:GetCurrentAttackTime() < 1 or self:GetCurrentAttackName() == "") then
        self:Attack(id)
    elseif self:GetCurrentAttackName() == id and not canAttack then
        self:SetCurrentAttackTime(0)
        self:SetCurrentAttackName("")
    end

    self:ThinkRecoil( id, data )
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

    if istable(chargeData) then
        local chargeType = chargeData.Type or aerial.enums.CHARGE_TYPE_RELEASE
        if chargeType == aerial.enums.CHARGE_TYPE_RELEASE then
            if ply:KeyDown(self:GetAttackKey(data)) then return end

        elseif chargeType == aerial.enums.CHARGE_TYPE_HOLD then
            if attackTime > ct then return end
        end
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
