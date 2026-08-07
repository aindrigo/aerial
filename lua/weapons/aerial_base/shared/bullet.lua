function SWEP:AttackBullet(id)
    if self:FireHook("AttackBullet", id) then return end
    self:AttackBulletPreEffects(id)
    self:AttackSchedule(id, self.AttackBulletPerform)
end

function SWEP:AttackBulletPerform(id, attackData)
    if self:FireHook("AttackBulletPerform", id, attackData) then return end


    local ply = attackData.Attacker
    local data = self:GetAttackTable(id)

    local magazineCount = self:GetAttackMagazineCount(id)
    attackData.Delay = attackData.Delay or data.Delay or 0.1

    local fireMode = self:GetAttackFireModeData(id, self:GetAttackFireMode(id))
    local chargeData = data.Charge

    local attackTime = CurTime()
    attackTime = attackTime + attackData.Delay

    local key = self:GetAttackKey(data)
    local keyDown = ply:KeyDown(key)


    local ammoPenalty = attackData.AmmoPenalty or data.AmmoPenalty or 1
    if magazineCount < ammoPenalty then
        if data.EmptyAnimation then
            self:PlayAnimation(data.EmptyAnimation)
            self:QueueIdle()
        end

        if data.SoundLooping then
            self:_AttackStopLoopingSound(id)
        end

        if data.EmptySound then
            self:EmitSound(data.EmptySound, SNDLVL_NORM)
        end

        self:SetCurrentAttackTime(0)
        self:SetCurrentAttackName("")
        return
    end

    local isBursting = isnumber(fireMode.Burst)
    if isBursting then
        self:SetBurstFireCount(self:GetBurstFireCount() + 1)
    end

    if not istable(chargeData) or chargeData.Enabled == false then
        if fireMode.Automatic and keyDown then
            self:SetCurrentAttackName(id)
            self:SetCurrentAttackTime(attackTime)
        elseif not fireMode.Automatic then
            if isBursting then
                if self:GetBurstFireCount() >= fireMode.Burst then
                    self:SetBurstFireCount(0)
                    self:SetCurrentAttackName("")
                    self:SetCurrentAttackTime(0)

                    self:SetNextAttack(id, attackTime)
                else
                    self:SetCurrentAttackName(id)
                    self:SetCurrentAttackTime(attackTime)
                end
            end
        end
    else
        if fireMode.Automatic and keyDown then
            self:SetCurrentAttackName(id)
            self:SetCurrentAttackTime(attackTime)
        elseif not fireMode.Automatic then
            if self:GetBurstFireCount() >= fireMode.Burst then
                self:SetBurstFireCount(0)
                self:SetCurrentAttackName("")
                self:SetCurrentAttackTime(0)

                self:SetNextAttack(id, attackTime)
            else
                self:SetCurrentAttackName(id)
                self:SetCurrentAttackTime(attackTime)
            end

            self:SetCurrentAttackName("")
            self:SetCurrentAttackTime(0)
        end
    end

    self:AttackTakeAmmo(id, attackData, ammoPenalty)

    attackData.Delay = attackData.Delay or delay
    attackData.Damage = attackData.Damage or data.Damage
    attackData.DamageType = attackData.DamageType or data.DamageType or DMG_BULLET
    attackData.Traces = {}

    attackData.Recoil = self:AttackCalculateRecoil(id, data, attackData)

    self:SetShot(self:GetShot() + 1)
    self:SetLastShootTime(CurTime()) -- HACK

    ply:LagCompensation(true)
    for i = 1, (data.ShotCount or 1) do
        local traceResult = self:AttackBulletTrace(id, attackData, i)

        if traceResult.Hit and IsValid(traceResult.Entity) then
            self:AttackHitEntity(id, attackData, traceResult)
        end

        table.insert(attackData.Traces, traceResult)
    end
    ply:LagCompensation(false)

    self:AttackBulletEffects(id, attackData)

    self.m_tLastAttacks = self.m_tLastAttacks or {}
    self.m_tLastAttacks[id] = attackData
end

function SWEP:AttackBulletTrace(id, attackData, index)
    local hookResult = self:FireHook("AttackBulletTrace", id, attackData, index)
    if istable(hookResult) then
        return hookResult
    end

    local ply = attackData.Attacker

    local data = self:GetAttackTable(id)
    local spread = self:AttackCalculateFinalShotPlacement(id, data, attackData, index)

    local direction = ply:GetAimVector()
    local angle = direction:Angle()

    angle:RotateAroundAxis(angle:Right(), spread.x)
    angle:RotateAroundAxis(angle:Up(), spread.z)

    direction = angle:Forward()

    local startPosition = ply:GetShootPos()
    local endPosition = startPosition + direction * (data.Distance or 8192)

    local traceData = {}
    traceData.start = startPosition
    traceData.endpos = endPosition
    traceData.filter = { self, ply }
    traceData.mask = MASK_SHOT

    local traceResult = util.TraceLine(traceData)

    if CLIENT then
        debugoverlay.Line(traceData.start, traceResult.HitPos, 5, ColorRand(false), false)
    end

    return traceResult
end

function SWEP:AttackBulletPreEffects(id)
    if self:FireHook("AttackBulletPreEffects", id) then return end

    local data = self:GetAttackTable(id)
    local chargeData = data.Charge
    if istable(chargeData) and isstring(chargeData.StartSound) then
        self:EmitSound(chargeData.StartSound)
    end
end

function SWEP:AttackBulletEffects(id, attackData)
    if self:FireHook("AttackBulletEffects", id, attackData) then return end

    local data = self:GetAttackTable(id)

    local ply = attackData.Attacker
    ply:SetAnimation(PLAYER_ATTACK1)

    if isstring(data.SoundLooping) then
        self:_AttackStartLoopingSound(id)
    elseif isstring(data.Sound) then
        self:EmitSound(data.Sound, SNDLVL_GUNFIRE)
    end

    if isstring(data.SoundLayer) then
        self:EmitSound(data.SoundLayer, SNDLVL_GUNFIRE)
    elseif istable(data.SoundLayer) then
        self:EmitSound(data.SoundLayer[math.random(#data.SoundLayer)], SNDLVL_GUNFIRE)
    end

    local customRecoil = data.CustomRecoilEffects or {}
    if (self:GetAiming() and not data.ShootAnimationAiming) or customRecoil.Always then
        if customRecoil.UseShootAnimation or customRecoil.Disabled then
            self:PlayAnimation(data.ShootAnimation or ACT_VM_PRIMARYATTACK)
            self:QueueIdle()
        end

        if not customRecoil.Disabled then
            local force = customRecoil.Force
            if not force then
                force = (attackData.Damage * (attackData.ShotCount or 1)) / 6
            end

            local yaw = attackData.Recoil.x * 0.2
            if isnumber(customRecoil.YawMultiplier) then
                yaw = yaw * customRecoil.YawMultiplier
            end

            local pitch = -force

            self:SetCustomRecoilMode(aerial.enums.CUSTOM_RECOIL_MODE_KICKBACK)
            self:SetCustomRecoilTargetPosition(Vector(pitch, 0, 0))
            self:SetCustomRecoilTargetAngles(Angle(pitch, yaw, 0))
        end
    else
        self:PlayAnimation(attackData.Animation or data.ShootAnimation or ACT_VM_PRIMARYATTACK)
        self:QueueIdle()
    end


    for _, traceResult in ipairs(attackData.Traces) do
        if not traceResult.Hit or not (game.SinglePlayer() or IsFirstTimePredicted()) then continue end
        local impactEffect = EffectData()
        impactEffect:SetOrigin(traceResult.HitPos)
        impactEffect:SetStart(traceResult.StartPos)
        impactEffect:SetSurfaceProp(traceResult.SurfaceProps)
        impactEffect:SetEntity(traceResult.Entity)
        impactEffect:SetHitBox(traceResult.HitBoxBone or 0)
        impactEffect:SetDamageType(attackData.DamageType)

        util.Effect("Impact", impactEffect, true, false)

        if traceResult.MatType == MAT_FLESH then
            impactEffect = EffectData()
            impactEffect:SetOrigin(traceResult.HitPos)
            impactEffect:SetNormal(traceResult.Normal)

            util.Effect("BloodImpact", impactEffect, true, false)
        elseif traceResult.MatType == MAT_METAL then
            impactEffect = EffectData()
            impactEffect:SetOrigin(traceResult.HitPos)
            impactEffect:SetNormal(traceResult.Normal)

            util.Effect("MetalSpark", impactEffect, true, false)
        elseif traceResult.MatType == MAT_GLASS then
            impactEffect = EffectData()
            impactEffect:SetOrigin(traceResult.HitPos)
            impactEffect:SetNormal(traceResult.Normal)

            util.Effect("GlassImpact", impactEffect, true, false)
        end
    end

    self:AttackEffectMuzzleFlash(id, attackData)
    self:AttackEffectRecoil(id, attackData)
end

function SWEP:AttackBulletCancel(id)
    local data = self:GetAttackTable(id)
    if isstring(data.SoundLooping) then
        self:_AttackStopLoopingSound(id)
    end
end
