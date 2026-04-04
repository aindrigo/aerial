local sin = math.sin
local cos = math.cos

function SWEP:GetViewModelPosition(eyePos, eyeAng)
    -- We have to use our own time-delta calculation because (Real)FrameTime seems to just not work properly in this hook
    -- Also, SysTime is much smoother
    local ct = SysTime()
    self.m_fLastCurTime = self.m_fLastCurTime or ct

    local ft = (ct - self.m_fLastCurTime) * GetConVar("host_timescale"):GetFloat()

    -- Find muzzle
    local muzzleAttachment = self:GetMuzzleAttachment()

    -- Other data
    local matrix = Matrix()
    matrix:SetTranslation(eyePos)
    matrix:SetAngles(eyeAng)

    local moveSpeed = self:GetOwnerSpeed()

    -- Calculations
    self:VMAim(ct, ft, matrix)
    self:VMViewSway(ct, ft, muzzleAttachment, matrix)
    self:VMRecoil(ct, ft, muzzleAttachment, matrix)
    self:VMViewBob(ct, ft, moveSpeed, muzzleAttachment, matrix)

    -- Offset
    local inverseAimFraction = 1 - (self.m_fAimFraction or 0)

    local vmSettings = self.VMSettings or {}
    if istable(vmSettings.Offset) then
        local offset = vmSettings.Offset
        if isvector(offset.Position) then
            matrix:Translate(offset.Position * inverseAimFraction)
        end

        if isangle(offset.Angles) then
            matrix:Rotate(offset.Angles * inverseAimFraction)
        end
    end

    if istable(vmSettings.CenteredOffset) and aerial.console.center:GetBool() then
        local offset = vmSettings.CenteredOffset
        if isvector(offset.Position) then
            matrix:Translate(offset.Position * inverseAimFraction)
        end

        if isangle(offset.Angles) then
            matrix:Rotate(offset.Angles * inverseAimFraction)
        end
    end

    eyePos, eyeAng = matrix:GetTranslation(), matrix:GetAngles()
    self.m_fLastCurTime = ct

    return eyePos, eyeAng
end

function SWEP:VMViewBob(ct, ft, moveSpeed, muzzle, matrix)
    local bobTable = self.Bob or {}

    local speed = self.m_fBobLastSpeed or moveSpeed
    local time = self.m_fBobTime or 0

    local bobFrequency = 1
    local bobAmplitude = speed * 2
    local backMultiplier = 1

    if isnumber(bobTable.AmplitudeMultiplier) then
        bobAmplitude = bobAmplitude * bobTable.AmplitudeMultiplier
    end

    if isnumber(bobTable.FrequencyMultiplier) then
        bobFrequency = bobFrequency * bobTable.FrequencyMultiplier
    end

    if self:GetAiming() then
        local aimAmplitudeMultiplier = bobTable.AimingAmplitudeMultiplier or 0.5
        if isnumber(aimAmplitudeMultiplier) then
            bobAmplitude = bobAmplitude * aimAmplitudeMultiplier
            backMultiplier = backMultiplier * aimAmplitudeMultiplier
        end
    end

    local calculatedPosition = Vector(0, 0, 0)
    calculatedPosition.x = -speed * 1.5 * backMultiplier
    calculatedPosition.z = -speed * 0.75 * backMultiplier

    local calculatedAngles = Angle(0, 0, 0)
    local t = time * -2.1

    calculatedAngles.y = calculatedAngles.y + sin(time * bobFrequency)
    calculatedAngles.y = calculatedAngles.y + sin(time * bobFrequency * 2.1 + t) * 0.4
    calculatedAngles.y = calculatedAngles.y + sin(time * bobFrequency * 2.4 + t) * 0.2
    calculatedAngles.y = calculatedAngles.y * bobAmplitude * 1.1

    calculatedAngles.p = calculatedAngles.p + cos(time * bobFrequency * 2) * -0.3
    calculatedAngles.p = calculatedAngles.p + cos(time * bobFrequency * 2.4) * -0.09
    calculatedAngles.p = calculatedAngles.p * bobAmplitude

    -- Increase time
    local delta = ft * math.min(speed, 0.61) * 16

    time = time + delta
    self.m_fBobTime = time

    -- Lerp
    self.m_fBobLastSpeed = Lerp(ft * 8, speed, moveSpeed)

    -- Translate
    matrix:Translate(calculatedPosition)

    -- Rotate
    local bobOrigin = muzzle.Pos
    local forwardMultiplier = 4

    if isnumber(bobTable.ForwardMultiplier) then
        forwardMultiplier = bobTable.ForwardMultiplier
    end

    if isvector(bobTable.Origin) then
        bobOrigin = bobTable.Origin
    else
        bobOrigin = bobOrigin + muzzle.Ang:Forward() * forwardMultiplier
    end

    matrix:Translate(bobOrigin)
    matrix:Rotate(calculatedAngles)
    matrix:Translate(-bobOrigin)
end

function SWEP:VMViewSway(ct, ft, muzzle, matrix)
    local swayTable = self.Sway or {}
    local eyeAng = matrix:GetAngles()

    self.m_aLastEyeAng = self.m_aLastEyeAng or eyeAng
    local difference = eyeAng - self.m_aLastEyeAng

    local speed = self.Sway.Speed or 6
    if self:GetAiming() then
        if istable(self.Aim) and isnumber(self.Aim.SwaySpeed) then
            speed = self.Aim.SwaySpeed
        end

        speed = speed * 2
    end

    self.m_aLastEyeAng = aerial.math.Lerp(ft * speed, self.m_aLastEyeAng, eyeAng)

    if difference.y >= 180 then
        difference.y = difference.y - 360
    elseif difference.y <= -180 then
        difference.y = difference.y + 360
    end

    local range = 30
    local multiplier = swayTable.Multiplier or 1

    if self:GetAiming() then
        local adsMultiplier = swayTable.AimingMultiplier or 0.6
        if isnumber(adsMultiplier) then
            multiplier = multiplier * adsMultiplier
        end
    end

    local rot = Angle(difference.p, difference.y, 0)
    rot.p = math.Clamp(rot.p * 0.3 * multiplier, -range, range)
    rot.y = math.Clamp(rot.y * 0.3 * multiplier, -range, range)

    if rot.y >= 180 then
        rot.y = rot.y - 360
    elseif rot.y <= -180 then
        rot.y = rot.y + 360
    end

    local swayOrigin = nil
    local forwardMultiplier = swayTable.ForwardMultiplier or -4

    if isvector(swayTable.Origin) then
        swayOrigin = swayTable.Origin
    else
        swayOrigin = muzzle.Pos + muzzle.Ang:Forward() * forwardMultiplier
    end

    if swayTable.Invert then
        rot = -rot
    end

    matrix:Translate(swayOrigin)
    matrix:Rotate(rot)
    matrix:Translate(-swayOrigin)
end

function SWEP:VMAim(ct, ft, matrix)
    if not istable(self.Aim) or not isvector(self.Aim.Position) or not isangle(self.Aim.Angles) then return end
    local aimData = self.Aim

    local position = aimData.Position
    local angles = aimData.Angles

    if not isvector(aimData.MiddlePosition) then
        aimData.MiddlePosition = position + angles:Up() * -4
    end

    if not isangle(aimData.MiddleAngles) then
        aimData.MiddleAngles = angles / 2
    end

    local targetFraction = self:GetAiming() and 1 or 0
    if targetFraction == 1 and self.m_fAimFraction == 1 then
        matrix:Rotate(angles)
        matrix:Translate(position)
        return
    end

    self.m_fAimFraction = Lerp(ft * 12 * (aimData.Speed or 1), self.m_fAimFraction or 0, targetFraction)
    matrix:Rotate(math.QuadraticBezier(self.m_fAimFraction, Angle(), aimData.MiddleAngles, angles))
    matrix:Translate(math.QuadraticBezier(self.m_fAimFraction, Vector(), aimData.MiddlePosition, position))
end

function SWEP:VMDrawElement(index, elementData, vm, flags)
    local state = self._vmElements[index]
    if not istable(state) then
        state = {}
        local csModel = ClientsideModel(elementData.Model)
        csModel:SetParent(vm)
        csModel:SetNoDraw(true)
        if elementData.BoneMerge then
            csModel:AddEffects(EF_BONEMERGE)
        end

        if elementData.Scale then
            csModel:SetModelScale(elementData.Scale)
        end

        state.csModel = csModel
        self._vmElements[index] = state
    end

    state.csModel:DrawModel(flags)
end

function SWEP:ViewModelDrawn(vm, flags)
    local attachments = aerial.Attachments.Data[self:EntIndex()] or {}
    for name, data in pairs(attachments) do
        self:VMDrawAttachment(name, data, vm, flags)
    end

    local vmSettings = self.VMSettings or {}
    if istable(vmSettings.Elements) then
        self._vmElements = self._vmElements or {}
        for index, elementData in ipairs(vmSettings.Elements) do
            self:VMDrawElement(index, elementData, vm, flags)
        end
    end
end
