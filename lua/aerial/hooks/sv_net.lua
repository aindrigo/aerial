util.AddNetworkString("aerial.SyncAttachments")
util.AddNetworkString("aerial.AddAttachment")
util.AddNetworkString("aerial.RemoivAttachment")

net.Receive("aerial.SyncAttachments", function(_, ply)
    local ct = CurTime()
    ply.m_fNextAerialSync = ply.m_fNextAerialSync or 0

    if ply.m_fNextAerialSync > ct then return end
    ply.m_fNextAerialSync = ct + 180

    net.WriteUInt(#aerial.Attachments.Data, 16)
    for index, attachments in pairs(aerial.Attachments.Data) do
        net.WriteUInt(index, 16)
        net.WriteUInt(#attachments, 8)
        for _, name in ipairs(attachments) do
            net.WriteString(name)
        end
    end
end)