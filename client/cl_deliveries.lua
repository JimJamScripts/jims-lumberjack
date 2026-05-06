--========================================================--
--  JIMS LUMBERJACK - CLIENT DELIVERY SYSTEM
--========================================================--

local activeDelivery = nil
local dropoffNPC = nil
local dropoffBlip = nil
local interacting = false

--========================================================--
--  SPAWN DROPOFF NPC
--========================================================--
local function SpawnDropoffNPC(model, coords, heading)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    local ped = CreatePed(model, coords.x, coords.y, coords.z, heading, false, true)
    SetModelAsNoLongerNeeded(model)

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    dropoffNPC = ped
end

--========================================================--
--  CREATE DROPOFF BLIP
--========================================================--
local function CreateDropoffBlip(coords)
    if dropoffBlip and DoesBlipExist(dropoffBlip) then
        RemoveBlip(dropoffBlip)
    end

    dropoffBlip = N_0x554d9d53f696d002(1664425300, coords.x, coords.y, coords.z)
    SetBlipSprite(dropoffBlip, 1865988756, true)
    SetBlipScale(dropoffBlip, 0.3)
    SetBlipColour(dropoffBlip, 0)
end

--========================================================--
--  START DELIVERY (FROM SERVER)
--========================================================--
RegisterNetEvent("jims-lumberjack:startDeliveryClient", function(data)
    Utils.Debug("Delivery started client-side")

    activeDelivery = data

    -- Spawn NPC
    SpawnDropoffNPC(`A_M_M_RANCHER_01`, data.dropoff, data.heading)

    -- Create blip
    CreateDropoffBlip(data.dropoff)
end)

--========================================================--
--  FINISH DELIVERY
--========================================================--
local function FinishDelivery()
    if not activeDelivery then return end

    Utils.Debug("Finishing delivery")

    TriggerServerEvent("jims-lumberjack:finishDelivery", activeDelivery.route)

    -- Cleanup
    if dropoffNPC then
        DeleteEntity(dropoffNPC)
        dropoffNPC = nil
    end

    if dropoffBlip and DoesBlipExist(dropoffBlip) then
        RemoveBlip(dropoffBlip)
        dropoffBlip = nil
    end

    activeDelivery = nil
end

--========================================================--
--  MAIN INTERACTION LOOP
--========================================================--
CreateThread(function()
    while true do
        Wait(0)

        if not Permissions:HasAccess(GetLumberRank(), "Deliveries") then
            Wait(1000)
            goto continue
        end

        -- START DELIVERY
        if not activeDelivery then
            local wagon = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 6.0, 0, 70)
            if wagon ~= 0 and DoesEntityExist(wagon) then
                SetTextScale(0.35, 0.35)
                SetTextColor(255, 255, 255, 215)
                SetTextCentre(true)
                DisplayText(CreateVarString(10, "LITERAL_STRING", "Press [E] to Start Delivery"), 0.5, 0.88)

                if IsControlJustPressed(0, 0xCEFD9220) then -- E
                    TriggerServerEvent("jims-lumberjack:startDelivery", NetworkGetNetworkIdFromEntity(wagon))
                end
            else
                Wait(250)
            end

            goto continue
        end

        -- FINISH DELIVERY
        if activeDelivery and dropoffNPC then
            local ped = PlayerPedId()
            local pcoords = GetEntityCoords(ped)
            local dist = Utils.Distance(pcoords, activeDelivery.dropoff)

            if dist <= 2.0 then
                SetTextScale(0.35, 0.35)
                SetTextColor(255, 255, 255, 215)
                SetTextCentre(true)
                DisplayText(CreateVarString(10, "LITERAL_STRING", "Press [E] to Deliver Cargo"), 0.5, 0.88)

                if IsControlJustPressed(0, 0xCEFD9220) then -- E
                    FinishDelivery()
                end
            end
        end

        ::continue::
    end
end)
