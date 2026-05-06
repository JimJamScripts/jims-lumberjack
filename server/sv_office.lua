--========================================================--
--  JIMS LUMBERJACK - SERVER OFFICE SYSTEM
--========================================================--

local data = LumberServer.GetData()

--========================================================--
--  SAVE HELPERS
--========================================================--
local function SaveEmployees()
    Utils.SaveJSON("data/employees.json", data.employees)
end

local function SaveBusiness()
    Utils.SaveJSON("data/business_data.json", data.office)
end

local function SaveUpgrades()
    Utils.SaveJSON("data/upgrades.json", data.upgrades)
end

--========================================================--
--  OPEN OFFICE MENU
--========================================================--
RegisterNetEvent("jims-lumberjack:openOffice", function()
    local src = source
    local rank = LumberServer.GetRank(src)

    if not Permissions:HasAccess(rank, "OfficeMenu") then return end

    local payload = {
        employees = data.employees,
        upgrades = data.upgrades,
        business = data.office,
        ledger = data.ledger,
        canManage = Permissions:HasAccess(rank, "OfficeManage")
    }

    TriggerClientEvent("jims-lumberjack:openOfficeUI", src, payload)
end)

--========================================================--
--  OFFICE ACTIONS
--========================================================--
RegisterNetEvent("jims-lumberjack:officeAction", function(dataIn)
    local src = source
    local action = dataIn.action
    local target = tonumber(dataIn.target) or 0
    local rank = LumberServer.GetRank(src)

    local identifier = Utils.GetIdentifier(target)
    if not identifier then return end

    --========================================================--
    --  HIRE EMPLOYEE
    --========================================================--
    if action == "hire" then
        if not Permissions:HasAccess(rank, "OfficeManage") then return end

        if data.employees[identifier] then
            TriggerClientEvent("chat:addMessage", src, {
                color = {255, 50, 50},
                args = {"Lumber Co.", "This player is already employed."}
            })
            return
        end

        data.employees[identifier] = {
            rank = Permissions.Ranks.WORKER,
            name = GetPlayerName(target)
        }

        SaveEmployees()
        LumberServer.Sync(target)
        return
    end

    --========================================================--
    --  FIRE EMPLOYEE
    --========================================================--
    if action == "fire" then
        if not Permissions:HasAccess(rank, "OfficeManage") then return end

        if not data.employees[identifier] then return end

        data.employees[identifier] = nil

        SaveEmployees()
        LumberServer.Sync(target)
        return
    end

    --========================================================--
    --  PROMOTE EMPLOYEE
    --========================================================--
    if action == "promote" then
        if not Permissions:HasAccess(rank, "OfficeManage") then return end

        local emp = data.employees[identifier]
        if not emp then return end

        if emp.rank >= Permissions.Ranks.FOREMAN then return end

        emp.rank = emp.rank + 1

        SaveEmployees()
        LumberServer.Sync(target)
        return
    end

    --========================================================--
    --  DEMOTE EMPLOYEE
    --========================================================--
    if action == "demote" then
        if not Permissions:HasAccess(rank, "OfficeManage") then return end

        local emp = data.employees[identifier]
        if not emp then return end

        if emp.rank <= Permissions.Ranks.WORKER then return end

        emp.rank = emp.rank - 1

        SaveEmployees()
        LumberServer.Sync(target)
        return
    end

    --========================================================--
    --  BUSINESS SETTINGS UPDATE
    --========================================================--
    if action == "updateBusiness" then
        if not Permissions:HasAccess(rank, "OfficeManage") then return end

        data.office.name = dataIn.name or data.office.name
        data.office.wagonSpawn = dataIn.wagonSpawn or data.office.wagonSpawn

        SaveBusiness()
        return
    end

    --========================================================--
    --  UPGRADE PURCHASE
    --========================================================--
    if action == "buyUpgrade" then
        if not Permissions:HasAccess(rank, "OfficeManage") then return end

        local upgrade = dataIn.upgrade
        if not upgrade then return end

        -- Ensure upgrade exists
        data.upgrades[upgrade] = data.upgrades[upgrade] or {level = 0}

        local cost = (data.upgrades[upgrade].level + 1) * 500

        -- Check business balance
        if data.shopfront.balance < cost then
            TriggerClientEvent("chat:addMessage", src, {
                color = {255, 50, 50},
                args = {"Lumber Co.", "Not enough business funds."}
            })
            return
        end

        -- Deduct cost
        data.shopfront.balance = data.shopfront.balance - cost

        -- Increase upgrade level
        data.upgrades[upgrade].level = data.upgrades[upgrade].level + 1

        SaveUpgrades()
        return
    end
end)

--========================================================--
--  EXPORT MODULE
--========================================================--
LumberOffice = {}

return LumberOffice
