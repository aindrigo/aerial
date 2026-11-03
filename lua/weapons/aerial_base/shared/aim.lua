function SWEP:CanAim()
    if istable(self.Aim) and self.Aim.Enabled == false then
        return false
    end

    if self:GetOwnerSpeed() > 0.8 then
        return false
    end

    local ct = CurTime()
    return not self:GetReloading() and ct >= self:GetReloadTime()
end

function SWEP:OnAimStateChange(state)
    if self:FireHook("OnAimStateChange", state) == false then return end
    self:SetAiming(state)

    local ply = self:GetOwner()

    if CLIENT and (IsFirstTimePredicted() or game.SinglePlayer()) then
        ply:EmitSound(state and "Aerial.AimIn" or "Aerial.AimOut")
    end
end
