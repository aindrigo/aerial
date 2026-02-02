function SWEP:GetAttackMagazineCount(id)
    if id == "Primary" then
        return self:Clip1()
    elseif id == "Secondary" then
        return self:Clip2()
    end

    return self["Get"..id.."MagazineCount"](self)
end

function SWEP:SetAttackMagazineCount(id, value)
    if id == "Primary" then
        return self:SetClip1(value)
    elseif id == "Secondary" then
        return self:SetClip2(value)
    end

    return self["Set"..id.."MagazineCount"](self, value)
end
