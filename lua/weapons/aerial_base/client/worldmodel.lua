function SWEP:DrawWorldModel(flags)
    if not istable(self.WM) or not istable(self.WM.Offset) or not (isvector(self.WM.Offset.Position) and not isangle(self.WM.Offset.Angles)) then
        self:DrawModel(flags)
        return
    end

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

        if istable(self.WM) then
            if istable(self.WM.Offset) then
                if isvector(self.WM.Offset.Position) then
                    matrix:Translate(self.WM.Offset.Position)
                end

                if isangle(self.WM.Offset.Angles) then
                    matrix:Rotate(self.WM.Offset.Angles)
                end
            end
        end

        wm:SetPos(matrix:GetTranslation())
        wm:SetAngles(matrix:GetAngles())

        wm:SetupBones()
    else
        wm:SetPos(self:GetPos())
        wm:SetAngles(self:GetAngles())
    end


    wm:DrawModel(flags)
end