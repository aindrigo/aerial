function SWEP:CalculateFOV()
    local hookResult = self:FireHook("CalculateFOV")

    local mod = 1
    if hookResult ~= nil then
        mod = mod * hookResult
    end

    if istable(self.ADS) and isnumber(self.ADS.FOV) and self:GetADS() then
        mod = mod * self.ADS.FOV
    end

    return mod
end

function SWEP:TranslateFOV(fov)
    local multiplier = self:CalculateFOV()
    self.m_fFOVMultiplier = Lerp(FrameTime() * 2, self.m_fFOVMultiplier or multiplier, multiplier)

    return fov * self.m_fFOVMultiplier
end
