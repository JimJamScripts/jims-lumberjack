--========================================================--
--  JIMS LUMBERJACK - CLIENT STORAGE SYSTEM
--========================================================--

local interacting = false

--========================================================--
--  FIND NEAREST STORAGE PROP
--========================================================--
local function GetNearestStorage()
    local data = GetBusinessData()
    if not data or not data.storageProps then return nil end

    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)

    for id, prop in pairs(data.storageProps) do
        local dist = Utils.Distance(pcoords, vector3(prop.x, prop.y, prop.z))
        if dist <= Config.InteractDistance then
            return id, prop
        end
    end

    return nil
end

--========================================================--
--  OPEN STORAGE UI
--========================================================--
local function OpenStorage(storageId)
    if interacting then return end
    interacting = true

    Utils.Debug("Opening storage: " .. tostring(storageId))

    TriggerServerEvent("jims-lumberjack:openStorage", storageId)
end

--========================================================--
--  RECEIVE STORAGE DATA FROM SERVER
--========================================================--
RegisterNetEvent("jims-lumberjack:openStorageUI", function(storageData)
    OpenLumberUI("storage", storageData)
    interacting = false
end)

--========================================================--
--  NUI CALLBACKS FOR STORAGE
--========================================================--
RegisterNUICallback("storageAction", function(data, cb)
    TriggerServerEvent("jims-lumberjack:storageAction", data)
    cb("ok")
end)

--========================================================--
--  MAIN INTERACTION LOOP
--========================================================--
CreateThread(function()
    while true do
        Wait(0)

        if not Permissions:HasAccess(GetLumberRank(), "StorageAccess") then
            Wait(1000)
            goto continue
        end

        local storageId, prop = GetNearestStorage()
        if storageId then
            -- Draw prompt
            SetTextScale(0.35, 0.35)
            SetTextColor(255, 255, 255, 215)
            SetTextCentre(true)
            DisplayText(CreateVarString(10, "LITERAL_STRING", "Press [E] to Open Storage"), 0.5, 0.88)

            if IsControlJustPressed(0, 0xCEFD9220) then -- E
                OpenStorage(storageId)
            end
        else
            Wait(250)
        end

        ::continue::
    end
end)
