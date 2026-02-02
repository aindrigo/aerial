function SWEP:DrawAttachmentHUD(name, data)
    local attachment = self.Attachments[name]
    if not istable(attachment) then return end

    if istable(attachment.Cosmetic) and istable(attachment.Cosmetic.View) then
        local vm = self:VM()
        local cosmeticData = attachment.Cosmetic.View
        local model = data.m_eCSModelVM

        if IsValid(model) and istable(cosmeticData.RenderTarget) then
            self:VMDrawRenderTarget(name, data, vm, model, cosmeticData.RenderTarget)
        end
    end
end


function SWEP:DrawDeveloperHUD()
    local y = 48
    surface.SetTextPos(48, y)
    surface.SetFont("aerial48")
    surface.SetTextColor(aerial.color)
    surface.DrawText("aerial")

    y = y + 48
    surface.SetTextColor(color_white)
    surface.SetTextPos(48, y)
    surface.SetFont("aerial24")
    surface.DrawText("Version "..tostring(aerial.version[1]).."."..tostring(aerial.version[2]).."."..tostring(aerial.version[3]))

    y = y + 24
    surface.SetTextPos(48, y)
    surface.SetFont("aerial24")
    surface.DrawText("Last Attack: "..self:GetLastAttackName())

    y = y + 48

    local attackData = self:GetLastAttackTable()
    for name, attackData in pairs(self:GetAttackTables()) do
        if attackData.Ammo == "none" then continue end

        surface.SetFont("aerial32")
        surface.SetTextPos(48, y)
        surface.DrawText(name)
        y = y + 32

        surface.SetFont("aerial24")
        surface.SetTextPos(48, y)
        surface.DrawText("Damage: "..tostring(attackData.Damage))
        y = y + 24

        local spreadData = attackData.Spread or {}
        surface.SetTextPos(48, y)
        surface.DrawText("Cone: "..tostring(spreadData.Cone or 0))
        y = y + 24

        self.m_tLastAttacks = self.m_tLastAttacks or {}
        local lastAttack = self.m_tLastAttacks[name] or {}

        surface.SetTextPos(48, y)
        surface.DrawText("Last Spread: "..tostring(lastAttack.Spread or vector_origin))
        y = y + 24

        surface.SetTextPos(48, y)
        surface.DrawText("Last Recoil: "..tostring(lastAttack.Recoil or vector_origin))

        y = y + 48
    end

end

function SWEP:DrawHUD()
    if aerial.console.debug:GetBool() then
        self:DrawDeveloperHUD()
    end

    local attachments = aerial.Attachments.Data[self:EntIndex()]
    if istable(attachments) then
        for name, data in pairs(attachments) do
            self:DrawAttachmentHUD(name, data)
        end
    end
end
