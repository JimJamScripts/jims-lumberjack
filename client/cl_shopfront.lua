--========================================================--
--  JIMS LUMBERJACK - CLIENT SHOPFRONT SYSTEM
--========================================================--

local interacting = false

--========================================================--
--  FIND NEAREST SHOPFRONT
--========================================================--
local function GetNearestShopfront()
    local data = GetBusinessData()
    if not data or not data.shopfront or not data.shopfront.coords then return nil end

    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)
    local c = data.shopfront.coords

    local dist = Utils.Distance(pcoords, vector3(c.x, c.y, c.z))
    if dist <= Config.InteractDistance then
        return true
    end

    return false
end

--========================================================--
--  OPEN SHOPFRONT UI
--========================================================--
local function OpenShopfront()
    if interacting then return end
    interacting = true

    Utils.Debug("Opening shopfront")

    TriggerServerEvent("jims-lumberjack:openShopfront")
end

--========================================================--
--  RECEIVE SHOPFRONT DATA FROM SERVER
--========================================================--
RegisterNetEvent("jims-lumberjack:openShopfrontUI", function(shopData)
    OpenLumberUI("shopfront", shopData)
    interacting = false
end)

--========================================================--
--  NUI CALLBACKS FOR SHOPFRONT
--========================================================--
RegisterNUICallback("shopAction", function(data, cb)
    TriggerServerEvent("jims-lumberjack:shopAction", data)
    cb("ok")
end)

--========================================================--
--  MAIN INTERACTION LOOP
--========================================================--
CreateThread(function()
    while true do
        Wait(0)

        if not Config.Shopfront.AllowCiviliansToBuy and GetLumberRank() == 0 then
            Wait(1000)
            goto continue
        end

        if GetNearestShopfront() then
            -- Draw prompt
            SetTextScale(0.35, 0.35)
            SetTextColor(255, 255, 255, 215)
            SetTextCentre(true)
            DisplayText(CreateVarString(10, "LITERAL_STRING", "Press [E] to Open Shop"), 0.5, 0.88)

            if IsControlJustPressed(0, 0xCEFD9220) then -- E
                OpenShopfront()
            end
        else
            Wait(250)
        end

        ::continue::
    end
end)
