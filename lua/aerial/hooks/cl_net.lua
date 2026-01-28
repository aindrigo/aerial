net.Receive("aerial.SyncAttachments", function()
    local weaponCount = net.ReadUInt(16)
    for _ = 1, weaponCount do
        local index = net.ReadUInt(16)
        local weapon = Entity(index)
        if not IsValid(weapon) or not weapon:IsWeapon() or not weapon.Aerial then return end

        if istable(aerial.Attachments.Data[index]) then
            for name, _ in pairs(aerial.Attachments.Data[index]) do
                weapon:TakeAttachment(name)
            end
        end

        aerial.Attachments.Data[index] = {}
        local attachmentCount = net.ReadUInt(8)

        for _ = 1, attachmentCount do
            local id = net.ReadString()
            weapon:GiveAttachment(id)
        end
    end
end)

net.Receive("aerial.AddAttachment", function()
    local index = net.ReadUInt(16)
    local weapon = Entity(index)
    if not IsValid(weapon) or not weapon:IsWeapon() or not weapon.Aerial then return end

    weapon:GiveAttachment(net.ReadString())
end)

net.Receive("aerial.RemoveAttachment", function()
    local index = net.ReadUInt(16)
    local weapon = Entity(index)
    if not IsValid(weapon) or not weapon:IsWeapon() or not weapon.Aerial then return end

    weapon:TakeAttachment(net.ReadString())
end)