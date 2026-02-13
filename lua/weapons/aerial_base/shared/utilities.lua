function SWEP:VM(index)
    if not IsValid( self:GetOwner() ) then return end
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
