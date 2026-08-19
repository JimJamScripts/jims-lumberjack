--========================================================--
--  JIMS LUMBERJACK - CLIENT BLIPS 
--========================================================--

local treeBlips = {}
local sapBlips = {}
local shopfrontBlip = nil

-- Cached client-side rank + business data
local clientRank = 0
local businessData = {}

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
--  PERMISSION CHECK (CLIENT-SIDE)
--========================================================--
local function HasAccess(permission)
    return Permissions:HasAccess(clientRank, permission)
end

--========================================================--
--  CREATE TREE BLIPS (EMPLOYEES ONLY)
--========================================================--
local function CreateTreeBlips()
    ClearAllTreeBlips()

    if not Config.Blips.ShowTreesToEmployees then return end
    if not HasAccess("TreeBlips") then return end

    if not businessData or not businessData.trees then return end

    for _, tree in pairs(businessData.trees) do
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
    if not HasAccess("SapBlips") then return end

    if not businessData or not businessData.sapBuckets then return end

    for _, bucket in pairs(businessData.sapBuckets) do
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
    if not businessData or not businessData.shopfront or not businessData.shopfront.coords then return end

    local c = businessData.shopfront.coords

    shopfrontBlip = N_0x554d9d53f696d002(1664425300, c.x, c.y, c.z)
    SetBlipSprite(shopfrontBlip, 1865988756, true)
    SetBlipScale(shopfrontBlip, 0.3)
    SetBlipColour(shopfrontBlip, 0)
    SetBlipName(shopfrontBlip, businessData.shopfront.name or "Lumber Shop")
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
--  BUSINESS DATA SYNC
--========================================================--
RegisterNetEvent("jims-lumberjack:updateBusinessData", function(data)
    businessData = data or {}
    RefreshAllBlips()
end)

--========================================================--
--  RANK SYNC
--========================================================--
RegisterNetEvent("jims-lumberjack:setRank", function(rank)
    clientRank = rank or 0
    RefreshAllBlips()
end)

--========================================================--
--  INITIAL LOAD
--========================================================--
CreateThread(function()
    Wait(2000)
    RefreshAllBlips()
end)
