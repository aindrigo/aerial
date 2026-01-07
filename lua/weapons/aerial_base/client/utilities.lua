function SWEP:GetMuzzleAttachment()
    self.m_tMuzzle = self.m_tMuzzle or self:FindMuzzleAttachment()
    return self.m_tMuzzle
end

function SWEP:FindMuzzleAttachment()
    local vm = self:VM()

    local muzzleAttachmentName = self.MuzzleAttachmentName or "muzzle"
    local muzzleAttachmentIndex = vm:LookupAttachment(muzzleAttachmentName)
    local muzzleAttachment = {}
    if muzzleAttachmentIndex > 0 then
        muzzleAttachment = vm:GetAttachment(muzzleAttachmentIndex)
    else
        muzzleAttachment.Pos = vm:GetPos()
        muzzleAttachment.Ang = vm:GetAngles()
        muzzleAttachment.Bone = 0
    end

    -- Make muzzle an offset
    muzzleAttachment.Pos = muzzleAttachment.Pos - vm:GetPos()
    muzzleAttachment.Ang = muzzleAttachment.Ang - vm:GetAngles()
    return muzzleAttachment
end