--========================================================--
--  JIMS LUMBERJACK - PERMISSION DEFINITIONS
--========================================================--

Permissions = {}

--========================================================--
--  RANK DEFINITIONS
--========================================================--
Permissions.Ranks = {
    OWNER = 4,
    FOREMAN = 3,
    SENIOR = 2,
    LUMBERJACK = 1,
    CIVILIAN = 0
}

--========================================================--
--  PERMISSION TABLE
--========================================================--
Permissions.Access = {

    --------------------------------------------------------
    -- PROCESSING STATIONS
    --------------------------------------------------------
    Processing = {
        [Permissions.Ranks.OWNER] = true,
        [Permissions.Ranks.FOREMAN] = true,
        [Permissions.Ranks.SENIOR] = true,
        [Permissions.Ranks.LUMBERJACK] = true,
        [Permissions.Ranks.CIVILIAN] = false
    },

    --------------------------------------------------------
    -- WAGONS
    --------------------------------------------------------
    Wagons = {
        [Permissions.Ranks.OWNER] = true,
        [Permissions.Ranks.FOREMAN] = true,
        [Permissions.Ranks.SENIOR] = true,
        [Permissions.Ranks.LUMBERJACK] = true,
        [Permissions.Ranks.CIVILIAN] = false
    },

    --------------------------------------------------------
    -- SHOPFRONT: WITHDRAW ITEMS
    --------------------------------------------------------
    ShopfrontWithdraw = {
        [Permissions.Ranks.OWNER] = true,
        [Permissions.Ranks.FOREMAN] = true,
        [Permissions.Ranks.SENIOR] = false,
        [Permissions.Ranks.LUMBERJACK] = false,
        [Permissions.Ranks.CIVILIAN] = false
    },

    --------------------------------------------------------
    -- SHOPFRONT: DEPOSIT ITEMS
    --------------------------------------------------------
    ShopfrontDeposit = {
        [Permissions.Ranks.OWNER] = true,
        [Permissions.Ranks.FOREMAN] = true,
        [Permissions.Ranks.SENIOR] = false,
        [Permissions.Ranks.LUMBERJACK] = false,
        [Permissions.Ranks.CIVILIAN] = false
    },

    --------------------------------------------------------
    -- SHOPFRONT: MANAGE BUY LIST
    --------------------------------------------------------
    ShopfrontManage = {
        [Permissions.Ranks.OWNER] = true,
        [Permissions.Ranks.FOREMAN] = true,
        [Permissions.Ranks.SENIOR] = false,
        [Permissions.Ranks.LUMBERJACK] = false,
        [Permissions.Ranks.CIVILIAN] = false
    },

    --------------------------------------------------------
    -- OFFICE MENU ACCESS
    --------------------------------------------------------
    OfficeMenu = {
        [Permissions.Ranks.OWNER] = true,
        [Permissions.Ranks.FOREMAN] = true,
        [Permissions.Ranks.SENIOR] = false,
        [Permissions.Ranks.LUMBERJACK] = false,
        [Permissions.Ranks.CIVILIAN] = false
    },

    --------------------------------------------------------
    -- HIRING / FIRING
    --------------------------------------------------------
    Hire = {
        [Permissions.Ranks.OWNER] = true,
        [Permissions.Ranks.FOREMAN] = true,
        [Permissions.Ranks.SENIOR] = false,
        [Permissions.Ranks.LUMBERJACK] = false,
        [Permissions.Ranks.CIVILIAN] = false
    },

    Fire = {
        [Permissions.Ranks.OWNER] = true,
        [Permissions.Ranks.FOREMAN] = true,   -- but cannot fire Owner or other Foremen
        [Permissions.Ranks.SENIOR] = false,
        [Permissions.Ranks.LUMBERJACK] = false,
        [Permissions.Ranks.CIVILIAN] = false
    },

    --------------------------------------------------------
    -- PROMOTE / DEMOTE
    --------------------------------------------------------
    Promote = {
        [Permissions.Ranks.OWNER] = true,
        [Permissions.Ranks.FOREMAN] = false
    },

    Demote = {
        [Permissions.Ranks.OWNER] = true,
        [Permissions.Ranks.FOREMAN] = false
    },

    --------------------------------------------------------
    -- UPGRADES
    --------------------------------------------------------
    Upgrades = {
        [Permissions.Ranks.OWNER] = true,
        [Permissions.Ranks.FOREMAN] = false,
        [Permissions.Ranks.SENIOR] = false,
        [Permissions.Ranks.LUMBERJACK] = false,
        [Permissions.Ranks.CIVILIAN] = false
    },

    --------------------------------------------------------
    -- DELIVERIES
    --------------------------------------------------------
    Deliveries = {
        [Permissions.Ranks.OWNER] = true,
        [Permissions.Ranks.FOREMAN] = true,
        [Permissions.Ranks.SENIOR] = true,
        [Permissions.Ranks.LUMBERJACK] = true,
        [Permissions.Ranks.CIVILIAN] = false
    },

    --------------------------------------------------------
    -- PHYSICAL STORAGE PROPS
    --------------------------------------------------------
    StorageAccess = {
        [Permissions.Ranks.OWNER] = true,
        [Permissions.Ranks.FOREMAN] = true,
        [Permissions.Ranks.SENIOR] = true,
        [Permissions.Ranks.LUMBERJACK] = true,
        [Permissions.Ranks.CIVILIAN] = false
    },

    --------------------------------------------------------
    -- BLIP VISIBILITY
    --------------------------------------------------------
    TreeBlips = {
        [Permissions.Ranks.OWNER] = true,
        [Permissions.Ranks.FOREMAN] = true,
        [Permissions.Ranks.SENIOR] = true,
        [Permissions.Ranks.LUMBERJACK] = true,
        [Permissions.Ranks.CIVILIAN] = false
    },

    SapBlips = {
        [Permissions.Ranks.OWNER] = true,
        [Permissions.Ranks.FOREMAN] = true,
        [Permissions.Ranks.SENIOR] = true,
        [Permissions.Ranks.LUMBERJACK] = true,
        [Permissions.Ranks.CIVILIAN] = false
    },

    ShopfrontBlip = {
        [Permissions.Ranks.OWNER] = true,
        [Permissions.Ranks.FOREMAN] = true,
        [Permissions.Ranks.SENIOR] = true,
        [Permissions.Ranks.LUMBERJACK] = true,
        [Permissions.Ranks.CIVILIAN] = true
    }
}

--========================================================--
--  PERMISSION CHECK FUNCTION
--========================================================--
function Permissions:HasAccess(rank, permission)
    if not Permissions.Access[permission] then return false end
    return Permissions.Access[permission][rank] or false
end

return Permissions
