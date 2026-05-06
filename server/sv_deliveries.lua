--========================================================--
--  JIMS LUMBERJACK - SERVER DELIVERY SYSTEM
--========================================================--

local data = LumberServer.GetData()
local Wagons = exports['jims-lumberjack']:GetWagonModule() -- Provided by sv_wagons.lua

--========================================================--
--  DELIVERY ROUTES
--========================================================--
local Routes = {
    {
        name = "Blackwater Mill",
        dropoff = vector3(-875.12, -1335.44, 43.12),
        heading = 90.0,
        payoutPerItem = 90
    },
    {
        name = "Strawberry Lumberyard",
        dropoff = vector3(-1750.22, -400.55, 155.22),
        heading = 180.0,
        payoutPerItem = 90
    }
}

--========================================================--
--  START DELIVERY
--========================================================--
RegisterNetEvent("jims-lumberjack:startDelivery", function(wagonNet)
    local src = source

    -- Permission check
    if not LumberPerms.Require(src, "Deliveries") then return end

    -- Validate wagon
    local wagon = Wagons.Get(wagonNet)
    if not wagon then
        print(("^1[ERROR]^0 Player %s attempted delivery with unregistered wagon %s"):format(src, wagonNet))
        return
    end

    -- Must have cargo
    if wagon.cargo <= 0 then
        TriggerClientEvent("chat:addMessage", src, {
            color = {255, 50, 50},
            args = {"Lumber Co.", "Your wagon is empty."}
        })
        return
    end

    -- Assign random route
    local routeIndex = math.random(1, #Routes)
    local route = Routes[routeIndex]

    -- Send to client
    TriggerClientEvent("jims-lumberjack:startDeliveryClient", src, {
        route = routeIndex,
        dropoff = route.dropoff,
        heading = route.heading
    })

    print(("^2[DELIVERY]^0 Player %s started delivery route %s"):format(src, route.name))
end)

--========================================================--
--  FINISH DELIVERY
--========================================================--
RegisterNetEvent("jims-lumberjack:finishDelivery", function(routeIndex)
    local src = source

    -- Permission check
    if not LumberPerms.Require(src, "Deliveries") then return end

    local route = Routes[routeIndex]
    if not route then
        print(("^1[ERROR]^0 Player %s attempted invalid delivery route %s"):format(src, routeIndex))
        return
    end

    -- Validate wagon again
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local wagonEntity = GetClosestVehicle(coords.x, coords.y, coords.z, 6.0, 0, 70)
    if wagonEntity == 0 then
        TriggerClientEvent("chat:addMessage", src, {
            color = {255, 50, 50},
            args = {"Lumber Co.", "You must bring the wagon to the drop-off point."}
        })
        return
    end

    local wagonNet = NetworkGetNetworkIdFromEntity(wagonEntity)
    local wagon = Wagons.Get(wagonNet)

    if not wagon then
        print(("^1[ERROR]^0 Player %s attempted delivery with unregistered wagon %s"):format(src, wagonNet))
        return
    end

    -- Must have cargo
    if wagon.cargo <= 0 then
        TriggerClientEvent("chat:addMessage", src, {
            color = {255, 50, 50},
            args = {"Lumber Co.", "Your wagon is empty."}
        })
        return
    end

    -- Calculate payout
    local payout = wagon.cargo * route.payoutPerItem

    -- Add to business account
    data.shopfront.balance = (data.shopfront.balance or 0) + payout

    -- Ledger entry
    table.insert(data.ledger, {
        time = os.time(),
        player = Utils.GetIdentifier(src),
        action = "delivery",
        route = route.name,
        items = wagon.cargo,
        total = payout
    })
    Utils.SaveJSON("data/ledger.json", data.ledger)

    -- Clear wagon cargo
    Wagons.Clear(wagonNet)

    print(("^2[DELIVERY]^0 Player %s delivered %s items for $%s on route %s")
        :format(src, wagon.cargo, payout, route.name))

    -- Notify player
    TriggerClientEvent("chat:addMessage", src, {
        color = {50, 200, 50},
        args = {"Lumber Co.", ("Delivery complete! Earned $%s."):format(payout)}
    })
end)

--========================================================--
--  EXPORT MODULE
--========================================================--
LumberDeliveries = {}

return LumberDeliveries
