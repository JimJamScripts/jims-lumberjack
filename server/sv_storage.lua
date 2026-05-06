--========================================================--
--  JIMS LUMBERJACK - SERVER STORAGE SYSTEM
--========================================================--

local data = LumberServer.GetData()

--========================================================--
--  SAVE + SYNC HELPERS
--========================================================--
local function SaveStorage()
    Utils.SaveJSON("data/storage_data.json", data.storageProps)
end

local function SyncStorage(src)
    TriggerClientEvent("jims-lumberjack:updateStorage", src, data.storageProps)
end

--========================================================--
--  VALIDATE STORAGE EXISTS
--========================================================--
local function StorageExists(storageId)
    return data.storageProps[storageId] ~= nil
end

--========================================================--
--  OPEN STORAGE
--========================================================--
RegisterNetEvent("jims-lumberjack:openStorage", function(storageId)
    local src = source

    -- Permission check
    if not LumberPerms.Require(src, "StorageAccess") then return end

    -- Validate storage
    if not StorageExists(storageId) then
        print(("^1[ERROR]^0 Player %s attempted to open invalid storage %s"):format(src, tostring(storageId)))
        return
    end

    local storage = data.storageProps[storageId]

    -- Ensure storage has an inventory table
    storage.inventory = storage.inventory or {}

    -- Send UI data
    TriggerClientEvent("jims-lumberjack:openStorageUI", src, {
        id = storageId,
        items = storage.inventory,
        capacity = 2000
    })
end)

--========================================================--
--  STORAGE ACTIONS (ADD / REMOVE)
--========================================================--
RegisterNetEvent("jims-lumberjack:storageAction", function(dataIn)
    local src = source
    local storageId = dataIn.id
    local action = dataIn.action
    local item = dataIn.item
    local amount = tonumber(dataIn.amount) or 0

    -- Permission check
    if not LumberPerms.Require(src, "StorageAccess") then return end

    -- Validate storage
    if not StorageExists(storageId) then
        print(("^1[ERROR]^0 Player %s attempted storage action on invalid storage %s"):format(src, tostring(storageId)))
        return
    end

    local storage = data.storageProps[storageId]
    storage.inventory = storage.inventory or {}

    --========================================================--
    --  ADD ITEM TO STORAGE
    --========================================================--
    if action == "deposit" then
        if amount <= 0 then return end

        -- Check player has item
        if not exports.inventory:HasItem(src, item, amount) then
            TriggerClientEvent("chat:addMessage", src, {
                color = {255, 50, 50},
                args = {"Lumber Co.", "You don't have enough of that item."}
            })
            return
        end

        -- Capacity check
        local total = 0
        for _, v in pairs(storage.inventory) do
            total = total + v
        end

        if total + amount > 2000 then
            TriggerClientEvent("chat:addMessage", src, {
                color = {255, 50, 50},
                args = {"Lumber Co.", "Storage is full."}
            })
            return
        end

        -- Remove from player
        exports.inventory:RemoveItem(src, item, amount)

        -- Add to storage
        storage.inventory[item] = (storage.inventory[item] or 0) + amount

        SaveStorage()

        -- Re-open UI
        TriggerClientEvent("jims-lumberjack:openStorageUI", src, {
            id = storageId,
            items = storage.inventory,
            capacity = 2000
        })
    end

    --========================================================--
    --  REMOVE ITEM FROM STORAGE
    --========================================================--
    if action == "withdraw" then
        if amount <= 0 then return end

        local stored = storage.inventory[item] or 0
        if stored < amount then
            TriggerClientEvent("chat:addMessage", src, {
                color = {255, 50, 50},
                args = {"Lumber Co.", "Not enough items in storage."}
            })
            return
        end

        -- Remove from storage
        storage.inventory[item] = stored - amount
        if storage.inventory[item] <= 0 then
            storage.inventory[item] = nil
        end

        -- Give to player
        exports.inventory:AddItem(src, item, amount)

        SaveStorage()

        -- Re-open UI
        TriggerClientEvent("jims-lumberjack:openStorageUI", src, {
            id = storageId,
            items = storage.inventory,
            capacity = 2000
        })
    end
end)

--========================================================--
--  EXPORT FOR OTHER SERVER MODULES
--========================================================--
LumberStorage = {}

function LumberStorage.SyncAll(src)
    SyncStorage(src)
end

return LumberStorage