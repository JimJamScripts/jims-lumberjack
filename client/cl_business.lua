-- =========================================================
--  Lumber Business - Client Ownership Handler
-- =========================================================

local isOwner = false
local businessData = nil

-- Expose these for other client scripts
LumberBusiness = {
    IsOwner = function()
        return isOwner
    end,

    GetBusiness = function()
        return businessData
    end
}

-- =========================================================
--  Debug Notify Wrapper
-- =========================================================
local function Debug(msg, level)
    if not Config.Debug then return end
    if level > Config.DebugLevel then return end

    print(("^3[Lumber Debug]^7 %s"):format(msg))
end

-- =========================================================
--  Client Notifications (simple for now)
-- =========================================================
RegisterNetEvent("lumber:client:Notify", function(msg)
    print("^2[Lumber]^7 " .. msg)
end)

-- =========================================================
--  Ownership Granted
-- =========================================================
RegisterNetEvent("lumber:client:OwnershipGranted", function(data)
    isOwner = true
    businessData = data

    Debug("Ownership granted for business: " .. data.name, 3)

    print("^2You are now the owner of ^7" .. data.name)
end)

-- =========================================================
--  Ownership Revoked
-- =========================================================
RegisterNetEvent("lumber:client:OwnershipRevoked", function()
    isOwner = false
    businessData = nil

    Debug("Ownership revoked", 3)

    print("^1Your lumber business ownership has been revoked.")
end)
