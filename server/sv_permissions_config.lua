--========================================================--
--  JIMS LUMBERJACK - PERMISSION CONFIG
--========================================================--

Permissions = {}

--========================================================--
--  RANK DEFINITIONS
--========================================================--
Permissions.Ranks = {
    CIVILIAN = 0,
    WORKER   = 1,
    SENIOR   = 2,
    FOREMAN  = 3,
    OWNER    = 4
}

Permissions.RankNames = {
    [0] = "Civilian",
    [1] = "Worker",
    [2] = "Senior Worker",
    [3] = "Foreman",
    [4] = "Owner"
}

--========================================================--
--  PERMISSION GROUPS
--========================================================--
Permissions.Groups = {
    -- Workers
    Processing       = {1, 2, 3, 4},
    StorageAccess    = {1, 2, 3, 4},
    Wagons           = {1, 2, 3, 4},
    Deliveries       = {1, 2, 3, 4},

    -- Foreman + Owner
    ShopfrontManage  = {3, 4},
    OfficeMenu       = {3, 4},

    -- Owner only
    OfficeManage     = {4}
}

--========================================================--
--  CHECK ACCESS
--========================================================--
function Permissions:HasAccess(rank, permission)
    local allowed = self.Groups[permission]
    if not allowed then return false end

    for _, r in ipairs(allowed) do
        if r == rank then
            return true
        end
    end

    return false
end

return Permissions
