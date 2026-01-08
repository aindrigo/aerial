function SWEP:CalculateFOV()
    if istable(self.ADS) and isnumber(self.ADS.FOV) and self:GetADS() then
        return self.ADS.FOV
    end
    return 1
end

function SWEP:TranslateFOV(fov)
    local multiplier = self:CalculateFOV()
    self.m_fFOVMultiplier = Lerp(FrameTime() * 8, self.m_fFOVMultiplier or multiplier, multiplier)

    return fov * self.m_fFOVMultiplier
end