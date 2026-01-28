function SWEP:CalcView(ply, position, angles, fov)
    if not self:GetReloading() or not aerial.console.reloadCameraEnabled:GetBool() then return end

    local muzzleOrigin = self:GetMuzzleAttachment()
    local realMuzzle = self:GetRealMuzzleAttachment()

    local ct = CurTime()
    local startTime = self:GetReloadStartTime()
    local endTime = self:GetReloadEndTime()

    local fraction = math.TimeFraction(startTime, endTime, ct)
    fraction = math.sin(math.pi * fraction)

    local muzzleDifference = realMuzzle.Pos - muzzleOrigin.Pos
    muzzleDifference:Mul(fraction)

    angles:RotateAroundAxis(angles:Up(), muzzleDifference.y)
    angles:RotateAroundAxis(angles:Right(), -muzzleDifference.z)

    return position, angles, fov
end