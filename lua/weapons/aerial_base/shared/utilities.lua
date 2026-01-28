function SWEP:VM(index)
    return self:GetOwner():GetViewModel(index)
end

function SWEP:GetAttackTables()
    local tables = { ["Primary"] = self.Primary, ["Secondary"] = self.Secondary }
    if istable(self.AttackTables) then
        for id, data in pairs(self.AttackTables) do
            tables[id] = data
        end
    end

    return tables
end

function SWEP:GetAttackTable(id)
    if id == "Primary" then return self.Primary end
    if id == "Secondary" then return self.Secondary end

    return self.AttackTables[id]
end

function SWEP:GetAttackKey(idOrData)
    local data = idOrData
    if isstring(idOrData) then
        data = self:GetAttackTable(idOrData)
    end

    local key = data.Key
    if isnumber(key) then return key end

    if data.ID == "Primary" then
        return IN_ATTACK
    elseif data.ID == "Secondary" then
        return IN_ATTACK2
    end
end

function SWEP:GetLastAttackTable()
    return self:GetAttackTable(self:GetLastAttackName())
end

function SWEP:GetOwnerSpeed(min, max)
    local ply = self:GetOwner()

    min = min or 0
    max = max or 1

    local vel = ply:GetVelocity()
    return math.Clamp(vel:Length2D() / ply:GetRunSpeed(), min, max)
end

function SWEP:_GetSpreadModifier(spreadData)
    local ply = self:GetOwner()
    local mod = 1
    if isnumber(spreadData.ADSMod) and self:GetADS() then
        mod = mod * spreadData.ADSMod
    end

    if isnumber(spreadData.CrouchMod) and ply:Crouching() then
        mod = mod * spreadData.CrouchMod
    end

    if isnumber(spreadData.AirMod) and not ply:IsOnGround() then
        mod = mod * spreadData.AirMod
    end

    if isnumber(spreadData.VelocityMod) then
        mod = mod + (self:GetOwnerSpeed() * spreadData.VelocityMod)
    end

    return mod
end