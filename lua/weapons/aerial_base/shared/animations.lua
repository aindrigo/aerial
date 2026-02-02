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

function SWEP:GetAnimationDuration(id)
    local vm = self:VM()
    local sequence = isstring(id) and vm:LookupSequence(id) or vm:SelectWeightedSequence(id)

    return vm:SequenceDuration(sequence)
end

function SWEP:QueueIdle()
    local vm = self:VM()
    local duration = vm:SequenceDuration() + 0.1
    self:SetIdleTime(CurTime() + duration)
end