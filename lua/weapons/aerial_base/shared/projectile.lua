function SWEP:AttackProjectile(id)
    if self:FireHook("AttackProjectile", id) then return end
    self:AttackProjectilePreEffects(id)
    self:AttackSchedule(id, self.AttackProjectilePerform)
end

function SWEP:AttackProjectilePerform(id, attackData)
    if self:FireHook("AttackProjectilePerform", id, attackData) then return end

    local data = self:GetAttackTable(id)
    local ct = CurTime()
    local attackTime = ct

    local chargeData = data.Charge
    if not istable(chargeData) or chargeData.Enabled == false then
        attackTime = attackTime + attackData.Delay
        self:SetNextAttack(id, attackTime)
    else
        self:SetCurrentAttackName("")
        self:SetCurrentAttackTime(0)
    end


    local ply = attackData.Attacker
    attackData.Position = ply:GetShootPos()
    attackData.Direction = ply:GetAimVector()

    attackData.Force = attackData.Direction * (data.Force or 800)

    if SERVER and IsFirstTimePredicted() then
        local ent = ents.Create("aerial_projectile")
        ent:SetAttackData(attackData)
        ent:SetProjectileData(data.Projectile)
        ent:Spawn()
    end

    self:AttackTakeAmmo(id, 1)
    self:AttackProjectileEffects(id, attackData)
end

function SWEP:AttackProjectilePreEffects(id)
    if self:FireHook("AttackProjectilePreEffects", id) then return end
    local data = self:GetAttackTable(id)
    if data.StartAnimation ~= nil then
        self:PlayAnimation(data.StartAnimation)
        self:QueueIdle()
    end
end

function SWEP:AttackProjectileEffects(id, attackData)
    if self:FireHook("AttackProjectileEffects", id, attackData) then return end

    local ply = attackData.Attacker
    ply:SetAnimation(PLAYER_ATTACK1)
end