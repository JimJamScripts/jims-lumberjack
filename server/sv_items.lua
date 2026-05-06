--========================================================--
--  JIMS LUMBERJACK - SERVER ITEM SYSTEM
--========================================================--

local data = LumberServer.GetData()

--========================================================--
--  ITEM DEFINITIONS
--========================================================--
-- This table defines all items used by the lumberjack job.
-- It ensures consistency and prevents typos across modules.
local ItemDefs = {
    hardwood        = {label = "Hardwood Log"},
    raw_sap         = {label = "Raw Sap"},
    split_wood      = {label = "Split Wood"},
    lumber          = {label = "Lumber"},
    finished_plank  = {label = "Finished Plank"},
    refined_sap     = {label = "Refined Sap"},
}

--========================================================--
--  VALIDATE ITEM EXISTS
--========================================================--
local function ItemExists(item)
    return ItemDefs[item] ~= nil
end

--========================================================--
--  GIVE ITEM
--========================================================--
local function GiveItem(src, item, amount)
    if not ItemExists(item) then
        print(("^1[ERROR]^0 Attempt to give invalid item '%s' to %s"):format(item, src))
        return false
    end

    amount = tonumber(amount) or 0
    if amount <= 0 then return false end

    exports.inventory:AddItem(src, item, amount)

    print(("^2[ITEM]^0 Gave %sx %s to %s"):format(amount, item, src))
    return true
end

--========================================================--
--  REMOVE ITEM
--========================================================--
local function RemoveItem(src, item, amount)
    if not ItemExists(item) then
        print(("^1[ERROR]^0 Attempt to remove invalid item '%s' from %s"):format(item, src))
        return false
    end

    amount = tonumber(amount) or 0
    if amount <= 0 then return false end

    if not exports.inventory:HasItem(src, item, amount) then
        return false
    end

    exports.inventory:RemoveItem(src, item, amount)

    print(("^3[ITEM]^0 Removed %sx %s from %s"):format(amount, item, src))
    return true
end

--========================================================--
--  EVENT: GIVE ITEM (USED BY OTHER MODULES)
--========================================================--
RegisterNetEvent("jims-lumberjack:giveItem", function(srcOverride, item, amount)
    local src = source

    -- Allow server modules to pass a different target
    local target = srcOverride or src

    GiveItem(target, item, amount)
end)

--========================================================--
--  EVENT: REMOVE ITEM (USED BY OTHER MODULES)
--========================================================--
RegisterNetEvent("jims-lumberjack:removeItem", function(srcOverride, item, amount)
    local src = source

    local target = srcOverride or src

    RemoveItem(target, item, amount)
end)

--========================================================--
--  EXPORT MODULE
--========================================================--
LumberItems = {}

function LumberItems.Give(src, item, amount)
    return GiveItem(src, item, amount)
end

function LumberItems.Remove(src, item, amount)
    return RemoveItem(src, item, amount)
end

function LumberItems.Exists(item)
    return ItemExists(item)
end

return LumberItems