
function SWEP:WMDrawElement(index, elementData, wm, flags)
    local state = self._wmElements[index]
    if not istable(state) then
        state = {}
        local csModel = ClientsideModel(elementData.Model)
        csModel:SetParent(wm)
        csModel:SetNoDraw(true)
        if elementData.BoneMerge then
            csModel:AddEffects(EF_BONEMERGE)
        end

        if elementData.Scale then
            csModel:SetModelScale(elementData.Scale)
        end

        state.csModel = csModel
        self._wmElements[index] = state
    end

    local csModel = state.csModel
    if csModel:GetParent() ~= wm then
        csModel:SetParent(wm)
    end

    csModel:DrawModel(flags)
end

function SWEP:DrawWorldModel(flags)
    if not istable(self.WM) then
        self:DrawModel(flags)
        return
    end

    local data = self.WM

    local wm = self.m_eWorldModel
    if not IsValid(wm) then
        wm = ClientsideModel(self.WorldModel)
        wm:SetNoDraw(true)
        self.m_eWorldModel = wm
    end

    local ply = self:GetOwner()
    if IsValid(ply) then
        local boneId = ply:LookupBone("ValveBiped.Bip01_R_Hand")
        if not boneId then return end

        local matrix = ply:GetBoneMatrix(boneId)
        if not matrix then return end

        if istable(data.Offset) then
            if isvector(data.Offset.Position) then
                matrix:Translate(data.Offset.Position)
            end

            if isangle(data.Offset.Angles) then
                matrix:Rotate(data.Offset.Angles)
            end
        end

        wm:SetPos(matrix:GetTranslation())
        wm:SetAngles(matrix:GetAngles())

        wm:SetupBones()
    else
        wm:SetPos(self:GetPos())
        wm:SetAngles(self:GetAngles())
    end

    if istable(data.Elements) then
        self._wmElements = self._wmElements or {}
        for index, elementData in ipairs(data.Elements) do
            self:WMDrawElement(index, elementData, wm, flags)
        end
    end

    wm:DrawModel(flags)
end
