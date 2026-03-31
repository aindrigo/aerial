function SWEP:GetAttackFireMode(id)
    return self["Get"..id.."FireMode"](self)
end

function SWEP:SetAttackFireMode(id, value)
    self["Set"..id.."FireMode"](self, value)
end

function SWEP:GetAttackFireModeData(attackId, fireMode)
    local data = self:GetAttackTable(attackId)
    local value = nil
    if istable(data.FireModes) then
        value = data.FireModes[fireMode]
        if istable(value) then
            return value
        end
    end

    if value == nil then
        value = data.Automatic and aerial.enums.FIRE_MODE_AUTOMATIC or aerial.enums.FIRE_MODE_SEMIAUTOMATIC 
    end

    if value == aerial.enums.FIRE_MODE_AUTOMATIC then
        return { Automatic = true }
    elseif value == aerial.enums.FIRE_MODE_SEMIAUTOMATIC then
        return { Automatic = false }
    else
        error("unknown firemode "..value)
    end
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