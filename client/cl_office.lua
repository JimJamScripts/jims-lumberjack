-- =========================================================
--  Lumber Business - Office / Company Ledger Interaction
-- =========================================================

local buildingOffice = false
local officeBuilt = false
local campId = "lumber_1"

-- =========================================================
--  Foundation Build Trigger (Phase 1)
-- =========================================================
RegisterNetEvent("construction:startFoundation", function(camp)
    if camp ~= campId then return end
    buildingOffice = true

    CreateThread(function()
        local timeLeft = Config.OfficeBuildTime

        while timeLeft > 0 do
            print(("^2Building foundation... ^7%d seconds remaining"):format(timeLeft))
            Wait(1000)
            timeLeft -= 1
        end

        buildingOffice = false
        officeBuilt = true

        print("^2Your foundation has been completed.")
    end)
end)

-- =========================================================
--  Main Loop: Invisible Ledger Interaction
-- =========================================================
CreateThread(function()
    while true do
        Wait(0)

        local ped = PlayerPedId()

        -- Force coords into a proper vector3
        local x, y, z = table.unpack(GetEntityCoords(ped))
        local coords = vector3(x, y, z)

        -- Ledger interaction point
        local ledgerPos = Config.Camps[campId].ledgerPrompt
        if not ledgerPos then
            -- Safety check so this never hard-errors
            Wait(1000)
            goto continue
        end

        -- Distance check
        local dist = #(coords - ledgerPos)

        -- Owner OR worker can interact (safe even if LumberBusiness isn't ready yet)
        local isOwner = LumberBusiness and LumberBusiness.IsOwner and LumberBusiness.IsOwner() or false
        local isWorker = LumberBusiness and LumberBusiness.IsWorker and LumberBusiness.IsWorker(campId) or false

if dist < 2.0 then
    if IsControlJustPressed(0, 0xCEFD9220) then
        TriggerServerEvent("lumber:openCompanyLedger", campId)
    end
end


        ::continue::
    end
end)
