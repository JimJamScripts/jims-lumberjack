--========================================================--
--  JIMS LUMBERJACK - SERVER SAP BUCKET SYSTEM
--========================================================--

local data = LumberServer.GetData()

--========================================================--
--  SAVE + SYNC HELPERS
--========================================================--
local function SaveSap()
    Utils.SaveJSON("data/sap_buckets.json", data.sapBuckets)
end

local function SyncSap()
    TriggerClientEvent("jims-lumberjack:updateSapBuckets", -1, data.sapBuckets)
end

--========================================================--
--  VALIDATE BUCKET EXISTS
--========================================================--
local function BucketExists(bucketId)
    return data.sapBuckets[bucketId] ~= nil
end

--========================================================--
--  COLLECT SAP EVENT
--========================================================--
RegisterNetEvent("jims-lumberjack:sapCollected", function(bucketId)
    local src = source

    -- Permission check
    if not LumberPerms.Require(src, "Processing") then return end

    -- Validate bucket
    if not BucketExists(bucketId) then
        print(("^1[ERROR]^0 Player %s attempted to collect invalid sap bucket %s"):format(src, tostring(bucketId)))
        return
    end

    local bucket = data.sapBuckets[bucketId]

    -- Prevent double-collect
    if bucket.state == "cooldown" then
        print(("^3[WARN]^0 Player %s attempted to collect a bucket on cooldown"):format(src))
        return
    end

    -- Mark bucket as collected
    bucket.state = "cooldown"
    bucket.respawn = os.time() + Config.SapRespawnTime

    -- Give reward
    local reward = 1 -- 1 raw sap per bucket
    TriggerEvent("jims-lumberjack:giveItem", src, "raw_sap", reward)

    -- Save + sync
    SaveSap()
    SyncSap()

    -- Respawn timer
    CreateThread(function()
        Wait(Config.SapRespawnTime * 1000)

        bucket.state = "ready"
        bucket.respawn = nil

        SaveSap()
        SyncSap()
    end)
end)

--========================================================--
--  AUTO-RESPAWN CHECK ON RESOURCE START
--========================================================--
CreateThread(function()
    Wait(1000)

    for id, bucket in pairs(data.sapBuckets) do
        if bucket.state == "cooldown" and bucket.respawn then
            local remaining = bucket.respawn - os.time()

            if remaining <= 0 then
                -- Respawn immediately
                bucket.state = "ready"
                bucket.respawn = nil
            else
                -- Schedule respawn
                CreateThread(function()
                    Wait(remaining * 1000)
                    bucket.state = "ready"
                    bucket.respawn = nil
                    SaveSap()
                    SyncSap()
                end)
            end
        end
    end

    SaveSap()
    SyncSap()
end)

--========================================================--
--  EXPORT FOR OTHER SERVER MODULES
--========================================================--
LumberSap = {}

function LumberSap.SyncAll()
    SyncSap()
end

return LumberSap
