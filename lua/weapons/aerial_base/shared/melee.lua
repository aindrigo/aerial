function SWEP:AttackMelee(id)
    if self:FireHook("AttackMelee", id) then return end
    local data = self:GetAttackTable(id)
    self:AttackMeleePreEffects(id)
    self:AttackSchedule(id, self.AttackMeleePerform)
end

function SWEP:AttackMeleePerform(id, attackData)
    if self:FireHook("AttackMeleePerform", id, attackData) then return end
    local ct = CurTime()

    local ply = attackData.Attacker
    local data = self:GetAttackTable(id)

    attackData.Traces = {}
    attackData.Delay = attackData.Delay or data.Delay or 0
    attackData.Range = attackData.Range or data.Range or 70
    attackData.DamageType = attackData.DamageType or data.DamageType or DMG_CLUB

    local attackTime = ct
    local chargeData = data.Charge

    if not istable(chargeData) or chargeData.Enabled == false then
        attackTime = attackTime + attackData.Delay
        self:SetNextAttack(id, attackTime)
    else
        self:SetCurrentAttackName("")
        self:SetCurrentAttackTime(0)
    end

    ply:LagCompensation(true)
    for i = 1, (data.HitCount or 1) do
        local traceResult = self:AttackMeleeTrace(id, attackData, i)
        table.insert(attackData.Traces, traceResult)

        if traceResult.Hit and IsValid(traceResult.Entity) then
            self:AttackHitEntity(id, attackData, traceResult)
        end
    end
    ply:LagCompensation(false)

    self:AttackTakeAmmo(id, 1)
    self:AttackMeleeEffects(id, attackData)
end

function SWEP:AttackMeleeTrace(id, attackData, index)
    local hookResult = self:FireHook("AttackMeleeTrace", id, attackData, index)
    if istable(hookResult) then
        return hookResult
    end

    local data = self:GetAttackTable(id)
    if not isvector(attackData.HullMins) then
        if isvector(data.HullMins) then
            attackData.HullMins = data.HullMins
        elseif isnumber(data.HullSize) then
            attackData.HullMins = Vector(-data.HullSize, -data.HullSize, -data.HullSize)
        elseif isvector(data.HullMaxs) then
            attackData.HullMins = -data.HullMaxs
        end
    end

    if not isvector(attackData.HullMaxs) then
        if isvector(data.HullMaxs) then
            attackData.HullMaxs = data.HullMaxs
        elseif isnumber(data.HullSize) then
            attackData.HullMaxs = Vector(data.HullSize, data.HullSize, data.HullSize)
        elseif isvector(data.HullMins) then
            attackData.HullMaxs = -data.HullMins
        end
    end

    local ply = attackData.Attacker

    local traceData = {}
    traceData.start = attackData.Position
    traceData.endpos = traceData.start + attackData.Direction * attackData.Range
    traceData.filter = ply
    traceData.mask = MASK_SHOT_HULL

    traceData.mins = attackData.HullMins
    traceData.maxs = attackData.HullMaxs

    return util.TraceHull(traceData)
end

function SWEP:AttackMeleePreEffects(id)
    if self:FireHook("AttackMeleePreEffects", id, attackData) then return end
    local ply = self:GetOwner()

    ply:SetAnimation(PLAYER_ATTACK1)
    local data = self:GetAttackTable(id)

    if isstring(data.StartSound) then
        self:EmitSound(data.StartSound)
    end

    if data.StartAnimation ~= false then
        self:PlayAnimation(data.StartAnimation or ACT_VM_MISSCENTER)
        self:QueueIdle()
    end
end

function SWEP:AttackMeleeEffects(id, attackData)
    if self:FireHook("AttackMeleeEffects", id, attackData) then return end

    local data = self:GetAttackTable(id)
    local hitWorld = false

    for _, traceResult in ipairs(attackData.Traces) do
        if not traceResult.Hit or not (game.SinglePlayer() or IsFirstTimePredicted()) then continue end
        if traceResult.HitWorld and not hitWorld then
            hitWorld = true
        end

        local impactEffect = EffectData()
        impactEffect:SetOrigin(traceResult.HitPos)
        impactEffect:SetStart(traceResult.StartPos)
        impactEffect:SetSurfaceProp(traceResult.SurfaceProps)
        impactEffect:SetEntity(traceResult.Entity)
        impactEffect:SetHitBox(traceResult.HitBoxBone or 0)
        impactEffect:SetDamageType(attackData.DamageType)

        util.Effect("Impact", impactEffect, true, false)
    end

    if isstring(data.ImpactSound) and (data.ImpactSoundWorldOnly and hitWorld or not data.ImpactSoundWorldOnly) then
        self:EmitSound(data.ImpactSound)
    end
end