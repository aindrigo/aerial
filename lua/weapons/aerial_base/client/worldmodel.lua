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