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

function SWEP:PlayAnimation(id)
    self:FireHook("PlayAnimation", id)
    local vm = self:VM()
    local sequence = isstring(id) and vm:LookupSequence(id) or vm:SelectWeightedSequence(id)

    if sequence <= 0 then
        return aerial.dprint("Invalid animation "..id.." played")
    end

    vm:ResetSequenceInfo()
    vm:SendViewModelMatchingSequence(sequence)

    return vm:SequenceDuration(sequence)
end

function SWEP:QueueIdle()
    local vm = self:VM()
    local duration = vm:SequenceDuration() + 0.1
    self:SetIdleTime(CurTime() + duration)
end