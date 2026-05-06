--========================================================--
--  JIMS LUMBERJACK - CLIENT BLIPS
--========================================================--

local treeBlips = {}
local sapBlips = {}
local shopfrontBlip = nil

--========================================================--
--  CLEAR BLIPS
--========================================================--
local function ClearBlip(blip)
    if blip and DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
end

local function ClearAllTreeBlips()
    for _, blip in pairs(treeBlips) do
        ClearBlip(blip)
    end
    treeBlips = {}
end

local function ClearAllSapBlips()
    for _, blip in pairs(sapBlips) do
        ClearBlip(blip)
    end
    sapBlips = {}
end

local function ClearShopfrontBlip()
    ClearBlip(shopfrontBlip)
    shopfrontBlip = nil
end

--========================================================--
--  CREATE TREE BLIPS (EMPLOYEES ONLY)
--========================================================--
local function CreateTreeBlips()
    ClearAllTreeBlips()

    if not Config.Blips.ShowTreesToEmployees then return end
    if not Permissions:HasAccess(GetLumberRank(), "TreeBlips") then return end

    local data = GetBusinessData()
    if not data or not data.trees then return end

    for _, tree in pairs(data.trees) do
        local blip = N_0x554d9d53f696d002(1664425300, tree.x, tree.y, tree.z)
        SetBlipSprite(blip, Config.TreeBlipSprite, true)
        SetBlipScale(blip, 0.2)
        SetBlipColour(blip, Config.TreeBlipColor)
        table.insert(treeBlips, blip)
    end
end

--========================================================--
--  CREATE SAP BUCKET BLIPS (EMPLOYEES ONLY)
--========================================================--
local function CreateSapBlips()
    ClearAllSapBlips()

    if not Config.Blips.ShowSapToEmployees then return end
    if not Permissions:HasAccess(GetLumberRank(), "SapBlips") then return end

    local data = GetBusinessData()
    if not data or not data.sapBuckets then return end

    for _, bucket in pairs(data.sapBuckets) do
        local blip = N_0x554d9d53f696d002(1664425300, bucket.x, bucket.y, bucket.z)
        SetBlipSprite(blip, Config.SapBlipSprite, true)
        SetBlipScale(blip, 0.2)
        SetBlipColour(blip, Config.SapBlipColor)
        table.insert(sapBlips, blip)
    end
end

--========================================================--
--  CREATE SHOPFRONT BLIP (PUBLIC)
--========================================================--
local function CreateShopfrontBlip()
    ClearShopfrontBlip()

    if not Config.Blips.ShowShopfrontToCivs then return end

    local data = GetBusinessData()
    if not data or not data.shopfront or not data.shopfront.coords then return end

    local c = data.shopfront.coords

    shopfrontBlip = N_0x554d9d53f696d002(1664425300, c.x, c.y, c.z)
    SetBlipSprite(shopfrontBlip, 1865988756, true) -- store icon
    SetBlipScale(shopfrontBlip, 0.3)
    SetBlipColour(shopfrontBlip, 0)
    SetBlipName(shopfrontBlip, data.shopfront.name or "Lumber Shop")
end

--========================================================--
--  REFRESH ALL BLIPS
--========================================================--
local function RefreshAllBlips()
    CreateTreeBlips()
    CreateSapBlips()
    CreateShopfrontBlip()
end

--========================================================--
--  WHEN BUSINESS DATA UPDATES, REFRESH BLIPS
--========================================================--
RegisterNetEvent("jims-lumberjack:updateBusinessData", function(data)
    RefreshAllBlips()
end)

--========================================================--
--  WHEN PLAYER RANK CHANGES, REFRESH BLIPS
--========================================================--
RegisterNetEvent("jims-lumberjack:setRank", function(rank)
    RefreshAllBlips()
end)

--========================================================--
--  INITIAL LOAD
--========================================================--
CreateThread(function()
    Wait(2000)
    RefreshAllBlips()
end)
