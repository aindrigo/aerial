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

function SWEP:GetMuzzleAttachment()
    self.m_tMuzzle = self.m_tMuzzle or self:FindMuzzleAttachment()
    return self.m_tMuzzle
end

function SWEP:ResetMuzzleAttachment()
    self.m_tMuzzle = self:FindMuzzleAttachment()
end

function SWEP:FindMuzzleAttachment()
    local hookResult = self:FireHook("FindMuzzleAttachment")
    if hookResult ~= nil then
        return hookResult
    end

    local vmSettings = self.VMSettings or {}

    local vm = self:VM()
    local dummy = ClientsideModel(vm:GetModel(), RENDERGROUP_VIEWMODEL)
    dummy:Spawn()
    dummy:ResetSequence(dummy:SelectWeightedSequence(self.IdleAnimation or ACT_VM_IDLE))

    local muzzleAttachmentName = vmSettings.MuzzleAttachmentName or "muzzle"
    local muzzleAttachmentIndex = dummy:LookupAttachment(muzzleAttachmentName)
    local muzzleAttachment = {}
    if muzzleAttachmentIndex > 0 then
        muzzleAttachment = dummy:GetAttachment(muzzleAttachmentIndex)
    else
        muzzleAttachment.Pos = Vector(0, 0, 0)
        muzzleAttachment.Ang = Angle(0, 0, 0)
        muzzleAttachment.Bone = 0

        aerial.dprint("Warning: muzzle attachment "..muzzleAttachmentName.." not found")
        return muzzleAttachment
    end

    -- Make muzzle an offset
    muzzleAttachment.Pos = dummy:WorldToLocal(muzzleAttachment.Pos)
    muzzleAttachment.Ang = dummy:WorldToLocalAngles(muzzleAttachment.Ang)

    -- Cleanup
    dummy:Remove()

    return muzzleAttachment
end

function SWEP:GetRealMuzzleAttachment()
    local hookResult = self:FireHook("GetRealMuzzleAttachment")
    if hookResult ~= nil then
        return hookResult
    end
    
    local vm = self:VM()
    local vmSettings = self.VMSettings or {}

    local muzzleAttachmentName = self.VMSettings.MuzzleAttachmentName or "muzzle"
    local muzzleAttachmentIndex = vm:LookupAttachment(muzzleAttachmentName)
    local muzzleAttachment = {}
    if muzzleAttachmentIndex > 0 then
        muzzleAttachment = vm:GetAttachment(muzzleAttachmentIndex)
        muzzleAttachment.Pos = vm:WorldToLocal(muzzleAttachment.Pos)
        muzzleAttachment.Ang = vm:WorldToLocalAngles(muzzleAttachment.Ang)
    else
        muzzleAttachment.Pos = Vector(0, 0, 0)
        muzzleAttachment.Ang = Angle(0, 0, 0)
        muzzleAttachment.Bone = 0

        aerial.dprint("Warning: muzzle attachment "..muzzleAttachmentName.." not found")
    end

    

    return muzzleAttachment
end