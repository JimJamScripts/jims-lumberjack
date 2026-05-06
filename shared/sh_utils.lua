--========================================================--
--  JIMS LUMBERJACK - SHARED UTILITY FUNCTIONS
--========================================================--

Utils = {}

--========================================================--
--  DEBUG PRINT
--========================================================--
function Utils.Debug(msg)
    if Config.Debug then
        print("^3[JIMS-LUMBERJACK DEBUG]^0 " .. tostring(msg))
    end
end

--========================================================--
--  SAFE JSON LOAD
--========================================================--
function Utils.LoadJSON(path, fallback)
    local file = LoadResourceFile(GetCurrentResourceName(), path)
    if not file or file == "" then
        Utils.Debug("JSON missing, creating new: " .. path)
        return fallback or {}
    end

    local decoded = json.decode(file)
    if not decoded then
        Utils.Debug("JSON decode failed for: " .. path)
        return fallback or {}
    end

    return decoded
end

--========================================================--
--  SAFE JSON SAVE
--========================================================--
function Utils.SaveJSON(path, data)
    if not data then return end
    SaveResourceFile(GetCurrentResourceName(), path, json.encode(data, { indent = true }), -1)
end

--========================================================--
--  DEEP COPY TABLE
--========================================================--
function Utils.DeepCopy(tbl)
    if type(tbl) ~= "table" then return tbl end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = Utils.DeepCopy(v)
    end
    return copy
end

--========================================================--
--  TABLE CONTAINS VALUE
--========================================================--
function Utils.TableContains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then return true end
    end
    return false
end

--========================================================--
--  RANDOM DELIVERY ROUTE
--========================================================--
function Utils.RandomRoute()
    local routes = Config.DeliveryRoutes
    return routes[math.random(1, #routes)]
end

--========================================================--
--  SAFE NUMBER CHECK
--========================================================--
function Utils.SafeNumber(num, fallback)
    num = tonumber(num)
    if not num then return fallback or 0 end
    return num
end

--========================================================--
--  CLAMP NUMBER
--========================================================--
function Utils.Clamp(num, min, max)
    if num < min then return min end
    if num > max then return max end
    return num
end

--========================================================--
--  VECTOR DISTANCE (CLIENT + SERVER SAFE)
--========================================================--
function Utils.Distance(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = a.z - b.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

--========================================================--
--  GET PLAYER IDENTIFIER (SERVER)
--========================================================--
function Utils.GetIdentifier(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:sub(1, 8) == "license:" then
            return id
        end
    end
    return nil
end

--========================================================--
--  EXPORTS
--========================================================--
return Utils
