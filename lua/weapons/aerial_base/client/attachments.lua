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

function SWEP:VMDrawAttachment(name, data)
    local attachment = self.Attachments[name]
    if not istable(attachment.Cosmetic) or not istable(attachment.Cosmetic.View) then return end

    local vm = self:VM()

    local cosmeticData = attachment.Cosmetic.View
    local csModel = data.m_eCSModelVM

    if not IsValid(csModel) then
        csModel = ClientsideModel(cosmeticData.Model, RENDERGROUP_VIEWMODEL)
        csModel:SetParent(vm)
        csModel:SetNoDraw(true)
        data.m_eCSModelVM = csModel
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

    csModel:SetPos(matrix:GetTranslation())
    csModel:SetAngles(matrix:GetAngles())
    csModel:DrawModel()
end

function SWEP:ViewModelDrawn()
    local vm = self:VM()
    if not IsValid(vm) then return end

    local attachments = aerial.Attachments.Data[self:EntIndex()] or {}
    for name, data in pairs(attachments) do
        self:VMDrawAttachment(name, data)
    end
end