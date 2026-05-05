print("CLIENT UI LOADED")

RegisterNetEvent("lumber:openUI")
AddEventHandler("lumber:openUI", function()
    print("NUI OPEN EVENT RECEIVED")
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "open" })
end)
