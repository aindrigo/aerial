AddCSLuaFile("base.lua")
include("base.lua")

for _, fileName in ipairs(file.Find("weapons/aerial_base/shared/*.lua", "LUA")) do
    local filePath = "shared/"..fileName
    AddCSLuaFile(filePath)
    include(filePath)
end

if SERVER then
    for _, fileName in ipairs(file.Find("weapons/aerial_base/server/*.lua", "LUA")) do
        local filePath = "server/"..fileName
        include(filePath)
    end
end

for _, fileName in ipairs(file.Find("weapons/aerial_base/client/*.lua", "LUA")) do
    local filePath = "client/"..fileName
    AddCSLuaFile(filePath)
    if CLIENT then
        include(filePath)
    end
end
