------------------------------------------------------------
-- LUMBER COMPANY UI CONTROLLER (CLEANED)
------------------------------------------------------------
print("CLIENT UI LOADED")

local uiOpen = false

------------------------------------------------------------
-- OPEN UI (SERVER → CLIENT)
------------------------------------------------------------
RegisterNetEvent("lumber:receiveLedgerData")
AddEventHandler("lumber:receiveLedgerData", function(data)
    uiOpen = true
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = "lumber_open",
        data = data
    })
end)

RegisterNetEvent("lumber:receiveInventoryData")
AddEventHandler("lumber:receiveInventoryData", function(data)
    SendNUIMessage({
        action = "lumber_open_inventory",
        data = data
    })
end)

------------------------------------------------------------
-- TEST COMMAND
------------------------------------------------------------
RegisterCommand("lumbertest", function()
    TriggerServerEvent("lumber:requestLedgerData")
end)

------------------------------------------------------------
-- CLOSE UI
------------------------------------------------------------
RegisterNUICallback("lumber_ui_close", function(_, cb)
    uiOpen = false
    SetNuiFocus(false, false)
    cb({})
end)

------------------------------------------------------------
-- TAB SWITCHING (CLIENT → SERVER)
------------------------------------------------------------
RegisterNUICallback("lumber_ui_switch_tab", function(data, cb)
    TriggerServerEvent("lumber:uiSwitchTab", data.tab)
    cb({})
end)

------------------------------------------------------------
-- LEDGER TAB
------------------------------------------------------------
RegisterNUICallback("lumber_ledger_deposit", function(data, cb)
    TriggerServerEvent("lumber_ledger_deposit", { amount = data.amount })
    cb({})
end)

RegisterNUICallback("lumber_ledger_withdraw", function(data, cb)
    TriggerServerEvent("lumber_ledger_withdraw", { amount = data.amount })
    cb({})
end)

------------------------------------------------------------
-- UPGRADES TAB (PLACEHOLDERS)
------------------------------------------------------------
RegisterNUICallback("lumber_upgrade_office", function(_, cb)
    TriggerServerEvent("lumber:upgradeOfficePhase")
    cb({})
end)

RegisterNUICallback("lumber_place_upgrade", function(data, cb)
    TriggerServerEvent("lumber:requestPlaceUpgrade", data)
    cb({})
end)

------------------------------------------------------------
-- STABLES TAB (PLACEHOLDERS)
------------------------------------------------------------
RegisterNUICallback("lumber_upgrade_stables", function(_, cb)
    TriggerServerEvent("lumber:upgradeStablesPhase")
    cb({})
end)

RegisterNUICallback("lumber_buy_wagon", function(data, cb)
    TriggerServerEvent("lumber:buyWagon", data.wagonType)
    cb({})
end)

RegisterNUICallback("lumber_set_wagon_spawn", function(_, cb)
    TriggerServerEvent("lumber:setWagonSpawn")
    cb({})
end)

------------------------------------------------------------
-- INVENTORY TAB
------------------------------------------------------------
RegisterNUICallback("lumber_inventory_withdraw", function(data, cb)
    TriggerServerEvent("lumber_inventory_withdraw", data)
    cb({})
end)

RegisterNUICallback("lumber_inventory_deposit", function(data, cb)
    TriggerServerEvent("lumber_inventory_deposit", data)
    cb({})
end)
