function SWEP:HasAttachment(name)
    local id = self:EntIndex()
    if not istable(self.Attachments) or not istable(self.Attachments[name]) or not istable(aerial.Attachments.Data[id]) then
        return false
    end

    return istable(aerial.Attachments.Data[id][name])
end

function SWEP:AttachmentExists(name)
    return istable(self.Attachments) and istable(self.Attachments[name])
end

function SWEP:_ApplyAttachmentOverrides(name, tree, key, value)
    if istable(value) then
        tree = tree[key]
        for k, v in pairs(value) do
            self:_ApplyAttachmentOverrides(name, tree, k, v)
        end

        return
    end

    tree[key] = value
end

function SWEP:_AddAttachment(name)
    local id = self:EntIndex()
    aerial.Attachments.Data[id] = aerial.Attachments.Data[id] or {}
    aerial.Attachments.Data[id][name] = {}

    self:_RefreshAttachmentOverrides(name)
end

function SWEP:_RemoveAttachment(name)
    local id = self:EntIndex()
    aerial.Attachments.Data[id] = aerial.Attachments.Data[id] or {}

    local attachmentData = self.Attachments[name]
    if istable(attachmentData.Overrides) then
        local base = weapons.Get(self:GetClass())
        for key, value in pairs(attachmentData.Overrides) do
            self[key] = base[key]
        end
    end

    local data = aerial.Attachments.Data[id][name]
    aerial.Attachments.Data[id][name] = nil

    return data
end

function SWEP:_RefreshAttachmentOverrides(name)
    local attachmentData = self.Attachments[name]
    if istable(attachmentData.Overrides) then
        for key, value in pairs(attachmentData.Overrides) do
            self:_ApplyAttachmentOverrides(name, self, key, value)
        end
    end
end