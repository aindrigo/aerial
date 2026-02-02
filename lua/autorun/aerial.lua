aerial = aerial or {}

-- Major, minor, revision/patch
aerial.version = { 1, 0, 0 }

aerial.color = Color(62, 178, 20)

--- Includes a file
-- @string filePath File path
-- @string[opt] fileName File name, auto-detected if not provided
-- @realm shared
-- @internal
function aerial.include(filePath, fileName)
    if fileName == nil then
        local split = string.Explode("/", filePath)
        fileName = split[#split]
    end

    if string.StartsWith(fileName, "cl_") then
        AddCSLuaFile(filePath)
        if CLIENT then
            include(filePath)
        end
    elseif string.StartsWith(fileName, "sv_") then
        include(filePath)
    else
        AddCSLuaFile(filePath)
        include(filePath)
    end
end

--- Includes all file in a directory using aerial.include
-- @string dirPath The directory path
-- @realm shared
function aerial.includeDirectory(dirPath)
    for _, fileName in ipairs(file.Find(dirPath.."/*.lua", "LUA")) do
        aerial.include(dirPath.."/"..fileName, fileName)
    end
end

--- Prints only when `developer 1` is enabled
-- @string msg The message to print
-- @realm shared
function aerial.dprint(msg)
    local dev = GetConVar("developer")
    if dev:GetBool() then
        print("[aerial debug] "..msg)
    end
end

aerial.includeDirectory("aerial/libs")
aerial.includeDirectory("aerial")
aerial.includeDirectory("aerial/hooks")