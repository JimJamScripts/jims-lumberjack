--========================================================--
--  JIMS LUMBERJACK - SERVER PERMISSIONS (VORP READY)
--========================================================--

local VORPcore = exports.vorp_core:getCore()

Permissions = {}

--========================================================--
--  GET PLAYER RANK (VORP CHARACTER)
--========================================================--
local function GetRank(src)
    local user = VORPcore.getUser(src)
    if not user then return PermissionsConfig.Ranks.CIVILIAN end

    local char = user.getUsedCharacter()
    if not char then return PermissionsConfig.Ranks.CIVILIAN end

    local identifier = char.charIdentifier
    if not identifier then return PermissionsConfig.Ranks.CIVILIAN end

    local employees = LumberServer.GetData().employees
    local emp = employees[identifier]

    return emp and emp.rank or PermissionsConfig.Ranks.CIVILIAN
end

--========================================================--
--  CHECK ACCESS
--========================================================--
function Permissions.Require(src, permission)
    local rank = GetRank(src)
    return PermissionsConfig:HasAccess(rank, permission)
end

--========================================================--
--  DIRECT ACCESS CHECK
--========================================================--
function Permissions.Has(src, permission)
    local rank = GetRank(src)
    return PermissionsConfig:HasAccess(rank, permission)
end

--========================================================--
--  GET RANK NAME
--========================================================--
function Permissions.GetRankName(src)
    local rank = GetRank(src)
    return PermissionsConfig:GetRankName(rank)
end

--========================================================--
--  EXPORT MODULE
--========================================================--
return Permissions
