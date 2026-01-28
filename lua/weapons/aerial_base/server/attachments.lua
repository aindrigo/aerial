function SWEP:GiveAttachment(name, network)
    self:FireHook("GiveAttachment", name, network)

    if not istable(self.Attachments) or not istable(self.Attachments[name]) then
        error("Invalid attachment "..name)
        return
    end

    self:_AddAttachment(name)

    if network ~= false then
        net.Start("aerial.AddAttachment")
        net.WriteUInt(self:EntIndex(), 16)
        net.WriteString(name)
        net.Broadcast()
    end
end

function SWEP:TakeAttachment(name, network)
    self:FireHook("GiveAttachment", name, network)
    if not istable(self.Attachments) or not istable(self.Attachments[name]) then
        error("Invalid attachment "..name)
        return
    end

    self:_RemoveAttachment(name)
    if network ~= false then
        net.Start("aerial.RemoveAttachment")
        net.WriteUInt(self:EntIndex(), 16)
        net.WriteString(name)
        net.Broadcast()
    end
end