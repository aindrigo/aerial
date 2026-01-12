--[[
    Aerial, a weapon base designed to ease the creation of realistic weapons within Garry's Mod.
    Copyright (C) 2026  aindrigo

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]--

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
end

function SWEP:VMDrawRenderTarget(name, data, vm, model, rtData)
    local width = aerial.renderTarget.widthConvar:GetInt()
    local height = aerial.renderTarget.heightConvar:GetInt()

    local renderData = {}
    renderData.origin = vm:GetPos()
    renderData.angles = vm:GetAngles()
    renderData.fov = rtData.FOV or 14
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

    if rtData.SubMaterial then
        model:SetSubMaterial(rtData.SubMaterial, "!"..aerial.renderTarget.material:GetName())
    end
end

function SWEP:ViewModelDrawn(vm, flags)
    local attachments = aerial.Attachments.Data[self:EntIndex()] or {}
    for name, data in pairs(attachments) do
        self:VMDrawAttachment(name, data, vm, flags)
    end
end