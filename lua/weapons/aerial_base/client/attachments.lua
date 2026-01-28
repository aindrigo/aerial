function SWEP:GiveAttachment(name)
    self:FireHook("GiveAttachment", name)
    self:_AddAttachment(name)
end

function SWEP:TakeAttachment(name)
    self:FireHook("TakeAttachment", name)

    local id = self:EntIndex()
    aerial.Attachments.Data[id] = aerial.Attachments.Data[id] or {}
    local data = self:_RemoveAttachment(name)

    if IsValid(data.m_eCSModelVM) then
        data.m_eCSModelVM:Remove()
    end
end

function SWEP:VMDrawAttachment(name, data, vm, flags)
    local attachment = self.Attachments[name]
    if not istable(attachment.Cosmetic) or not istable(attachment.Cosmetic.View) then return end

    local cosmeticData = attachment.Cosmetic.View
    local model = data.m_eCSModelVM

    if not IsValid(model) then
        model = ClientsideModel(cosmeticData.Model, RENDERGROUP_VIEWMODEL)
        model:SetParent(vm)
        model:SetNoDraw(true)
        data.m_eCSModelVM = model
    end

    local matrix
    if cosmeticData.Bone then
        local bone = vm:LookupBone(cosmeticData.Bone)

        if not bone then
            aerial.dprint("No such bone "..cosmeticData.Bone)
            return
        end

        matrix = vm:GetBoneMatrix(bone)
        if not matrix then
            aerial.dprint("Could not get bone matrix for "..cosmeticData.Bone)
            return
        end
    else
        matrix = Matrix()
        matrix:Translate(vm:GetPos())
        matrix:Rotate(vm:GetAngles())
    end

    if isvector(cosmeticData.Position) then
        matrix:Translate(cosmeticData.Position)
    end

    if isangle(cosmeticData.Angles) then
        matrix:Rotate(cosmeticData.Angles)
    end


    model:SetPos(matrix:GetTranslation())
    model:SetAngles(matrix:GetAngles())

    model:DrawModel(flags)

    if istable(cosmeticData.Reticule) then
        local shouldMask = cosmeticData.Reticule.Mask ~= false
        if shouldMask then
            aerial.render.MaskEntity(model)
        end

        self:VMDrawReticule(name, data, vm, model, matrix, cosmeticData.Reticule)
        
        if shouldMask then
            aerial.render.Unmask()
        end
    elseif istable(cosmeticData.Reticules) then
        aerial.render.MaskEntity(model)

        for _, reticule in ipairs(cosmeticData.Reticules) do
            if reticule.Mask == false then
                aerial.render.Unmask()
            end

            self:VMDrawReticule(name, data, vm, model, matrix, reticule)

            aerial.render.MaskEntity(model)
        end

        aerial.render.Unmask()
    end
end

function SWEP:VMDrawRenderTarget(name, data, vm, model, renderTargetData)
    local width = aerial.renderTarget.widthConvar:GetInt()
    local height = aerial.renderTarget.heightConvar:GetInt()

    local renderData = {}
    renderData.origin = vm:GetPos()
    renderData.angles = vm:GetAngles()
    renderData.fov = renderTargetData.FOV or 14
    renderData.x = 0
    renderData.y = 0
    renderData.w = width
    renderData.h = height

    renderData.drawviewmodel = false
    renderData.drawhud = false
    renderData.aspect = 1

    render.PushRenderTarget(aerial.renderTarget.rt)
    render.OverrideAlphaWriteEnable(true, true)

    cam.Start2D()
    render.Clear(0, 0, 0, 255)
    render.RenderView(renderData)
    cam.End2D()

    draw.NoTexture()
    render.PopRenderTarget()
    render.OverrideAlphaWriteEnable(false, false)

    if renderTargetData.SubMaterial then
        model:SetSubMaterial(renderTargetData.SubMaterial, "!"..aerial.renderTarget.material:GetName())
    end
end

function SWEP:VMDrawReticule(name, data, vm, model, modelMatrix, reticuleData)
    local matrix = Matrix(modelMatrix)

    if isvector(reticuleData.Position) then
        matrix:Translate(reticuleData.Position)
    end

    if isangle(reticuleData.Angles) then
        matrix:Rotate(reticuleData.Angles)
    end

    local rotation = matrix:GetAngles()

    render.SetMaterial(reticuleData.Material)
    render.DrawQuadEasy(
        matrix:GetTranslation(),
        rotation:Forward(),
        reticuleData.Width or 32,
        reticuleData.Height or 32,
        reticuleData.Color or color_white,
        rotation.r - 180
    )
end
