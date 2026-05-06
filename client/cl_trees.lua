--========================================================--
--  JIMS LUMBERJACK - CLIENT TREE SYSTEM
--========================================================--

local chopping = false
local currentTree = nil
local hitCount = 0

--========================================================--
--  PLAY CHOP ANIMATION
--========================================================--
local function PlayChopAnim()
    local ped = PlayerPedId()

    RequestAnimDict("mech_lumberjack@chop_wood")
    while not HasAnimDictLoaded("mech_lumberjack@chop_wood") do
        Wait(10)
    end

    TaskPlayAnim(ped, "mech_lumberjack@chop_wood", "chop_wood", 8.0, -8.0, 1500, 1, 0, false, 0, false)
end

--========================================================--
--  FIND NEAREST TREE
--========================================================--
local function GetNearestTree()
    local data = GetBusinessData()
    if not data or not data.trees then return nil end

    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)

    for id, tree in pairs(data.trees) do
        local dist = Utils.Distance(pcoords, vector3(tree.x, tree.y, tree.z))
        if dist <= Config.InteractDistance then
            return id, tree
        end
    end

    return nil
end

--========================================================--
--  START CHOPPING
--========================================================--
local function StartChopping(treeId)
    if chopping then return end
    chopping = true
    hitCount = 0
    currentTree = treeId

    Utils.Debug("Started chopping tree: " .. tostring(treeId))

    CreateThread(function()
        while chopping do
            Wait(0)

            if IsControlJustPressed(0, 0x07CE1E61) then -- LEFT CLICK
                PlayChopAnim()
                hitCount = hitCount + 1

                if hitCount >= Config.TreeChopHits then
                    chopping = false
                    TriggerServerEvent("jims-lumberjack:treeChopped", currentTree)
                    currentTree = nil
                    return
                end
            end

            -- Cancel if player walks away
            local _, tree = GetNearestTree()
            if not tree then
                chopping = false
                currentTree = nil
                return
            end
        end
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

        local treeId, tree = GetNearestTree()
        if treeId then
            -- Draw prompt
            SetTextScale(0.35, 0.35)
            SetTextColor(255, 255, 255, 215)
            SetTextCentre(true)
            DisplayText(CreateVarString(10, "LITERAL_STRING", "Press [E] to Chop Tree"), 0.5, 0.88)

            if IsControlJustPressed(0, 0xCEFD9220) then -- E
                StartChopping(treeId)
            end
        else
            Wait(250)
        end

        ::continue::
    end
end)

--========================================================--
--  TREE STATE UPDATED FROM SERVER
--========================================================--
RegisterNetEvent("jims-lumberjack:updateTrees", function()
    Utils.Debug("Tree states updated.")
end)
