function SWEP:CanReload()
    local canReloadHook = self:FireHook("CanReload")
    if canReloadHook == false then return false end

    local ct = CurTime()

    for id, _ in pairs(self:GetAttackTables()) do
        local magazine = self:GetAttackMagazineCount(id)
        if magazine <= 0 then continue end

        local nextFire = self:GetNextAttack(id)
        if nextFire >= ct then
            return false
        end
    end

    return not self:GetReloading() and ct >= self:GetReloadTime() and ct >= self:GetFireModeTime() and ct > self:GetCurrentAttackTime()
end

function SWEP:Reload()
    if self:FireHook("Reload") or not self:CanReload() then return end
    self:ReloadAttack(self:GetLastAttackName())
end

function SWEP:CanReloadAttack(id)
    if self:FireHook("CanReloadAttack", id) == false then return false end

    local data = self:GetAttackTable(id)

    local capacity = data.ClipSize
    local currentMagazine = self:GetAttackMagazineCount(id)

    local ammo = self:GetOwner():GetAmmoCount(data.Ammo)
    return ammo > 0 and (data.CanChamberBullet and currentMagazine <= capacity or currentMagazine < capacity)
end

function SWEP:ReloadAttack(id)
    if self:FireHook("ReloadAttack", id) or not self:CanReloadAttack(id) then return end

    local ct = CurTime()

    local ply = self:GetOwner()
    ply:DoReloadEvent()

    local data = self:GetAttackTable(id)

    local capacity = data.ClipSize
    local currentMagazine = self:GetAttackMagazineCount(id)

    local reloadMode = data.ReloadMode or aerial.enums.RELOAD_MODE_NORMAL
    local reloadAnimation = nil

    self:SetReloadName(id)

    self:SetReloading(true)
    if reloadMode == aerial.enums.RELOAD_MODE_NORMAL then
        local normalReloadAnimation = data.ReloadAnimation or ACT_VM_RELOAD
        local reloadAnimation = normalReloadAnimation
        if currentMagazine <= 0 then
            reloadAnimation = data.EmptyReloadAnimation or normalReloadAnimation
        end

        local endTime = ct + self:PlayAnimation(reloadAnimation)
        self:QueueIdle()

        self:SetReloadStartTime(ct)
        self:SetReloadTime(endTime)
        self:SetReloadEndTime(endTime)
    elseif reloadMode == aerial.enums.RELOAD_MODE_BULLET_BY_BULLET then
        local endTime = ct + self:PlayAnimation(data.StartReloadAnimation or ACT_SHOTGUN_RELOAD_START)
        self:QueueIdle()

        self:SetReloadStartTime(ct)
        self:SetReloadTime(endTime)

        local bulletsToInsert = capacity - currentMagazine

        endTime = endTime + self:GetAnimationDuration(data.InsertBulletAnimation or ACT_VM_RELOAD) * bulletsToInsert
        endTime = endTime + self:GetAnimationDuration(data.FinishReloadAnimation or ACT_SHOTGUN_RELOAD_FINISH)

        self:SetReloadEndTime(endTime)
    end
end

function SWEP:ReloadAttackTimer(id)
    if self:FireHook("ReloadAttackTimer", id) then return end

    local data = self:GetAttackTable(id)
    local mode = data.ReloadMode or aerial.enums.RELOAD_MODE_NORMAL

    local ply = self:GetOwner()

    local capacity = data.ClipSize
    local currentMagazine = self:GetAttackMagazineCount(id)
    local reserve = ply:GetAmmoCount(data.Ammo)

    if mode == aerial.enums.RELOAD_MODE_NORMAL then
        local target = math.min(math.max(capacity, reserve), capacity)

        local isChambering = data.CanChamberBullet and target == capacity and currentMagazine > 0
        if isChambering then
            target = target + 1
        end

        local difference = target - math.min(self:GetAttackMagazineCount(id), isChambering and capacity + 1 or capacity)
        ply:SetAmmo(reserve - difference, data.Ammo)

        self:SetAttackMagazineCount(id, target)
        self:SetReloadStartTime(0)
        self:SetReloadTime(0)
        self:SetReloadName("")
        self:SetReloading(false)
    elseif aerial.enums.RELOAD_MODE_BULLET_BY_BULLET then
        local ct = CurTime()

        if currentMagazine == capacity or reserve == 0 then
            if self:GetReloadFinished() then
                self:SetReloadStartTime(0)
                self:SetReloadTime(0)
                self:SetReloadName("")
                self:SetReloadFinished(false)
                self:SetReloading(false)
                return
            end

            self:SetReloadTime(ct + self:PlayAnimation(data.FinishReloadAnimation or ACT_SHOTGUN_RELOAD_FINISH))
            self:QueueIdle()
            self:SetReloadFinished(true)
            return
        end

        local bulletsToAdd = 1
        local target = math.min(currentMagazine + bulletsToAdd, reserve)
        ply:SetAmmo(reserve - bulletsToAdd, data.Ammo)

        self:SetAttackMagazineCount(id, target)
        self:SetReloadTime(ct + self:PlayAnimation(data.InsertBulletAnimation or ACT_VM_RELOAD))
        self:QueueIdle()
    end
    
end