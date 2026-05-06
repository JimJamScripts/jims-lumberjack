--========================================================--
--  JIMS LUMBERJACK - GLOBAL CONFIGURATION
--========================================================--

Config = {}

--========================================================--
--  DEBUG MODE
--========================================================--
Config.Debug = false   -- true = prints server/client debug messages

--========================================================--
--  TREE SYSTEM
--========================================================--
Config.TreeRespawnTime = 300        -- seconds (5 minutes)
Config.TreeChopHits = 6             -- hits required to chop a tree
Config.TreeBlipsEnabled = true      -- employees only
Config.TreeBlipSprite = 2033377404  -- tree icon hash
Config.TreeBlipColor = 0            -- white

--========================================================--
--  SAP BUCKET SYSTEM
--========================================================--
Config.SapBucketRespawn = 120       -- seconds (2 minutes)
Config.SapBucketReward = 4          -- raw sap per bucket
Config.SapBlipsEnabled = true       -- employees only
Config.SapBlipSprite = 1865988756   -- bucket icon hash
Config.SapBlipColor = 0

--========================================================--
--  PROCESSING STATIONS
--========================================================--
Config.ProcessingTimes = {
    Splitting = 5,      -- seconds
    Sawing = 6,         -- seconds
    Planing = 7,        -- seconds
    SapStation = 4      -- seconds
}

Config.ProcessingRewards = {
    HardwoodToSplit = 1,    -- 1 hardwood → 1 split log
    SplitToRough = 1,       -- 1 split log → 1 rough plank
    RoughToPlank = 1,       -- 1 rough plank → 1 plank
    RawSapToBarrel = 10     -- 10 raw sap → 1 sap barrel
}

--========================================================--
--  STORAGE SYSTEM
--========================================================--
Config.StorageLimits = {
    PlankStorage = 2000,
    HardwoodStorage = 2000,
    SplitLogStorage = 2000,
    SapStorage = 2000
}

--========================================================--
--  VIRTUAL STORAGE (UNLIMITED)
--========================================================--
Config.VirtualStorage = {
    Logs = true,
    Sap = true,
    Office = true,
    Shopfront = true
}

--========================================================--
--  WAGONS
--========================================================--
Config.WagonModels = {
    LogWagon = `cart06`,
    SapWagon = `cart06`,
    StorageWagon = `cart06`
}

Config.WagonCapacities = {
    Logs = 10,
    Sap = 10
}

--========================================================--
--  DELIVERY SYSTEM
--========================================================--
Config.DeliveryPayouts = {
    Log = 90,       -- per log
    Sap = 60        -- per barrel
}

Config.DeliveryRoutes = {
    "blackwater",
    "strawberry"
}

Config.DeliveryCooldown = 0   -- seconds (0 = disabled)

--========================================================--
--  SHOPFRONT
--========================================================--
Config.Shopfront = {
    MaxBuyListItems = 20,
    AllowCiviliansToBuy = true,
    AllowCiviliansToSell = false
}

--========================================================--
--  OFFICE SYSTEM
--========================================================--
Config.BusinessDefaults = {
    Name = "Lumber Company",
    ShopName = "Lumber Shop",
    Description = "A hardworking lumber business."
}

--========================================================--
--  INTERACTION DISTANCES
--========================================================--
Config.InteractDistance = 2.0
Config.WagonDistance = 10.0

--========================================================--
--  BLIP VISIBILITY
--========================================================--
Config.Blips = {
    ShowShopfrontToCivs = true,
    ShowTreesToEmployees = true,
    ShowSapToEmployees = true
}

--========================================================--
--  PERMISSIONS (handled in sh_permissions.lua)
--========================================================--

return Config
