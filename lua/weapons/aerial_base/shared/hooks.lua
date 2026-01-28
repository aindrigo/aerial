function SWEP:FireHook(name, ...)
    local attachments = aerial.Attachments.Data[self:EntIndex()]
    if istable(attachments) then
        for attachmentName, _ in pairs(attachments) do
            local attachment = self.Attachments[attachmentName]
            if not istable(attachments) or not istable(attachments.Hooks) then continue end

            local func = attachments.Hooks[name]
            if not isfunction(func) then continue end

            local result = func(self, ...)
            if result ~= nil then
                return result
            end
        end
    end

    if not istable(self.Hooks) then return end

    local hookFunction = self.Hooks[name]
    if not isfunction(hookFunction) then return end

    return hookFunction(self, ...)
end