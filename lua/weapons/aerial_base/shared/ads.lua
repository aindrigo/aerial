function SWEP:CanADS()
    if istable(self.ADS) and self.ADS.Enabled == false then
        return false
    end

    local ct = CurTime()
    return not self:GetReloading() and ct >= self:GetReloadTime()
end

function SWEP:OnADSChange(state)
    if self:FireHook("OnADSChange", state) == false then return end
    self:SetADS(state)

    local ply = self:GetOwner()

    if CLIENT and (IsFirstTimePredicted() or game.SinglePlayer()) then
        ply:EmitSound(state and "Aerial.ADSIn" or "Aerial.ADSOut")
    end
end
