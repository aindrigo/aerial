function SWEP:AddAttachment(name)
    if not istable(self.Attachments) or not istable(self.Attachments[id]) then
        error("Invalid attachment "..name)
        return
    end

    local id = self:EntIndex()

    aerial.Attachments.Data[id] = aerial.Attachments.Data[id] or {}
    table.insert(aerial.Attachments.Data[id], name)

    net.Start("aerial.AddAttachment")
    net.WriteUInt(self:EntIndex(), 32)
    net.WriteString(name)
    net.Broadcast()
end

function SWEP:RemoveAttachment(name)
    if not istable(self.Attachments) or not istable(self.Attachments[id]) then
        error("Invalid attachment "..name)
        return
    end

    local id = self:EntIndex()
    local attachmentIndex

    for i, attachmentName in ipairs(aerial.Attachments.Data[id] or {}) do
        if attachmentName == name then
            attachmentIndex = i
        end
    end

    if attachmentIndex == nil then return end
    table.remove(aerial.Attachments.Data[id], attachmentIndex)
end