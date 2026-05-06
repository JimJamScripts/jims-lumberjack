--========================================================--
--  JIMS LUMBERJACK - SERVER WAGON SYSTEM
--========================================================--

local data = LumberServer.GetData()

--========================================================--
--  WAGON REGISTRY
--========================================================--
-- Stored in memory only (not JSON)
local Wagons = {}

--========================================================--
--  WAGON DEFINITIONS
--========================================================--
local WagonTypes = {
    LogWagon = {
        model = `CART06`,
        capacity = 20,
        item = "lumber"
    },
    SapWagon = {
        model = `CART07`,
        capacity = 20,
        item = "refined_sap"
    }
}

--========================================================--
--  SPAWN WAGON
--========================================================--
RegisterNetEvent("jims-lumberjack:spawnWagon", function(wagonType)
    local src = source

    -- Permission check
    if not LumberPerms.Require(src, "Wagons") then return end

    local def = WagonTypes[wagonType]
    if not def then
        print(("^1[ERROR]^0 Invalid wagon type '%s' requested by %s"):format(wagonType, src))
        return
    end

    -- Spawn position (from business data)
    local spawn = data.office.wagonSpawn
    if not spawn then
        print("^1[ERROR]^0 No wagon spawn location defined.")
        return
    end

    -- Send spawn request to client
    TriggerClientEvent("jims-lumberjack:spawnWagonClient", src, def.model, spawn, spawn.h)

    print(("^2[WAGON]^0 Player %s spawned a %s"):format(src, wagonType))
end)

--========================================================--
--  REGISTER WAGON ON LOAD
--========================================================--
local function RegisterWagon(netId, wagonType, owner)
    Wagons[netId] = {
        type = wagonType,
        owner = owner,
        cargo = 0
    }
end

--========================================================--
--  LOAD INTO WAGON
--========================================================--
RegisterNetEvent("jims-lumberjack:loadWagon", function(itemType, wagonNet)
    local src = source

    -- Permission check
    if not LumberPerms.Require(src, "Wagons") then return end

    local wagon = Wagons[wagonNet]
    if not wagon then
        -- First time seeing this wagon — register it
        if itemType == "logs" then
            RegisterWagon(wagonNet, "LogWagon", src)
        elseif itemType == "sap" then
            RegisterWagon(wagonNet, "SapWagon", src)
        else
            print(("^1[ERROR]^0 Unknown wagon item type '%s' from %s"):format(itemType, src))
            return
        end
        wagon = Wagons[wagonNet]
    end

    local def = WagonTypes[wagon.type]
    if not def then return end

    -- Validate item type
    if (itemType == "logs" and def.item ~= "lumber") or
       (itemType == "sap" and def.item ~= "refined_sap") then
        print(("^1[WARN]^0 Player %s attempted to load wrong item type into wagon"):format(src))
        return
    end

    -- Check capacity
    if wagon.cargo >= def.capacity then
        TriggerClientEvent("chat:addMessage", src, {
            color = {255, 50, 50},
            args = {"Lumber Co.", "This wagon is full."}
        })
        return
    end

    -- Check player inventory
    if not exports.inventory:HasItem(src, def.item, 1) then
        TriggerClientEvent("chat:addMessage", src, {
            color = {255, 50, 50},
            args = {"Lumber Co.", "You don't have the required item."}
        })
        return
    end

    -- Remove from player
    exports.inventory:RemoveItem(src, def.item, 1)

    -- Add to wagon
    wagon.cargo = wagon.cargo + 1

    print(("^2[WAGON]^0 %s loaded 1 %s into wagon %s (%s/%s)")
        :format(src, def.item, wagonNet, wagon.cargo, def.capacity))
end)

--========================================================--
--  GET WAGON CARGO (USED BY DELIVERY SYSTEM)
--========================================================--
function GetWagonCargo(wagonNet)
    return Wagons[wagonNet] or nil
end

--========================================================--
--  EXPORT FOR OTHER SERVER MODULES
--========================================================--
LumberWagons = {}

function LumberWagons.Get(wagonNet)
    return Wagons[wagonNet]
end

function LumberWagons.Clear(wagonNet)
    Wagons[wagonNet] = nil
end

return LumberWagons
