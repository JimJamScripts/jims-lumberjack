--========================================================--
--  JIMS LUMBERJACK - SERVER PERMISSION SYSTEM
--========================================================--

--========================================================--
--  CHECK PERMISSION
--========================================================--
local function HasPermission(src, permission)
    local rank = LumberServer.GetRank(src)
    return Permissions:HasAccess(rank, permission)
end

--========================================================--
--  EXPORT FOR OTHER SERVER FILES
--========================================================--
LumberPerms = {}

function LumberPerms.Check(src, permission)
    return HasPermission(src, permission)
end

--========================================================--
--  DENY HELPER
--========================================================--
local function Deny(src, reason)
    reason = reason or "You do not have permission to do that."
    TriggerClientEvent("chat:addMessage", src, {
        color = {255, 50, 50},
        multiline = false,
        args = {"Lumber Co.", reason}
    })
end

--========================================================--
--  PERMISSION VALIDATION WRAPPER
--========================================================--
function LumberPerms.Require(src, permission)
    if not HasPermission(src, permission) then
        Deny(src)
        return false
    end
    return true
end

--========================================================--
--  LOG PERMISSION VIOLATIONS
--========================================================--
local function LogViolation(src, permission)
    local name = GetPlayerName(src) or "Unknown"
    print(("^1[JIMS-LUMBERJACK] PERMISSION VIOLATION:^0 %s attempted %s"):format(name, permission))
end

--========================================================--
--  SECURE SERVER EVENT WRAPPER
--========================================================--
function LumberPerms.SecureEvent(src, permission)
    if not HasPermission(src, permission) then
        LogViolation(src, permission)
        Deny(src)
        return false
    end
    return true
end

--========================================================--
--  RETURN MODULE
--========================================================--
return LumberPerms
