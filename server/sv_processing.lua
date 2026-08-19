--========================================================--
--  JIMS LUMBERJACK - SERVER PROCESSING SYSTEM (VORP READY)
--========================================================--

local data = LumberServer.GetData()

-- VORP Core + Inventory
local VORPcore = exports.vorp_core:getCore()
local VORPInv   = exports.vorp_inventory:vorp_inventoryApi()

--========================================================--
--  SAVE + SYNC HELPERS
--========================================================--
local function SaveStations()
    Utils.SaveJSON("data/stations.json", data.stations)
end

local function SyncStations()
    TriggerClientEvent("jims-lumberjack:updateStations", -1, data.stations)
end

--========================================================--
--  VALIDATE STATION EXISTS
--========================================================--
local function StationExists(stationId)
    return data.stations[stationId] ~= nil
end

--========================================================--
--  PROCESSING RECIPES
--========================================================--
local Recipes = {
    split = {
        input = "hardwood",
        output = "split_wood",
        amount = 1
    },
    saw = {
        input = "split_wood",
        output = "lumber",
        amount = 1
    },
    plane = {
        input = "lumber",
        output = "finished_plank",
        amount = 1
    },
    sap = {
        input = "raw_sap",
        output = "refined_sap",
        amount = 1
    }
}

--========================================================--
--  PROCESS ITEM EVENT
--========================================================--
RegisterNetEvent("jims-lumberjack:processItem", function(stationId)
    local src = source

    -- Permission check
    if not Permissions.Require(src, "Processing") then return end

    -- Validate station
    if not StationExists(stationId) then
        print(("^1[ERROR]^0 Player %s attempted to process invalid station %s"):format(src, tostring(stationId)))
        return
    end

    local station = data.stations[stationId]
    local recipe = Recipes[station.type]

    if not recipe then
        print(("^1[ERROR]^0 Invalid station type '%s' at station %s"):format(station.type, stationId))
        return
    end

    -- Check player inventory (VORP)
    local count = VORPInv.getItemCount(src, recipe.input)
    if not count or count < 1 then
        VORPcore.NotifyRightTip(src, "You don't have the required materials.", 3000)
        return
    end

    -- Remove input item
    VORPInv.subItem(src, recipe.input, 1)

    -- Add output item
    VORPInv.addItem(src, recipe.output, recipe.amount)

    -- Log to ledger
    table.insert(data.ledger, {
        time = os.time(),
        player = VORPcore.getUser(src).getUsedCharacter().charIdentifier,
        action = "processed",
        input = recipe.input,
        output = recipe.output
    })

    Utils.SaveJSON("data/ledger.json", data.ledger)

    -- Sync stations (if needed)
    SyncStations()
end)

--========================================================--
--  EXPORT FOR OTHER SERVER MODULES
--========================================================--
LumberProcessing = {}

function LumberProcessing.SyncAll()
    SyncStations()
end

return LumberProcessing
