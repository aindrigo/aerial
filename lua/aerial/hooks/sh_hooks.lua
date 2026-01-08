hook.Add("PlayerButtonDown", "aerialButtonDown", function(ply, button)
    local code = ply:GetInfoNum("aerial_bind_firemode", 0)
    if code < 1 or button ~= code then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or not wep:IsWeapon() or not wep.Aerial then return end

    wep:ToggleFireMode()
end)

hook.Add("EntityRemoved", "aerialEntityRemoved", function(ent, fullUpdate)
    if not ent:IsWeapon() or not ent.Aerial or (CLIENT and fullUpdate) then return end

    local index = ent:EntIndex()
    aerial.Attachments.Data[index] = nil
end)