function SWEP:AttackEffectRecoil(id, attackData)
    if self:FireHook("AttackEffectRecoil", id, attackData) then return end

    local data = self:GetAttackTable(id)
    local ply = attackData.Attacker

    -- View punch
    local recoil = attackData.Recoil
    local recoilData = data.Recoil or {}

    local xPunch = recoilData.PunchX or 0.15
    local zPunch = recoilData.PunchZ or 0.07

    local punch = Angle(
        util.SharedRandom("ARVPP", -recoil.z * zPunch, recoil.z * zPunch),
        util.SharedRandom("ARVPY", 0, -recoil.x * xPunch),
        0
    )

    ply:ViewPunch(punch)
    if IsFirstTimePredicted() or game.SinglePlayer() then
        ply:SetEyeAngles(ply:EyeAngles() + punch * 0.4)
    end
end


function SWEP:AttackCalculateRecoil(id, attackData)
    local hookResult = self:FireHook("AttackCalculateRecoil", id, ply)
    if isvector(hookResult) then
        return hookResult
    end

    local data = self:GetAttackTable(id)

    local ply = attackData.Attacker
    local recoilData = data.Recoil or {}
    local globalRecoilData = self.Recoil or {}

    local compensation = 1 / (globalRecoilData.Compensation or 1)

    local min = recoilData.Min or 0
    local max = recoilData.Max or 1

    local x = util.SharedRandom("ARRX"..ply:SteamID(), recoilData.MinX or min, recoilData.MaxX or max)
    local z = util.SharedRandom("ARRZ"..ply:SteamID(), recoilData.MinZ or min, recoilData.MaxZ or max)

    local currentRecoil = self:GetRecoil() * compensation
    return currentRecoil + Vector(x, 0, z)
end

function SWEP:AttackCalculateSpread(id, attackData, index)
    local hookResult = self:FireHook("AttackCalculateSpread", id, attackData, index)
    if isvector(hookResult) then
        return hookResult
    end

    local data = self:GetAttackTable(id)

    local ply = attackData.Attacker
    local spreadData = data.Spread or {}

    local cone = Vector(spreadData.Cone, 0, spreadData.Cone)
    cone = cone * attackData.Recoil * (spreadData.RecoilMod or 1)

    local mod = self:_GetSpreadModifier(spreadData)
    cone:Mul(mod)
    cone = cone / 2

    local min = spreadData.Min or -math.huge
    local max = spreadData.Max or math.huge

    return Vector(
        math.Clamp(util.SharedRandom("ARSX"..tostring(index)..ply:SteamID(), -cone.x, cone.x), spreadData.MinX or min, spreadData.MaxX or max),
        0,
        math.Clamp(util.SharedRandom("ARSZ"..tostring(index)..ply:SteamID(), -cone.z, cone.z), spreadData.MinZ or min, spreadData.MaxZ or max)
    )
end


function SWEP:ThinkRecoil()
    local ft = FrameTime()

    local recoil = self:GetRecoil()
    if recoil.x == 0 and recoil.z == 0 then return end
    local recoilData = self.Recoil or {}
    local compensation = recoilData.Compensation or 1

    self:SetRecoil(aerial.math.Lerp(ft * 4 * compensation, recoil, vector_origin))
end

function SWEP:ThinkCustomRecoil()
    local ft = FrameTime()

    local targetPosition = self:GetCustomRecoilTargetPosition()
    local targetAngles = self:GetCustomRecoilTargetAngles()

    local currentPosition = self:GetCustomRecoilPosition()
    local currentAngles = self:GetCustomRecoilAngles()

    local mode = self:GetCustomRecoilMode()

    if currentPosition == targetPosition and currentAngles == targetAngles then
        if mode == aerial.enums.CUSTOM_RECOIL_MODE_COMPENSATING then
            return
        end

        mode = aerial.enums.CUSTOM_RECOIL_MODE_COMPENSATING
        targetPosition = Vector()
        targetAngles = Angle()

        self:SetCustomRecoilMode(mode)
        self:SetCustomRecoilTargetPosition(targetPosition)
        self:SetCustomRecoilTargetAngles(targetAngles)
    end

    local speed = mode == aerial.enums.CUSTOM_RECOIL_MODE_COMPENSATING and 8 or 48

    speed = ft * speed
    currentPosition = aerial.math.Lerp(speed, currentPosition, targetPosition)
    currentAngles = aerial.math.Lerp(speed, currentAngles, targetAngles)

    self:SetCustomRecoilPosition(currentPosition)
    self:SetCustomRecoilAngles(currentAngles)
end
