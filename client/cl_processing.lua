--========================================================--
--  JIMS LUMBERJACK - CLIENT PROCESSING SYSTEM
--========================================================--

local processing = false

--========================================================--
--  PLAY GENERIC WORK ANIMATION
--========================================================--
local function PlayWorkAnim()
    local ped = PlayerPedId()

    RequestAnimDict("mech_lumberjack@chop_wood")
    while not HasAnimDictLoaded("mech_lumberjack@chop_wood") do
        Wait(10)
    end

    TaskPlayAnim(ped, "mech_lumberjack@chop_wood", "idle", 8.0, -8.0, -1, 1, 0, false, 0, false)
end

--========================================================--
--  STOP ANIMATION
--========================================================--
local function StopAnim()
    ClearPedTasks(PlayerPedId())
end

--========================================================--
--  FIND NEAREST PROCESSING STATION
--========================================================--
local function GetNearestStation()
    local data = GetBusinessData()
    if not data or not data.stations then return nil end

    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)

    for id, station in pairs(data.stations) do
        local dist = Utils.Distance(pcoords, vector3(station.x, station.y, station.z))
        if dist <= Config.InteractDistance then
            return id, station
        end
    end

    return nil
end

--========================================================--
--  START PROCESSING
--========================================================--
local function StartProcessing(stationId, station)
    if processing then return end
    processing = true

    Utils.Debug("Processing at station: " .. tostring(stationId))

    PlayWorkAnim()

    local time = Config.ProcessingTimes[station.type] or 5
    local endTime = GetGameTimer() + (time * 1000)

    -- Progress bar loop
    CreateThread(function()
        while processing do
            Wait(0)

            local remaining = endTime - GetGameTimer()
            if remaining <= 0 then break end

            local percent = math.floor(((time * 1000 - remaining) / (time * 1000)) * 100)

            SetTextScale(0.35, 0.35)
            SetTextColor(255, 255, 255, 215)
            SetTextCentre(true)
            DisplayText(CreateVarString(10, "LITERAL_STRING", "Processing: " .. percent .. "%"), 0.5, 0.88)
        end

        StopAnim()
        processing = false

        TriggerServerEvent("jims-lumberjack:processItem", stationId)
    end)
end

--========================================================--
--  MAIN INTERACTION LOOP
--========================================================--
CreateThread(function()
    while true do
        Wait(0)

        if not Permissions:HasAccess(GetLumberRank(), "Processing") then
            Wait(1000)
            goto continue
        end

        local stationId, station = GetNearestStation()
        if stationId then
            -- Draw prompt
            SetTextScale(0.35, 0.35)
            SetTextColor(255, 255, 255, 215)
            SetTextCentre(true)
            DisplayText(CreateVarString(10, "LITERAL_STRING", "Press [E] to Process"), 0.5, 0.88)

            if IsControlJustPressed(0, 0xCEFD9220) then -- E
                StartProcessing(stationId, station)
            end
        else
            Wait(250)
        end

        ::continue::
    end
end)

--========================================================--
--  STATION STATE UPDATED FROM SERVER
--========================================================--
RegisterNetEvent("jims-lumberjack:updateStations", function()
    Utils.Debug("Processing station states updated.")
end)
