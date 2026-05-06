--========================================================--
--  JIMS LUMBERJACK - CLIENT WAGON SYSTEM
--========================================================--

local activeWagon = nil
local loading = false

--========================================================--
--  PLAY LOADING ANIMATION
--========================================================--
local function PlayLoadAnim()
    local ped = PlayerPedId()

    RequestAnimDict("mech_carry_box")
    while not HasAnimDictLoaded("mech_carry_box") do
        Wait(10)
    end

    TaskPlayAnim(ped, "mech_carry_box", "idle", 8.0, -8.0, 1500, 1, 0, false, 0, false)
end

--========================================================--
--  FIND NEAREST WAGON
--========================================================--
local function GetNearestWagon()
    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)

    local veh = GetClosestVehicle(pcoords.x, pcoords.y, pcoords.z, 6.0, 0, 70)
    if veh ~= 0 and DoesEntityExist(veh) then
        return veh
    end

    return nil
end

--========================================================--
--  REQUEST WAGON SPAWN
--========================================================--
local function SpawnWagon(wagonType)
    TriggerServerEvent("jims-lumberjack:spawnWagon", wagonType)
end

--========================================================--
--  RECEIVE WAGON FROM SERVER
--========================================================--
RegisterNetEvent("jims-lumberjack:spawnWagonClient", function(model, coords, heading)
    Utils.Debug("Spawning wagon client-side")

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    local wagon = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
    SetVehicleOnGroundProperly(wagon)
    SetModelAsNoLongerNeeded(model)

    activeWagon = wagon
end)

--========================================================--
--  LOAD ITEM INTO WAGON
--========================================================--
local function LoadIntoWagon(itemType)
    if loading then return end
    loading = true

    local wagon = GetNearestWagon()
    if not wagon then
        Utils.Debug("No wagon nearby")
        loading = false
        return
    end

    PlayLoadAnim()
    Wait(1500)

    TriggerServerEvent("jims-lumberjack:loadWagon", itemType, NetworkGetNetworkIdFromEntity(wagon))

    loading = false
end

--========================================================--
--  MAIN INTERACTION LOOP
--========================================================--
CreateThread(function()
    while true do
        Wait(0)

        if not Permissions:HasAccess(GetLumberRank(), "Wagons") then
            Wait(1000)
            goto continue
        end

        local wagon = GetNearestWagon()
        if wagon then
            -- Draw prompt
            SetTextScale(0.35, 0.35)
            SetTextColor(255, 255, 255, 215)
            SetTextCentre(true)
            DisplayText(CreateVarString(10, "LITERAL_STRING", "Press [E] to Load Wagon"), 0.5, 0.88)

            if IsControlJustPressed(0, 0xCEFD9220) then -- E
                -- Open small menu
                OpenLumberUI("wagon", {
                    wagonNet = NetworkGetNetworkIdFromEntity(wagon)
                })
            end
        else
            Wait(250)
        end

        ::continue::
    end
end)

--========================================================--
--  NUI CALLBACKS FOR WAGON MENU
--========================================================--
RegisterNUICallback("wagonAction", function(data, cb)
    if data.action == "loadLogs" then
        LoadIntoWagon("logs")
    elseif data.action == "loadSap" then
        LoadIntoWagon("sap")
    elseif data.action == "spawnLogWagon" then
        SpawnWagon("LogWagon")
    elseif data.action == "spawnSapWagon" then
        SpawnWagon("SapWagon")
    end

    cb("ok")
end)
