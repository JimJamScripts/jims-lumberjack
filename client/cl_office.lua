--========================================================--
--  JIMS LUMBERJACK - CLIENT OFFICE SYSTEM
--========================================================--

local interacting = false

--========================================================--
--  FIND NEAREST OFFICE LOCATION
--========================================================--
local function GetNearestOffice()
    local data = GetBusinessData()
    if not data or not data.office or not data.office.coords then return nil end

    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)
    local c = data.office.coords

    local dist = Utils.Distance(pcoords, vector3(c.x, c.y, c.z))
    if dist <= Config.InteractDistance then
        return true
    end

    return false
end

--========================================================--
--  OPEN OFFICE UI
--========================================================--
local function OpenOffice()
    if interacting then return end
    interacting = true

    Utils.Debug("Opening office menu")

    TriggerServerEvent("jims-lumberjack:openOffice")
end

--========================================================--
--  RECEIVE OFFICE DATA FROM SERVER
--========================================================--
RegisterNetEvent("jims-lumberjack:openOfficeUI", function(officeData)
    OpenLumberUI("office", officeData)
    interacting = false
end)

--========================================================--
--  NUI CALLBACKS FOR OFFICE ACTIONS
--========================================================--
RegisterNUICallback("officeAction", function(data, cb)
    TriggerServerEvent("jims-lumberjack:officeAction", data)
    cb("ok")
end)

--========================================================--
--  MAIN INTERACTION LOOP
--========================================================--
CreateThread(function()
    while true do
        Wait(0)

        -- Only Owner + Foreman can open office
        if not Permissions:HasAccess(GetLumberRank(), "OfficeMenu") then
            Wait(1000)
            goto continue
        end

        if GetNearestOffice() then
            -- Draw prompt
            SetTextScale(0.35, 0.35)
            SetTextColor(255, 255, 255, 215)
            SetTextCentre(true)
            DisplayText(CreateVarString(10, "LITERAL_STRING", "Press [E] to Open Office"), 0.5, 0.88)

            if IsControlJustPressed(0, 0xCEFD9220) then -- E
                OpenOffice()
            end
        else
            Wait(250)
        end

        ::continue::
    end
end)
