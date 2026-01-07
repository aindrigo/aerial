function SWEP:GetAttackFireMode(id)
    return self["Get"..id.."FireMode"](self)
end

function SWEP:GetAttackFireModeEnum(id)
    local data = self:GetAttackTable(id)
    if not istable(id) or #data.FireModes < 1 then
        return data.Automatic and aerial.enums.FIRE_MODE_AUTOMATIC or aerial.enums.FIRE_MODE_SEMIAUTOMATIC
    end

    return data.FireModes[self:GetAttackFireMode(id)]
end

function SWEP:SetAttackFireMode(id, value)
    return self["Set"..id.."FireMode"](self, value)
end

function SWEP:ToggleFireMode()
    local id = self:GetLastAttackName()
    local data = self:GetAttackTable(id)

    if not istable(data.FireModes) or #data.FireModes <= 1 then return end

    local currentMode = self:GetAttackFireMode(id)
    local nextMode = (currentMode + 1) % #data.FireModes

    print(nextMode)
    self:SetAttackFireMode(id, nextMode)
end