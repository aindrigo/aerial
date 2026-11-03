aerial.sound = aerial.sound or {}

function aerial.sound.DefineHandlingSound(name, path)
    sound.Add({
        name = name,
        sound = path,
        channel = CHAN_STATIC
    })
end

function aerial.sound.DefineFiringSound(name, path, pitchRange)
    if isstring(path) then
        util.PrecacheSound(path)
    elseif istable(path) then
        for _, p in ipairs(path) do
            util.PrecacheSound(p)
        end
    end

    if pitchRange == nil then
        pitchRange = { 99, 101 }
    elseif isnumber(pitchRange) then
        pitchRange = { 100 - pitchRange, 100 + pitchRange }
    end

    sound.Add({
        name = name,
        sound = path,
        channel = CHAN_WEAPON,
        pitch = pitchRange
    })
end

aerial.sound.DefineHandlingSound("Aerial.AimIn", {
    "weapons/ins2/uni/uni_ads_in_01.wav",
    "weapons/ins2/uni/uni_ads_in_02.wav",
    "weapons/ins2/uni/uni_ads_in_03.wav",
    "weapons/ins2/uni/uni_ads_in_04.wav",
    "weapons/ins2/uni/uni_ads_in_05.wav",
    "weapons/ins2/uni/uni_ads_in_06.wav"
})

aerial.sound.DefineHandlingSound("Aerial.AimOut", "weapons/ins2/uni/uni_ads_out_01.wav")
