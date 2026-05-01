print("^1[DEBUG] sv_business.lua loaded")

local Businesses = {}

-- Load all businesses on resource start
CreateThread(function()
    local result = MySQL.query.await("SELECT * FROM businesses")
    for _, v in ipairs(result) do
        Businesses[v.type] = v
    end
    print("^2[Lumber] Loaded " .. tostring(#result) .. " businesses.")
end)

-- Utility: get license identifier
local function GetLicense(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:sub(1, 7) == "license" then
            return id
        end
    end
    return nil
end

-- Utility: notify client
local function Notify(src, msg)
    TriggerClientEvent("lumber:client:Notify", src, msg)
end

-- /business command
RegisterCommand("business", function(src, args)
    local sub = args[1]
    local bType = args[2]

    if not sub or not bType then
        return Notify(src, "Usage: /business <create/delete/give/remove/info> <type> [args]")
    end

    -----------------------------------------------------
    -- CREATE BUSINESS
    -----------------------------------------------------
    if sub == "create" then
        local name = table.concat(args, " ", 3)
        if name == "" then
            return Notify(src, "You must provide a business name.")
        end

        local id = MySQL.insert.await("INSERT INTO businesses (type, name) VALUES (?, ?)", {
            bType, name
        })

        Businesses[bType] = {
            id = id,
            type = bType,
            name = name
        }

        Notify(src, "Business created: " .. name)
        return
    end

    -----------------------------------------------------
    -- DELETE BUSINESS
    -----------------------------------------------------
    if sub == "delete" then
        local business = Businesses[bType]
        if not business then return Notify(src, "Business does not exist.") end

        MySQL.query.await("DELETE FROM business_owners WHERE business_id = ?", { business.id })
        MySQL.query.await("DELETE FROM businesses WHERE id = ?", { business.id })

        Businesses[bType] = nil

        Notify(src, "Business deleted.")
        return
    end

    -----------------------------------------------------
    -- GIVE OWNERSHIP
    -----------------------------------------------------
    if sub == "give" then
        local target = tonumber(args[3])
        if not target then return Notify(src, "Invalid player ID.") end

        local business = Businesses[bType]
        if not business then return Notify(src, "Business does not exist.") end

        local license = GetLicense(target)
        if not license then return Notify(src, "Could not get player license.") end

        MySQL.insert.await("INSERT INTO business_owners (business_id, citizenid) VALUES (?, ?)", {
            business.id, license
        })

        TriggerClientEvent("lumber:client:OwnershipGranted", target, business)
        Notify(src, "Ownership granted.")
        return
    end

    -----------------------------------------------------
    -- REMOVE OWNERSHIP
    -----------------------------------------------------
    if sub == "remove" then
        local target = tonumber(args[3])
        if not target then return Notify(src, "Invalid player ID.") end

        local business = Businesses[bType]
        if not business then return Notify(src, "Business does not exist.") end

        local license = GetLicense(target)
        if not license then return Notify(src, "Could not get player license.") end

        MySQL.query.await("DELETE FROM business_owners WHERE business_id = ? AND citizenid = ?", {
            business.id, license
        })

        TriggerClientEvent("lumber:client:OwnershipRevoked", target)
        Notify(src, "Ownership removed.")
        return
    end

    -----------------------------------------------------
    -- BUSINESS INFO
    -----------------------------------------------------
    if sub == "info" then
        local business = Businesses[bType]
        if not business then return Notify(src, "Business does not exist.") end

        Notify(src, "Business: " .. business.name)
        return
    end
end)
