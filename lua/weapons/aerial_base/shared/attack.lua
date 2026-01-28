function SWEP:GetNextAttack(id)
    local func = self["GetNext"..id.."Fire"]
    return func(self)
end

function SWEP:SetNextAttack(id, value)
    local func = self["SetNext"..id.."Fire"]
    return func(self, value)
end

function SWEP:BuildAttackData(id)
    local data = self:GetAttackTable(id)
    local attackType = data.AttackType or aerial.enums.ATTACK_TYPE_BULLET

    local ply = self:GetOwner()

    local attackData = {}
    attackData.Type = attackType
    attackData.Attacker = ply
    attackData.Damage = data.Damage

    attackData.Position = ply:GetShootPos()
    attackData.Direction = ply:GetAimVector()
    return attackData
end

function SWEP:AttackTakeAmmo(id, count)
    local data = self:GetAttackTable(id)
    local flags = data.Flags or 0

    if bit.band(flags, aerial.enums.ATTACK_FLAGS_NO_AMMO) == aerial.enums.ATTACK_FLAGS_NO_AMMO then
        return
    end

    self:SetAttackMagazineCount(id, math.max(self:GetAttackMagazineCount(id) - (count or 1), 0))
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:CanAttack(id)
    if self:FireHook("CanAttack", id) == false then return false end

    local ct = CurTime()
    return ct >= self:GetNextAttack(id) and ct >= self:GetReloadTime() and ct >= self:GetFireModeTime()
end

function SWEP:AttackSchedule(id, performFunction)
    local data = self:GetAttackTable(id)
    if not istable(data.Charge) and not isnumber(data.StartDelay) then
        local attackData = self:BuildAttackData(id)
        performFunction(self, id, attackData)
        return
    end

    local ct = CurTime()
    local time = ct

    if istable(data.Charge) and data.Charge.Type == aerial.enums.CHARGE_TYPE_HOLD then
        time = time + data.Charge.HoldTime
    elseif isnumber(data.StartDelay) then
        time = time + data.StartDelay
    end

    self:SetCurrentAttackTime(time)
    self:SetCurrentAttackName(id)
end

function SWEP:Attack(id)
    if self:FireHook("Attack", id) or not self:CanAttack(id) then return end

    self:SetLastAttackName(id)

    local data = self:GetAttackTable(id)
    local attackType = data.AttackType or aerial.enums.ATTACK_TYPE_BULLET

    if attackType == aerial.enums.ATTACK_TYPE_BULLET then
        self:AttackBullet(id)
    elseif attackType == aerial.enums.ATTACK_TYPE_MELEE then
        self:AttackMelee(id)
    elseif attackType == aerial.enums.ATTACK_TYPE_PROJECTILE then
        self:AttackProjectile(id)
    end
end

function SWEP:AttackHitEntity(id, attackData, traceResult)
    if self:FireHook("AttackHitEntity", id, attackData) then return end

    local data = self:GetAttackTable(id)
    local dmgInfo = DamageInfo()
    dmgInfo:SetDamage(attackData.Damage)
    dmgInfo:SetAttacker(attackData.Attacker)
    dmgInfo:SetInflictor(self)
    dmgInfo:SetWeapon(self)

    dmgInfo:SetDamageType(data.DamageType or DMG_BULLET)
    dmgInfo:SetDamagePosition(traceResult.HitPos)
    dmgInfo:SetDamageForce(traceResult.Normal * (data.Force or 1))

    traceResult.Entity:DispatchTraceAttack(dmgInfo, traceResult)
end
