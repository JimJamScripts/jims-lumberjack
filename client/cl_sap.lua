--========================================================--
--  JIMS LUMBERJACK - CLIENT SAP BUCKET SYSTEM
--========================================================--

local collecting = false

--========================================================--
--  PLAY SAP COLLECTION ANIMATION
--========================================================--
local function PlaySapAnim()
    local ped = PlayerPedId()

    RequestAnimDict("mech_pickup@plant@berries")
    while not HasAnimDictLoaded("mech_pickup@plant@berries") do
        Wait(10)
    end

    TaskPlayAnim(ped, "mech_pickup@plant@berries", "pickup_ground", 8.0, -8.0, 1500, 1, 0, false, 0, false)
end

--========================================================--
--  FIND NEAREST SAP BUCKET
--========================================================--
local function GetNearestBucket()
    local data = GetBusinessData()
    if not data or not data.sapBuckets then return nil end

    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)

    for id, bucket in pairs(data.sapBuckets) do
        local dist = Utils.Distance(pcoords, vector3(bucket.x, bucket.y, bucket.z))
        if dist <= Config.InteractDistance then
            return id, bucket
        end
    end

    return nil
end

--========================================================--
--  START COLLECTING SAP
--========================================================--
local function StartCollecting(bucketId)
    if collecting then return end
    collecting = true

    Utils.Debug("Collecting sap from bucket: " .. tostring(bucketId))

    PlaySapAnim()

    Wait(1500)

    TriggerServerEvent("jims-lumberjack:sapCollected", bucketId)

    collecting = false
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

        local bucketId, bucket = GetNearestBucket()
        if bucketId then
            -- Draw prompt
            SetTextScale(0.35, 0.35)
            SetTextColor(255, 255, 255, 215)
            SetTextCentre(true)
            DisplayText(CreateVarString(10, "LITERAL_STRING", "Press [E] to Collect Sap"), 0.5, 0.88)

            if IsControlJustPressed(0, 0xCEFD9220) then -- E
                StartCollecting(bucketId)
            end
        else
            Wait(250)
        end

        ::continue::
    end
end)

--========================================================--
--  SAP BUCKET STATE UPDATED FROM SERVER
--========================================================--
RegisterNetEvent("jims-lumberjack:updateSapBuckets", function()
    Utils.Debug("Sap bucket states updated.")
end)
