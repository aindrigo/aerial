local PLAYER_META = FindMetaTable("Player")

function PLAYER_META:GetAerialFiremodeBind()
    local code = self:GetInfoNum("aerial_bind_firemode", 0)
    return code
end