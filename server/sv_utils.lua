--========================================================--
--  JIMS LUMBERJACK - SERVER UTILITY FUNCTIONS (VORP READY)
--========================================================--

Utils = {}

--========================================================--
--  LOAD JSON FILE
--========================================================--
function Utils.LoadJSON(path, default)
    local file = LoadResourceFile(GetCurrentResourceName(), path)
    if not file or file == "" then
        return default
    end

    local decoded = json.decode(file)
    if not decoded then
        print(("^1[ERROR]^0 Failed to decode JSON file: %s"):format(path))
        return default
    end

    return decoded
end

--========================================================--
--  SAVE JSON FILE
--========================================================--
function Utils.SaveJSON(path, data)
    local encoded = json.encode(data, {indent = true})
    SaveResourceFile(GetCurrentResourceName(), path, encoded, -1)
end

--========================================================--
--  GET PLAYER IDENTIFIER (VORP CHARACTER)
--========================================================--
function Utils.GetIdentifier(src)
    local VORPcore = exports.vorp_core:getCore()
    local user = VORPcore.getUser(src)
    if not user then return nil end

    local char = user.getUsedCharacter()
    if not char then return nil end

    return char.charIdentifier
end

--========================================================--
--  DISTANCE HELPER
--========================================================--
function Utils.Distance(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = a.z - b.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

--========================================================--
--  DEBUG LOGGING
--========================================================--
Utils.DebugEnabled = true

function Utils.Debug(msg)
    if Utils.DebugEnabled then
        print("^3[JIMS-LUMBERJACK DEBUG]^0 " .. tostring(msg))
    end
end

--========================================================--
--  SAFE NUMBER PARSE
--========================================================--
function Utils.ToNumber(v, fallback)
    local n = tonumber(v)
    return n or fallback
end

--========================================================--
--  SAFE TABLE ENSURE
--========================================================--
function Utils.EnsureTable(tbl)
    return tbl or {}
end

--========================================================--
--  RETURN MODULE
--========================================================--
return Utils
