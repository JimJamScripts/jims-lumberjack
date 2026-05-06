--========================================================--
--  JIMS LUMBERJACK - SERVER MAIN
--========================================================--

local businessData = {
    trees = {},
    sapBuckets = {},
    stations = {},
    storageProps = {},
    shopfront = {},
    office = {},
    employees = {},
    ledger = {},
    upgrades = {}
}

--========================================================--
--  LOAD ALL JSON DATA
--========================================================--
local function LoadAllData()
    businessData.trees        = Utils.LoadJSON("data/trees.json", {})
    businessData.sapBuckets   = Utils.LoadJSON("data/sap_buckets.json", {})
    businessData.stations     = Utils.LoadJSON("data/stations.json", {})
    businessData.storageProps = Utils.LoadJSON("data/storage_data.json", {})
    businessData.shopfront    = Utils.LoadJSON("data/shopfront_data.json", {})
    businessData.office       = Utils.LoadJSON("data/business_data.json", {})
    businessData.employees    = Utils.LoadJSON("data/employees.json", {})
    businessData.ledger       = Utils.LoadJSON("data/ledger.json", {})
    businessData.upgrades     = Utils.LoadJSON("data/upgrades.json", {})

    print("^2[JIMS-LUMBERJACK]^0 Data loaded.")
end

--========================================================--
--  SAVE ALL JSON DATA
--========================================================--
local function SaveAllData()
    Utils.SaveJSON("data/trees.json", businessData.trees)
    Utils.SaveJSON("data/sap_buckets.json", businessData.sapBuckets)
    Utils.SaveJSON("data/stations.json", businessData.stations)
    Utils.SaveJSON("data/storage_data.json", businessData.storageProps)
    Utils.SaveJSON("data/shopfront_data.json", businessData.shopfront)
    Utils.SaveJSON("data/business_data.json", businessData.office)
    Utils.SaveJSON("data/employees.json", businessData.employees)
    Utils.SaveJSON("data/ledger.json", businessData.ledger)
    Utils.SaveJSON("data/upgrades.json", businessData.upgrades)
end

--========================================================--
--  GET PLAYER RANK
--========================================================--
local function GetPlayerRank(src)
    local identifier = Utils.GetIdentifier(src)
    if not identifier then return Permissions.Ranks.CIVILIAN end

    return businessData.employees[identifier] and businessData.employees[identifier].rank or 0
end

--========================================================--
--  SYNC BUSINESS DATA TO CLIENT
--========================================================--
local function SyncBusinessData(src)
    TriggerClientEvent("jims-lumberjack:updateBusinessData", src, businessData)
end

--========================================================--
--  SYNC PLAYER RANK TO CLIENT
--========================================================--
local function SyncPlayerRank(src)
    local rank = GetPlayerRank(src)
    TriggerClientEvent("jims-lumberjack:setRank", src, rank)
end

--========================================================--
--  PLAYER REQUESTS SYNC
--========================================================--
RegisterNetEvent("jims-lumberjack:requestSync", function()
    local src = source
    SyncPlayerRank(src)
    SyncBusinessData(src)
end)

--========================================================--
--  EXPORTS FOR OTHER SERVER FILES
--========================================================--
LumberServer = {}

function LumberServer.GetData()
    return businessData
end

function LumberServer.Save()
    SaveAllData()
end

function LumberServer.GetRank(src)
    return GetPlayerRank(src)
end

function LumberServer.Sync(src)
    SyncPlayerRank(src)
    SyncBusinessData(src)
end

--========================================================--
--  RESOURCE STARTUP
--========================================================--
AddEventHandler("onResourceStart", function(res)
    if res ~= GetCurrentResourceName() then return end

    LoadAllData()

    print("^2[JIMS-LUMBERJACK]^0 Server initialized.")
end)

--========================================================--
--  RESOURCE STOP (AUTO-SAVE)
--========================================================--
AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end

    SaveAllData()

    print("^3[JIMS-LUMBERJACK]^0 Data saved on shutdown.")
end)
