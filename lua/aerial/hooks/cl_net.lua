net.Receive("aerial.SyncAttachments", function()
    local weaponCount = net.ReadUInt(16)
    for _ = 1, weaponCount do
        local index = net.ReadUInt(16)
        local attachmentCount = net.ReadUInt(8)
        local attachments = {}

        for _ = 1, attachmentCount do
            local id = net.ReadString()
            table.insert(attachments, id)
        end

        aerial.Attachments.Data[index] = attachments
    end
end)

net.Receive("aerial.AddAttachment", function()
    local index = net.ReadUInt(16)
    aerial.Attachments.Data[index] = aerial.Attachments.Data[index] or {}

    local name = net.ReadString()
    table.insert(aerial.Attachments.Data[index], name)
end)

net.Receive("aerial.RemoveAttachment", function()
    local index = net.ReadUInt(16)
    aerial.Attachments.Data[index] = aerial.Attachments.Data[index] or {}

    local name = net.ReadString()
    local attachmentIndex

    for i, attachmentName in ipairs(aerial.Attachments.Data[index]) do
        if attachmentName == name then
            attachmentIndex = i
        end
    end

    if attachmentIndex == nil then return end
    table.remove(aerial.Attachments.Data[index], attachmentIndex)
end)