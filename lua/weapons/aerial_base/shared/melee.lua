--[[
    Aerial, a weapon base designed to ease the creation of realistic weapons within Garry's Mod.
    Copyright (C) 2026  aindrigo

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]--

function SWEP:AttackMelee(id)
    if self:FireHook("AttackMelee", id) then return end

    local data = self:GetAttackTable(id)

    if isstring(data.StartSound) then
        self:EmitSound(data.StartSound)
    end

    if not isnumber(data.HitDelay) or data.HitDelay <= 0 then
        local attackData = self:BuildAttackData(id)
        self:AttackMeleePerform(id, attackData)
        return
    end

    local ct = CurTime()
    self:SetCurrentAttackTime(ct + data.HitDelay)
    self:SetCurrentAttackName(id)
end

function SWEP:AttackMeleePerform(id, attackData)
    if self:FireHook("AttackMeleePerform", id, attackData) then return end
    local ct = CurTime()

    local ply = attackData.Attacker
    local data = self:GetAttackTable(id)

    attackData.Traces = {}
    attackData.Delay = attackData.Delay or data.Delay or 0
    attackData.Range = attackData.Range or data.Range or 70

    self:SetNextAttack(id, ct + attackData.Delay)

    ply:LagCompensation(true)
    for i = 1, (data.HitCount or 1) do
        local traceResult = self:AttackMeleeTrace(id, attackData, i)
        table.insert(attackData.Traces, traceResult)

        if traceResult.Hit and IsValid(traceResult.Entity) then
            self:AttackHitEntity(id, attackData, traceResult)
        end
    end
    ply:LagCompensation(false)

    self:AttackMeleeEffects(id, attackData)
end

function SWEP:AttackMeleeTrace(id, attackData, index)
    local hookResult = self:FireHook("AttackMeleeTrace", id, attackData, index)
    if istable(hookResult) then
        return hookResult
    end

    local data = self:GetAttackTable(id)
    if not isvector(attackData.HullMins) then
        if isvector(data.HullMins) then
            attackData.HullMins = data.HullMins
        elseif isnumber(data.HullSize) then
            attackData.HullMins = Vector(-data.HullSize, -data.HullSize, -data.HullSize)
        elseif isvector(data.HullMaxs) then
            attackData.HullMins = -data.HullMaxs
        end
    end

    if not isvector(attackData.HullMaxs) then
        if isvector(data.HullMaxs) then
            attackData.HullMaxs = data.HullMaxs
        elseif isnumber(data.HullSize) then
            attackData.HullMaxs = Vector(data.HullSize, data.HullSize, data.HullSize)
        elseif isvector(data.HullMins) then
            attackData.HullMaxs = -data.HullMins
        end
    end

    local ply = attackData.Attacker

    local traceData = {}
    traceData.start = attackData.Position
    traceData.endpos = traceData.start + attackData.Direction * attackData.Range
    traceData.filter = ply
    traceData.mask = MASK_SHOT_HULL

    traceData.mins = attackData.HullMins
    traceData.maxs = attackData.HullMaxs

    return util.TraceHull(traceData)
end

function SWEP:AttackMeleeEffects(id, attackData)
    if self:FireHook("AttackMeleeEffects", id, attackData) then return end
    local data = self:GetAttackTable(id)

    local ply = attackData.Attacker
    ply:SetAnimation(PLAYER_ATTACK1)

    self:PlayAnimation(attackData.SwingAnimation or data.SwingAnimation or ACT_VM_PRIMARYATTACK)
    self:QueueIdle()
end