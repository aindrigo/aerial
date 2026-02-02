function SWEP:GetAttackFireMode(id)
    return self["Get"..id.."FireMode"](self)
end

function SWEP:SetAttackFireMode(id, value)
    return self["Set"..id.."FireMode"](self, value)
end

function SWEP:GetAttackFireModeEnum(id)
    local data = self:GetAttackTable(id)
    if not istable(data.FireModes) or table.IsEmpty(data.FireModes) then
        return data.Automatic and aerial.enums.FIRE_MODE_AUTOMATIC or aerial.enums.FIRE_MODE_SEMIAUTOMATIC
    end

    return data.FireModes[self:GetAttackFireMode(id)]
end

function SWEP:ToggleFireMode()
    local ct = CurTime()
    if self:GetFireModeTime() > ct then return end

    local id = self:GetLastAttackName()
    local data = self:GetAttackTable(id)
    
    local count = 0
    if istable(data.FireModes) then
        count = table.Count(data.FireModes)
    end

    if count <= 1 then return end
    
    local currentMode = self:GetAttackFireMode(id)
    local nextMode = (currentMode + 1) % count

    self:SetAttackFireMode(id, nextMode)
    if not data.NoFireModeAnimation then
        local duration = self:PlayAnimation(data.FireModeAnimation or ACT_VM_FIREMODE)
        self:QueueIdle()
        self:SetFireModeTime(ct + duration)
    end
end